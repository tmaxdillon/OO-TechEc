function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,Pmtrl,Pinst,Pmooring, ...
    vesselcost,turbrepair,battreplace,battencl, ... 
    triptime,nvi,batt_L,batt_lft,dp,S,P,D,L] =  ...
    simWind(kW,Smax,opt,data,atmo,batt,econ,uc,bc,turb)

%for debug
% disp([num2str(kW) ' ' num2str(Smax)])
ID = [kW Smax];

%if fmin is suggesting a negative input (physically impossible), exit 
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%extract data
wind = data.met.wind_spd; %[m/s]
if atmo.dyn_h %use log law to adjust wind speed based on rotor height
    for i = 1:length(wind)
%         wind(i) = adjustHeight(wind(i),data.met.wind_ht, ...
%             turb.clearance + ...
%             sqrt(1000*2*kW/(atmo.rho_a*pi*turb.ura^3)),'log',atmo.zo);
        wind(i) = adjustHeight(wind(i),data.met.wind_ht, ...
            turb.clearance + ...
            sqrt(1000*2*kW/(turb.eta*atmo.rho_a*pi*turb.ura^3)) ...
            ,'log',atmo.zo);
    end
end
T = length(wind); %total time steps
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] distance to shore
depth = data.depth;   %[m] water depth

%initialize diagnostic variables
S = zeros(1,length(wind)); %battery level timeseries
S(1) = Smax*1000; %assume battery begins fully charged
P = zeros(1,length(wind)); %power produced timeseries
D = zeros(1,length(wind)); %power dumped timeseries
L = ones(1,length(wind))*uc.draw; %power put to sensing timeseries
batt_L = zeros(1,T); %battery L (degradation) timeseries
fbi = 1; %fresh battery index
surv = 1;

%run simulation
for t = 1:length(wind)
    if t < fbi + batt.bdi - 1 %less than first interval after fresh batt
        batt_L(t) = 0;
    elseif rem(t,batt.bdi) == 0 %evaluate degradation on interval
        batt_L(t:t+batt.bdi) = batDegModel(S(fbi:t)/(1000*Smax), ...
            batt.T,3600*(t-fbi),batt.rf_os,ID);
        if batt_L(t) > batt.EoL %new battery
            fbi = t;
            S(t) = Smax*1000; 
            if ~exist('batt_lft','var')
                batt_lft = t*dt*(1/8760)*(12); %[mo] battery lifetime
            end
        end
    end
    %find power from turbine
    if wind(t) < turb.uci %below cut out
        P(t) = 0; %[W]
    elseif turb.uci < wind(t) && wind(t) <= turb.ura %below rated
        P(t) = kW*1000*wind(t)^3/turb.ura^3; %[W]
    elseif turb.ura < wind(t) && wind(t) <= turb.uco %above rated
        P(t) = kW*1000; %[W]
    else %above cut out
        P(t) = 0; %[W]
    end
    %find next battery storage level
    if t == fbi
        cf = 0; %fresh battery
    else
        cf = batt_L(t)*Smax*1000; %[Wh] capacity fading
    end
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    S(t+1) = dt*(P(t) - uc.draw) + S(t) - sd; %[Wh]
    if S(t+1) > (Smax*1000 - cf) %dump power if larger than battery capacity
        D(t) = S(t+1) - (Smax*1000 - cf); %[Wh]
        S(t+1) = Smax*1000 - cf; %[Wh]
    elseif S(t+1) <= Smax*batt.dmax*1000 %empty battery bank
        S(t+1) = dt*P(t) + S(t) - sd; %[Wh] save what's remaining, L = 0
        L(t) = 0; %drop load to zero because not enough power
    end
end

% battery degradation model
if batt.lcm == 1 %bolun's model
%     [batt_L,batt_lft] =  irregularDegradation(S/(Smax*1000), ...
%         data.wave.time',uc.lifetime,batt); %retrospective modeling (old)
    if ~exist('batt_lft','var') %battery never reached EoL
        batt_lft = batt.EoL/batt_L(t)*t*12/(8760); %[mo]
    end
elseif batt.lcm == 2 %dyanmic (old) model
    opt.phi = Smax/(Smax - (min(S)/1000)); %extra depth
    batt_lft = batt.lc_nom*opt.phi^(batt.beta); %new lifetime
    batt_lft(batt_lft > batt.lc_max) = batt.lc_max; %no larger than max
else %fixed (really old) model
    batt_lft = batt.lc_nom; %[m]
end
nbr = ceil((12*uc.lifetime/batt_lft-1)); %number of battery replacements

nvi = nbr + econ.wind.lambda*uc.lifetime; %number of vessel interventions

%economic modeling
%should we assume spares provisioning for wind too? if so:
%-kW cost goes up x2
%-turb repair goes down by 1/2
%-assuming yes...
kWcost = 2*polyval(opt.p_dev.t,kW)*econ.wind.marinization ...
    *econ.wind.tcm; %turbine
Icost = 2*(econ.wind.installed - 0.5*kWcost/ ...
    (kW*econ.wind.marinization*econ.wind.tcm))*kW; %installation
if Icost < 0, Icost = 0; end
if bc == 1 %lead acid
    if Smax < opt.p_dev.kWhmax %less than linear region
        Scost = polyval(opt.p_dev.b,Smax);
    else %in linear region
        Scost = polyval(opt.p_dev.b,opt.p_dev.kWhmax)* ... 
            (Smax/opt.p_dev.kWhmax);
    end
elseif bc == 2 %lithium phosphate
    Scost = batt.cost*Smax;
end
battencl = econ.batt.enclmult*Scost; %battery enclosure cost
Pmtrl = (1/1000)*econ.platform.wf*econ.platform.steel* ... 
    econ.platform.steel_fab* ...
    kW*turb.wf; %platform material
t_i = interp1(econ.platform.d_i,econ.platform.t_i,depth, ...
    'linear','extrap'); %installation time
Pinst = econ.vessel.speccost*(t_i/24); %platform instllation
dp = 0.8;
Pmooring = interp1(econ.platform.wind.depth, ...
    econ.platform.wind.cost,depth,'linear'); %mooring cost
% dp = getSparDiameter(kW,atmo,turb);
% if dp < 1, dp = 1; end
% if dp < 4 %within bounds, use linear interpolation
%     Pmooring = interp2(econ.platform.mdd.diameter, ...
%         econ.platform.mdd.depth, ...
%         econ.platform.mdd.cost,dp,depth,'linear'); %mooring cost
% else %not within bounds, use spline extrapolation
%     Pmooring = interp2(econ.platform.mdd.diameter, ...
%         econ.platform.mdd.depth, ...
%         econ.platform.mdd.cost,dp,depth,'spline'); %mooring cost
% end
if uc.SI < 12 %short term instrumentation
    triptime = 0; %attributed to instrumentation
    t_os = econ.vessel.t_ms/24; %[d]
    C_v = econ.vessel.speccost;
else %long term instrumentation and infrastructures
    triptime = dist*kts2mps(econ.vessel.speed)^(-1)*(1/86400); %[d]
    t_os = econ.vessel.t_mosv/24; %[d]
    C_v = econ.vessel.osvcost;
end
vesselcost = C_v*(nvi*(2*triptime + t_os)); %vessel cost
turbrepair = 1/2*0.5*(kWcost+Icost)*(nvi); %turbine repair cost
if turbrepair < 0, turbrepair = 0; end
battreplace = Scost*nbr; %number of battery replacements
CapEx = Pmooring + Pinst + Pmtrl + battencl + Scost + Icost + kWcost;
OpEx = battreplace + turbrepair + vesselcost;
cost = CapEx + OpEx;

%determine if desired uptime was met. if not, output infinite cost.
if sum(L == uc.draw)/(length(L)) < uc.uptime 
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end

end

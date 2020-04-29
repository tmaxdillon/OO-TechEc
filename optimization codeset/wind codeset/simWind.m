function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,Pmtrl,Pinst,Pline, ...
    Panchor,vesselcost,turbrepair,battreplace,battencl, ... 
    t_add_batt,triptime,nvi,Fdmax,dp,CF,S,P,D,L] =  ...
    simWind(kW,Smax,opt,data,atmo,batt,econ,uc,bc,turb)

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
        wind(i) = adjustHeight(wind(i),data.met.wind_ht, ...
            turb.clearance + ...
            sqrt(1000*2*kW/(atmo.rho_a*pi*turb.ura^3)),'log',atmo.zo);
    end
end
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] distance to shore
depth = data.depth;   %[m] water depth

%initialize diagnostic variables
S = zeros(1,length(wind)); %battery level timeseries
S(1) = Smax*1000; %assume battery begins fully charged
P = zeros(1,length(wind)); %power produced timeseries
D = zeros(1,length(wind)); %power dumped timeseries
L = ones(1,length(wind))*uc.draw; %power put to sensing timeseries
surv = 1;

%run simulation
for t = 1:length(wind)
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
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    S(t+1) = dt*(P(t) - uc.draw) + S(t) - sd; %[Wh]
    if S(t+1) > Smax*1000 %dump power if larger than battery capacity
        D(t) = S(t+1) - Smax*1000; %[Wh]
        S(t+1) = Smax*1000; %[Wh]
    elseif S(t+1) <= Smax*batt.dmax*1000 %empty battery bank
        S(t+1) = dt*P(t) + S(t) - sd; %[Wh] save what's remaining, L = 0
        %L(t) = S(t)/dt; %adjust load to what can be consumed
        L(t) = 0; %drop load to zero because not enough power
    end
end

CF = nanmean(P)/(kW*1000); %capacity factor

%dynamic battery degradation model
if batt.dyn_lc
    opt.phi = Smax/(Smax - (min(S)/1000)); %unused depth
    batt.lc = batt.lc_nom*opt.phi^(batt.beta); %[m] new lifetime
    batt.lc(batt.lc > batt.lc_max) = batt.lc_max; %no larger than max 
else
    batt.lc = batt.lc_nom; %[m]
end
nbr = ceil((12*uc.lifetime/batt.lc-1)); %number of battery replacements

%find added battery maintenance/installation time
if Smax > batt.t_add_min
    t_add_batt = batt.t_add_m*Smax-batt.t_add_m*batt.t_add_min;
else
    t_add_batt = 0;
end

%economic modeling
kWcost = polyval(opt.p_dev.t,kW)*econ.wind.marinization; %turbine
Icost = (econ.wind.installed - kWcost/ ...
    (kW*econ.wind.marinization))*kW; %installation
if Icost < 0, Icost = 0; end
if bc == 1 %lead acid
    if Smax < opt.p_dev.kWhmax %less than linear region
        Scost = polyval(opt.p_dev.b,Smax);
    else %in linear region
        Scost = polyval(opt.p_dev.b,opt.p_dev.kWhmax)*(Smax/opt.p_dev.kWhmax);
    end
elseif bc == 2 %lithium phosphate
    Scost = batt.cost*Smax;
end
battencl = applyScaleFactor(econ.batt.encl.cost,econ.batt.encl.cap, ...
    Smax,econ.batt.encl.sf); %battery enclosure
Pmtrl = (1/1000)*econ.platform.wf*econ.platform.steel* ... 
    kW*turb.wf; %platform material
Pinst = econ.vessel.speccost* ... 
    ((econ.platform.t_i+t_add_batt)/24); %platform instllation
dp = getSparDiameter(kW,atmo,turb);
% if turb.nu*kW > batt.nu*Smax %platform diameter
%     dp = turb.nu*kW; %set by turbine
% else
%     dp = batt.nu*Smax; %set by battery
% end
% Fdmax = (1/1000)*(2/(3*pi))*atmo.rho_w*econ.platform.k_ext ...
%     *econ.platform.Cd*Amax^3*dp;
% Pmoor = 4*Fdmax*(econ.platform.S*depth*econ.platform.fiber + ...
%     econ.platform.anchor); %mooring cost
%Pmoor = dp*depth*econ.platform.moorcost; %mooring cost
Pline = dp*depth*econ.platform.line;
Panchor = dp*econ.platform.anchor;
if Panchor < econ.platform.anchor_min 
    Panchor = econ.platform.anchor_min;
end
Fdmax = 0;
nvi = nbr + uc.turb.lambda; %number of vessel interventions
if uc.SI < 12 %short term instrumentation
    triptime = 0; %attributed to instrumentation
    t_os = econ.vessel.t_ms/24; %[d]
    C_v = econ.vessel.speccost;
else %long term instrumentation and infrastructure
    triptime = dist*kts2mps(econ.vessel.speed)^(-1)*(1/86400); %[d]
    t_os = econ.vessel.t_mosv/24; %[d]
    C_v = econ.vessel.osvcost;
end
vesselcost = C_v*(nvi*(2*triptime + t_os) + nbr*t_add_batt); %vessel cost
turbrepair = 1/2*kWcost*(uc.turb.lambda-1); %turbine repair cost
battreplace = Scost*nbr; %number of battery replacements
CapEx = Pline + Panchor + Pinst + Pmtrl + battencl + Scost + Icost + ...
kWcost;
OpEx = battreplace + turbrepair + vesselcost;
cost = CapEx + OpEx;
if opt.fmin && opt.nm.fmindebug
    kW
    cost
    pause
end

%determine if desired uptime was met. if not, output infinite cost.
if sum(L == uc.draw)/(length(L)) < uc.uptime 
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end

end

function [cost,surv,CapEx,OpEx,kWcost,Scost,Pmtrl,Pinst,Pmooring, ...
    vesselcost,genrepair,battreplace,battencl,genencl,fuel, ...
    triptime,runtime,nvi,batt_L,batt_lft,nfr,noc,dp,S,P,D,L] =  ...
    simDies(kW,Smax,opt,data,atmo,batt,econ,uc,bc,dies)

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
time = data.time;
T = length(time);
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] distance to shore
depth = data.depth; %[m] water depth

%initialize diagnostic variables
S = zeros(1,length(time)); %battery level timeseries
S(1) = Smax*1000; %assume battery begins fully charged
P = zeros(1,length(time)); %power produced timeseries
D = zeros(1,length(time)); %power dumped timeseries
L = ones(1,length(time))*uc.draw; %power put to sensing timeseries
batt_L = zeros(1,T); %battery L (degradation) timeseries
fbi = 1; %fresh battery index
surv = 1;
charging = false;
runtime = 0; %[h], amount of time spent running

lambda = floor(uc.lifetime*econ.dies.fail); %unexpected failures

%run simulation
for t = 1:length(time)
    if t < fbi + batt.bdi - 1 %less than first interval after fresh batt
        batt_L(t) = 0;
    elseif rem(t,batt.bdi) == 0 %evaluate degradation on interval
        batt_L(t:t+batt.bdi) = batDegModel(S(fbi:t)/(1000*Smax), ...
            batt.T,3600*(t-fbi),batt.rf_os,ID);
        if batt_L(t) > batt.EoL %new battery
            fbi = t+1;
            S(t) = Smax*1000; 
            if ~exist('batt_lft','var')
                batt_lft = t*dt*(1/8760)*(12); %[mo] battery lifetime
            end
        end
    end
    cf = batt_L(t)*Smax*1000; %[Wh] capacity fading
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    if ~charging %generator off
        S(t+1) = dt*(-1*uc.draw) + S(t) - sd;
        if S(t+1) < dies.genon*Smax*1000 %turn generator on
            charging = true;
        end
    else %generator on
        P(t) = kW*1000;
        S(t+1) = dt*(P(t) - uc.draw) + S(t) - sd; %[Wh]
        if S(t+1) >= (Smax*1000 - cf)
            S(t+1) = Smax*1000 - cf;
            charging = false;
        end
        runtime = runtime + dt; %[h]
    end
    if S(t+1) <= Smax*batt.dmax*1000 %bottomed out
        S(t+1) = dt*P(t) + S(t) - sd;
        L(t) = 0; %load drops to zero
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

%compute number of vessel requirements
lph = polyval(opt.p_dev.d_burn,kW); %[l/h], burn rate
nfr = ceil(runtime*lph/dies.fmax-1); %number of fuel replacements
if uc.lifetime/nfr > dies.ftmax/12 %fuel will go bad
    nfr = ceil(12*uc.lifetime/dies.ftmax-1);
end
noc = ceil(runtime/dies.oilint-1); %number of oil changes
nvi = max([nfr noc nbr]) + lambda; %number of vessel interventions

%economic modeling
kWcost = polyval(opt.p_dev.d_cost,kW)*2*econ.dies.gcm + ...
    econ.dies.autostart; %generator (with spares provisioning: 2)
genencl = polyval(opt.p_dev.d_size,kW)^3* ...
    (econ.dies.enclcost/econ.dies.enclcap); %generator enclosure
fuel = runtime*lph*econ.dies.fcost; %cost of consumed fuel
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
    polyval(opt.p_dev.d_mass,kW); %platform material
dp = polyval(opt.p_dev.d_size,kW);
if dp < 2, dp = 2; end %this will always occur - diesel platform = 2m
if dp > 8 %apply installtion time multiplier if big mooring
    inst_mult = interp1([8 econ.platform.inso.boundary_di], ...
        [1 econ.platform.inso.boundary_mf],dp);
else
    inst_mult = 1;
end
t_i = interp1(econ.platform.d_i,econ.platform.t_i,depth, ...
    'linear','extrap')*inst_mult; %installation time
Pinst = econ.vessel.speccost*(t_i/24); %platform instllation
% if dp < 4 %within bounds, use linear interpolation
%     Pmooring = interp2(econ.platform.mdd.diameter, ...
%         econ.platform.mdd.depth, ...
%         econ.platform.mdd.cost,dp,depth,'linear'); %mooring cost
% else %not within bounds, use spline extrapolation
%     Pmooring = interp2(econ.platform.mdd.diameter, ...
%         econ.platform.mdd.depth, ...
%         econ.platform.mdd.cost,dp,depth,'spline'); %mooring cost
% end
Pmooring = interp2(econ.platform.inso.diameter, ...
    econ.platform.inso.depth, ...
    econ.platform.inso.cost,dp,depth,'linear'); %mooring cost
if uc.SI < 12 %short term instrumentation
    triptime = 0; %attributed to instrumentation
    t_os = econ.vessel.t_ms/24; %[d]
    C_v = econ.vessel.speccost;
else %long term instrumentation and infrastructure
    triptime = dist*kts2mps(econ.vessel.speed)^(-1)*(1/86400); %[d]
    t_os = econ.vessel.t_mosv/24; %[d]
    C_v = econ.vessel.osvcost;
end
vesselcost = C_v*(nvi*(2*triptime + t_os)); %vessel cost
genrepair = 1/2*(0.5)*(kWcost+genencl)*lambda; %generator repair cost
battreplace = Scost*nbr; %number of battery replacements
CapEx = Pmooring + Pinst + Pmtrl + battencl + Scost + ...
    genencl + kWcost;
OpEx = fuel + battreplace + genrepair + vesselcost;
cost = CapEx + OpEx;

%determine if desired uptime was met. if not, output infinite cost.
if sum(L == uc.draw)/(length(L)) < uc.uptime
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end

end

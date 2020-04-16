function [cost,surv,CapEx,OpEx,kWcost,Scost,Pmtrl,Pinst,Pline, ...
    Panchor,vesselcost,genrepair,battreplace,battencl,genencl,fuel, ...
    triptime,runtime,nvi,nbr,nfr,noc,Fdmax,dp,CF,S,P,D,L] =  ...
    simDies(kW,Smax,opt,data,atmo,batt,econ,uc,bc,dies)

%if fmin is suggesting a negative input (physically impossible), exit
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

if kW > dies.kWmax
    kW = dies.kWmax;
end

if kW < dies.kWmin
    kW = dies.kWmin;
end

%extract data
time = data.time;
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] distance to shore
depth = data.depth; %[m] water depth
Amax = data.Amax; %[m] 50 year storm maximum amplitude

%initialize diagnostic variables
S = zeros(1,length(time)); %battery level timeseries
S(1) = Smax*1000; %assume battery begins fully charged
P = zeros(1,length(time)); %power produced timeseries
D = zeros(1,length(time)); %power dumped timeseries
L = ones(1,length(time))*uc.draw; %power put to sensing timeseries
surv = 1;
charging = false;
runtime = 0; %[h], amount of time spent running

%run simulation
for t = 1:length(time)
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    if ~charging %generator off
        S(t+1) = dt*(-1*uc.draw) + S(t) - sd;
        if S(t+1) < dies.genon*Smax*1000 %turn generator on
            charging = true;
        end
    else %generator on
        P(t) = kW*1000;
        S(t+1) = dt*(P(t) - uc.draw) + S(t) - sd; %[Wh]
        if S(t+1) >= Smax*1000
            S(t+1) = Smax*1000;
            charging = false;
        end
        runtime = runtime + dt; %[h]
    end
    if S(t+1) <= Smax*batt.dmax*1000 %bottomed out
        S(t+1) = dt*P(t) + S(t) - sd;
        L(t) = 0; %load drops to zero
    end
end

CF = nanmean(P)/(kW*1000); %capacity factor

%dynamic battery degradation model
if batt.dyn_lc
    opt.phi = Smax/(Smax - (min(S)/1000)); %unused depth
    batt.lc = batt.lc_nom*opt.phi^(batt.beta); %new lifetime
    batt.lc(batt.lc > batt.lc_max) = batt.lc_max; %no larger than max
else
    batt.lc = batt.lc_nom; %[m]
end

%find burn rate
lph = polyval(opt.p_dev.d_burn,kW); %[l/h]

nfr = ceil(runtime*lph/dies.fmax-1); %number of fuel replacements
if uc.lifetime/nfr > dies.ftmax/12 %fuel will go bad
    nfr = ceil(12*uc.lifetime/dies.ftmax-1);
end
noc = ceil(runtime/dies.oilint-1); %number of oil changes
nbr = ceil(12*uc.lifetime/batt.lc-1); %number of battery replacements

nvi = max([nfr noc nbr]) + uc.dies.lambda; %number of vessel interventions

%find added battery maintenance/installation time
if Smax > batt.t_add_min
    t_add_batt = batt.t_add_m*Smax-batt.t_add_m*batt.t_add_min;
else
    t_add_batt = 0;
end

%economic modeling
kWcost = polyval(opt.p_dev.d_cost,kW)*2 + ...
    econ.dies.autostart; %generator (with spare)
genencl = polyval(opt.p_dev.d_size,kW)^3* ...
    (econ.dies.enclcost/econ.dies.enclcap); %generator enclosure
fuel = runtime*lph*econ.dies.fcost; %cost of consumed fuel
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
    polyval(opt.p_dev.d_mass,kW); %platform material
Pinst = econ.vessel.speccost* ... 
    ((econ.platform.t_i+t_add_batt)/24); %platform instllation
dp = polyval(opt.p_dev.d_size,kW)*dies.bm;
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
genrepair = 1/2*kWcost*(uc.dies.lambda-1); %turbine repair cost
battreplace = Scost*nbr; %number of battery replacements
CapEx = Pline + Panchor + Pinst + Pmtrl + battencl + Scost + ...
    genencl + kWcost;
OpEx = fuel + battreplace + genrepair + vesselcost;
cost = CapEx + OpEx;
if opt.fmin && opt.fmindebug
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

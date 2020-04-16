function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,Pmtrl,Pinst,Pline, ...
    Panchor,vesselcost,wecrepair,battreplace,battencl, ...
    triptime,nvi,Fdmax,dp,width,cw,CF,S,P,D,L] =  ...
    simWave(kW,Smax,opt,data,atmo,batt,econ,uc,bc,wave)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%extract data
Hs = data.wave.significant_wave_height; %[m]
Tp = data.wave.peak_wave_period; %[s]
Tp_eff = opt.wave.cwr_b_ts; %[m^-1] period efficiency timeseries
wavepower = opt.wave.wavepower_ts; %wavepower timeseries
T = length(Tp_eff); %total time steps
dt = 24*(data.wave.time(2) - data.wave.time(1)); %time in hours
dist = data.dist; %[m] dist to shore
depth = data.depth;   %[m] water depth
Amax = data.Amax; %[m] 50 year storm maximum amplitude

%find width through rated power conditions, computed up front
%in optRun(), from rated conditions: hs_eff_ra, tp_eff_ra, wavepower_ra
width = sqrt(1000*kW*(1+wave.house)/(wave.eta_ct* ... 
    interp1(opt.wave.Tp_ws,opt.wave.cwr_b_ws,wave.Tp_ra,'spline')* ...
    opt.wave.wavepower_ra)); %[m] physical width of wec
P = (wave.eta_ct.*width.^2.*Tp_eff.*wavepower - kW*wave.house); %[kW]
L = atmo.g.*Tp.^2/(2*pi); %wavelength
P(Hs./L > .14) = 0; %breaking waves, set to zero
P(P<0) = 0; %no negative power
cw = Tp_eff.*width^2; %m
P(P>kW) = kW; %no larger than rated power

%initialize
S = zeros(1,T); %battery level timeseries
S(1) = Smax*1000; %assume battery begins fully charged
D = zeros(1,T); %power dumped timeseries
L = ones(1,T)*uc.draw; %power put to sensing timeseries
surv = 1;

%run simulation
for t = 1:T
%     %find power from wec
%     P(t) = powerFromWEC_oo(Hs(t),Tp(t),kW,wave,opt,width)*1000; %[W]
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    S(t+1) = dt*(P(t)*1000 - uc.draw) + S(t) - sd; %[Wh]
    if S(t+1) > Smax*1000 %dump power if over limit
        D(t) = S(t+1) - Smax*1000; %[Wh]
        S(t+1) = Smax*1000; %[Wh]
    elseif S(t+1) <= Smax*batt.dmax*1000 %bottomed out
        S(t+1) = dt*P(t)*1000 + S(t) - sd; %[Wh] save what's remaining
        %L(t) = S(t)/dt; %adjust load to what can be consumed
        L(t) = 0; %drop load to zero because not enough power
    end
end

CF = nanmean(P)/(kW); %capacity factor
P = P*1000; %convert to watts

%dynamic battery degradation model
if batt.dyn_lc
    opt.phi = Smax/(Smax - (min(S)/1000)); %extra depth
    batt.lc = batt.lc_nom*opt.phi^(batt.beta); %new lifetime
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

if isfield(econ.wave,'enf_scen') %sensitivity analysis
    costmult = econ.wave.enf_scen(1);
    nvi = nbr + econ.wave.enf_scen(2);
else %scenario analysis
    switch econ.wave.scen
        case 1 %conservative
            costmult = econ.wave.costmult_con; %cost multiplier
            nvi = nbr + uc.turb.lambda; %number of vessel interventions
        case 2 %optimistic cost
            costmult = econ.wave.costmult_opt; %cost multiplier
            nvi = nbr + uc.turb.lambda; %number of vessel interventions
        case 3 %optimistic durability
            costmult = econ.wave.costmult_con; %cost multiplier
            nvi = nbr; %number of vessel interventions
    end
end

%economic modeling
kWcost = costmult*polyval(opt.p_dev.t,kW)* ...
    econ.wind.marinization; %wec
Icost = (econ.wind.installed - kWcost/ ...
    (kW*econ.wind.marinization*costmult))*kW; %installation
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
% Pmtrl = (1/1000)*econ.platform.wf*econ.platform.steel ...
%     *(Smax*1000/(batt.V*batt.se)); %platform material, no generation mass
Pmtrl = 0;
Pinst = econ.vessel.speccost* ... 
    ((econ.platform.t_i+t_add_batt)/24); %platform instllation
% if wave.nu*kW > batt.nu*Smax %platform diameter
%     dp = wave.nu*kW; %set by panels
% else
%     dp = batt.nu*Smax; %set by battery
% end
dp = width;
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
if uc.SI < 12
    triptime = 0; %attributed to instrumentation
    t_os = econ.vessel.t_ms/24; %[d]
    C_v = econ.vessel.speccost;
else
    triptime = dist*kts2mps(econ.vessel.speed)^(-1)*(1/86400); %[d]
    t_os = econ.vessel.t_mosv/24; %[d]
    C_v = econ.vessel.osvcost;
end
vesselcost = C_v*(nvi*(2*triptime + t_os) + nbr*t_add_batt); %vessel cost
wecrepair = 1/2*kWcost*(nvi-1); %wec repair cost
if wecrepair < 0, wecrepair = 0; end %if nvi = 0, wec repair must be 0
battreplace = Scost*nbr; %number of battery replacements
CapEx = Pline + Panchor + Pinst + Pmtrl + ... 
    battencl + Scost + Icost + kWcost;
OpEx = battreplace + wecrepair + vesselcost;
cost = CapEx + OpEx;
if opt.fmin && opt.fmindebug
    kW
    cost
    %pause
end

if sum(L == uc.draw)/(length(L)) < uc.uptime 
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end

end





function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,Pmtrl,Pinst,Pmooring, ...
    vesselcost,wecrepair,battreplace,battencl, ...
    triptime,nvi,dp,width,cw,S,P,D,L] =  ...
    simWave(kW,Smax,opt,data,atmo,batt,econ,uc,bc,wave)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%set capture width modifier
cw_mod = wave.cw_mod;

%extract data
wavepower = opt.wave.wavepower_ts; %wavepower timeseries
T = length(opt.wave.wavepower_ts); %total time steps
dt = 24*(data.wave.time(2) - data.wave.time(1)); %delta time in hours
dist = data.dist; %[m] dist to shore, from km to m
depth = data.depth; %[m] water depth

if wave.method == 1 %divide by B methodology       
    cwr_b = wave.cw_mod.*opt.wave.cwr_b_ts; %[m^-1] eta timeseries (cwr/b)    
    %find width through rated power conditions
    width = sqrt(1000*kW*(1+wave.house)/(wave.eta_ct* ...
        cw_mod*opt.wave.cwr_b_ra* ...
        opt.wave.wavepower_ra)); %[m] physical width of wec
    cw = cwr_b.*width^2; %[m] capture width timeseries
elseif wave.method == 2 %3d interpolation methodology
    %extract data
    Hs = data.wave.significant_wave_height; %Hs timeseries
    Tp = data.wave.peak_wave_period; %Tp timeseries
    %find width through rated power conditions
    width = interp1(opt.wave.B_func(2,:),opt.wave.B_func(1,:),kW); %[m], B
    cw = width.*opt.wave.F(Tp,Hs,width*ones(length(Tp),1)); %[m] cw ts
end

%compute power timeseries
P = wave.eta_ct*cw.*wavepower - kW*wave.house; %[kW] 
P(P<0) = 0; %no negative power
P(P>kW) = kW; %no larger than rated power

%initialize
S = zeros(1,T); %battery level timeseries
S(1) = Smax*1000; %assume battery begins fully charged
D = zeros(1,T); %power dumped timeseries
L = ones(1,T)*uc.draw; %power put to sensing timeseries
surv = 1;

%run simulation
for t = 1:T
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    S(t+1) = dt*(P(t)*1000 - uc.draw) + S(t) - sd; %[Wh]
    if S(t+1) > Smax*1000 %dump power if over limit
        D(t) = S(t+1) - Smax*1000; %[Wh]
        S(t+1) = Smax*1000; %[Wh]
    elseif S(t+1) <= Smax*batt.dmax*1000 %bottomed out
        S(t+1) = dt*P(t)*1000 + S(t) - sd; %[Wh] save what's remaining
        L(t) = 0; %drop load to zero because not enough power
    end
end

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

nvi = econ.wave.lambda + nbr; %vessel interventions

%economic modeling
kWcost = 2*econ.wave.costmult*polyval(opt.p_dev.t,kW); %wec
Icost = (econ.wind.installed - kWcost/ ...
    (kW*econ.wave.costmult))*kW; %installation
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
Pmtrl = 0;
Pinst = econ.vessel.speccost* ...
    ((econ.platform.t_i)/24); %platform instllation
dp = width;
if dp < 1, dp = 1; end
if dp < 4 %within bounds, use linear interpolation
    Pmooring = interp2(econ.platform.mdd.diameter, ...
        econ.platform.mdd.depth, ...
        econ.platform.mdd.cost,dp,depth,'linear'); %mooring cost
else %not within bounds, use spline extrapolation
    Pmooring = interp2(econ.platform.mdd.diameter, ...
        econ.platform.mdd.depth, ...
        econ.platform.mdd.cost,dp,depth,'spline'); %mooring cost
end
if uc.SI < 12
    triptime = 0; %attributed to instrumentation
    t_os = econ.vessel.t_ms/24; %[d]
    C_v = econ.vessel.speccost;
else
    triptime = dist*kts2mps(econ.vessel.speed)^(-1)*(1/86400); %[d]
    t_os = econ.vessel.t_mosv/24; %[d]
    C_v = econ.vessel.osvcost;
end
vesselcost = C_v*(nvi*(2*triptime + t_os)); %vessel cost
wecrepair = 1/2*kWcost*(nvi-1); %wec repair cost
if wecrepair < 0, wecrepair = 0; end %if nvi = 0, wec repair must be 0
battreplace = Scost*nbr; %number of battery replacements
CapEx = Pmooring + Pinst + Pmtrl + ...
    battencl + Scost + Icost + kWcost;
OpEx = battreplace + wecrepair + vesselcost;
cost = CapEx + OpEx;

if sum(L == uc.draw)/(length(L)) < uc.uptime
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end

end





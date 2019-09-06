function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,FScost,maint, ...
    vesselcost,wecrepair,battreplace,battencl,platform, ...
    battvol,triptime,trips,width,CF,S,P,D,L] =  ...
    simWave(kW,Smax,opt,data,atmo,batt,econ,uc,wave)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%extract data
Hs = data.wave.significant_wave_height; %[m]
Tp = data.wave.peak_wave_period; %[s]
dt = 24*(data.wave.time(2) - data.wave.time(1)); %time in hours
dist = data.dist; %[m] dist to shore
T = min(length(Hs),length(Tp)); %totatl time steps

%find width through resonance and rated power conditions, computed up front
%in optRun() from median conditions: hs_eff_r, tp_eff_r, wavepower_r
width = 1000*kW/(wave.eta_ct*opt.wave.hs_eff_r* ... 
    opt.wave.tp_eff_r*opt.wave.wavepower_r - ...
    1000*kW*wave.house); %[m] physical width of wec

%initialize
S = zeros(1,T);
S(1) = Smax*1000;
P = zeros(1,T);
D = zeros(1,T);
L = ones(1,T)*uc.draw;
surv = 1;

%run simulation
for t = 1:T
    %find power from wec
    P(t) = powerFromWEC(Hs(t),Tp(t),kW,wave,opt,width)*1000; %[W]
    %find next storage state
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    S(t+1) = dt*(P(t) - uc.draw) + S(t) - sd; %[Wh]
    if S(t+1) > Smax*1000 %dump power if over limit
        D(t) = S(t+1) - Smax*1000; %[Wh]
        S(t+1) = Smax*1000; %[Wh]
    elseif S(t+1) <= 0 %bottomed out
        S(t+1) = 0; %no less than bottom
        L(t) = S(t)/dt; %adjust load to what was consumed
    end
end

CF = nanmean(P)/(kW*1000); %capacity factor

if batt.dyn_lc
    opt.phi = Smax/(Smax - (min(S)/1000)); %extra depth
    batt.lc = batt.lc_nom*opt.phi; %effective battery size
end

if isfield(econ.wave,'costmult') %sensitivity analysis
    costmult = econ.wave.costmult;
    interventions = uc.turb.iv;
else %scenario analysis
    switch econ.wave.scen
        case 1 % conservative
            costmult = 5;
            interventions = uc.turb.iv;
        case 2 % optimistic cost
            costmult = 2;
            interventions = uc.turb.iv;
        case 3 % optimistic reliability
            costmult = 5;
            interventions = 0;
    end
end

%economic modeling
kWcost = costmult*polyval(opt.p_dev.t,kW)* ...
    econ.wind.marinization; %wec
Icost = (costmult*econ.wind.installed - kWcost/ ...
    (kW*econ.wind.marinization))*kW*econ.wind.mim; %installation
if Icost < 0, Icost = 0; end
%compute foundation costs using scale factor
FScost = costmult*applyScaleFactor(econ.wind.foundsub.cost,5640,kW, ...
    econ.wind.foundsub.sf)*kW;
if kW > 8000, FScost = 10500*costmult; end %can't be negative
if Smax < opt.p_dev.kWhmax %less than linear region
    Scost = polyval(opt.p_dev.b,Smax);
else %in linear region
    Scost = polyval(opt.p_dev.b,opt.p_dev.kWhmax)*(Smax/opt.p_dev.kWhmax);
end
battvol = Smax*10^3/(batt.ed*batt.V/1.638e-5);
battencl = applyScaleFactor(econ.batt.encl.cost,econ.batt.encl.scale, ...
    battvol,econ.batt.encl.sf)*battvol; %battery ecnlosure
if Smax > 8030, battencl = 2085142.66; end %can't be negative
platform = (1/2204.62)*Smax*1000/(batt.V*batt.wf)* ...
    econ.platform.wf*econ.platform.steel;
trips = ceil((uc.lifetime)*(12/batt.lc - 12/uc.SI)); %number of trips
if trips < 0, trips = 0; end
trips = trips + interventions;
triptime = dist*kts2mps(econ.wind.vessel.speed)^(-1)*(1/86400); %[d]
vesselcost = 2*trips*econ.wind.vessel.cost*triptime;
if isfield(uc.ship,'t_add') %add cost due to instrumentation vessel usage
    addedcost = (uc.ship.t_add/24)*uc.ship.cost* ... 
        (uc.lifetime)*(12/uc.SI);
    vesselcost = vesselcost + addedcost;
end
maint = costmult*econ.wind.maintenance*kW*trips*uc.lifetime;
wecrepair = kWcost*(2 + 1/2*(12/batt.lc*uc.lifetime-1+interventions-1));
if interventions == 0, wecrepair = 0; end
battreplace = Scost*(12/batt.lc*uc.lifetime-1);
if battreplace < 0, battreplace = 0; end
if wecrepair < 0, wecrepair = 0; end
CapEx = platform + battencl + Scost + FScost + Icost + kWcost;
OpEx = battreplace + wecrepair + maint + vesselcost;
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





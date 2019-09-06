function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,FScost,maint, ...
    vesselcost,turbrepair,battreplace,battencl,platform, ...
    battvol,triptime,trips,CF,S,P,D,L] =  ...
    simWind(kW,Smax,opt,data,atmo,batt,econ,uc,turb)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%extract data
wind = data.met.wind_spd; %[m/s]
if atmo.dyn_h %use log law to adjust height dynamically basec on size
    for i = 1:length(wind)
        wind(i) = adjustHeight(wind(i),data.met.wind_ht, ...
            turb.clearance + sqrt(1000*2*kW/(atmo.rho*pi*turb.ura^3)), ...
            'log',atmo.zo);
    end
end
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] dist to shore

%initialize
S = zeros(1,length(wind));
S(1) = Smax*1000;
P = zeros(1,length(wind));
D = zeros(1,length(wind));
L = ones(1,length(wind))*uc.draw;
surv = 1;

%run simulation
for t = 1:length(wind)
    %find power from turbine
    if wind(t) < turb.uci
        P(t) = 0; %[W]
    elseif turb.uci < wind(t) && wind(t) <= turb.ura
        P(t) = kW*1000*wind(t)^3/turb.ura^3; %[W]
    elseif turb.ura < wind(t) && wind(t) <= turb.uco
        P(t) = kW*1000; %[W]
    else
        P(t) = 0; %[W]
    end
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

%economic modeling
kWcost = polyval(opt.p_dev.t,kW)*econ.wind.marinization; %turbine
Icost = (econ.wind.installed - kWcost/ ...
    (kW*econ.wind.marinization))*kW*econ.wind.mim; %installation
if Icost < 0, Icost = 0; end
%compute foundation costs using scale factor
FScost = applyScaleFactor(econ.wind.foundsub.cost,5640,kW, ...
    econ.wind.foundsub.sf)*kW;
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
trips = trips + uc.turb.iv;
triptime = dist*kts2mps(econ.wind.vessel.speed)^(-1)*(1/86400); %[d]
vesselcost = 2*trips*econ.wind.vessel.cost*triptime;
if isfield(uc.ship,'t_add') %add cost due to instrumentation vessel usage
    addedcost = (uc.ship.t_add/24)*uc.ship.cost* ... 
        (uc.lifetime)*(12/uc.SI);
    vesselcost = vesselcost + addedcost;
end
maint = econ.wind.maintenance*kW*trips*uc.lifetime;
turbrepair = kWcost*(2 + 1/2*(12/batt.lc*uc.lifetime-1+uc.turb.iv-1));
battreplace = Scost*(12/batt.lc*uc.lifetime-1);
if battreplace < 0, battreplace = 0; end
if turbrepair < 0, turbrepair = 0; end
CapEx = platform + battencl + Scost + FScost + Icost + kWcost;
OpEx = battreplace + turbrepair + maint + vesselcost;
cost = CapEx + OpEx;
if opt.fmin && opt.fmindebug
    kW
    cost
    pause
end

if sum(L == uc.draw)/(length(L)) < uc.uptime 
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end

end





function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,FScost,maint, ...
    vesselcost,fuelcost,turbrepair,battreplace,battencl,wiring, ...
    battvol,triptime,trips,CF,S,P,D,L] =  ...
    simWind(kW,Smax,opt,data,atmo,batt,econ,uc,turb)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%extract data
if atmo.dyn_h %[use log law to adjust height dynamically]
    wind = data.met.wind_spd_orig; %[m/s]
    for i = 1:length(wind)
        wind(i) = adjustHeight(wind(i),data.met.wind_ht_orig, ...
            turb.clearance + sqrt(2*kW/(atmo.rho*pi*turb.ura^3)),'log',atmo.zo);
    end
else %not dynamically adjusting height
    wind = data.met.wind_spd; %[m/s]
end
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] dist to shore

%economic modeling
kWcost = polyval(opt.p.t,kW)*econ.wind.marinization; %cost of turbine
Icost = (econ.wind.installed - kWcost/ ...
    (kW*econ.wind.marinization))*kW; %cost of installation
if Icost < 0, Icost = 0; end
%compute foundation costs using scale factor
FScost = applyScaleFactor(econ.wind.foundsub.cost,5640,kW, ...
    econ.wind.foundsub.sf)*kW;
if Smax < opt.p.kWhmax
    Scost = polyval(opt.p.b,Smax);
else
    Scost = polyval(opt.p.b,opt.p.kWhmax)*(Smax/opt.p.kWhmax);
end
battvol = Smax*10^3/(batt.ed*batt.V/1.638e-5);
battencl = applyScaleFactor(econ.batt.encl.cost,econ.batt.encl.scale, ... 
    battvol,econ.batt.encl.sf)*battvol;
wiring = econ.batt.wiring*Smax;
trips = ceil((uc.lifetime)*(12/batt.lc - 12/uc.SI)); %vessel interventions for power
if trips < 0, trips = 0; end
trips = trips + turb.uf;
triptime = dist*kts2mps(econ.wind.vessel.speed)^(-1)*(1/86400);
fuelcost = 2*trips*econ.wind.vessel.fuel*econ.wind.vessel.mileage*dist* ...
    econ.wind.vessel.speed^(-1)*(1/86400);
vesselcost = 2*trips*econ.wind.vessel.cost*triptime;
maint = econ.wind.maintenance*kW*12/turb.mtbf*uc.lifetime;
turbrepair = kWcost*(12/batt.lc*uc.lifetime-1+turb.uf);
battreplace = Scost*(12/batt.lc*uc.lifetime-1);
if turbrepair < 0, turbrepair = 0; end
CapEx = wiring + battencl + Scost + FScost + Icost + kWcost;
OpEx = battreplace + turbrepair + maint + vesselcost + fuelcost;
cost = CapEx + OpEx;

%missing: transmission to battery, repair time, battery buoy

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
    S(t+1) = dt*(P(t) - uc.draw) + S(t); %[Wh]
    if S(t+1) > Smax*1000 %dump power if over limit
        D(t) = S(t+1) - Smax*1000; %[Wh]
        S(t+1) = Smax*1000; %[Wh]
    elseif S(t+1) < Smax*1000*batt.lb %less than lower bound
        if S(t+1) <= 0 %bottomed out
            S(t+1) = 0; %no less than bottom
            L(t) = S(t)/dt; %adjust load to what was consumed
        end %no less than 0 kWh
    end
end

CF = nanmean(P/1000)/kW; %capacity factor

%check to see if we fell beneath uptime constraint
if opt.utw
    for t = 1:length(L)-uc.uptime_window*24
        if sum(L(t:t+uc.uptime_window*24) == uc.draw)/ ...
                (uc.uptime_window*24) < uc.uptime
            surv = 0;
        end
    end
else
    if sum(L == uc.draw)/(length(L)) < uc.uptime
        surv = 0;
    end
end

if surv == 0
    if opt.initminset > 0
        cost = opt.initminset + (opt.initminset - cost);
        %cost = inf;
    elseif opt.fmin
        if opt.failurezoneslope
            cost = 2*opt.init + 3*opt.init*(1 - (1/opt.kW_m)*kW - ...
                (1/opt.Smax_n)*Smax);
        else
            cost = inf;
        end
    end
end



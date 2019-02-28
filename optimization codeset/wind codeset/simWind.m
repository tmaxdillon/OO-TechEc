function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,FScost,maint, ... 
    vesselcost,fuelcost,repair, ...
    triptime,trips,CF,S,P,D,L] =  ...
    simWind(kW,Smax,opt,data,atmo,batt,econ,uc,turb,p)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

wind = data.met.wind_spd; %extract wind speed
if atmo.adj_h
    for i = 1:length(wind)
        wind(i) = adjustHeight(wind(i),data.met.wind_ht,atmo.h,'log',atmo.zo);
    end
end

dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] dist to shore

%compute cost
kWcost = polyval(p.t,kW)*econ.wind.marinization; %cost of turbine
Icost = (econ.wind.installed - kWcost/ ... 
    (kW*econ.wind.marinization))*kW; %cost of installation
if Icost < 0, Icost = 0; end
%compute foundation costs using scale factor
FScost = applyScaleFactor(econ.wind.foundsub.cost,5640,kW, ... 
    econ.wind.foundsub.sf)*kW;
if Smax < p.kWhmax
    Scost = polyval(p.b,Smax);
else
    Scost = polyval(p.b,p.kWhmax)*(Smax/p.kWhmax);
end
trips = ceil((uc.lifetime)*(12/turb.mtbf - 12/uc.SI)); %number of trips for power alone
if trips < 0, trips = 0; end
triptime = dist*kts2mps(econ.wind.vessel.speed)^(-1)*(1/86400);
fuelcost = 2*trips*econ.wind.vessel.fuel*econ.wind.vessel.mileage*dist* ... 
    econ.wind.vessel.speed^(-1)*(1/86400);
vesselcost = 2*trips*econ.wind.vessel.cost*triptime;
maint = econ.wind.maintenance*kW*12/turb.mtbf*uc.lifetime;
repair = kWcost*kW*12/turb.mtbf*uc.lifetime;
CapEx = Scost + FScost + Icost + kWcost;
OpEx = repair + maint + vesselcost + fuelcost;
cost = CapEx + OpEx;

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
        if S(t+1) <= 0 %bottommed out
            S(t+1) = 0; %no less than bottom
            L(t) = S(t)/dt; %adjust load to what was consumed
        end %no less than 0 kWh
    end
end

CF = nanmean(P/1000)/kW; %capacity factor

%check to see if we fell beneath uptime constraint
if length(find(L==uc.draw))/length(L) < uc.uptime
    surv = 0;
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



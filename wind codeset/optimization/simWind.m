function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,FScost,maint,shipping, ... 
    triptime,fuelconsump,trips,singletrip,CF,S,P,D,L] =  ...
    simWind(kW,Smax,opt,data,atmo,batt,econ,uc,turb,p)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

wind = data.met.wind_spd; %extract wind speed
for i = 1:length(wind)
    wind(i) = adjustHeight(wind(i),data.met.wind_ht,atmo.h,'log',atmo.zo);
end
    
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] dist to shore

%compute cost
trips = ceil((uc.lifetime)*(12/turb.mtbf - 12/uc.SI)); %number of trips for power alone
if trips < 0, trips = 0; end
triptime = dist*kts2mps(econ.vessel.speed)^(-1)*(1/86400);
fuelconsump = econ.vessel.mileage*dist*econ.vessel.speed^(-1)*(1/86400);
singletrip = 2*(econ.vessel.cost*triptime + econ.vessel.fuel*fuelconsump);
maint = econ.maintenance*kW*12/turb.mtbf*uc.lifetime;
shipping = singletrip*trips;
OpEx = maint + shipping;
kWcost = polyval(p.t,kW)*econ.marinization; %cost of turbine
Icost = (econ.installed - kWcost/(kW*econ.marinization))*kW; %const of installation
FScost = econ.foundsub*kW; %cost of substructure and foundation
if Icost < 0, Icost = 0; end
if Smax < p.kWhmax
    Scost = polyval(p.b,Smax);
else
    Scost = polyval(p.b,p.kWhmax)*(Smax/p.kWhmax);
end
CapEx = kWcost + Scost + Icost + FScost;
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



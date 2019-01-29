function [cost,surv,CapEx,OpEx,kWcost,Scost,CF,S,P,D,L] =  ...
    simWind(R,Smax,opt,data,atmo,batt,econ,load,turb)

wind = data.met.wind_spd; %extract wind speed
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
lat = data.met.lat;
lon = data.met.lon;
[dist,~,~] = dist_from_coast(lat,lon,'great_circle',inf); %dist to shore

%compute cost
kWcost = econ.rcost*(1/1000)*1/2*atmo.rho*pi*R^2*turb.ura^3*turb.eta;
Scost = econ.Scost*Smax;
CapEx = kWcost + Scost;
OpEx = interp1([econ.OpEx.p1(1) econ.OpEx.p2(1)], ...
    [econ.OpEx.p1(2) econ.OpEx.p2(2)],dist)*CapEx;
cost = CapEx + OpEx;

%initialize
S = zeros(1,length(wind));
S(1) = Smax*1000;
P = zeros(1,length(wind));
D = zeros(1,length(wind));
L = ones(1,length(wind))*load;
surv = 1;

%run simulation
for t = 1:length(wind)
    %find power from turbine
    if wind(t) < turb.uci
        P(t) = 0; %[W]
    elseif turb.uci < wind(t) && wind(t) <= turb.ura
        P(t) = 1/2*atmo.rho*pi*R^2*wind(t)^3*turb.eta; %[W]
    elseif turb.ura < wind(t) && wind(t) <= turb.uco
        P(t) = 1/2*atmo.rho*pi*R^2*turb.ura^3*turb.eta; %[W]
    else
        P(t) = 0; %[W]
    end
    %find next storage state
    S(t+1) = dt*(P(t) - load) + S(t); %[Wh]
    if S(t+1) > Smax*1000 %dump power if over limit
        D(t) = S(t+1) - Smax*1000; %[Wh]
        S(t+1) = Smax*1000; %[Wh]
    elseif S(t+1) < Smax*1000*batt.lb %less than lower bound
        if S(t+1) <= 0 %bottommed out
            S(t+1) = 0; %no less than bottom
            L(t) = S(t)/dt; %adjust load to what was consumed
        end %no less than 0 kWh
        if opt.constr.thresh
            surv = 0; %voilated lower constraint
        end
    end
end

CF = nanmean(P)/(1/2*atmo.rho*pi*R^2*turb.ura^3*turb.eta);

%check to see if we fell beneath uptime constraint
if opt.constr.uptime && length(find(L==load))/length(L) < opt.constr.uptimeval
    surv = 0;
end

if opt.fmin && surv == 0
    cost = inf;
end



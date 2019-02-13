function [cost,surv,CapEx,OpEx,kWcost,Scost,CF,S,P,D,L] =  ...
    simWind(kW,Smax,opt,data,atmo,batt,econ,node,turb,p)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

wind = data.met.wind_spd; %extract wind speed
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] dist to shore

%compute cost
trips = (node.lifetime*12)/(node.SI);
%singletrip = 2*(econ.ship*(dist*econ.speed^(-1)*(1/86400) + ...
%    econ.repairT) + econ.fuel*(dist*econ.speed^(-1)*(1/360)*econ.mileage));
%OpEx = turb.mtbf*(1/12)*singletrip*node.lifetime;
OpEx = econ.maintenance*kW*trips;
kWcost = polyval(p.t,kW);
Scost = polyval(p.b,Smax);
CapEx = kWcost + Scost;
cost = CapEx + OpEx;

%initialize
S = zeros(1,length(wind));
S(1) = Smax*1000;
P = zeros(1,length(wind));
D = zeros(1,length(wind));
L = ones(1,length(wind))*node.draw;
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
    S(t+1) = dt*(P(t) - node.draw) + S(t); %[Wh]
    if S(t+1) > Smax*1000 %dump power if over limit
        D(t) = S(t+1) - Smax*1000; %[Wh]
        S(t+1) = Smax*1000; %[Wh]
    elseif S(t+1) < Smax*1000*batt.lb %less than lower bound
        if S(t+1) <= 0 %bottommed out
            S(t+1) = 0; %no less than bottom
            L(t) = S(t)/dt; %adjust load to what was consumed
        end %no less than 0 kWh
        if node.constr.thresh
            surv = 0; %voilated lower constraint
        end
    end
end

CF = nanmean(P/1000)/kW; %capacity factor

%check to see if we fell beneath uptime constraint
if node.constr.uptime && length(find(L==node.draw))/length(L) < node.uptime
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



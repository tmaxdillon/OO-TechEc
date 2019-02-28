function [cost,surv,CapEx,OpEx,Mcost,Scost,Ecost,Icost,FScost,maint, ...
    vesselcost,fuelcost,repair, ...
    triptime,trips,CF,S,P,D,L] = ...
    simInso(kW,Smax,opt,data,batt,econ,uc,inso,p)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

swso = data.met.shortwave_irradiance; %extract irradiance [W/m^2]

dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours
dist = data.dist; %[m] dist to shore

%economic modeling
Mcost = econ.inso.module*kW;
Icost = econ.inso.installation*kW; %cost of installation
Ecost = econ.inso.electrical*kW; %cost of electrical infrastructure
FScost = 0; %cost of buoy [?]
if Smax < p.kWhmax
    Scost = polyval(p.b,Smax);
else
    Scost = polyval(p.b,p.kWhmax)*(Smax/p.kWhmax);
end
trips = ceil((uc.lifetime)*(12/inso.mtbf - 12/uc.SI)); %number of trips for power alone
if trips < 0, trips = 0; end
triptime = dist*kts2mps(econ.inso.vessel.speed)^(-1)*(1/86400);
fuelcost = 2*trips*econ.inso.vessel.fuel*econ.inso.vessel.mileage*dist* ... 
    econ.inso.vessel.speed^(-1)*(1/86400);
vesselcost = 2*trips*econ.inso.vessel.cost*triptime;
maint = 0; %cost of maintenance (not including parts) [?]
repair = 0; %cost of repair [?]
CapEx = Scost + FScost + Icost + Mcost + Ecost;
OpEx = repair + maint + vesselcost + fuelcost;
cost = CapEx + OpEx;

%initialize
S = zeros(1,length(swso));
S(1) = Smax*1000;
P = zeros(1,length(swso));
D = zeros(1,length(swso));
L = ones(1,length(swso))*uc.draw;
surv = 1;

%run simulation
for t = 1:length(swso)
    %find power from panel
    if swso(t) > inso.rated*1000
        P(t) = kW*1000; %[W]
    else
        P(t) = kW*1000*(swso(t)/(inso.rated*1000)); %[W]
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

CF = nanmean(P/1000)/nanmax(P); %capacity factor ?

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
            cost = 2*opt.init + 3*opt.init*(1 - (1/opt.A_m)*A - ...
                (1/opt.Smax_n)*Smax);
        else
            cost = inf;
        end
    end
end

end

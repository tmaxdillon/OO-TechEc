function [cost,surv,CapEx,OpEx,Mcost,Scost,Ecost,Icost,FScost,maint, ...
    vesselcost,fuelcost,PVreplace,battreplace,battencl,wiring, ...
    battvol,triptime,trips,CF,S,P,D,L,eff_t] = ...
    simInso(kW,Smax,opt,data,atmo,batt,econ,uc,inso)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%extract data
swso = data.met.shortwave_irradiance; %[W/m^2]
orig_l = length(swso);
%extend data to lifetime
tStart = datevec(data.met.time(1));
tEnd = tStart;
if uc.lifetime > 6 && econ.inso.caplife 
    tEnd(1) = tEnd(1) + 5;
    Nrep = floor(uc.lifetime/5) - 1; %number of times panels must be replaced
else
    tEnd(1) = tEnd(1) + uc.lifetime;
end
swso = [swso; zeros(etime(tEnd,tStart)/(60*60)-length(swso),1)];
for t = orig_l+1:length(swso)
    swso(t) = swso(orig_l - rem(t,8760));
end
dt = 24*(data.met.time(2) - data.met.time(1)); %[h]
dist = data.dist; %[m] dist to shore

%set pvci to service interval of OO if applicable
if ~inso.seasonalclean && inso.pvci > uc.SI
    inso.pvci = uc.SI;
end

%compute vessel intervention interval (vii)
if inso.seasonalclean
    vii = 12;
    inso.pvci = 12;
    batt.lc = 12*floor(batt.lc/12);
elseif inso.autoclean
    vii = batt.lc;
elseif inso.pvci > batt.lc
    vii = batt.lc;
    inso.pvci = batt.lc;
else %if clean interval is less than battery interval...
    %put battery interval on multiple of cleaning interval
    batt.lc = inso.pvci*floor(batt.lc/inso.pvci);
    vii = inso.pvci;
end

%economic modeling
Mcost = econ.inso.module*kW; %module
Icost = econ.inso.installation*kW; %installation
Ecost = econ.inso.electrical*kW; %electrical infrastructure
FScost = 0; %buoy [?]
if Smax < opt.p.kWhmax %storage
    Scost = polyval(opt.p.b,Smax);
else
    Scost = polyval(opt.p.b,opt.p.kWhmax)*(Smax/opt.p.kWhmax);
end
trips = ceil((uc.lifetime)*(vii/12 - 12/uc.SI)); %number of trips
if trips < 0, trips = 0; end
battvol = (Smax*10^3/(batt.ed*batt.V/1.638e-5)); %volume of battery
battencl = applyScaleFactor(econ.batt.encl.cost,econ.batt.encl.scale, ... 
    battvol,econ.batt.encl.sf)*battvol;
wiring = econ.batt.wiring*Smax;
triptime = dist*kts2mps(econ.inso.vessel.speed)^(-1)*(1/86400); %trip duration
fuelcost = 2*trips*econ.inso.vessel.fuel*econ.inso.vessel.mileage*dist* ...
    econ.inso.vessel.speed^(-1)*(1/86400);
vesselcost = 2*trips*econ.inso.vessel.cost*triptime;
maint = econ.inso.maintenance*kW*uc.lifetime; %maintenance
battreplace = Scost*(12/batt.lc*uc.lifetime-1);
if exist('Nrep','var'), PVreplace = Nrep*Mcost; else, PVreplace = 0; end
CapEx = wiring + battencl + Scost + FScost + Icost + Mcost + Ecost;
OpEx = battreplace + PVreplace + maint + vesselcost + fuelcost;
cost = CapEx + OpEx;

%missing: marinization, buoy (battery and solar), transmission to battery

%initialize
S = zeros(1,length(swso));
S(1) = Smax*1000;
P = zeros(1,length(swso));
D = zeros(1,length(swso));
L = ones(1,length(swso))*uc.draw;
eff_t = zeros(1,length(swso));
surv = 1;

%set efficiency degradation
eff = (1-(inso.deg/8760)*(1:1:length(swso)));

%find gap between first clean and start of timeseries
if inso.seasonalclean
    tStart = datevec(data.met.time(1)); %must restart tStart
    tFirstClean = tStart;
    tFirstClean(1) = tStart(1)-1;
    tFirstClean(2) = tStart(2)+(12-abs(inso.cleanmonth-tStart(2)));
    tGap = 24*(data.met.time(1)-datenum(tFirstClean(1),tFirstClean(2),1))-1;
end

%run simulation
for t = 1:length(swso)
    %find efficiency
    if inso.seasonalclean %cleaning done seasonally
        eff_t(t) = eff(t)*(1-atmo.soil/8760*rem(t+tGap,8760))*inso.eff;
    else %cleaning done on interval
        eff_t(t) = eff(t)*(1-atmo.soil/8760*rem(t,inso.pvci*30*24))*inso.eff;
    end
    %find power from panel
    if swso(t) > inso.rated*1000 %rated irradiance
        P(t) = eff_t(t)/inso.eff*kW*1000;
    else %sub rated irradiance
        P(t) = eff_t(t)/inso.eff*kW*1000*(swso(t)/(inso.rated*1000));
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

CF = nanmean(P)/(inso.rated*1000); %capacity factor [W/W]

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
            cost = 2*opt.init + 3*opt.init*(1 - (1/opt.A_m)*A - ...
                (1/opt.Smax_n)*Smax);
        else
            cost = inf;
        end
    end
end

end

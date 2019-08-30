function [cost,surv,CapEx,OpEx,Mcost,Scost,Ecost,Icost,maint, ...
    vesselcost,PVreplace,battreplace,battencl,platform, ...
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
%extend dataset to lifetime of instrumentation (to examine degradation)
tStart = datevec(data.met.time(1));
tEnd = tStart;
tEnd(1) = tEnd(1) + uc.lifetime;
swso = [swso; zeros(etime(tEnd,tStart)/(60*60)-length(swso),1)];
for t = orig_l+1:length(swso)
    swso(t) = swso(orig_l - rem(t,8760));
end
dt = 24*(data.met.time(2) - data.met.time(1)); %[h]
dist = data.dist; %[m] dist to shore

%initialize/preallocate
S = zeros(1,length(swso)); %[Wh] storage
S(1) = Smax*1000;
P = zeros(1,length(swso)); %[W] power produced
D = zeros(1,length(swso)); %[W] power dumped
L = ones(1,length(swso))*uc.draw; %[W] load
eff_t = zeros(1,length(swso)); %[~] efficiency
surv = 1; % satisfies use case requirements

% set the cleaning interval based on the use case service interval
% need better way of doing this?
if uc.SI > 6
    %if service interval is long-term, assume the panels will be cleaned
    %once every thirty months
    inso.pvci = 30;
else
    %if service interval is short-term, assume the panels will be cleaned
    %every six months
    inso.pvci = 6;
end

%set panel degradation
eff = (1-(inso.deg/8760)*(1:1:length(swso)));
%rain = repmat(linspace(0.5,0,24*30),[1,ceil(length(swso)/(24*30))]);

%run simulation
for t = 1:length(swso)
    %find efficiency
    soil_eff = (1-atmo.soil/8760*rem(t,inso.pvci*(365/12)*24));
    %soil_eff = (1-soil_eff)*rain(t) + soil_eff; %rainfall clean
    eff_t(t) = eff(t)*soil_eff*inso.eff;
    %find power from panel
    if swso(t) > inso.rated*1000 %rated irradiance
        P(t) = eff_t(t)/inso.eff*kW*1000; %[W]
    else %sub rated irradiance
        P(t) = eff_t(t)/inso.eff*kW*1000*(swso(t)/(inso.rated*1000)); %[W]
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

CF = nanmean(P)/(kW*1000); %capacity factor [W_avg/W_rated]

%compute life cycle of battery
if batt.dyn_lc
    opt.phi = Smax/(Smax - (min(S)/1000)); %extra depth
    batt.lc = batt.lc*opt.phi; %effective battery size
end

%economic modeling
Mcost = econ.inso.module*kW*econ.inso.marinization; %module
Icost = econ.inso.installation*kW; %installation
Ecost = econ.inso.electrical*kW; %electrical infrastructure
if Smax < opt.p_dev.kWhmax %less than linear region
    Scost = polyval(opt.p_dev.b,Smax);
else %in linear region
    Scost = polyval(opt.p_dev.b,opt.p_dev.kWhmax)*(Smax/opt.p_dev.kWhmax);
end
battvol = (Smax*10^3/(batt.ed*batt.V/1.638e-5));
battencl = applyScaleFactor(econ.batt.encl.cost,econ.batt.encl.scale, ...
    battvol,econ.batt.encl.sf)*battvol; %battery enclosure
if Smax > 8030, battencl = 2085142.66; end %hard coded, can't be negative
platform = ((1/2204.62)*Smax*1000/(batt.V*batt.wf)+ ...
    (1/1000)*inso.wf*kW/inso.rated)* ...
    econ.platform.wf*econ.platform.steel;
trips = ceil((uc.lifetime)*(12/batt.lc - 12/uc.SI)); %number of trips
if trips < 0, trips = 0; end
triptime = dist*kts2mps(econ.inso.vessel.speed)^(-1)*(1/86400); %[d]
vesselcost = 2*trips*econ.inso.vessel.cost*triptime;
maint = econ.inso.maintenance*kW*uc.lifetime;
battreplace = Scost*(12/batt.lc*uc.lifetime-1);
if battreplace < 0, battreplace = 0; end
if exist('Nrep','var'), PVreplace = Nrep*Mcost; else, PVreplace = 0; end
CapEx = platform + battencl + Scost + Icost + Mcost + Ecost;
OpEx = battreplace + PVreplace + maint + vesselcost;
cost = CapEx + OpEx;
if opt.fmin && opt.fmindebug
    kW
    cost
    pause
end

%evaluate if system requirements were met
if sum(L == uc.draw)/(length(L)) < uc.uptime 
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end

end

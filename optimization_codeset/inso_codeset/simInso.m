function [cost,surv,CapEx,OpEx,Mcost,Scost,Ecost,Icost,Strcost, ...
    Pmtrl,Pinst,Pmooring,vesselcost,battreplace,battencl, ...
    triptime,nvi,dp,S,P,D,L,eff_t,pvci,battlc] = ...
    simInso(kW,Smax,opt,data,atmo,batt,econ,uc,bc,inso)

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%extract data
swso = data.swso;
dt = 24*(data.met.time(2) - data.met.time(1)); %[h]
dist = data.dist; %[m] dist to shore
depth = data.depth;   %[m] water depth

%initialize/preallocate
S = zeros(1,length(swso)); %[Wh] storage
S(1) = Smax*1000;
P = zeros(1,length(swso)); %[W] power produced
D = zeros(1,length(swso)); %[W] power dumped
L = ones(1,length(swso))*uc.draw; %[W] load
eff_t = zeros(1,length(swso)); %[~] efficiency
surv = 1; % satisfies use case requirements

% set the cleaning interval based on the use case service interval
if uc.SI > 6
    %if service interval is long-term, guess the panels will be cleaned
    %once every thirty months, run shooting scheme
    inso.pvci = 10; %[months] initial guess
    over = true; %over/under indicator
    dm = 10; %change in pvci
    tol = 2; %tolerance
    if inso.cleanstrat == 2
        mult = 2;
    else
        mult = 1;
    end
else
    %if service interval is short-term, assume the panels will be cleaned
    %every six months
    inso.pvci = 6;
end

%set panel degradation
eff = (1-((inso.deg/100)/8760)*(1:1:length(swso)));
%rain = repmat(linspace(0.5,0,24*30),[1,ceil(length(swso)/(24*30))]);
d_soil_eff = (atmo.soil/100)/8760; %change in soil deg per hour
soil_eff = 1; %starting soil efficiency

cont = 1;
while cont
    %set cleaning interval
    clear clean_ind
    clean_ind = zeros(length(swso),1);
    if inso.cleanstrat == 3 && uc.SI > 6 %winter cleaning
        clean_ind(data.wint_clean_ind) = 1;
    else
        clean_ind(1:ceil((inso.pvci/12)*8760):end) = 1; %interval cleaning
    end
    %run simulation
    for t = 1:length(swso)
        %find efficiency
        soil_eff = soil_eff - d_soil_eff;
        if clean_ind(t) == 1
            soil_eff = 1; %panels cleaned
        end
        %soil_eff = (1-(atmo.soil/100)/8760*rem(t,inso.pvci*(365/12)*24));
        %soil_eff = (1-soil_eff)*rain(t) + soil_eff; %rainfall clean
        eff_t(t) = eff(t)*soil_eff*inso.eff;
        %find power from panel
        if swso(t) > inso.rated*1000 %rated irradiance
            P(t) = eff_t(t)/inso.eff*kW*1000; %[W]
        else %sub rated irradiance
            P(t) = eff_t(t)/ ... 
                inso.eff*kW*1000*(swso(t)/(inso.rated*1000)); %[W]
        end
        %find next storage state
        sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
        S(t+1) = dt*(P(t) - uc.draw) + S(t) - sd; %[Wh]
        if S(t+1) > Smax*1000 %dump power if over limit
            D(t) = S(t+1) - Smax*1000; %[Wh]
            S(t+1) = Smax*1000; %[Wh]
        elseif S(t+1) <= Smax*batt.dmax*1000 %bottomed out
            S(t+1) = dt*P(t) + S(t) - sd; %[Wh] save what's left, L = 0
            %L(t) = S(t)/dt; %adjust load to what was consumed
            L(t) = 0; %drop load to zero because not enough power
        end
    end
    
    %compute life cycle of battery
    if batt.dyn_lc
        minbatt = min(S)/1000; %minimum battery storage
        %make sure minimum battery storage is not full capacity
        if minbatt == Smax, minbatt = .99*Smax; end
        opt.phi = Smax/(Smax - minbatt); %extra depth
        batt.lc = batt.lc_nom*opt.phi^(batt.beta); %new lifetime
        batt.lc(batt.lc > batt.lc_max) = batt.lc_max; %no larger than max
    else
        batt.lc = batt.lc_nom; %[m]
    end
    
    if inso.shootdebug
        disp(['pvci = ' num2str(inso.pvci)])
        disp(['battlc = ' num2str(batt.lc)])
        pause
    end
    
    if uc.SI == 6 || abs(batt.lc - mult*inso.pvci) < tol
        cont = 0;
    elseif batt.lc < mult*inso.pvci %cleaning interval > battery life
        inso.pvci = inso.pvci - dm;
        if inso.shootdebug
            disp('Decreasing pvci...')
            pause
        end
        if ~over
            dm = dm/2;
            over = true;
        end
    elseif batt.lc > mult*inso.pvci %cleaning interval < battery life
        inso.pvci = inso.pvci + dm;
        if inso.shootdebug
            disp('Increasing pvci...')
            pause
        end
        if over
            dm = dm/2;
            over = false;
        end
    end
end

pvci = inso.pvci; %pv cleaning interval
battlc = batt.lc; %battery life cycle
nbr = ceil((12*uc.lifetime/batt.lc-1)); %number of battery replacements

%economic modeling
Mcost = econ.inso.module*kW*econ.inso.marinization; %module
Icost = econ.inso.installation*kW; %installation
Ecost = econ.inso.electrical*kW; %electrical infrastructure
Strcost = econ.inso.structural*kW; %structural infrastructure
if bc == 1 %lead acid
    if Smax < opt.p_dev.kWhmax %less than linear region
        Scost = polyval(opt.p_dev.b,Smax);
    else %in linear region
        Scost = polyval(opt.p_dev.b,opt.p_dev.kWhmax)* ...
            (Smax/opt.p_dev.kWhmax);
    end
elseif bc == 2 %lithium phosphate
    Scost = batt.cost*Smax;
end
battencl = econ.batt.enclmult*Scost; %battery enclosure cost
Pmtrl = (1/1000)*econ.platform.wf*econ.platform.steel* ...
    inso.wf*kW/inso.rated; %platform material
Pinst = econ.vessel.speccost* ... 
    ((econ.platform.t_i)/24); %platform instllation
dp = getInsoDiameter(kW,inso);
if dp < 1, dp = 1; end
if dp < 4 %within bounds, use linear interpolation
    Pmooring = interp2(econ.platform.mdd.diameter, ...
        econ.platform.mdd.depth, ...
        econ.platform.mdd.cost,dp,depth,'linear'); %mooring cost
else %not within bounds, use spline extrapolation
    Pmooring = interp2(econ.platform.mdd.diameter, ...
        econ.platform.mdd.depth, ...
        econ.platform.mdd.cost,dp,depth,'spline'); %mooring cost
end
if inso.cleanstrat == 1
    nvi = nbr;
elseif inso.cleanstrat == 2
    if uc.SI > 6
        nvi = ceil((12*uc.lifetime/inso.pvci-1));
    else
        nvi = nbr;
    end
elseif inso.cleanstrat == 3
    if uc.SI > 6
        nvi = length(data.wint_clean_ind);
    else
        nvi = nbr;
    end
end
if uc.SI < 12 %short term instrumentation
    triptime = 0; %attributed to instrumentation
    t_os = econ.vessel.t_ms/24; %[d]
    C_v = econ.vessel.speccost;
else %long term instrumentation and infrastructure
    triptime = dist*kts2mps(econ.vessel.speed)^(-1)*(1/86400); %[d]
    t_os = econ.vessel.t_mosv/24; %[d]
    C_v = econ.vessel.osvcost;
end
vesselcost = C_v*(nvi*(2*triptime + t_os) + nbr); %vessel cost
battreplace = Scost*(12/batt.lc*uc.lifetime-1);
if battreplace < 0, battreplace = 0; end
CapEx = Pmooring + Pinst + Pmtrl + battencl + Scost + Icost + ...
    Mcost + Ecost + Strcost;
OpEx = battreplace + vesselcost;
cost = CapEx + OpEx;

%evaluate if system requirements were met
if sum(L == uc.draw)/(length(L)) < uc.uptime
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end

end

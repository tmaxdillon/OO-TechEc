function [cost,surv,CapEx,OpEx,Mcost,Scost,Ecost,Icost,Strcost, ...
    Pmtrl,Pinst,Pmooring,vesselcost,battreplace,battencl, ...
    triptime,nvi,batt_L,batt_lft,dp,S,P,D,L,eff_t,pvci] = ...
    simInso(kW,Smax,opt,data,atmo,batt,econ,uc,bc,inso)

%for debug
% disp([num2str(kW) ' ' num2str(Smax)])
ID = [kW Smax];

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%extract data
swso = data.swso;
T = length(swso); %total time steps
dt = 24*(data.met.time(2) - data.met.time(1)); %[h]
dist = data.dist; %[m] dist to shore
depth = data.depth;   %[m] water depth

% set the cleaning interval based on the use case service interval
if uc.SI > 6
    %if service interval is long-term, guess the panels will be cleaned
    %once every thirty months, run shooting scheme
    inso.pvci = 10; %[months] initial guess
    over = true; %over/under indicator
    dm = 10; %change in pvci
    tol = inso.shoottol; %tolerance
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
if econ.inso.scen == 1 %automated cleaning
    d_soil_eff = 0;
    econ.inso.marinization = econ.inso.marinization*2;
elseif econ.inso.scen == 2 %human cleaning
    d_soil_eff = (atmo.soil/100)/8760; %change in soil deg per hour
end
soil_eff = 1; %starting soil efficiency

% if inso.debug
%     disp([num2str(kW) ' kW'])
%     disp([num2str(Smax) ' kWh'])
%     pause
% end

cont = 1;
%t1 = tic;
t2 = tic;
while cont
    %initialize/preallocate
    S = zeros(1,length(swso)); %[Wh] storage
    S(1) = Smax*1000;
    P = zeros(1,length(swso)); %[W] power produced
    D = zeros(1,length(swso)); %[W] power dumped
    L = ones(1,length(swso))*uc.draw; %[W] load
    batt_L = zeros(1,T); %battery L (degradation) timeseries
    fbi = 1; %fresh battery index
    eff_t = zeros(1,length(swso)); %[~] efficiency
    surv = 1; % satisfies use case requirements
    %set cleaning interval
    clear clean_ind batt_lft
    clean_ind = zeros(length(swso),1);
    if inso.cleanstrat == 3 || inso.cleanstrat == 4 && ...
            uc.SI > 6 %winter cleaning
        clean_ind(data.wint_clean_ind) = 1;
    else
        clean_ind(1:ceil((inso.pvci/12)*8760):end) = 1; %interval cleaning
    end
    %run simulation
    for t = 1:length(swso)
        if t < fbi + batt.bdi - 1 %less than first interval after fresh batt
            batt_L(t) = 0;
        elseif rem(t,batt.bdi) == 0 %evaluate degradation on interval
            batt_L(t:t+batt.bdi) = batDegModel(S(fbi:t)/(1000*Smax), ...
                batt.T,3600*(t-fbi),batt.rf_os,ID);
            if batt_L(t) > batt.EoL %new battery
                fbi = t;
                S(t) = Smax*1000;
                if ~exist('batt_lft','var')
                    batt_lft = t*dt*(1/8760)*(12); %[mo] battery lifetime
                end
            end
        end
        %find efficiency
        soil_eff = soil_eff - d_soil_eff;
        if soil_eff < 0 
            soil_eff = 0; %no negative efficiency
        end
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
        if t == fbi 
            cf = 0; %fresh battery
        else
            cf = batt_L(t)*Smax*1000; %[Wh] capacity fading
        end
        sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
        S(t+1) = dt*(P(t) - uc.draw) + S(t) - sd; %[Wh]
        if S(t+1) > (Smax*1000 - cf) %dump power if over limit           
            D(t) = S(t+1) - (Smax*1000 - cf); %[Wh]
            S(t+1) = Smax*1000 - cf; %[Wh]
        elseif S(t+1) <= Smax*batt.dmax*1000 %bottomed out
            S(t+1) = dt*P(t) + S(t) - sd; %[Wh] save what's left, L = 0
            %L(t) = S(t)/dt; %adjust load to what was consumed
            L(t) = 0; %drop load to zero because not enough power
        end
    end
    
    %compute life cycle of battery
    % battery degradation model
    if batt.lcm == 1 %bolun's model
        %     [batt_L,batt_lft] =  irregularDegradation(S/(Smax*1000), ...
        %         data.wave.time',uc.lifetime,batt); %retrospective modeling (old)
        if ~exist('batt_lft','var') %battery never reached EoL
            batt_lft = batt.EoL/batt_L(t)*t*12/(8760); %[mo]
        end
    elseif batt.lcm == 2 %dyanmic (old) model
        opt.phi = Smax/(Smax - (min(S)/1000)); %extra depth
        batt_lft = batt.lc_nom*opt.phi^(batt.beta); %new lifetime
        batt_lft(batt_lft > batt.lc_max) = batt.lc_max; %no larger than max
    else %fixed (really old) model
        batt_lft = batt.lc_nom; %[m]
    end
    
    if inso.shootdebug
        disp(['pvci = ' num2str(inso.pvci)])
        disp(['battlc = ' num2str(batt_lft)])
        disp(['dm = ' num2str(dm)])
        pause
    end
    
    if uc.SI == 6 || abs(batt_lft - mult*inso.pvci) < tol || ...
        inso.cleanstrat == 3 || inso.cleanstrat == 4
        cont = 0;
    elseif batt_lft < mult*inso.pvci %cleaning interval > battery life
        inso.pvci = inso.pvci - dm;
        if inso.shootdebug
            disp('Decreasing pvci...')
            %pause
        end
        if ~over
            dm = dm/2;
            over = true;
        end
    elseif batt_lft > mult*inso.pvci %cleaning interval < battery life
        %if batt lifetime is too long for cleaning to occur then...
        if inso.pvci > inso.cleanlim
            inso.pvci = inso.cleanlim; %set cleaning interval to limit
            cont = 0;
        else
            inso.pvci = inso.pvci + dm;
            if inso.shootdebug
                disp('Increasing pvci...')
                %pause
            end
            if over
                dm = dm/2;
                over = false;
            end
        end
    end
    
    %adjust if time is running too long
    %time1 = toc(t1);
    time2 = toc(t2);
    %     if time1 > 1
    %         dm = 20; %reset dm if it's taking too long
    %         disp('Resetting dm')
    %         t1 = tic; %reset timer
    %         %I don't think this improves convergence...
    %     end
    if time2 > 10 && ~inso.shootdebug
        error([num2str(kW) ' kW and ' num2str(Smax) ...
            ' kWh do not converge'])
    end
end

pvci = inso.pvci; %pv cleaning interval
nbr = ceil((12*uc.lifetime/batt_lft-1)); %number of battery replacements

%economic modeling
Mcost = econ.inso.module*kW*econ.inso.marinization*econ.inso.pcm; %module
Icost = econ.inso.installation*kW*econ.inso.pcm; %installation
Ecost = econ.inso.electrical*kW*econ.inso.marinization ...
    *econ.inso.pcm; %electrical infrastructure
Strcost = econ.inso.structural*kW*econ.inso.marinization ...
    *econ.inso.pcm; %structural infrastructure
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
    econ.platform.steel_fab* ...
    inso.wf*kW/(inso.rated*inso.eff); %platform material
dp = getInsoDiameter(kW,inso);
if dp < 2, dp = 2; end
if dp > 8 %apply installtion time multiplier if big mooring
    inst_mult = interp1([8 econ.platform.inso.boundary_di], ...
        [1 econ.platform.inso.boundary_mf],dp);
else
    inst_mult = 1;
end
t_i = interp1(econ.platform.d_i,econ.platform.t_i,depth, ...
    'linear','extrap')*inst_mult; %installation time
Pinst = econ.vessel.speccost*(t_i/24); %platform instllation cost

% if dp < 8 %within bounds, use linear interpolation
%     Pmooring = interp2(econ.platform.inso.diameter, ...
%         econ.platform.inso.depth, ...
%         econ.platform.inso.cost,dp,depth,'linear'); %mooring cost
% else %not within bounds, use spline extrapolation
%     Pmooring = interp2(econ.platform.inso.diameter, ...
%         econ.platform.inso.depth, ...
%         econ.platform.inso.cost,dp,depth,'spline'); %mooring cost
% end
Pmooring = interp2(econ.platform.inso.diameter, ...
    econ.platform.inso.depth, ...
    econ.platform.inso.cost,dp,depth,'linear'); %mooring cost
if inso.cleanstrat == 1 || econ.inso.scen == 1
    nvi = nbr;
% elseif inso.cleanstrat == 2
%     if uc.SI > 6
%         nvi = ceil((12*uc.lifetime/inso.pvci-1));
%     else
%         nvi = nbr;
%     end
% elseif inso.cleanstrat == 3 || inso.cleanstrat == 4
%     if uc.SI > 6
%         nvi = length(data.wint_clean_ind);
%     else
%         nvi = nbr;
%     end
elseif inso.cleanstrat == 4 %cleaning every other winter
    if uc.SI > 6
        nvi = length(data.wint_clean_ind);
    else
        nvi = nbr;
    end
    %nvi = length(data.wint_clean_ind);
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
vesselcost = C_v*(nvi*(2*triptime + t_os)); %vessel cost
battreplace = Scost*(12/batt_lft*uc.lifetime-1);
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

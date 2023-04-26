function [cost,surv,CapEx,OpEx,kWcost,Scost,Icost,Pmtrl,Pinst, ...
    Pmooring,vesselcost,wecrepair,battreplace,battencl, ...
    triptime,nvi,batt_L,batt_lft,dp,width,cw,S,P,D,L] =  ...
    simWave(kW,Smax,opt,data,atmo,batt,econ,uc,bc,wave)

%for debug
% disp([num2str(kW) ' ' num2str(Smax)])
% kW = 0.2306;
% Smax = 296;
ID = [kW Smax];

%if fmin is suggesting a negative input, block it
if opt.fmin && Smax < 0 || kW < 0
    surv = 0;
    cost = inf;
    return
end

%set capture width modifier
cw_mod = wave.cw_mod;

%extract data
wavepower = opt.wave.wavepower_ts; %wavepower timeseries
T = length(opt.wave.wavepower_ts); %total time steps
dt = 24*(data.wave.time(2) - data.wave.time(1)); %delta time in hours
dist = data.dist; %[m] dist to shore, from km to m
depth = data.depth; %[m] water depth

if wave.method == 1 %divide by B methodology       
    cwr_b = wave.cw_mod.*opt.wave.cwr_b_ts; %[m^-1] eta timeseries (cwr/b)    
    %find width through rated power conditions
    width = sqrt(1000*kW*(1+wave.house)/(wave.eta_ct* ...
        cw_mod*opt.wave.cwr_b_ra* ...
        opt.wave.wavepower_ra)); %[m] physical width of wec
    cw = cwr_b.*width^2; %[m] capture width timeseries
elseif wave.method == 2 %3d interpolation methodology
    %extract data
    Hs = opt.wave.Hs; %Hs timeseries
    Tp = opt.wave.Tp; %Tp timeseries
    %find width through rated power conditions
    width = interp1(opt.wave.B_func(2,:),opt.wave.B_func(1,:),kW); %[m], B
    cw = width.*opt.wave.F(Tp,Hs,width*ones(length(Tp),1)); %[m] cw ts
end

%compute power timeseries
P = wave.eta_ct*cw.*wavepower - kW*wave.house; %[kW] 
P(P<0) = 0; %no negative power
P(P>kW) = kW; %no larger than rated power

%initialize
S = zeros(1,T); %battery level timeseries
S(1) = Smax*1000; %assume battery begins fully charged
D = zeros(1,T); %power dumped timeseries
L = ones(1,T)*uc.draw; %power put to sensing timeseries
batt_L = zeros(1,T); %battery L (degradation) timeseries
fbi = 1; %fresh battery index
surv = 1;

%run simulation
for t = 1:T
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
    if t == fbi
        cf = 0; %fresh battery
    else
        cf = batt_L(t)*Smax*1000; %[Wh] capacity fading
    end
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    S(t+1) = dt*(P(t)*1000 - uc.draw) + S(t) - sd; %[Wh]
    if S(t+1) > (Smax*1000 - cf) %dump power if over limit (minus cap fade)
        D(t) = S(t+1) - (Smax*1000 - cf); %[Wh]
        S(t+1) = Smax*1000 - cf; %[Wh]
    elseif S(t+1) <= Smax*batt.dmax*1000 %bottomed out
        S(t+1) = dt*P(t)*1000 + S(t) - sd; %[Wh] save what's remaining
        L(t) = 0; %drop load to zero because not enough power
    end
end

P = P*1000; %convert to watts

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
nbr = ceil((12*uc.lifetime/batt_lft-1)); %number of battery replacements

nvi = econ.wave.lambda*uc.lifetime + nbr; %vessel interventions

%economic modeling
kWcost = 2*econ.wave.costmult*polyval(opt.p_dev.t,kW); %wec
Icost = 2*(econ.wind.installed - (0.5*kWcost)/ ...
    (kW*econ.wave.costmult))*kW; %installation
if Icost < 0, Icost = 0; end
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
Pmtrl = 0;
t_i = interp1(econ.platform.d_i,econ.platform.t_i,depth, ...
    'linear','extrap'); %installation time
Pinst = econ.vessel.speccost*(t_i/24); %platform instllation
dp = width;
if dp < 1, dp = 1; end
Pmooring = interp2(econ.platform.wave.diameter, ...
    econ.platform.wave.depth, ...
    econ.platform.wave.cost,dp,depth,'linear'); %mooring cost
% if dp < 4 %within bounds, use linear interpolation
%     Pmooring = interp2(econ.platform.mdd.diameter, ...
%         econ.platform.mdd.depth, ...
%         econ.platform.mdd.cost,dp,depth,'linear'); %mooring cost
% else %not within bounds, use spline extrapolation
%     Pmooring = interp2(econ.platform.mdd.diameter, ...
%         econ.platform.mdd.depth, ...
%         econ.platform.mdd.cost,dp,depth,'spline'); %mooring cost
% end
if uc.SI < 12
    triptime = 0; %attributed to instrumentation
    t_os = econ.vessel.t_ms/24; %[d]
    C_v = econ.vessel.speccost;
else
    triptime = dist*kts2mps(econ.vessel.speed)^(-1)*(1/86400); %[d]
    t_os = econ.vessel.t_mosv/24; %[d]
    C_v = econ.vessel.osvcost;
end
vesselcost = C_v*(nvi*(2*triptime + t_os)); %vessel cost
wecrepair = 1/2*(0.5)*(kWcost+Icost)*(nvi); %wec repair cost
if wecrepair < 0, wecrepair = 0; end %if nvi = 0, wec repair must be 0
battreplace = Scost*nbr; %number of battery replacements
CapEx = Pmooring + Pinst + Pmtrl + ...
    battencl + Scost + Icost + kWcost;
OpEx = battreplace + wecrepair + vesselcost;
cost = CapEx + OpEx;

if sum(L == uc.draw)/(length(L)) < uc.uptime
    surv = 0;
    if opt.fmin
        cost = inf;
    end
end
% if sum(S > batt_L*Smax*1000)/(length(S)) < uc.uptime
%     surv = 0;
%     if opt.fmin
%         cost = inf;
%     end
% end

end





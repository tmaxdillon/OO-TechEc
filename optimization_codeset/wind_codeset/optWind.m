function [output,opt] = optWind(opt,data,atmo,batt,econ,uc,bc,turb)

%set kW and Smax mesh
opt.kW_1 = 0.1;
opt.kW_m = opt.bf.M*2; %[kW] (up to 8 kW for wind)
opt.Smax_1 = 1;
opt.Smax_n = opt.bf.N; %[kWh]

%set sensitivity modifiers to 1 if absent
if isfield(data,'depth_mod')
    data.depth_mod = data.depth_mod; %depth modifier
end
if isfield(data,'dist_mod')
    data.dist_mod = data.dist_mod; %dist to coast modifier
end
if isfield(econ.vessel,'tmt_enf') && ...
        (opt.sens || opt.tdsens || opt.senssm) && ...
        isequal(opt.tuned_parameter,'tmt')
    econ.vessel.t_mosv = econ.vessel.tmt_enf; %osv maintenance time
    econ.vessel.t_ms = econ.vessel.tmt_enf; %spec maintenance time
end

%set econ scenario
switch econ.wind.scen
    case 1 %optimistic durability
        econ.wind.lambda = econ.wind.lowfail; %vessel interventions
    case 2 %conservative
        econ.wind.lambda = econ.wind.highfail; %vessel interventions
end
%if sensitivity analysis
if isfield(econ.wave,'lambda_mod')
    econ.wind.lambda = econ.wind.lambda_mod; %lamdba modifier
end

%check to make sure coarse mesh will work
opt.fmin = false;
check_s = 0;
while ~check_s
    [~,check_s] = simWind(opt.kW_m/2,opt.Smax_n/2,opt,data, ... 
        atmo,batt,econ,uc,bc,turb);
    if ~check_s
        opt.kW_m = 2*opt.kW_m;
        opt.Smax_n = 2*opt.Smax_n;
    end
end

%initialize inputs/outputs and set up for parallelization
m = opt.bf.m;
n = opt.bf.n;
opt.kW = linspace(opt.kW_1,opt.kW_m,m);              %[kW]
opt.Smax = linspace(opt.Smax_1,opt.Smax_n,n);    %[kWh]
[K,S] = meshgrid(opt.kW,opt.Smax);
K = reshape(K,[m*n 1]);
S = reshape(S,[m*n 1]);
C_temp = zeros(m*n,1);
S_temp = zeros(m*n,1);
X = zeros(m*n,1);
%set number of cores
if isempty(gcp('nocreate')) %no parallel pool running
    cores = feature('numcores'); %find number of cofes
    if cores > 2 %only start if using HPC
        parpool(cores);
    end
end
%parallel computing via parfor
tGrid = tic;
disp(['Populating grid values: m=' num2str(m) ', n=' num2str(n)])
parfor (i = 1:m*n,opt.bf.maxworkers)
    [C_temp(i),S_temp(i)] = ...
        simWind(K(i),S(i),opt,data,atmo,batt,econ,uc,bc,turb);
    if S_temp(i) == 0 %update obj val X
        X(i) = inf;
    else
        X(i) = C_temp(i);
    end
end
output.cost = reshape(C_temp,[m n])'; %return cost to matrix and structure
output.surv = reshape(S_temp,[m n])'; %return surv to matrix and structure
X = reshape(X,[m n])'; %return objval X to matrix
output.tGrid = toc(tGrid);

disp('Brute forcing global minimum...')
[I(1),I(2)] = find(X == min(X(:)),1);
output.min.kW = opt.kW(I(1));
output.min.Smax = opt.Smax(I(2));
[output.min.cost,output.min.surv,output.min.CapEx,output.min.OpEx,...
    output.min.kWcost,output.min.Scost,output.min.Icost, ... 
    output.min.Pmtrl,output.min.Pinst,...
    output.min.Pmooring,output.min.vesselcost, ... 
    output.min.turbrepair,output.min.battreplace,output.min.battencl, ...
    output.min.triptime,output.min.nvi,output.min.batt_L, ...
    output.min.batt_lft,output.min.dp, ...
    output.min.S,output.min.P,output.min.D,output.min.L] ...
    = simWind(output.min.kW,output.min.Smax, ... 
    opt,data,atmo,batt,econ,uc,bc,turb);
output.min.batt_dyn_lc = batt.lc_nom*(output.min.Smax/ ...
    (output.min.Smax - (min(output.min.S)/1000)))^batt.beta;
output.min.CF = mean(output.min.P)/(1000*output.min.kW);
output.min.rotor_h = turb.clearance + ... 
    sqrt(1000*2*output.min.kW/(atmo.rho_a*pi*turb.ura^3)); %rotor height
%cycles per year
% output.min.cyc60 = countCycles(output.min.S,output.min.Smax,60)/ ...
%     (length(data.wave.time)/8760);
% output.min.cyc80 = countCycles(output.min.S,output.min.Smax,80)/ ...
%     (length(data.wave.time)/8760);
% output.min.cyc100 = countCycles(output.min.S,output.min.Smax,100)/ ...
%     (length(data.wave.time)/8760);

end


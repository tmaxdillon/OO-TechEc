function [output,opt] = optWave(opt,data,atmo,batt,econ,uc,bc,wave)

%set kW and Smax mesh
opt.kW_1 = 0.215; %lower limit for wecsim is 0.2143
opt.Smax_1 = 1;
if ~opt.highresobj
    opt.kW_m = opt.bf.M; %[kW]
    opt.Smax_n = opt.bf.N; %[kWh]
else
    opt.bf.loc_ind = find(contains(opt.locations,data.loc, ...
        'IgnoreCase',false));
    opt.kW_m = opt.bf.M_hros(opt.bf.loc_ind);
    opt.Smax_n = opt.bf.N_hros(opt.bf.loc_ind);
end

%set sensitivity modifiers to 1 if absent and to value if existing
if ~isfield(wave,'cw_mod')
    wave.cw_mod = 1; %capture width modifier
end
if isfield(data,'depth_mod')
    data.depth = data.depth_mod; %depth modifier
end
if isfield(data,'dist_mod')
    data.dist = data.dist_mod; %dist to coast modifier
end
if isfield(econ.vessel,'tmt_enf') && ...
        (opt.sens || opt.tdsens || opt.senssm) && ...
        isequal(opt.tuned_parameter,'tmt')
    econ.vessel.t_mosv = econ.vessel.tmt_enf; %osv maintenance time
    econ.vessel.t_ms = econ.vessel.tmt_enf; %spec maintenance time
end

%set econ scenario
switch econ.wave.scen
    case 1 %conservative
        econ.wave.costmult = econ.wave.costmult_con; %cost multiplier
        econ.wave.lambda = econ.wave.highfail; %vessel interventions
    case 2 %optimistic cost
        econ.wave.costmult = econ.wave.costmult_opt; %cost multiplier
        econ.wave.lambda = econ.wave.highfail; %vessel interventions
    case 3 %optimistic durability
        econ.wave.costmult = econ.wave.costmult_con; %cost multiplier
        econ.wave.lambda = econ.wave.lowfail; %vessel interventions
end
%if sensitivity analysis
if isfield(econ.wave,'lambda_mod')
    econ.wave.lambda = econ.wave.lambda_mod; %lamdba modifier
end
if isfield(econ.wave,'costmult_mod')
    econ.wave.costmult = econ.wave.costmult_mod; %cost modifier
end

%check to make sure coarse mesh will work
opt.fmin = false;
check_s = 0;
while ~check_s
    [~,check_s] = simWave(opt.kW_m/2,opt.Smax_n/2,opt,data, ...
        atmo,batt,econ,uc,bc,wave);
    if ~check_s
        opt.kW_m = 2*opt.kW_m;
        opt.Smax_n = 2*opt.Smax_n;
        if opt.kW_m > wave.kW_max %no larger than max wec-sim value
            opt.kW_m = wave.kW_max;
        end
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
    cores = feature('numcores'); %find number of cores
    if cores > 2 %only start if using HPC
        parpool(cores);
    end
end
%parallel computing via parfor
tGrid = tic;
disp(['Populating grid values: m=' num2str(m) ', n=' num2str(n)])
parfor (i = 1:m*n,opt.bf.maxworkers)
    [C_temp(i),S_temp(i)] = ...
        simWave(K(i),S(i),opt,data,atmo,batt,econ,uc,bc,wave);
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
    output.min.Pmtrl,output.min.Pinst, ...
    output.min.Pmooring,output.min.vesselcost, ...
    output.min.wecrepair,output.min.battreplace,output.min.battencl, ...
    output.min.triptime,output.min.nvi,output.min.batt_L, ...
    output.min.batt_lft,output.min.dp,output.min.width,output.min.cw, ...
    output.min.S,output.min.P,output.min.D,output.min.L] ...
    = simWave(output.min.kW,output.min.Smax, ...
    opt,data,atmo,batt,econ,uc,bc,wave);
output.min.batt_dyn_lc = batt.lc_nom*(output.min.Smax/ ...
    (output.min.Smax - (min(output.min.S)/1000)))^batt.beta;
output.min.CF = mean(output.min.P)/(1000*output.min.kW);
output.min.cw_avg = mean(output.min.cw); %average capture width
output.min.cwr_avg = mean(output.min.cw_avg/output.min.width); %average cwr
%cycles per year
% output.min.cyc60 = countCycles(output.min.S,output.min.Smax,60)/ ...
%     (length(data.wave.time)/8760);
% output.min.cyc80 = countCycles(output.min.S,output.min.Smax,80)/ ...
%     (length(data.wave.time)/8760);
% output.min.cyc100 = countCycles(output.min.S,output.min.Smax,100)/ ...
%     (length(data.wave.time)/8760);

end


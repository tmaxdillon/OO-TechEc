function [output,opt] = optWave(opt,data,atmo,batt,econ,uc,bc,wave)

%set kW and Smax mesh
opt.kW_1 = 0.15;
opt.kW_m = opt.bf.M; %[kW]
opt.Smax_1 = 1;
opt.Smax_n = opt.bf.N; %[kWh]

%set econ scenario
switch econ.wave.scen
    case 1 %conservative
        econ.wave.costmult = econ.wave.costmult_con; %cost multiplier
        econ.wave.lambda = uc.turb.lambda; %vessel interventions
    case 2 %optimistic cost
        econ.wave.costmult = econ.wave.costmult_opt; %cost multiplier
        econ.wave.lambda = uc.turb.lambda; %vessel interventions
    case 3 %optimistic durability
        econ.wave.costmult = econ.wave.costmult_con; %cost multiplier
        econ.wave.lambda = 0; %vessel interventions
end

%check to make sure coarse mesh will work
opt.fmin = false;
check_s = 0;
while ~check_s
    [~,check_s] = simWave(opt.kW_m,opt.Smax_n,opt,data, ...
        atmo,batt,econ,uc,bc,wave);
    if ~check_s
        opt.kW_m = 2*opt.kW_m;
        opt.Smax_n = 2*opt.Smax_n;
    end
end

%initialize inputs/outputs
opt.kW = linspace(opt.kW_1,opt.kW_m,opt.bf.m);              %[kW]
opt.Smax = linspace(opt.Smax_1,opt.Smax_n,opt.bf.n);        %[kWh]
output.cost = zeros(opt.bf.m,opt.bf.n);
output.surv = zeros(opt.bf.m,opt.bf.n);
X = zeros(opt.bf.m,opt.bf.n);
%initial/coarse optimization
tInitOpt = tic;
disp('Populating grid...')
for i = 1:opt.bf.m
    for j = 1:opt.bf.n
        [output.cost(i,j),output.surv(i,j)] = ...
            simWave(opt.kW(i),opt.Smax(j),opt,data,atmo,batt,econ,uc, ...
            bc,wave);
        if output.surv(i,j) == 0
            X(i,j) = inf;
        else
            X(i,j) = output.cost(i,j);
        end
    end
end
% X = output.cost;
% X(output.surv == 0) = inf;
output.tInitOpt = toc(tInitOpt);

disp('Brute forcing global minimum...')
[I(1),I(2)] = find(X == min(X(:)),1);
output.min.kW = opt.kW(I(1));
output.min.Smax = opt.Smax(I(2));
[output.min.cost,output.min.surv,output.min.CapEx,output.min.OpEx,...
    output.min.kWcost,output.min.Scost,output.min.Icost, ...
    output.min.Pmtrl,output.min.Pinst,output.min.Pline, ...
    output.min.Panchor,output.min.vesselcost, ...
    output.min.wecrepair,output.min.battreplace,output.min.battencl, ...
    output.min.triptime,output.min.nvi, ...
    output.min.dp,output.min.width,output.min.cw, ...
    output.min.S,output.min.P,output.min.D,output.min.L] ...
    = simWave(output.min.kW,output.min.Smax, ...
    opt,data,atmo,batt,econ,uc,bc,wave);
output.min.batt_dyn_lc = batt.lc_nom*(output.min.Smax/ ...
    (output.min.Smax - (min(output.min.S)/1000)))^batt.beta;
output.min.CF = mean(output.min.P)/(1000*output.min.kW);
output.min.cw_avg = mean(output.min.cw); %average capture width
output.min.cwr_avg = mean(output.min.cw_avg/output.min.width); %average cwr
output.min.cyc60 = countCycles(output.min.S,output.min.Smax,60);
output.min.cyc80 = countCycles(output.min.S,output.min.Smax,80);
output.min.cyc100 = countCycles(output.min.S,output.min.Smax,100);

end


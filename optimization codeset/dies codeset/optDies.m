function [output,opt] = optDies(opt,data,atmo,batt,econ,uc,bc,dies)

%set kW and Smax mesh
opt.kW_1 = dies.kWmin; %min size
opt.kW_m = dies.kWmax; %max size
opt.Smax_1 = 1;
opt.Smax_n = uc.draw*24*opt.nm.battgriddur/1000*(1/3); %bgd days no power

%check to make sure coarse mesh will work
opt.fmin = false;
check_s = 0;
while ~check_s
    [~,check_s] = simDies(opt.kW_m,opt.Smax_n,opt,data, ... 
        atmo,batt,econ,uc,bc,dies);
    if ~check_s
        opt.kW_m = 2*opt.kW_m;
        opt.Smax_n = 2*opt.Smax_n;
    end
end

%initialize inputs/outputs
opt.kW = linspace(opt.kW_1,opt.kW_m,opt.nm.m);              %[kW] 
opt.Smax = linspace(opt.Smax_1,opt.Smax_n,opt.nm.n);        %[kWh] 
output.cost = zeros(opt.nm.m,opt.nm.n);
output.surv = zeros(opt.nm.m,opt.nm.n);

%initial/coarse optimization
tInitOpt = tic;
disp('Populating coarse grid...')
for i = 1:opt.nm.m
    for j = 1:opt.nm.n
        [output.cost(i,j),output.surv(i,j)] = ...
            simDies(opt.kW(i),opt.Smax(j),opt,data,atmo,batt,econ, ...
            uc,bc,dies);
    end
end
X = output.cost;
X(output.surv == 0) = inf;
%no initial minima near origin
X(:,1:floor(opt.nm.n*opt.nm.initminlim)) = inf;
X(1:floor(opt.nm.m*opt.nm.initminlim),:) = inf;
[I(1),I(2)] = find(X == min(X(:)),1,'first');
opt.init = output.cost(I(1),I(2));
opt.kW_init = opt.kW(I(1));
opt.Smax_init = opt.Smax(I(2));
opt.I_init = I;
output.tInitOpt = toc(tInitOpt);

%nelder mead optimization
tFminOpt = tic; %start timer
opt.fmin = true; %let simWind know that fminsearch is on
%objective function
fun = @(x)simDies(x(1),x(2),opt,data,atmo,batt,econ,uc,bc,dies);
%set options (show convergence and objective space or not)
if opt.nm.show
    options = optimset('MaxFunEvals',10000,'Algorithm', ... 
        'sqp','MaxIter',10000, ...
        'TolFun',opt.nm.tolfun,'TolX',opt.nm.tolx, ... 
        'PlotFcns',@optimplotfval);
else
    options = optimset('MaxFunEvals',10000,'Algorithm', ... 
        'sqp','MaxIter',10000, ...
        'TolFun',opt.nm.tolfun,'TolX',opt.nm.tolx);
end
disp('Beginning Nelder Mead')
%fminsearch
[opt_ind] = ...
    fminsearch(fun,[opt.kW_init opt.Smax_init],options);
%store outputs of minima into output.min
if opt_ind(1) > dies.kWmax
    output.min.kW = dies.kWmax;
else
    output.min.kW = opt_ind(1);
end
output.min.Smax = opt_ind(2);
[output.min.cost,output.min.surv,output.min.CapEx,output.min.OpEx,...
    output.min.kWcost,output.min.Scost,output.min.Pmtrl,...
    output.min.Pinst,output.min.Pline,output.min.Panchor, ...
    output.min.vesselcost,output.min.genrepair, ...
    output.min.battreplace,output.min.battencl,output.min.genencl, ...
    output.min.fuel,output.min.triptime,output.min.runtime, ... 
    output.min.nvi,output.min.nbr,output.min.nfr,output.min.noc, ...
    output.min.Fdmax,output.min.dp, ...
    output.min.CF,output.min.S,output.min.P,output.min.D,output.min.L] ...
    = simDies(output.min.kW,output.min.Smax, ...
    opt,data,atmo,batt,econ,uc,bc,dies);
output.min.cyc60 = countCycles(output.min.S,output.min.Smax,60);
output.min.cyc80 = countCycles(output.min.S,output.min.Smax,80);
output.min.cyc100 = countCycles(output.min.S,output.min.Smax,100);
output.tFminOpt = toc(tFminOpt); %end timer

end


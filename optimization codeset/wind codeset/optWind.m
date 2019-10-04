function [output,opt] = optWind(opt,data,atmo,batt,econ,uc,turb)

%set kW and Smax mesh
opt.kW_1 = 0.1;
opt.kW_m = uc.draw/1000*(turb.ura^3/turb.uci^3)*(1/4); %survive at cut in
opt.Smax_1 = 1;
opt.Smax_n = uc.draw*24*opt.nm.battgriddur/1000*(1/3); %bgd days without power

%check to make sure coarse mesh will work
opt.fmin = false;
check_s = 0;
while ~check_s
    [~,check_s] = simWind(opt.kW_m,opt.Smax_n,opt,data, ... 
        atmo,batt,econ,uc,turb);
    opt.kW_m = 2*opt.kW_m;
    opt.Smax_n = 2*opt.Smax_n;
end

%initialize inputs/outputs
opt.kW = linspace(opt.kW_1,opt.kW_m,opt.nm.m);              %[kW] 
opt.Smax = linspace(opt.Smax_1,opt.Smax_n,opt.nm.n);        %[kWh] 
output.cost = zeros(opt.nm.m,opt.nm.n);
output.surv = zeros(opt.nm.m,opt.nm.n);

%initial/coarse optimization
tInitOpt = tic;
for i = 1:opt.nm.m
    for j = 1:opt.nm.n
        [output.cost(i,j),output.surv(i,j)] = ...
            simWind(opt.kW(i),opt.Smax(j),opt,data,atmo,batt,econ,uc,turb);
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
fun = @(x)simWind(x(1),x(2),opt,data,atmo,batt,econ,uc,turb);
%set options (show convergence and objective space or not)
if opt.nm.show
    options = optimset('MaxFunEvals',10000,'Algorithm','sqp','MaxIter',10000, ...
        'TolFun',opt.nm.tolfun,'TolX',opt.nm.tolx, ... 
        'PlotFcns',@optimplotfval);
else
    options = optimset('MaxFunEvals',10000,'Algorithm','sqp','MaxIter',10000, ...
        'TolFun',opt.nm.tolfun,'TolX',opt.nm.tolx);
end
%fminsearch
[opt_ind] = ...
    fminsearch(fun,[opt.kW_init opt.Smax_init],options);
%store outputs of minima into output.min
output.min.kW = opt_ind(1);
output.min.Smax = opt_ind(2);
[output.min.cost,output.min.surv,output.min.CapEx,output.min.OpEx,...
    output.min.kWcost,output.min.Scost,output.min.Icost,output.min.FScost, ...
    output.min.maint,output.min.vesselcost, ... 
    output.min.turbrepair,output.min.battreplace,output.min.battencl, ...
    output.min.platform, ...
    output.min.battvol,output.min.triptime,output.min.trips, ... 
    output.min.CF,output.min.S,output.min.P,output.min.D,output.min.L] ...
    = simWind(output.min.kW,output.min.Smax,opt,data,atmo,batt,econ,uc,turb);
output.min.rotor_h = turb.clearance + ... 
    sqrt(1000*2*output.min.kW/(atmo.rho*pi*turb.ura^3)); %store rotor height
output.tFminOpt = toc(tFminOpt); %end timer

end


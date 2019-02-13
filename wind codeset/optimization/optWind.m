function [output,opt] = optWind(opt,data,atmo,batt,econ,node,turb,tTot)

%print status to command window
if opt.mult
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' beginning after ' num2str(round(toc(tTot),2)) ' seconds. ' ...
        opt.tuned_parameter ' tuned to ' ...
        num2str(opt.tuning_array(opt.s)) '.'])
else
    disp('Optimization beginning')
end
tOpt = tic;

%curve-fit devices, find polyvals
p.t = calcDeviceCost('turbine',[],econ.turb_n);
p.b = calcDeviceCost('battery',[],econ.batt_n);

%set R and Smax mesh
opt.kW_1 = 0;
opt.kW_m = node.draw/1000*(turb.ura^3/turb.uci^3); %survive at cut in
opt.Smax_1 = 0;
opt.Smax_n = node.draw*24*opt.battgriddur/1000; %one month without power

%enforce the grid
if opt.enforcegrid
    opt.kW_1 = opt.enfkW_1;
    opt.Smax_1 = opt.enfSmax_1;
    opt.kW_m = opt.enfkW_m;
    opt.Smax_n = opt.enfSmax_n;
end

%check to make sure coarse mesh will work
opt.fmin = false;
[~,check_s] = simWind(opt.kW_m,opt.Smax_n,opt,data,atmo,batt,econ,node,turb,p);
if ~check_s
    opt.kW_m = 2*opt.kW_m;
    opt.Smax_n = 2*opt.Smax_n;
end

%initialize inputs/outputs
opt.kW = linspace(opt.kW_1,opt.kW_m,opt.m);                %[m] rated power
opt.Smax = linspace(opt.Smax_1,opt.Smax_n,opt.n);       %[kWh] maximum storage capacity
output.cost = zeros(opt.m,opt.n);
output.surv = zeros(opt.m,opt.n);
if opt.show
    output.CapEx = zeros(opt.m,opt.n);
    output.OpEx = zeros(opt.m,opt.n);
    output.kWcost = zeros(opt.m,opt.n);
    output.Scost = zeros(opt.m,opt.n);
    output.CF = zeros(opt.m,opt.n);
    output.S = zeros(opt.m,opt.n,length(data.met.time)+1);
    output.P = zeros(opt.m,opt.n,length(data.met.time));
    output.D = zeros(opt.m,opt.n,length(data.met.time));
    output.L = zeros(opt.m,opt.n,length(data.met.time));
end

%initial/coarse optimization
tInitOpt = tic;
for i = 1:opt.m
    for j = 1:opt.n
        [output.cost(i,j),output.surv(i,j),output.CapEx(i,j), ...
            output.OpEx(i,j),output.kWcost(i,j), ...
            output.Scost(i,j),output.CF(i,j),output.S(i,j,:), ...
            output.P(i,j,:),output.D(i,j,:),output.L(i,j,:)] ...
            = simWind(opt.kW(i),opt.Smax(j),opt,data,atmo,batt,econ,node,turb,p);
    end
end
X = output.cost;
X(output.surv == 0) = inf;
X(:,1:floor(opt.n*opt.initminlim)) = inf; %don't allow initial minima near Smax = 0
X(1:floor(opt.m*opt.initminlim),:) = inf; %don't allow initial minima near R = 0
[I(1),I(2)] = find(X == min(X(:)),1,'first');
if opt.initminrand
    I(1) = I(1) + randi(opt.m - floor(opt.m*opt.initminlim) - 1);
    I(2) = I(2) + randi(opt.m - floor(opt.m*opt.initminlim) - 1);
end
opt.init = output.cost(I(1),I(2));
opt.kW_init = opt.kW(I(1));
opt.Smax_init = opt.Smax(I(2));
opt.I_init = I;
output.tInitOpt = toc(tInitOpt);

%nelder mead optimization
tFminOpt = tic; %start timer
opt.fmin = true; %let simWind know that fminsearch is on
%objective function
fun = @(x)simWind(x(1),x(2),opt,data,atmo,batt,econ,node,turb,p);
%set options (show convergence and objective space or not)
if opt.show
    options = optimset('MaxFunEvals',10000,'Algorithm','sqp','MaxIter',10000, ...
        'TolFun',opt.nelder.tolfun,'TolX',opt.nelder.tolx,'PlotFcns',@optimplotfval);
else
    options = optimset('MaxFunEvals',10000,'Algorithm','sqp','MaxIter',10000, ...
        'TolFun',opt.nelder.tolfun,'TolX',opt.nelder.tolx);
end
%fminsearch
[opt_ind] = ...
    fminsearch(fun,[opt.kW_init opt.Smax_init],options);
%store outputs of minima into output.min
output.min.kW = opt_ind(1);
output.min.Smax = opt_ind(2);
[output.min.cost,output.min.surv,output.min.CapEx,output.min.OpEx,...
    output.min.kWcost,output.min.Scost,output.min.CF,output.min.S, ...
    output.min.P,output.min.D,output.min.L] ...
    = simWind(output.min.kW,output.min.Smax,opt,data,atmo,batt,econ,node,turb,p);
output.tFminOpt = toc(tFminOpt); %end timer

%print status to command window
if opt.mult
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' complete after ' num2str(round(toc(tOpt),2)) ' seconds.'])
else
    disp(['Optimization complete after ' num2str(round(toc(tTot),2)) ' seconds.'])
end
output.min %print nelder mead min values
opt.kW_init; %print initial kW value
opt.Smax_init; %print inial Smax value

end


function [output,opt] = optWind(opt,data,atmo,batt,econ,load,turb,tTot)

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

%initialize inputs/outputs
opt.R = linspace(opt.R_1,opt.R_m,opt.m);                %[m] radius
opt.Smax = linspace(opt.Smax_1,opt.Smax_n,opt.n);       %[kWh] maximum storage capacity
opt.initmin = inf;
opt.fmin = false;
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
tInitOpt = tic;
for i = 1:opt.m
    for j = 1:opt.n
        [output.cost(i,j),output.surv(i,j),output.CapEx(i,j), ...
            output.OpEx(i,j),output.kWcost(i,j), ...
            output.Scost(i,j),output.CF(i,j),output.S(i,j,:), ...
            output.P(i,j,:),output.D(i,j,:),output.L(i,j,:)] ...
            = simWind(opt.R(i),opt.Smax(j),opt,data,atmo,batt,econ,load,turb);
    end
end


X = output.cost;
X(output.surv == 0) = inf;
[I(1),I(2)] = find(X == min(X(:)));
opt.init = output.cost(I(1),I(2));
opt.R_init = opt.R(I(1));
opt.Smax_init = opt.Smax(I(2));
opt.I_init = I;

output.tInitOpt = toc(tInitOpt);

tFminOpt = tic; %start timer
opt.fmin = true; %let simWind know that fminsearch is on
%objective function
fun = @(x)simWind(x(1),x(2),opt,data,atmo,batt,econ,load,turb);
%set options (show convergence and objective space or not)
options = [];
if opt.show
    options = optimset('PlotFcns',@optimplotfval);
end
%fminsearch
[opt_ind] = ...
    fminsearch(fun,[opt.R_init opt.Smax_init],options);
%store outputs of minima into output.min
output.min.R = opt_ind(1);
output.min.Smax = opt_ind(2);
[output.min.cost,output.min.surv,output.min.CapEx,output.min.OpEx,...
    output.min.kWcost,output.min.Scost,output.min.CF,output.min.S,output.min.P, ...
    output.min.D,output.min.L] ...
    = simWind(output.min.R,output.min.Smax,opt,data,atmo,batt,econ,load,turb);
output.min.ratedP = (1/2*atmo.rho*pi*output.min.R^2*turb.ura^3*turb.eta);
output.tFminOpt = toc(tFminOpt); %end timer

%print status to command window
if opt.mult
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' complete after ' num2str(round(toc(tOpt),2)) ' seconds.'])
else
    disp(['Optimization complete after ' num2str(round(toc(tTot),2)) ' seconds.'])
end

end


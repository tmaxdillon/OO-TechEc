%created by Trent Dillon on January 15th 2018

clear all, close all, clc

%% top do

% 1 - make visWindOpt()
% 1 - make visWindSim()
% 2 - make runWindOpt()
% 3 - move dist from coast to a variable inside the structure

%% setup

%load data
location = 'argBasin';
if ~exist('data','var')
    data = load(location,location);
    data = data.(location);
end
clear location

%economic parameters
econ.rcost = 1047.4;                %[$/rated kW] Nature Power 400 W turbine
econ.Scost = 275;                   %[$/kWh storage] lifeline GPL-L16T-2V
econ.OpEx.p1 = [160934, 0.02];      %[miles offshore, percent of CapEx]
econ.OpEx.p2 = [1.609e6, 0.1];      %[miles offshore, percent of CapEx]

%turbine parameters
turb.uci = 3.13;            %[m/s] Nature Power 400 W turbine
turb.ura = 12.5;            %[m/s] Nature Power 400 W turbine
turb.uco = 49.2;            %[m/s] Nature Power 400 W turbine
turb.eta = 0.36;            %[m/s] Nature Power 400 W turbine

%battery parameters
batt.lb = 0.2;              %floor = percentage of Smax

%atmospheric parameters
atmo.rho = 1;               %[kg/m^3] density
%add surface roughness for vertical adjustment

%load parameters
load = 200;                 %[W] - secondary node

%optimization variables
opt.m = 15;
opt.n = 15;
opt.R_1 = 0;
opt.R_m = 10;
opt.Smax_1 = 0;
opt.Smax_n = 40;
opt.save = false;
opt.surf = true;

%% implement nelder mead fminsearch optimization

%initialize inputs/outputs
opt.R = linspace(opt.R_1,opt.R_m,opt.m);                %[m] radius
opt.Smax = linspace(opt.Smax_1,opt.Smax_n,opt.n);       %[kWh] maximum storage capacity
opt.initmin = inf;
opt.fmin = false;
if opt.surf
    output.cost = zeros(opt.m,opt.n);
    output.CapEx = zeros(opt.m,opt.n);
    output.OpEx = zeros(opt.m,opt.n);
    output.kWcost = zeros(opt.m,opt.n);
    output.Scost = zeros(opt.m,opt.n);
    output.CF = zeros(opt.m,opt.n);
    output.S = zeros(opt.m,opt.n,length(data.met.time)+1);
    output.P = zeros(opt.m,opt.n,length(data.met.time));
    output.D = zeros(opt.m,opt.n,length(data.met.time));
    output.L = zeros(opt.m,opt.n,length(data.met.time));
    output.surv = zeros(opt.m,opt.n);
end
tic
for i = 1:opt.m
    for j = 1:opt.n
        if ~opt.surf
            [temp_c,temp_s] = simWind(opt.R(i),opt.Smax(j),opt, ...
                data,atmo,batt,econ,load,turb);
            if temp_c < opt.initmin && temp_s
                opt.initmin = temp_c;
                opt.R_init = opt.R(i);
                opt.Smax_init = opt.Smax(j);
            end
        end
        if opt.surf
            [output.cost(i,j),output.surv(i,j),output.CapEx(i,j), ...
                output.OpEx(i,j),output.kWcost(i,j), ...
                output.Scost(i,j),output.CF(i,j),output.S(i,j,:), ...
                output.P(i,j,:),output.D(i,j,:),output.L(i,j,:)] ...
                = simWind(opt.R(i),opt.Smax(j),opt,data,atmo,batt,econ,load,turb);
        end
    end
end
toc

if opt.surf
    X = output.cost;
    X(output.surv == 0) = inf;
    [I(1),I(2)] = find(X == min(X(:)));
    opt.init = output.cost(I(1),I(2));
    opt.R_init = opt.R(I(1));
    opt.Smax_init = opt.Smax(I(2));
end

tic
opt.fmin = true;
fun = @(x)simWind(x(1),x(2),opt,data,atmo,batt,econ,load,turb);
[opt_ind] = ...
    fminsearch(fun,[opt.R_init opt.Smax_init]);
output.min.R = opt_ind(1);
output.min.Smax = opt_ind(2);
[output.min.cost,output.min.surv_,output.min.CapEx,output.min.OpEx,... 
    output.min.kWcost,output.min.Scost,output.min.CF,output.S,output.min.P, ... 
    output.min.D,output.min.L] ...
    = simWind(output.min.R,output.min.Smax,opt,data,atmo,batt,econ,load,turb);
if opt.surf
    visWindOpt(opt,output,data,atmo,batt,econ,load,turb)
end
toc

clear i j temp_c temp_s fun I X opt_ind

%% visualize optimization

visWindOpt(opt,output,data,atmo,batt,econ,load,turb);

%% visualize specific simulation

R_val = 8.9;
Smax_val = 19.4;

visWindSim(R_val,Smax_val,save,opt,output,data,atmo,batt,econ,load,turb);

clear R_val Smax_val





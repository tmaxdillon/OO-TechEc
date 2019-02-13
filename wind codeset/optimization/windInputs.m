%load data
location = 'argBasin';
if ~exist('data','var')
    data = load(location,location);
    data = data.(location);
end
clear location

%economic parameters
%econ.ship = 80000;          %[$/day] of vessel charter UNOLS global class vessels (Dana)
%econ.repairT = 2/24;        %[d] additional repair time
econ.maintenance = 37;       %[$/(kW*visit)] maint costs (Orrell and Poehlman, 2017 + dwr)
%econ.marinize = ??
%econ.install = ??
%econ.tower = ??
econ.batt_n = 2;            %polynomial fit
econ.turb_n = 2;            %polynomial fit

%turbine parameters
turb.uci = 3;               %[m/s] guess
turb.ura = 11;              %[m/s] awea
turb.uco = 30;              %[m/s] guess, high? maybe 25-30
turb.eta = 0.35;            %[~] guess
%turb.mtbf = 12;             %[months], mean time between failure (made up)

%battery parameters
batt.lb = 0.2;              %floor = percentage of Smax
%batt.FoS =                 %factor of safety (based on variance?)

%atmospheric parameters
atmo.rho = 1;               %[kg/m^3] density
%add surface roughness for vertical adjustment

%load parameters
node.draw = 500;            %[W] - secondary node
node.lifetime = 5;          %[y]
node.SI = 6;                %[months] service interval
node.uptime = 1;           %[%] uptime
node.constr.thresh = false;
node.constr.uptime = true;

%optimization parameters
opt.m = 8;
opt.n = 8;
opt.battgriddur = 7;       %[d]
opt.show = false;
opt.enforcegrid = false;
opt.initminset = 0;
opt.initminlim = .9;
opt.initminrand = false;
opt.failurezoneslope = false;
opt.enfKw_m = 4;
opt.enfSmax_n = 15;
opt.enfkW_1 = 1;
opt.enfSmax_1 = 3;
opt.nelder.tolfun = 1;
opt.nelder.tolx = 1;

%multiple optimization parameters
opt.mult = true;
%opt.tuning_array = [1 .99 .98 .97 .96 .95 .925 .9 .85 .8];
%opt.tuned_parameter = 'utp';
%opt.tuning_array = [50:50:1000];
%opt.tuned_parameter = 'load';
opt.tuning_array = linspace(2,40,30);
opt.tuned_parameter = 'bgd';

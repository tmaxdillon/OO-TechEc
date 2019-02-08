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
econ.maintenance = 37;       %[$/(kW*visit)] maintenance costs (Orrell and Poehlman, 2017 + dwr)
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
node.draw = 400;            %[W] - secondary node
node.lifetime = 5;          %[y]
node.SI = 6;                %[months] service interval
node.uptime = .9;           %[%] uptime

%optimization parameters
opt.m = 100;
opt.n = 100;
opt.battgriddur = 30;       %[d]
opt.show = false;
opt.constr.thresh = false;
opt.constr.uptime = true;
opt.enforcegrid = true;
opt.enfR_m = sqrt(2*1.8*1000/(atmo.rho*pi*turb.eta*turb.ura^3));
opt.enfSmax_n = 7.5;
opt.enfR_1 = sqrt(2*1.6*1000/(atmo.rho*pi*turb.eta*turb.ura^3));
opt.enfSmax_1 = 6;

%multiple optimization parameters
opt.mult = false;
%opt.tuning_array = [1 .99 .98 .97 .96 .95 .925 .9 .85 .8];
%opt.tuned_parameter = 'utp';
opt.tuning_array = [50:50:1000];
opt.tuned_parameter = 'load';

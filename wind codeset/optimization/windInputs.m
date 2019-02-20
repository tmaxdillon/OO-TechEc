%load data
location = 'argBasin';
if ~exist('data','var')
    data = load(location,location);
    data = data.(location);
end
clear location

%economic parameters
%econ.ship = 80000;             %[$/day] -- UNOLS global class vessels (Dana)
%econ.repairT = 2/24;           %[d] additional repair time
econ.maintenance = 37;          %[$/(kW*visit)] maint costs (O&P, 2017 + dwr)
econ.installed = 10117;         %installed costs
econ.marinization = 1.39;       %marinaiztaion factor
econ.batt_n = 2;                %polynomial fit
econ.turb_n = 2;                %polynomial fit
econ.vessel.fuel = 4;           %[$/gal]
econ.vessel.cost = 20000;       %[$/day]
econ.vessel.mileage = 1500;     %[gallons/day]
econ.vessel.speed = 10;         %[kts]
econ.foundsub = 1653;           %[$/kW] 

%turbine parameters
turb.uci = 3;               %[m/s] guess
turb.ura = 11;              %[m/s] awea
turb.uco = 30;              %[m/s] guess
turb.eta = 0.35;            %[~] guess
turb.mtbf = 36;             %[months], mean time between failure 

%battery parameters
batt.lb = 0.2;              %floor = percentage of Smax
%batt.FoS =                 %factor of safety (based on variance?)

%atmospheric parameters
atmo.rho = 1;               %[kg/m^3] density
atmo.h = 4;                 %[m]
atmo.zo = 0.01;

%use cases
c = 2;
%short term instrumentation
uc(1).draw = 200;             %[W] - secondary node
uc(1).lifetime = 5;           %[y]
uc(1).SI = 6;                 %[months] service interval
uc(1).uptime = .95;           %[%] uptime
uc(1).ship.cost = 40000;      %[$/day] for vessel
uc(1).ship.speed = 11.5;      %[kts]
uc(1).ship.mileage = 2700;    %gallons/day
%long term instrumentation
uc(2).draw = 500;             %[W] - secondary node
uc(2).lifetime = 5;           %[y]
uc(2).SI = inf;               %[months] service interval
uc(2).uptime = 1;             %[%] uptime
uc(2).ship.cost = 80000;      %[$/day] for vessel
uc(2).ship.speed = 11;        %[kts]
uc(2).ship.mileage = 2200;    %gallons/day
%infrastructure
uc(3).draw = 8000;            %[W] - secondary node
uc(3).lifetime = 25;          %[y]
uc(3).SI = inf;               %[months] service interval
uc(3).uptime = 99;            %[%] uptime
uc(3).ship.cost = [];         %[$/day] for vessel
uc(3).ship.speed = [];        %[kts]
uc(3).ship.mileage = [];      %gallons/day

%optimization parameters
opt.m = 8;
opt.n = 8;
opt.battgriddur = 7;       %[d]
opt.show = false;
opt.enforcegrid = false;
opt.initminset = 0;
opt.initminlim = .5;
opt.initminrand = false;
opt.failurezoneslope = false;
opt.enfKw_m = 4;
opt.enfSmax_n = 15;
opt.enfkW_1 = 1;
opt.enfSmax_1 = 3;
opt.nelder.tolfun = 10;
opt.nelder.tolx = 1;

%multiple optimization parameters
opt.mult = true;
%opt.tuning_array = [1 .99 .98 .97 .96 .95 .925 .9 .85 .8];
%opt.tuned_parameter = 'utp';
%opt.tuning_array = [50:50:1000];
%opt.tuned_parameter = 'load';
%opt.tuning_array = linspace(2,40,8);
%opt.tuned_parameter = 'bgd';
%opt.tuning_array = [4 8 16 32 100];
%opt.tuned_parameter = 'mxn';
%opt.tuning_array = [0.01:.05:0.5];
%opt.tuned_parameter = 'zo';
opt.tuning_array = [2 4 6 8 10 12 14 18 22 30 40];
opt.tuned_parameter = 'mtbf';

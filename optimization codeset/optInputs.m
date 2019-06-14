%load data
location = 'souOcean';
if ~exist('data','var')
    data = load(location,location);
    data = data.(location);
end
clear location

pm = 1; %power module
c = 2;  %use case

%ECONOMIC
%polynomial fits
econ.batt_n = 1;                    %[~]
econ.wind_n = 1;                    %[~]
%maintenance costs
econ.wind.maintenance = 37;         %[$/(kW*visit)] (O&P, 2017 + dwr)
econ.inso.maintenance = 41;         %[$/(kW*year)] (FEMP, NREL 2013)
%insalled costs
econ.wind.installed = 10117;        %[$/kW]
econ.inso.installation = 270;       %[$/kW]
%marinization
econ.wind.marinization = 1.8;       %[~]
econ.inso.marinization = [];        %[~]
%vessel info
econ.wind.vessel.fuel = 4;          %[$/gal]
econ.inso.vessel.fuel = 4;          %[$/gal]
econ.wind.vessel.cost = 20000;      %[$/day]
econ.inso.vessel.cost = 10000;      %[$/kW]
econ.wind.vessel.mileage = 1500;    %[gallons/day]
econ.inso.vessel.mileage = 1000;    %[gallons/day]
econ.wind.vessel.speed = 10;        %[kts]
econ.inso.vessel.speed = 15;        %[kts]
%foundation/substructure costs
econ.wind.foundsub.sf = .8;         %scaling factor
econ.wind.foundsub.cost = 1653;     %[$/kW]
econ.inso.foundsub.cost = [];
econ.batt.foundsub.cost = [];       %[$/kg] or [$/m^3]
%solar costs
econ.inso.module = 470;             %[$/kW]
econ.inso.installation = 270;       %[$/kW]
econ.inso.electrical = 210;         %[$/kW]
econ.inso.caplife = false;          %toggle capping lifetime for uc = 3
%battery costs
econ.batt.encl.sf = .9995;                          %scaling factor
econ.batt.encl.scale = 10*.3278*.1713*.2355;        %[m^3]
econ.batt.encl.cost = 5000/econ.batt.encl.scale;    %[$/m^3]
econ.batt.wiring = 10;                              %[$/kWh]

%DEVICE
%wind parameters
turb.uci = 3;               %[m/s] guess
turb.ura = 11;              %[m/s] awea
turb.uco = 30;              %[m/s] guess
turb.eta = 0.35;            %[~] guess
turb.mtbf = 12*3;           %[months], mean time between failure
turb.clearance = 4;         %[m] surface to bottom of swept area clearance
turb.uf = 1;                %unexpected failures
%solar parameters
inso.rated = 1;             %[kW/m^2] from Brian
inso.eff = 0.18;            %[~] from Devin (may trail off when off of MPP)
inso.deg = 0.005;           %[%/year]
inso.pvci = 24;             %[months] cleaning interval
inso.autoclean = 0;         %toggle automated cleaning
inso.seasonalclean = 0;     %toggle for annual clean
inso.cleanmonth = 5;        %month to clean annually
inso.wf = 60;               %[kg/m^2] weight factor
%battery parameters
batt.lb = 0.2;              %floor = percentage of Smax
batt.V = 12;                %[V] Voltage
batt.ed = 0.1;              %[Ah/in^3] energy density
batt.wf = 1.5;              %[Ah/lb] weight factor
batt.lc = 18;               %[months] life cycle
batt.mcr = [];              % maximum charge rate
batt.mdr = [];              % maximum discharge rate
batt.sdr = 2;               %[%/month] self discharge rate

%atmospheric parameters
atmo.rho = 1.225;           %[kg/m^3] density
atmo.h = 4;                 %[m]
atmo.zo = 0.02;             %[mm]
atmo.dyn_h = 0;             %toggle dynamic hub height
atmo.soil = 0.25;           %[%/year]

%USE CASES
%short term instrumentation
uc(1).draw = 200;               %[W] - secondary node
uc(1).lifetime = 5;             %[y]
uc(1).SI = 6;                   %[months] service interval
uc(1).uptime = .95;             %[%] uptime
uc(1).uptime_window = 360;      %[d]
uc(1).ship.cost = 40000;        %[$/day] for vessel
uc(1).ship.speed = 11.5;        %[kts]
uc(1).ship.mileage = 2700;      %gallons/day
%long term instrumentation
uc(2).draw = 500;               %[W] - secondary node
uc(2).lifetime = 5;             %[y]
uc(2).SI = 12*uc(2).lifetime;   %[months] service interval
uc(2).uptime = 1;               %[%] uptime
uc(2).uptime_window = 30;       %[d]
uc(2).ship.cost = 80000;        %[$/day] for vessel
uc(2).ship.speed = 11;          %[kts]
uc(2).ship.mileage = 2200;      %gallons/day
%infrastructure
uc(3).draw = 8000;              %[W] - secondary node
uc(3).lifetime = 25;            %[y]
uc(3).SI = 12*uc(3).lifetime;   %[months] service interval
uc(3).uptime = .99;             %[%] uptime
uc(3).uptime_window = 30;       %[d]
uc(3).ship.cost = [];           %[$/day] for vessel
uc(3).ship.speed = [];          %[kts]
uc(3).ship.mileage = [];        %gallons/day

%multiple optimizations
opt.mult = 1;
opt.tuning_array = [1 .99 .97 .95 .925 .9 .85 .8];
opt.tuned_parameter = 'utp';
%opt.tuning_array = [50:50:1000];
%opt.tuned_parameter = 'load';
%opt.tuning_array = linspace(2,40,8);
%opt.tuned_parameter = 'bgd';
%opt.tuning_array = [4:2:20];
%opt.tuned_parameter = 'mxn';
%opt.tuning_array = [0.01,0.2,.5];
%opt.tuned_parameter = 'zo';
%opt.tuning_array = [12:24:26*12];
% opt.tuning_array = [2 4 6 8 10 12 14 18 22 30 40];
% opt.tuned_parameter = 'mtbf';
% opt.tuning_array = 0.6:0.05:1;
% opt.tuned_parameter = 'psr';
% opt.tuning_array = [6 8 10 12 14 18 22 30 35 40 45 50];
% opt.tuned_parameter = 'pvci';
% opt.tuning_array = [1:1:12];
% opt.tuned_parameter = 'scm';
% opt.tuning_array = [0,1,2,3,4,5];
% opt.tuned_parameter = 'utf';

%optimization parameters
opt.m = 8;
opt.n = 8;
opt.l = 4;
opt.battgriddur = 7; %[d]
opt.many = true; %seed many initial points into nelder
opt.bgd_array = [5,9,10,14,22]; %[d]
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
opt.utw = 0; %uptime window?

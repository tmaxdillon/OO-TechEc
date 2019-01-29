%load data
location = 'argBasin';
if ~exist('data','var')
    data = load(location,location);
    data = data.(location);
end
clear location

%economic parameters
econ.Tcost = 1047.4;                %[$/rated kW] Nature Power 400 W turbine
econ.Scost = 275;                   %[$/kWh storage] lifeline GPL-L16T-2V (2.38 kWh)
%econ.OpEx.p1 = [160934, 0.02];      %[m offshore, percent of CapEx]
%econ.OpEx.p2 = [1.609e6, 0.1];      %[m offshore, percent of CapEx]
econ.ship = 1000;                   %[$/day] of vessel charter
econ.speed = 5;                     %[m/s] vessel speed
econ.repairT = 2;                   %[d] repair time
econ.fuel = 4;                      %[$/gal] diesel fuel (in seattle)
econ.mileage = 23.4;                %[gal/hr] fuel consumption

%turbine parameters
turb.uci = 3.13;            %[m/s] Nature Power 400 W turbine
turb.ura = 12.5;            %[m/s] Nature Power 400 W turbine
turb.uco = 49.2;            %[m/s] Nature Power 400 W turbine
turb.eta = 0.36;            %[m/s] Nature Power 400 W turbine
turb.mtbf = 12;             %[months], mean time between failure (made up)

%battery parameters
batt.lb = 0.2;              %floor = percentage of Smax


%atmospheric parameters
atmo.rho = 1;               %[kg/m^3] density
%add surface roughness for vertical adjustment

%load parameters
node = 200;                 %[W] - secondary node

%optimization parameters
opt.m = 8;
opt.n = 8;
opt.R_1 = 0;
opt.R_m = 2;
opt.Smax_1 = 0;
opt.Smax_n = 15;
opt.show = false;
opt.constr.thresh = false;
opt.constr.uptime = true;
opt.constr.uptimeval = 0.95;

%multiple optimization parameters
opt.mult = false;
opt.tuning_array = [1 .99 .98 .97 .96 .95 .925 .9 .85 .8];
opt.tuned_parameter = 'utv';

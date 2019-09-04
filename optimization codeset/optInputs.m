%DIMENSIONS
loc = 'cosPioneer';
pm = 3; %power module
c = 1;  %use case
opt.locations = {'argBasin';'souOcean';'cosPioneer';'cosEndurance'};
opt.powermodules = {'wind';'inso';'wave'};
opt.usecases = {'short term';'long term';'infrastructure'};

%ECONOMIC
%polynomial fits
econ.batt_n = 1;                    %[~]
econ.wind_n = 1;                    %[~]
%maintenance costs
econ.wind.maintenance = 37;         %[$/(kW*visit)] (O&P, 2017 + dwr)
econ.inso.maintenance = 41;         %[$/(kW*year)] (FEMP, NREL 2013)
%installed costs
econ.wind.installed = 10117;        %[$/kW]
econ.inso.installation = 270;       %[$/kW]
econ.wind.mim = 137/49;             %marine installment multiplier (CoWR)
%marinization
econ.wind.marinization = 1.8;       %[~]
econ.inso.marinization = 1.2;        %[~]
%vessel info
econ.wind.vessel.cost = 20000;      %[$/day]
econ.inso.vessel.cost = 20000;      %[$/day]
econ.wind.vessel.speed = 12;        %[kts]
econ.inso.vessel.speed = 12;        %[kts]
%foundation/substructure costs
econ.wind.foundsub.sf = .8;         %scaling factor
econ.wind.foundsub.cost = 1653;     %[$/kW]
%platform costs
econ.platform.wf = 1.2;             %weight factor (on light ship)
econ.platform.steel = 600;          %[$/metric ton]
%solar costs
econ.inso.module = 470;             %[$/kW]
econ.inso.installation = 270;       %[$/kW]
econ.inso.electrical = 210;         %[$/kW]
%battery costs
econ.batt.encl.sf = .9997;                          %scaling factor
econ.batt.encl.scale = 10*.3278*.1713*.2355;        %[m^3], WAMP
econ.batt.encl.cost = 5000/econ.batt.encl.scale;    %[$/m^3]
%wave costs
econ.wave.scen = 1;                 %scenario indicator
econ.wave.scenarios = 3;            %number of scenarios

%DEVICE
%wind parameters
turb.uci = 3;               %[m/s] guess
turb.ura = 11;              %[m/s] awea
turb.uco = 30;              %[m/s] guess
turb.eta = 0.35;            %[~] guess
turb.clearance = 4;         %[m] surface to bottom of swept area clearance
%solar parameters
inso.rated = 1;             %[kW/m^2] from Brian
inso.eff = 0.18;            %[~] from Devin (may trail off when off of MPP)
inso.deg = 0.005;           %[%/year]
inso.pvci = 24;             %[months] cleaning interval
inso.wf = 60;               %[kg/m^2] weight factor
%battery parameters
batt.V = 12;                %[V] Voltage
batt.ed = 0.1;              %[Ah/in^3] energy density
batt.wf = 1.5;              %[Ah/lb] weight factor
batt.lc = 18;               %[months] life cycle under deep cycling
batt.sdr = 2;               %[%/month] self discharge rate
batt.dyn_lc = true;         %toggle dynamic life cycle
%wave energy parameters
wave.w = 15;                %width of gaussian power matrix
wave.eta_ct = 0.6;          %[~] wec efficiency
wave.kW_gf = 0.5;           %resource % reduction for coarse grid

%atmospheric parameters
atmo.rho = 1.225;           %[kg/m^3] density
atmo.h = 4;                 %[m]
atmo.zo = 0.02;             %[mm]
atmo.dyn_h = true;          %toggle dynamic hub height
atmo.soil = 0.25;           %[%/year]
atmo.clean = 0.5;           %heavy rain cleans X amt of soil

%USE CASES
%short term instrumentation
uc(1).draw = 200;               %[W] - secondary node
uc(1).lifetime = 5;             %[y]
uc(1).SI = 6;                   %[months] service interval
uc(1).uptime = .99;             %[%] uptime
uc(1).ship.cost = 40000;        %[$/day] for vessel
uc(1).turb.iv = 0;              %turbine interventions
%long term instrumentation
uc(2).draw = 200;               %[W] - secondary node
uc(2).lifetime = 5;             %[y]
uc(2).SI = 12*uc(2).lifetime;   %[months] service interval
uc(2).uptime = .99;              %[%] uptime
uc(2).turb.iv = 2;              %turbine interventions
%infrastructure
uc(3).draw = 8000;              %[W] - secondary node
uc(3).lifetime = 25;            %[y]
uc(3).SI = 12*uc(3).lifetime;   %[months] service interval
uc(3).uptime = .99;             %[%] uptime
uc(3).uptime_window = 30;       %[d]
uc(3).turb.iv = 5;              %turbine interventions

%multiple optimizations
opt.alldim = 0;
opt.sens = 0;
opt.wavescen = 1;
%opt.tuning_array = [1 .99 .97 .95 .925 .9 .85 .8];
%opt.tuned_parameter = 'utp';
opt.tuning_array = [50:50:600];
opt.tuned_parameter = 'load';
% opt.tuning_array = [0.01,0.2,.5];
% opt.tuned_parameter = 'zo';
% opt.tuning_array = [0,1,2,3,4,5];
% opt.tuned_parameter = 'utf';

%optimization parameters
opt.nm.m = 8; %input grid resolution for rated power
opt.nm.n = 8; %input grid resolution for storage
opt.nm.battgriddur = 7; %[d]
opt.nm.many = true; %seed many initial points into nelder
opt.nm.bgd_array = [5,9,10,14,22]; %[d]
opt.nm.show = false; %show 
opt.nm.initminlim = .5; %percentage of grid to wipe out
opt.nm.tolfun = 10; %nelder mead output tolerance
opt.nm.tolx = 1; %nelder mead input tolerance
opt.cliff.srv_wind = ... %search ratio values for wind
[2    1    1    1     1    1    1    1    1    1    1; ...
 1    2    5    10    20   35   50   100  150  500  1000];
opt.cliff.tol = 0.001; %tolerance
opt.cliff.mult = 10; %multiplier
opt.cliff.dmult = 5; %change in multiplier
opt.cliff.stot = 1000; %total shots
opt.cliff.show = true; %show cliff after running
opt.cliff.mfe = 10000; %max function evals
opt.cliff.mi = 10000; %max iterations
opt.v2 = false;
opt.fmindebug = 0;
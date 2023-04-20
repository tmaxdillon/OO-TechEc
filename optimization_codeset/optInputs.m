%simulation settings
%interactive job
econ.wave.scen = 1; %scenario indicator 1:C, 2:OC, 3:OD
econ.inso.scen = 1; %scenario indicator 1:AU, 2:HU
econ.wind.scen = 2; %scenario indicator 1:OD, 2:C
opt.bf.m = 500;
opt.bf.n = 500;
opt.allscenuses = 0;
opt.alllocuses = 0;
opt.sens = 0;
opt.tdsens = 0;
opt.senssm = 0;
opt.highresobj = 0;
pm = 2; %power module, 1:Wi 2:In 3:Wa 4:Di
c = 2;  %use case 1:ST 2:LT
loc = 'cosEndurance_wa'; %location
%batch = false;
if ~exist('batchtype','var')
    batchtype = [];
    batchscen = [];
    batchloc = [];
    batchc = [];
end
if isequal(batchtype,'ssm')
    econ.wave.scen = batchscen;
    econ.inso.scen = batchscen;
    econ.wind.scen = batchscen;
    opt.bf.m = 500;
    opt.bf.n = 500;
    opt.allscenuses = 0;
    opt.alllocuses = 0;
    opt.sens = 0;
    opt.tdsens = 0;
    opt.senssm = 1;
    opt.highresobj = 0;
    pm = batchpm;
    c = batchc;
    loc = batchloc;
    %batch = true;
elseif isequal(batchtype,'alllocuses')
    econ.wave.scen = batchscen; 
    econ.inso.scen = batchscen;
    econ.wind.scen = batchscen;
    opt.bf.m = 500;
    opt.bf.n = 500;
    opt.allscenuses = 0;
    opt.alllocuses = 1;
    opt.sens = 0;
    opt.tdsens = 0;
    opt.senssm = 0;
    opt.highresobj = 0;
    pm = batchpm;
    c = [];
    loc = [];
    %batch = true;
elseif isequal(batchtype,'hros')
    econ.wave.scen = 1; %scenario indicator 1:C,2:OC,3:OD
    opt.bf.m = 750;
    opt.bf.n = 750;
    opt.allscenuses = 0;
    opt.alllocuses = 1;
    opt.sens = 0;
    opt.tdsens = 0;
    opt.senssm = 0;
    opt.highresobj = 1;
    pm = 3;
    c = batchc;
    loc = batchloc;
    %batch = true;
elseif isequal(batchtype,'sens')
    opt.tuning_array = linspace(0,2.25,10);
    opt.tuned_parameter = 'wiv';
    econ.wave.scen = batchscen; 
    opt.bf.m = 100;
    opt.bf.n = 100;
    opt.allscenuses = 0;
    opt.alllocuses = 0;
    opt.sens = 1;
    opt.tdsens = 0;
    opt.senssm = 0;
    opt.highresobj = 0;
    pm = 3;
    c = batchc;
    loc = batchloc;
    %batch = true;
end

%check to see if HPC
if feature('numcores') < 36
    opt.bf.n = 2;
    opt.bf.m = 2;
end
opt.wsc = 10; %number of work station cores (wss)

%strings
opt.locations = {'argBasin';'cosEndurance_wa'; ...
    'cosPioneer';'irmSea';'souOcean'};
opt.powermodules = {'wind';'inso';'wave';'dies'};
opt.usecases = {'short term';'long term'};
opt.wavescens = {'Conservative';'Optimistic Cost';'Optimistic Durability'};
if pm == 1
    opt.scens = {'optimistic durability','conservative'};
elseif pm == 2
    opt.scens = {'automated','human'};
elseif pm == 3
    opt.scens = opt.wavescens;
elseif pm == 4
    opt.scens = {'default'};
end

%ECONOMIC
%polynomial fits
econ.batt_n = 1;                    %[~]
econ.wind_n = 1;                    %[~]
econ.diescost_n = 1;                %[~]
econ.diesmass_n = 1;                %[~]   
econ.diessize_n = 1;                %[~]   
econ.diesburn_n = 1;                %[~]   
%platform 
% load('mdd_output.mat') - old (paper 1) mooring model
% econ.platform.mdd.cost = cost;          %mooring cost lookup matrix
% econ.platform.mdd.depth = depth;        %mooring cost lookup depth
% econ.platform.mdd.diameter = diameter;  %mooring cost lookup diameter
% clear cost depth diameter e_subsurface e_tension w_tension
if pm == 2 || pm == 4 %solar or diesel
    load('mdd_output_inso.mat')
    econ.platform.inso.cost = cost;
    econ.platform.inso.depth = depth;
    econ.platform.inso.diameter = diameter;
    econ.platform.inso.boundary = 1; %1: multi-mooring, 2: 8m diameter limit
    econ.platform.inso.boundary_di = 12; %[m] for multi-mooring
    econ.platform.inso.boundary_mf = 3; %multi line factor
elseif pm == 3 %wave
    load('mdd_output_wave.mat')
    econ.platform.wave.cost = cost;
    econ.platform.wave.depth = depth;
    econ.platform.wave.diameter = diameter;
elseif pm == 1 %wind
    load('mdd_output_wind.mat')
    econ.platform.wind.cost = cost;
    econ.platform.wind.depth = depth;
    econ.platform.wind.diameter = diameter;
end
clear cost depth diameter
econ.platform.wf = 5;               %weight factor (of light ship)
econ.platform.steel = 2000;          %[$/metric ton], steelbenchmarker
econ.platform.t_i = [6 12];         %[h] added h for inst
econ.platform.d_i = [500 5000];     %[m] depth for inst cost
%econ.platform.moorcost = 5.23;      %[$/(m-m)] cost of mooring (no AR)
% econ.platform.anchor = 1666.7;      %[$/m] anchor cost
% econ.platform.anchor_min = 1000;    %minimum anchor cost
% econ.platform.line = 4.83;          %[$/(m-m)] cost of line (no AR)
% econ.platform.bm = 1.5;             %barge multiplier
% econ.platform.S = 1.6;              %mooring scope
% econ.platform.fiber = 0.48;         %[$/(m*MT)] fiber cost
% econ.platform.anchor = 1200;        %[$/MT]
% econ.platform.Tp_ex = 25;        %extreme Tp
% econ.platform.k_ext = ...           %extreme wavenumber
%     (4*pi^2)/(9.81*econ.platform.Tp_ex^2);
% econ.platform.Cd = 1.2;             %coefficient of drag
%vessel
econ.vessel.osvcost = 15000*1.15;        %[$/day] 2020->2022
econ.vessel.speed = 10;             %[kts]
econ.vessel.t_mosv = 6;             %[h] time on site for maint (osv)
econ.vessel.speccost = 50000*1.15;       %[$/day] 2020->2022
econ.vessel.t_ms = 2;               %[h] time on site for maint (spec)
%battery 
% econ.batt.encl.sf = .5;             %scaling factor
% econ.batt.encl.cost = 5000;         %[$], WAMP
% econ.batt.encl.cap = 10;            %[kWh]
econ.batt.enclmult = 1;             %multiplier on battery cost for encl
%wind
%econ.wind.installed = 10117;        %[$/kW] installed cost (DWR, 2017)
econ.wind.installed = 5120;         %[$/kW] installed cost (DWR, 2022)
econ.wind.tcm = 1;                  %turbine cost multiplier (sens var)
%econ.wind.mim = 137/49;             %marine installment multiplier (CoWR)
econ.wind.marinization = 1.8;       %[CoWR]
econ.wind.lowfail = 0;              %failures per year (optimistic)
econ.wind.highfail = 1;              %failure per year (conservative)
%solar
econ.inso.module = 480;             %[$/kW], all SCB, Q12022
econ.inso.installation = 160;       %[$/kW]
econ.inso.electrical = 310;         %[$/kW]
econ.inso.structural = 90;         %[$/kW]
econ.inso.marinization = 1.2;       %[~]
econ.inso.pcm = 1;                  %cost multiplier (sens var)
%wave costs
econ.wave.scenarios = 3;            %number of scenarios
econ.wave.costmult_con = 10;         %conservative cost multiplier
econ.wave.costmult_opt = 4;         %optimistic cost multiplier
econ.wave.lowfail = 0;              %failures per year (optimistic)
econ.wave.highfail = 1;              %failure per year (conservative)
%diesel costs
econ.dies.fcost = 1.4;              %[$/L] diesel fuel cost
econ.dies.enclcost = 5000*1.19;     %[$], 2018->2022
econ.dies.enclcap = 1.5;            %[m^3]
econ.dies.autostart = 3000*1.15;    %[$], 2020->2022
econ.dies.fail = .2;                %failures per year
econ.dies.gcm = 1;                  %generator cost multiplier (sens var)

%ENERGY
%wind parameters
turb.uci = 3;               %[m/s] guess
turb.ura = 11;              %[m/s] awea
turb.uco = 30;              %[m/s] guess
turb.eta = 0.35;            %[~] guess
turb.clearance = 4;         %[m] surface to bottom of swept area clearance
turb.wf = 15;               %[kg/kW]
%turb.nu = 0.26;
% turb.spar_t = 0.04;         %[m] spar thickness
% turb.spar_ar = 6;           %aspect ratio 
% turb.spar_bm = 10;           %buoyancy multiplier
%solar parameters
inso.rated = 1;             %[kW/m^2] from Brian
inso.eff = 0.18;            %[~] from Devin (may trail off when off of MPP)
inso.deg = 0.5;             %[%/year]
%inso.pvci = 24;             %[months] cleaning interval
inso.wf = 30;               %[kg/m^2] weight factor
inso.debug = false;          %toggle debugging kW/kWh combo for shooter
inso.shootdebug = false;    %toggle debugging pvci shooter
inso.shoottol = 5;          %months
%inso.ct_eval = false;       %evaluate/compare trips for cleaning
inso.cleanstrat = 4;        %panel cleaning strategy 1:NC, 2:CT, 3:CTW
inso.cleanlim = 20;         %[mo] maximum limit for cleaning
%inso.nu = 1.01;             %[m/kW]
%wave energy parameters
wave.method = 2;            %1: divide by B, 2: 3d interpolation
wave.B_func_n = 1000;       %number of points in B(Gr) function
wave.Hs_ra = 4;             %[m], rated wave height
wave.Tp_ra = 9;            %[s], rated peak period
wave.eta_ct = 0.6;          %[~] wec efficiency
wave.house = 0.10;          %percent of rated power as house load
wave.kW_max = 17;           %[kW] maximum limit for wec-sim output
% wave.wsr = 'struct3m_opt';  %wec sim run
% wave.wsHs = 3;              %[m] wec sim Hs
%diesel parameters
dies.fmax = 800;            %[liters] fuel capacity
dies.ftmax = 18;            %[m] fuel can sit idle before going "bad"
%dies.lph = 2;               %[l/h]
dies.oilint = 250;          %[hours] maintenance interval
dies.genon = 0.1;           %battery level generator turns on at
dies.kWmax = 15;            %maximum power generation
dies.kWmin = 1;             %minimum power generation
dies.bm = 4;                %barge multiplier
% %AGM parameters
% agm.V = 12;                %[V] Voltage
% agm.se = 3.3;              %[Ah/kg] specific energy factor
% agm.lc_nom = 18;           %[months] nominal life cycle
% agm.beta = 6/10;           %decay exponential for life cycle
% agm.lc_max = 12*5;        %maximum months of operation
% agm.sdr = 5;               %[%/month] self discharge rate
% %agm.dyn_lc = true;         %toggle dynamic life cycle
% agm.dmax = .2;             %maximum depth of discharge
%LFP parameters
lfp.V = 12;                 %[V] Voltage
lfp.se = 8.75;              %[Ah/kg] specific energy factor
lfp.lc_nom = 18;            %[months] nominal life cycle
lfp.beta = 1;               %decay exponential for life cycle
lfp.lc_max = 12*5;          %maximum months of operation
lfp.sdr = 3;                %[%/month] self discharge rate
%lfp.dyn_lc = true;         %toggle dynamic life cycle
lfp.dmax = 0;              %maximum depth of discharge
%lfp.cost = 580;             %[$/kWh]
lfp.cost = 466;             %[$/kWh] - irena2020electricty
lfp.lcm = 1;%battery life cycle model, 1:bolun 2:dyn_lc 3:fixed_lc
lfp.T = 15;                 %[C] temperature
%lfp.EoL = 0.2;              %battery end of life
lfp.EoL = 0.02;              %battery end of life
lfp.rf_os = true;           %toggle using open source rainflow
lfp.bdi = 2190;              %battery degradation evaluation interaval
bc = 2; %battery chemistry 1:AGM 2:LFP
if bc == 1 %agm chemistry
    batt = agm;
elseif bc == 2 %lfp chemistry
    batt = lfp;
end

%atmospheric parameters
atmo.rho_a = 1.225;         %[kg/m^3] density of air
atmo.rho_w = 1025;          %[kg/m^3] density of water
atmo.g = 9.81;              %[m/s^2]
%atmo.h = 4;                 %[m]
atmo.zo = 0.02;             %[mm]
atmo.dyn_h = true;          %toggle dynamic hub height
atmo.soil = 35;             %[%/year]
%atmo.clean = 0.5;           %heavy rain cleans X amt of soil

%USE CASES
%short term instrumentation
uc(1).draw = 200;               %[W] - secondary node
uc(1).lifetime = 5;             %[y]
uc(1).SI = 6;                   %[months] service interval
uc(1).uptime = .99;             %[%] uptime
% uc(1).turb.lambda = 4;          %turbine interventions
% uc(1).dies.lambda = 1;          %diesel interventions
%long term instrumentation
uc(2).draw = 200;               %[W] - secondary node
uc(2).lifetime = 5;             %[y]
uc(2).SI = 12*uc(2).lifetime;   %[months] service interval
uc(2).uptime = .99;             %[%] uptime
% uc(2).turb.lambda = 4;          %turbine interventions
% uc(2).dies.lambda = 1;          %diesel interventions
%infrastructure
% uc(3).draw = 8000;              %[W] - secondary node
% uc(3).lifetime = 25;            %[y]
% uc(3).SI = 12*uc(3).lifetime;   %[months] service interval
% uc(3).uptime = .99;             %[%] uptime
% uc(3).turb.lambda = 20;         %turbine interventions
% uc(3).dies.lambda = 5;          %diesel interventions

%sensitivity analaysis
if ~isfield(opt,'tuning_array') && ~isfield(opt,'tuned_parameter')
% opt.tuning_array = [100 95 90 85 80 75 70];
% opt.tuned_parameter = 'wcp'; %wave cutout percentile
% opt.tuning_array = [1 2 3 4 5 6 7 8 9 10];
% opt.tuned_parameter = 'wcm'; %wave cost multiplier
% opt.tuning_array = [45 50 55 60 65 70 75 80 85 90];
% opt.tuned_parameter = 'wrp'; %wave rated percentile
% opt.tuning_array = linspace(.80,1,10);
% opt.tuned_parameter = 'utp';
% opt.tuning_array = [10:10:200];
% opt.tuned_parameter = 'load';
% opt.tuning_array = [0.01,0.2,.5];
% opt.tuned_parameter = 'zo';
% opt.tuning_array = [0,1,2,3,4,5];
% opt.tuned_parameter = 'utf';
% opt.tuning_array = [0 .01 .025 .05 .075 .1 .15 .2 .25];
% opt.tuned_parameter = 'whl'; %wec house load
% opt.tuning_array = [1 1.2 1.4 1.6 1.8 2];
% opt.tuned_parameter = 'imf'; %inso marinization factor
% opt.tuning_array = linspace(0.1,10,10);
% opt.tuned_parameter = 'btm'; %battery time slope
% opt.tuning_array = [10 20 30 40 50 60 70 80 90 100];
% opt.tuned_parameter = 'mbt'; %minimum battery for time added
% opt.tuning_array = linspace(1/2,2,10);
% opt.tuned_parameter = 'cwm'; %capture width multiplier
% opt.tuning_array = 1:1:10;
% opt.tuned_parameter = 'wcm'; %wave cost multiplier
% opt.tuning_array = linspace(0,9,50);
% opt.tuned_parameter = 'wiv'; %wec interventions
% opt.tuning_array = linspace(1/2,2,10);
% opt.tuned_parameter = 'dep'; %depth modifier
% opt.tuning_array = linspace(uc(c).lifetime-3,uc(c).lifetime+3,10);
% opt.tuned_parameter = 'lft'; %lifetime
    opt.tuning_array = linspace(10,1400,10)*1000;
    opt.tuned_parameter = 'dtc'; %distance to coast [OPEX]
end

%opt 2D sens
% opt.tdsens_ta(1,:) = 0.1:0.04:1.7;
% opt.tdsens_ta(2,:) = 40:2:120;
% opt.tdsens_tp{1} = 'btm'; %battery time slope
% opt.tdsens_tp{2} = 'mbt'; %minimum battery for time added
opt.tdsens_ta(1,:) = 2:1:7;
opt.tdsens_ta(2,:) = 6:1:11;
opt.tdsens_tp{1} = 'hra'; %rated Hs
opt.tdsens_tp{2} = 'tra'; %rated Tp

%optimization parameters
opt.V = 2;
opt.bf.M = 8; %[kW] max kW in grid
opt.bf.N = 500; %[kWh] max Smax in grid
opt.bf.M_hros = [2 4 5 1 1.75]; %[kW], high res os
opt.bf.N_hros = [350 500 500 300 350]; %[kWh], high res os
%opt.bf.maxworkers = 36; %maximum cores
% opt.nm.m = 5; %input grid resolution for rated power
% opt.nm.n = 5; %input grid resolution for storage
% opt.nm.many = false; %seed many initial points into nelder
% opt.nm.battgriddur = 80; %[d]
% opt.nm.ratedpowermultiplier = 120;
% opt.nm.bgd_array = [1,5,20,50,100]; %[d]
% opt.nm.rpm_array = [20,40,60,100,120]; %multiplier, solar only
% opt.nm.show = false; %show 
% opt.nm.initminlim = .5; %percentage of grid to wipe out
% opt.nm.tolfun = 100; %nelder mead output tolerance
% opt.nm.tolx = 10; %nelder mead input tolerance
% opt.nm.fmindebug = 0;
% opt.cliff.srv_wind = ... %search ratio values for wind
% [2    1    1    1     1    1    1    1    1    1    1; ...
%  1    2    5    10    20   35   50   100  150  500  1000];
% opt.cliff.tol = 0.001; %tolerance
% opt.cliff.mult = 10; %multiplier
% opt.cliff.dmult = 5; %change in multiplier
% opt.cliff.stot = 1000; %total shots
% opt.cliff.show = true; %show cliff after running
% opt.cliff.mfe = 10000; %max function evals
% opt.cliff.mi = 10000; %max iterations
%settings
opt.alllocuses = 0;
opt.sens = 0;
opt.tdsens = 0;
opt.ninepanel = 0;
pm = 3; %power module
bc = 2; %battery chemistry
c = 2;  %use case
loc = 'souOcean'; %location

%strings
opt.locations = {'argBasin';'cosEndurance_or';'cosEndurance_wa'; ...
    'cosPioneer';'irmSea';'souOcean'};
opt.powermodules = {'wind';'inso';'wave';'dies'};
opt.usecases = {'short term';'long term'};
opt.wavescens = {'Conservative';'Optimistic Cost';'Optimistic Durability'};

%ECONOMIC
%polynomial fits
econ.batt_n = 1;                    %[~]
econ.wind_n = 1;                    %[~]
econ.diescost_n = 1;                %[~]
econ.diesmass_n = 1;                %[~]   
econ.diessize_n = 1;                %[~]   
econ.diesburn_n = 1;                %[~]   
%platform 
load('mdd_output.mat')
econ.platform.mdd.cost = cost;          %mooring cost lookup matrix
econ.platform.mdd.depth = depth;        %mooring cost lookup depth
econ.platform.mdd.diameter = diameter;  %mooring cost lookup diameter
clear cost depth diameter e_subsurface e_tension w_tension
econ.platform.wf = 5;               %weight factor (of light ship)
econ.platform.steel = 600;          %[$/metric ton]
econ.platform.t_i = 12;             %[h] additional time on site for inst
%econ.platform.moorcost = 5.23;      %[$/(m-m)] cost of mooring (no AR)
econ.platform.anchor = 1666.7;      %[$/m] anchor cost
econ.platform.anchor_min = 1000;    %minimum anchor cost
econ.platform.line = 4.83;          %[$/(m-m)] cost of line (no AR)
econ.platform.bm = 1.5;             %barge multiplier
% econ.platform.S = 1.6;              %mooring scope
% econ.platform.fiber = 0.48;         %[$/(m*MT)] fiber cost
% econ.platform.anchor = 1200;        %[$/MT]
% econ.platform.Tp_ex = 25;        %extreme Tp
% econ.platform.k_ext = ...           %extreme wavenumber
%     (4*pi^2)/(9.81*econ.platform.Tp_ex^2);
% econ.platform.Cd = 1.2;             %coefficient of drag
%vessel
econ.vessel.osvcost = 15000;        %[$/day]
econ.vessel.speed = 10;             %[kts]
econ.vessel.t_mosv = 6;             %[h] time on site for maint (osv)
econ.vessel.speccost = 70000;       %[$/day] 
econ.vessel.t_ms = 1;               %[h] time on site for maint (spec)
%battery 
% econ.batt.encl.sf = .5;             %scaling factor
% econ.batt.encl.cost = 5000;         %[$], WAMP
% econ.batt.encl.cap = 10;            %[kWh]
econ.batt.enclmult = 2;             %multiplier on battery cost for encl
%wind
econ.wind.installed = 10117;        %[$/kW] installed cost (DWR)
%econ.wind.mim = 137/49;             %marine installment multiplier (CoWR)
econ.wind.marinization = 1.8;       %[CoWR]
%solar
econ.inso.module = 470;             %[$/kW], all SCB
econ.inso.installation = 270;       %[$/kW]
econ.inso.electrical = 210;         %[$/kW]
econ.inso.structural = 100;         %[$/kW]
econ.inso.marinization = 1.2;       %[~]
%wave costs
econ.wave.scen = 1;                 %scenario indicator 1:C,2:OC,3:OD
econ.wave.scenarios = 3;            %number of scenarios
econ.wave.costmult_con = 10;         %conservative cost multiplier
econ.wave.costmult_opt = 4;         %optimistic cost multiplier
econ.wave.lowfail = 0;              %optimistic failures
econ.wave.highfail = 4;              %conservative failures
%diesel costs
econ.dies.fcost = .83;              %[$/L] diesel fuel cost
econ.dies.enclcost = 5000;          %[$]
econ.dies.enclcap = 1.5;            %[m^3]
econ.dies.autostart = 3000;         %[$]

%ENERGY
%wind parameters
turb.uci = 3;               %[m/s] guess
turb.ura = 11;              %[m/s] awea
turb.uco = 30;              %[m/s] guess
turb.eta = 0.35;            %[~] guess
turb.clearance = 4;         %[m] surface to bottom of swept area clearance
turb.wf = 70;               %[kg/kW]
%turb.nu = 0.26;
turb.spar_t = 0.04;         %[m] spar thickness
turb.spar_ar = 4;           %aspect ratio 
turb.spar_bm = 4;           %buoyancy multiplier
%solar parameters
inso.rated = 1;             %[kW/m^2] from Brian
inso.eff = 0.18;            %[~] from Devin (may trail off when off of MPP)
inso.deg = 0.5;             %[%/year]
%inso.pvci = 24;             %[months] cleaning interval
inso.wf = 60;               %[kg/m^2] weight factor
inso.shootdebug = false;    %toggle debugging pvci shooter
%inso.ct_eval = false;       %evaluate/compare trips for cleaning
inso.cleanstrat = 1;        %panel cleaning strategy 1:NC, 2:CT, 3:CTW
%inso.nu = 1.01;             %[m/kW]
%wave energy parameters
wave.wsr = 'struct3m_opt';  %wec sim run
wave.wsHs = 3;              %[m] wec sim Hs
wave.Hs_ra = 3;             %[m], rated wave height
wave.Tp_ra = 10;            %[s], rated peak period
%wave.w = 60;                %width of gaussian power matrix in Hs
wave.eta_ct = 0.6;          %[~] wec efficiency
%wave.kW_gf = 0.5;           %resource % reduction for coarse grid
%wave.tp_N = 1000;           %discretization for Tp skewed gaussian fit
%wave.tp_res = 0.2;          %multiplier on median tp for resonance
%wave.tp_rated = 1;          %multiplier on median tp for rated power
%wave.hs_res = 1;            %multiplier on median hs for resonance
%wave.hs_rated = 1.2;          %multiplier on median hs for rated power
%wave.med_prob = 0.01;        %median probability for skewed gaussian
%wave.cutout = 15;           %wavepower X times ratedpower initiates cutout
wave.house = 0.10;          %percent of rated power as house load
%wave.enf_wave_med = false;  %enforce median sea state
%wave.nu = 1.21;             %[m/kW]
%diesel parameters
dies.fmax = 800;            %[liters] fuel capacity
dies.ftmax = 18;            %[m] fuel can sit idle before going "bad"
%dies.lph = 2;               %[l/h]
dies.oilint = 250;          %[hours] maintenance interval
dies.genon = 0.3;           %battery level generator turns on at
dies.kWmax = 20;            %maximum power generation
dies.kWmin = 1;             %minimum power generation
dies.bm = 2.5;                %barge multiplier
%AGM parameters
agm.V = 12;                %[V] Voltage
agm.se = 3.3;              %[Ah/kg] specific energy factor
agm.lc_nom = 18;           %[months] nominal life cycle
agm.beta = 6/10;           %decay exponential for life cycle
agm.lc_max = 12*10;        %maximum months of operation
agm.sdr = 5;               %[%/month] self discharge rate
agm.dyn_lc = true;         %toggle dynamic life cycle
agm.dmax = .2;             %maximum depth of discharge
agm.t_add_m = 0;           %hours added per kWh of battery
agm.t_add_min = inf;        %minimum battery size adding time
%LFP parameters
lfp.V = 12;                %[V] Voltage
lfp.se = 8.75;              %[Ah/kg] specific energy factor
lfp.lc_nom = 18;           %[months] nominal life cycle
lfp.beta = 6/10;           %decay exponential for life cycle
lfp.lc_max = 12*10;        %maximum months of operation
lfp.sdr = 3;               %[%/month] self discharge rate
lfp.dyn_lc = true;         %toggle dynamic life cycle
lfp.dmax = .0;             %maximum depth of discharge
lfp.t_add_m = 0;           %hours added per kWh of battery
lfp.t_add_min = inf;        %minimum battery size adding time
lfp.cost = 580;            %[$/kWh]
if bc == 1 %agm chemistry
    batt = agm;
elseif bc == 2 %lfp chemistry
    batt = lfp;
end

%atmospheric parameters
atmo.rho_a = 1.225;         %[kg/m^3] density of air
atmo.rho_w = 1020;          %[kg/m^3] density of water
atmo.g = 9.81;              %[m/s^2]
atmo.h = 4;                 %[m]
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
uc(1).turb.lambda = 4;          %turbine interventions
uc(1).dies.lambda = 1;          %diesel interventions
%long term instrumentation
uc(2).draw = 200;               %[W] - secondary node
uc(2).lifetime = 5;             %[y]
uc(2).SI = 12*uc(2).lifetime;   %[months] service interval
uc(2).uptime = .99;             %[%] uptime
uc(2).turb.lambda = 4;          %turbine interventions
uc(2).dies.lambda = 1;          %diesel interventions
%infrastructure
% uc(3).draw = 8000;              %[W] - secondary node
% uc(3).lifetime = 25;            %[y]
% uc(3).SI = 12*uc(3).lifetime;   %[months] service interval
% uc(3).uptime = .99;             %[%] uptime
% uc(3).turb.lambda = 20;         %turbine interventions
% uc(3).dies.lambda = 5;          %diesel interventions

%sensitivity analaysis
% opt.tuning_array = [100 95 90 85 80 75 70];
% opt.tuned_parameter = 'wcp'; %wave cutout percentile
% opt.tuning_array = [1 2 3 4 5 6 7 8 9 10];
% opt.tuned_parameter = 'wcm'; %wave cost multiplier
% opt.tuning_array = [45 50 55 60 65 70 75 80 85 90];
% opt.tuned_parameter = 'wrp'; %wave rated percentile
opt.tuning_array = linspace(.80,1,10);
opt.tuned_parameter = 'utp';
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

%opt 2D sens
opt.tdsens_ta(1,:) = 0.1:0.04:1.7;
opt.tdsens_ta(2,:) = 40:2:120;
opt.tdsens_tp{1} = 'btm'; %battery time slope
opt.tdsens_tp{2} = 'mbt'; %minimum battery for time added

%optimization parameters
opt.V = 2;
opt.nm.m = 5; %input grid resolution for rated power
opt.nm.n = 5; %input grid resolution for storage
opt.nm.many = false; %seed many initial points into nelder
opt.nm.battgriddur = 80; %[d]
opt.nm.ratedpowermultiplier = 120;
opt.nm.bgd_array = [1,5,20,50,100]; %[d]
opt.nm.rpm_array = [20,40,60,100,120]; %multiplier, solar only
opt.nm.show = false; %show 
opt.nm.initminlim = .5; %percentage of grid to wipe out
opt.nm.tolfun = 100; %nelder mead output tolerance
opt.nm.tolx = 10; %nelder mead input tolerance
opt.nm.fmindebug = 0;
opt.bf.m = 60;
opt.bf.n = 60;
opt.bf.M = 4; %[kW] max kW in grid
opt.bf.N = 250; %[kWh] max Smax in grid
opt.bf.maxworkers = 36; %maximum cores
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
%created by Trent Dillon on January 15th 2018

clear all, close all, clc

%% top do

% 2 - fix issue of surface being faster than no surface (improve speed)
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
load = 200;                 %[W] - secondary node

%optimization parameters
opt.m = 8;
opt.n = 8;
opt.R_1 = 0;
opt.R_m = 2;
opt.Smax_1 = 0;
opt.Smax_n = 15;
opt.save = false;
opt.mult = false;
opt.show = false;
opt.constr.thresh = false;
opt.constr.uptime = true;
opt.constr.uptimeval = 0.95;

%% run optimization

tTot = tic;
if opt.mult
    opt.tuning_array = [1 .99 .98 .97 .96 .95 .925 .9 .85 .8];
    opt.S = length(opt.tuning_array);
    opt.tuned_parameter = 'utv';
    %initialize outputs
    clear multStruct
    multStruct(opt.S) = struct();
    for i = 1:opt.S
        opt.s = i;
        %%%%%%%%%%%% TUNED PARAMETER UPDATE %%%%%%%%%%%%%%%%
        %opt.m = sqrt(opt.tuning_array(i));
        %opt.n = opt.m;
        opt.constr.uptimeval = opt.tuning_array(i);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [output,opt] = optWind(opt,data,atmo,batt,econ,load,turb,tTot);
        multStruct(i).output = output;
        multStruct(i).opt = opt;
        multStruct(i).data = data;
        multStruct(i).atmo = atmo;
        multStruct(i).batt = batt;
        multStruct(i).econ = econ;
        multStruct(i).load = load;
        multStruct(i).turb = turb;
    end
    clear i
    disp([num2str(opt.s) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
else
    [output,opt] = optWind(opt,data,atmo,batt,econ,load,turb,tTot);
end

%% save and visualize MDP outputs

if opt.mult && isequal(opt.tuned_parameter,'utv')
    name = ['multOpt_utv' num2str(opt.S)];
    stru.(name) = multStruct;
    save([name '.mat'],'-struct','stru','-v7.3');
    visBattConstr(stru.(name))
else
    name = 'optStruct_';
    stru.(name).atmo = atmo;
    stru.(name).batt = batt;
    stru.(name).data = data;
    stru.(name).econ = econ;
    stru.(name).load = load;
    stru.(name).opt = opt;
    stru.(name).output = output;
    stru.(name).turb = turb;
    save([name '.mat'],'-struct','stru','-v7.3')
    visWindOpt(stru.(name))
    visWindSim(stru.(name))
end

%% visualize optimization

visWindOpt(opt,output,data,atmo,batt,econ,load,turb);

%% visualize sim

visWindSim(output,data,atmo,batt,econ,load,turb);






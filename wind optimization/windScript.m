%created by Trent Dillon on January 15th 2018

clear all, close all, clc

%% top do

% 1 - adapt visWindSim() to work with data cursor from visWindOpt
% 1 - fix issue of surface being faster than no surface (improve speed)
% 2 - move dist from coast to a variable inside the structure

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
econ.Scost = 275;                   %[$/kWh storage] lifeline GPL-L16T-2V (2.38 kWh)
econ.OpEx.p1 = [160934, 0.02];      %[m offshore, percent of CapEx]
econ.OpEx.p2 = [1.609e6, 0.1];      %[m offshore, percent of CapEx]

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
opt.m = 8;
opt.n = 8;
opt.R_1 = 0;
opt.R_m = 4;
opt.Smax_1 = 0;
opt.Smax_n = 40;
opt.save = false;
opt.surf = true;
opt.mult = false;
opt.show = false;

%% implement nelder mead fminsearch optimization

if opt.mult
    opt.tuning_array = [2 5 7 8 10 12 15 25].^2;
    opt.A = length(opt.tuning_array);
    opt.tuned_parameter = 'mxn';
    opt.mult_surf = true;
    %initialize outputs
    clear multStruct_ns multStruct_s
    multStruct_s(opt.A) = struct();
    multStruct_ns(opt.A) = struct();
    opt.surf = false;
    for i = 1:opt.A
        %%%%%%%%%%%% TUNED PARAMETER UPDATE %%%%%%%%%%%%%%%%
        opt.m = sqrt(opt.tuning_array(i));
        opt.n = opt.m;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [output,opt] = optWind(opt,data,atmo,batt,econ,load,turb);
        multStruct_ns(i).output = output;
        multStruct_ns(i).opt = opt;
        multStruct_ns(i).data = data;
        multStruct_ns(i).atmo = atmo;
        multStruct_ns(i).batt = batt;
        multStruct_ns(i).econ = econ;
        multStruct_ns(i).load = load;
        multStruct_ns(i).turb = turb;
        if opt.mult_surf == true
            opt.surf = true;
            [output,opt] = optWind(opt,data,atmo,batt,econ,load,turb);
            multStruct_s(i).output = output;
            multStruct_s(i).opt = opt;
            multStruct_s(i).data = data;
            multStruct_s(i).atmo = atmo;
            multStruct_s(i).batt = batt;
            multStruct_s(i).econ = econ;
            multStruct_s(i).load = load;
            multStruct_s(i).turb = turb;
            opt.surf = false;
        end
    end
    clear i
else
    [output,opt] = optWind(opt,data,atmo,batt,econ,load,turb);
end

%% visualize optimization

visWindOpt(opt,output,data,atmo,batt,econ,load,turb);

%% visualize sim

visWindSim(output,data,atmo,batt,econ,load,turb);






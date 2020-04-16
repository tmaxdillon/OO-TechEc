%created by Trent Dillon on January 15th 2019

% to do
% 1 - high proirotuy
% 2 - second priority (after something)
% 3 - third priority

%platform

%wind
% 2 - wind sensitivity 9 panel

%solar

%battery
% 3 - find battery housing cost, and update calc
% 3 - sensitivity to life cycle analysis
% 3 - make battery optimization module

%wave
% 2 - need to re consider cut out (ask NREL people)

%dies

%other
% 3 - integrate all OOI sensor timeserieses + depths
% 3 - add parabolic distance to port
% 2 - fix initial coarse grid for NM
% 3 - remove all non-essential computations out of sim functions

%% run optimization

optInputs
if opt.sens && ~opt.alllocuses %multiple simulations for sensitivity analysis
    multStruct = doSens();
elseif opt.tdsens && ~opt.alllocuses %two dimensional sensitivity analysis
    multStruct = doTdSens();
elseif opt.alllocuses %run all dimensions
    allLocUses = doAllLocUses();
elseif opt.ninepanel
    [s1,s2,s3,s4,s5,s6,s7,s8,s9] = doNinePanel();
else %just one simulation
    disp(['Optimization (' char(loc) ', pm: ' num2str(pm), ...
        ', bc: ' num2str(bc) ...
        ', uc: ' num2str(c) ') beginning'])
    tTot = tic;
    optInputs %load inputs
    data = load(loc,loc);
    data = data.(loc);
    [output,opt] = ...
        optRun(pm,opt,data,atmo,batt,econ,uc(c),bc,inso,turb,wave, ...
        dies);
    optStruct.output = output;
    optStruct.opt = opt;
    optStruct.data = data;
    optStruct.atmo = atmo;
    optStruct.batt = batt;
    optStruct.econ = econ;
    optStruct.uc = uc(c);
    optStruct.pm = pm;
    optStruct.c = c;
    optStruct.loc = loc;
    if pm == 1
        optStruct.turb = turb;
    elseif pm == 2
        optStruct.inso = inso;
    elseif pm == 3
        optStruct.wave = wave;
    elseif pm == 4
        optStruct.dies = dies;
    end
    disp(['Optimization complete after ' ...
        num2str(round(toc(tTot),2)) ' seconds.'])
end

clear i tTot
uc = uc(c); %for debugging

% load train
% sound(y,Fs)









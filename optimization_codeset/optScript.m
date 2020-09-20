%created by Trent Dillon on January 15th 2019

% to do
% 1 - high proirotuy
% 2 - second priority
% 3 - third priority

%wind

%solar

%battery

%wave

%dies

%other
% 2 - automate all visWaWaWa annotation placements and axis limits

%% run optimization

optInputs
if opt.sens && ~opt.alllocuses %multiple simulations, sensitivity
    multStruct = doSens();
elseif opt.tdsens && ~opt.alllocuses %two dimensional sensitivity analysis
    multStruct = doTdSens();
elseif opt.alllocuses %run all dimensions for a power module / scenario
    allLocUses = doAllLocUses();
elseif opt.allscenuses %run all dimensions for a location
    allLocUses = doAllScenUses();
elseif opt.senssm
    [s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s0] = ...
        doSensSM();
    if pm == 3 %assign output to descriptive variables
        cwm = s1;
        wiv = s2;
        wcm = s3;
        whl = s4;
        ild = s5;
        osv = s6;
        nbl = s7;
        sdr = s8;
        utp = s9;
        bhc = s10;
        dep = s11;
        dtc = s12;
        mbl = s13;
        lft = s14;
        spv = s15;
        tmt = s16;
    end
else %just one simulation
    disp(['Optimization (' char(loc) ', pm: ' num2str(pm), ...
        ', bc: ' num2str(bc) ...
        ', uc: ' num2str(c) ') beginning'])
    tTot = tic;
    optInputs %load inputs
    data = load(loc,loc);
    data = data.(loc);
    [output,opt] = ...
        optRun(pm,opt,data,atmo,batt,econ,uc(c),bc,inso,turb,wave,dies);
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









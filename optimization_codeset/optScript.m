%created by Trent Dillon on January 15th 2019

%% run optimization

optInputs
T = tic;
if opt.sens && ~opt.alllocuses %multiple simulations, sensitivity
    disp('Two dimensional sensitivity beginning now.')
    multStruct = doSens([],[],batchtype,batchscen,batchloc,batchc);
    disp(['Sensitivity complete after ' ...
        num2str(round(toc(T)/60,2)) ' minutes.'])
elseif opt.tdsens && ~opt.alllocuses %two dimensional sensitivity analysis
    disp('Two dimensional sensitivity beginning now.')
    multStruct = doTdSens(batchtype,batchscen,batchloc,batchc);
    disp(['Two dimensional sensitivity complete after ' ...
        num2str(round(toc(T)/60,2)) ' minutes.'])
elseif opt.alllocuses %run all dimensions for a power module / scenario
    disp(['All locations and use cases for the '  ...
        loc ' scenario beginning now.'])
    allLocUses = doAllLocUses(batchtype,batchscen,batchloc,batchc);
    disp(['All locations and use cases for the ' loc ...
        ' scenario complete after' num2str(round(toc(T)/60,2)) ... 
        ' minutes.'])
elseif opt.allscenuses %run all dimensions for a location
    disp(['All scenaios and use cases for the ' ...
        char(opt.wavescnes(econ.wave.scen)) ' location beginning now.'])
    allLocUses = doAllScenUses(batchtype,batchscen,batchloc,batchc);
    disp(['All scenarios and use cases for the ' ...
        char(opt.wavescnes(econ.wave.scen)) ...
        ' scenario complete after' num2str(round(toc(T)/60,2)) ...
        ' minutes.'])
elseif opt.senssm
    [s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s0] = ...
        doSensSM(batchtype,batchscen,batchloc,batchc);
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
        bcc = s17;
    end
else %just one simulation
    disp(['Optimization (' char(loc) ', pm: ' num2str(pm), ...
        ', bc: ' num2str(bc) ...
        ', uc: ' num2str(c) ') beginning'])
    tTot = tic;
    %optInputs %load inputs
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

clear i tTot batchtype
uc = uc(c); %for debugging

% load train
% sound(y,Fs)









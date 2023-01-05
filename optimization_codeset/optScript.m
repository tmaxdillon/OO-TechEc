%created by Trent Dillon on January 15th 2019

%final changes
%-run without platform mass

%% run optimization

optInputs
T = tic;
if opt.sens && ~opt.alllocuses %multiple simulations, sensitivity
    disp(['Sensitivity for ' char(opt.usecases(c)) ' use case at ' loc ...
        ' under the ' char(opt.scens(econ.wave.scen)) ...
        ' beginning now.'])
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
        char(opt.scens(econ.wave.scen)) ' scenario beginning now.'])
    allLocUses = doAllLocUses(batchtype,batchpm,batchscen,batchloc,batchc);
    disp(['All locations and use cases for the ' ...
        char(opt.scens(econ.wave.scen)) ...
        ' scenario complete after ' num2str(round(toc(T)/60,2)) ... 
        ' minutes.'])
elseif opt.allscenuses %run all dimensions for a location
    disp(['All scenaios and use cases for the ' loc ...
         ' location beginning now.'])
    allLocUses = doAllScenUses(batchtype,batchpm,batchscen,batchloc, ...
        batchc);
    disp(['All scenarios and use cases for the ' loc ...
        ' scenario complete after' num2str(round(toc(T)/60,2)) ...
        ' minutes.'])
elseif opt.senssm
    if pm == 1
        [tiv,tcm,twf,cis,rsp,cos,szo,pmm, ...
            lft,dtc,osv,spv,tmt,eol,dep,bcc,bhc,utp,ild,sdr,s0] = ...
            doSensSM1(batchtype,batchpm,batchscen,batchloc,batchc);
    elseif pm == 2
        [pvd,psr,pcm,pwf,pve,rai,pmm, ...
            lft,dtc,osv,spv,tmt,eol,dep,bcc,bhc,utp,ild,sdr,s0] = ...
            doSensSM2(batchtype,batchpm,batchscen,batchloc,batchc);
    elseif pm == 3
        [wiv,wcm,whl,ect,rhs, ...
            lft,dtc,osv,spv,tmt,eol,dep,bcc,bhc,utp,ild,sdr,s0] = ...
            doSensSM3(batchtype,batchpm,batchscen,batchloc,batchc);
    elseif pm == 4
        [giv,fco,fca,fsl,oci,gcm,pmm, ...
            lft,dtc,osv,spv,tmt,eol,dep,bcc,bhc,utp,ild,sdr,s0] = ...
            doSensSM4(batchtype,batchpm,batchscen,batchloc,batchc);
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

clear i tTot
uc = uc(c); %for debugging

% load train
% sound(y,Fs)









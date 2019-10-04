%created by Trent Dillon on January 15th 2019

% to do

%key
% 3 - after all center (first priority)
% 4 - after all center (second priority)
% 5 - after all center (third priority)

%opt v2
% 3 - switch to linear interpolation instead of curve fit
% 3 - think about making this ^ agnostic to power type
% 4 - adapt to search along multiple discontinuities
% 5 - automate search ratio values

%wind

%solar

%battery
% 3 - add max depth of discharge (currently 100%)
% 3 - sensitivity to life cycle analysis
% 5 - make battery optimization module
% 5 - research chemistry for single use batteries

%wave
% 4 - need to re consider cut out (look into ben ideas)
% 4 - add region for breaking waves
% 4 - speed up

%cable
% 3 - basic cable model

%other
% 5 - consider adding cost of environmental compliance
% 5 - research tugboat cost
% 2.5 - integrate all OOI sensor timeserieses
% 5 - add parabolic distance to port

%% run optimization

tTot = tic;
optInputs %load inputs
%load data
data = load(loc,loc);
data = data.(loc);
if opt.sens && ~opt.alldim %multiple simulations for sensitivity analysis
    opt.S = length(opt.tuning_array);
    %initialize outputs
    clear multStruct
    multStruct(opt.S) = struct();
    for i = 1:opt.S
        opt.s = i;
        %update tuned parameter
        if isequal(opt.tuned_parameter,'wcp')
            wave.cutout_prctile = opt.tuning_array(i);
        end
        if isequal(opt.tuned_parameter,'wrp')
            wave.rated_prctile = opt.tuning_array(i);
        end
        if isequal(opt.tuned_parameter,'wcm')
            econ.wave.costmult = opt.tuning_array(i);
        end
        if isequal(opt.tuned_parameter,'utp')
            uc(c).uptime = opt.tuning_array(i);
        end
        if isequal(opt.tuned_parameter,'load')
            uc(c).draw = opt.tuning_array(i);
        end
        if isequal(opt.tuned_parameter,'zo')
            atmo.zo = opt.tuning_array(i);
        end        
        [multStruct(i).output,multStruct(i).opt] =  ...
            optRun(loc,pm,c,opt,data,atmo,batt,econ,uc(c),inso,turb,wave, ...
            tTot);
        multStruct(i).data = data;
        multStruct(i).atmo = atmo;
        multStruct(i).batt = batt;
        multStruct(i).econ = econ;
        multStruct(i).uc = uc(c);
        multStruct(i).pm = pm;
        multStruct(i).c = c;
        multStruct(i).loc = loc;
        if pm == 1
            multStruct(i).turb = turb;
        elseif pm == 2
            multStruct(i).inso = inso;
        elseif pm == 3
            multStruct(i).wave = wave;
        end
    end
    disp([num2str(opt.s) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
elseif opt.wavescen %wave scenarios
    clear data multStruct waveScenStruct
    pm = 3;
    waveScenStruct(length(opt.locations),length(opt.powermodules), ...
        length(opt.usecases)) = struct();
    for loc = 1:length(opt.locations)
        data = load(string(opt.locations(loc)), ...
            string(opt.locations(loc)));
        data = data.(string(opt.locations(loc)));
        for scen = 1:econ.wave.scenarios
            econ.wave.scen = scen;
            for c = 1:length(opt.usecases)
                [waveScenStruct(loc,scen,c).output, ... 
                    waveScenStruct(loc,scen,c).opt] = ...
                    optRun(loc,pm,c,opt,data,atmo,batt,econ,uc(c),inso,turb, ... 
                    wave,tTot);
                waveScenStruct(loc,scen,c).data = data;
                waveScenStruct(loc,scen,c).atmo = atmo;
                waveScenStruct(loc,scen,c).batt = batt;
                waveScenStruct(loc,scen,c).econ = econ;
                waveScenStruct(loc,scen,c).uc = uc(c);
                waveScenStruct(loc,scen,c).pm = pm;
                waveScenStruct(loc,scen,c).c = c;
                waveScenStruct(loc,scen,c).loc = loc;
                waveScenStruct(loc,scen,c).wave = wave;
            end
        end
    end
elseif opt.alldim %run all dimensions
    clear data multStruct allDimStruct
    allDimStruct(length(opt.locations),length(opt.powermodules), ...
        length(opt.usecases)) = struct();
    for loc = 1:length(opt.locations)
        data = load(string(opt.locations(loc)), ...
            string(opt.locations(loc)));
        data = data.(string(opt.locations(loc)));
        for pm = 1:length(opt.powermodules)
            for c = 1:length(opt.usecases)
                [allDimStruct(loc,pm,c).output,allDimStruct(loc,pm,c).opt] = ...
                    optRun(loc,pm,c,opt,data,atmo,batt,econ,uc(c),inso,turb, ... 
                    wave,tTot);
                allDimStruct(loc,pm,c).data = data;
                allDimStruct(loc,pm,c).atmo = atmo;
                allDimStruct(loc,pm,c).batt = batt;
                allDimStruct(loc,pm,c).econ = econ;
                allDimStruct(loc,pm,c).uc = uc(c);
                allDimStruct(loc,pm,c).pm = pm;
                allDimStruct(loc,pm,c).c = c;
                allDimStruct(loc,pm,c).loc = loc;
                if pm == 1
                    allDimStruct(loc,pm,c).turb = turb;
                elseif pm == 2
                    allDimStruct(loc,pm,c).inso = inso;
                end
            end
        end
    end
else %just one simulation
    [output,opt] = ...
        optRun(loc,pm,c,opt,data,atmo,batt,econ,uc(c),inso,turb,wave, ...
        tTot);
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
    end
end

clear i tTot
uc = uc(c); %for debugging







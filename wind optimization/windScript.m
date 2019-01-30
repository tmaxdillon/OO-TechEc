%created by Trent Dillon on January 15th 2019

clear all, close all, clc

%% run optimization

tTot = tic;
windInputs %load inputs
if opt.mult %multiple simulations for sensitivity analysis
    opt.S = length(opt.tuning_array);
    %initialize outputs
    clear multStruct
    multStruct(opt.S) = struct();
    for i = 1:opt.S
        opt.s = i;
        %update tuned parameter
        if isequal(opt.tuned_parameter,'utp')
            opt.constr.uptimeper = opt.tuning_array(i);
        end
        if isequal(opt.tuned_parameter,'load')
            node.draw = opt.tuning_array(i);
        end
        [output,opt] = optWind(opt,data,atmo,batt,econ,node,turb,tTot);
        multStruct(i).output = output;
        multStruct(i).opt = opt;
        multStruct(i).data = data;
        multStruct(i).atmo = atmo;
        multStruct(i).batt = batt;
        multStruct(i).econ = econ;
        multStruct(i).node = node;
        multStruct(i).turb = turb;
    end
    disp([num2str(opt.s) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
else %just one simulation
    [output,opt] = optWind(opt,data,atmo,batt,econ,node,turb,tTot);
end

clear i tTot

%% save and visualize optimization outputs

if opt.mult
    if isequal(opt.tuned_parameter,'utp')
        name = ['multOpt_utp' num2str(opt.S)];
        stru.(name) = multStruct;
        save([name '.mat'],'-struct','stru','-v7.3');
        visUptimeSens(stru.(name))
        load(name)
    elseif isequal(opt.tuned_parameter,'load')
        name = ['multOpt_load' num2str(opt.S)];
        stru.(name) = multStruct;
        save([name '.mat'],'-struct','stru','-v7.3');
        visDrawSens(stru.(name))
        load(name)
    end
else
    name = 'optStruct_';
    stru.(name).atmo = atmo;
    stru.(name).batt = batt;
    stru.(name).data = data;
    stru.(name).econ = econ;
    stru.(name).node = node;
    stru.(name).opt = opt;
    stru.(name).output = output;
    stru.(name).turb = turb;
    save([name '.mat'],'-struct','stru','-v7.3')
    visWindOpt(stru.(name))
    visWindSim(stru.(name))
    load(name)
end

clear name stru







%created by Trent Dillon on January 15th 2019

clear all, close all, clc

%% to do

% 4 - power law wind height
% 4 - add new economics

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
            node.uptime = opt.tuning_array(i);
        end
        if isequal(opt.tuned_parameter,'load')
            node.draw = opt.tuning_array(i);
        end
        if isequal(opt.tuned_parameter,'bgd')
            opt.battgriddur = opt.tuning_array(i);
        end
        [multStruct(i).output,multStruct(i).opt] =  ...
            optWind(opt,data,atmo,batt,econ,node,turb,tTot);
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
    [output,opt] = ...
        optWind(opt,data,atmo,batt,econ,node,turb,tTot);
    optStruct.output = output;
    optStruct.opt = opt;
    optStruct.data = data;
    optStruct.atmo = atmo;
    optStruct.batt = batt;
    optStruct.econ = econ;
    optStruct.node = node;
    optStruct.turb = turb;
end

clear i tTot

%% save and visualize optimization outputs

if opt.mult
    if isequal(opt.tuned_parameter,'utp')
        name = ['multOpt_utp' num2str(opt.S) '_bg' num2str(opt.battgriddur) ...
            'mn' num2str(opt.m*opt.n)];
        if econ.turb_n * econ.batt_n > 1
            name = [name 'nonlin'];
        else
            name = [name 'lin'];
        end
        stru.(name) = multStruct;
        save([name '.mat'],'-struct','stru','-v7.3');
    elseif isequal(opt.tuned_parameter,'load')
        name = ['multOpt_load' num2str(opt.S) '_bg' num2str(opt.battgriddur) ...
            'mn' num2str(opt.m) 'x' num2str(opt.n)];
        if econ.turb_n * econ.batt_n > 1
            name = [name 'nonlin'];
        else
            name = [name 'lin'];
        end
        stru.(name) = multStruct;
        save([name '.mat'],'-struct','stru','-v7.3');
    elseif isequal(opt.tuned_parameter,'bgd')
        name = ['multOpt_bgd' num2str(opt.S) '_load' num2str(node.draw) ...
            'utp' num2str(node.uptime*100) 'mn' num2str(opt.m) 'x' num2str(opt.n)];
        if econ.turb_n * econ.batt_n > 1
            name = [name 'nonlin'];
        else
            name = [name 'lin'];
        end
        if opt.initminlim
            name = [name 'iml'];
        end
        if opt.initminharsh
            name = [name 'imh'];
        end
        if opt.initmincentroid
            name = [name 'imc'];
        end
        stru.(name) = multStruct;
        save([name '.mat'],'-struct','stru','-v7.3');
    end
    visSensitivity(stru.(name))
    load(name)
else
    name = ['opt_' 'mn' num2str(opt.m) 'x' num2str(opt.n)];
    if econ.turb_n * econ.batt_n > 1
        name = [name 'nonlin'];
    else
        name = [name 'lin'];
    end
    stru.(name) = optStruct;
    save([name '.mat'],'-struct','stru','-v7.3')    
    visWindOpt_v2(stru.(name))
    %visWindSim(stru.(name))
    load(name)
end

clear name stru







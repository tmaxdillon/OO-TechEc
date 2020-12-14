function [multStruct] = doSens(ta,tp,batchtype,batchscen,batchloc,batchc)

tTot = tic;
optInputs %load inputs
if ~isempty(ta) && ~isempty(tp)
    opt.tuned_parameter = tp;
    opt.tuning_array = ta;
end
data = load(loc,loc);
data = data.(loc);
opt.S = length(opt.tuning_array);
%initialize outputs
multStruct(opt.S) = struct();
% %set number of cores
% if isempty(gcp('nocreate')) %no parallel pool running
%     cores = feature('numcores'); %find number of cores
%     if cores > 2 %only start if using HPC
%         parpool(cores);
%         disp([ opt.tuned_parameter ' optimization beginning after ' ...
%             num2str(round(toc(tTot),2)) ' seconds. '])
%         %         atmo = atmo;
%         %         batt = batt;
%         parfor i = 1:opt.S
%             if isequal(opt.tuned_parameter,'wcp')
%                 wave.cutout_prctile = opt.tuning_array(i);
%             end
%             [multStruct(i).output,multStruct(i).opt] =  ...
%                 optRun(pm,opt,data,atmo,batt,econ,uc(c),bc, ...
%                 inso,turb,wave,dies);
%         end
%     end
% end
for i = 1:opt.S
    opt.s = i;
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' beginning after ' num2str(round(toc(tTot),2)) ' seconds. ' ...
        opt.tuned_parameter ' tuned to ' ...
        num2str(opt.tuning_array(opt.s)) '.'])
    %update tuned parameter
    if isequal(opt.tuned_parameter,'wcp')
        wave.cutout_prctile = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'wrp')
        wave.rated_prctile = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'wes')
        econ.wave.enf_scen = opt.tuning_array(:,i);
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
    if isequal(opt.tuned_parameter,'imf')
        econ.inso.marinization = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'btm')
        batt.t_add_m = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'mbt')
        batt.t_add_min = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'mzm')
        econ.wind.marinization = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'sbm')
        turb.spar_bm = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'tiv')
        uc(c).turb.lambda = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'twf')
        turb.wf = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'ild')
        uc(c).draw = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'osv')
        econ.vessel.osvcost = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'nbl')
        batt.lc_nom = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'sdr')
        batt.sdr = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'utp')
        uc(c).uptime = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'bhc')
        econ.batt.enclmult = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'dep')
        data.depth_mod = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'dtc')
        data.dist_mod = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'cwm')
        wave.cw_mod = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'wiv')
        econ.wave.lambda_mod = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'wcm')
        econ.wave.costmult_mod = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'whl')
        wave.house = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'hra')
        wave.Hs_ra = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'tra')
        wave.Tp_ra = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'mbl')
        batt.lc_max = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'lft')
        uc(c).lifetime = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'spv')
        econ.vessel.speccost = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'tmt')
        econ.vessel.tmt_enf = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'bcc')
        batt.cost = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'bbt')
        batt.T = opt.tuning_array(i);
    end
    if isequal(opt.tuned_parameter,'eol')
        batt.EoL = opt.tuning_array(i);
    end
    [multStruct(i).output,multStruct(i).opt] =  ...
        optRun(pm,opt,data,atmo,batt,econ,uc(c),bc, ...
        inso,turb,wave,dies);
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
    elseif pm == 4
        multStruct(i).dies = dies;
    end
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' complete after ' num2str(round(toc(tTot),2)) ' seconds.'])
end
disp([num2str(opt.s) ' simulations complete after ' ...
    num2str(round(toc(tTot)/60,2)) ' minutes. '])
end


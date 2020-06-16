function [multStruct] = doSens(ta,tp)

tTot = tic;
optInputs %load inputs
if exist('ta','var')
    opt.tuned_parameter = tp;
    opt.tuning_array = ta;
end
data = load(loc,loc);
data = data.(loc);
opt.S = length(opt.tuning_array);
%initialize outputs
multStruct(opt.S) = struct();
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


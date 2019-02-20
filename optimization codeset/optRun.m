function [output,opt] = optRun(opt,data,atmo,batt,econ,uc,turb,tTot)

%print status to command window
if opt.mult
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' beginning after ' num2str(round(toc(tTot),2)) ' seconds. ' ...
        opt.tuned_parameter ' tuned to ' ...
        num2str(opt.tuning_array(opt.s)) '.'])
else
    disp('Optimization beginning')
end
tOpt = tic;

%curve-fit devices, find polyvals
p.t = calcDeviceCost('turbine',[],econ.turb_n);
[p.b,~,p.kWhmax] = calcDeviceCost('battery',[],econ.batt_n);

if opt.many
    opt.C = length(opt.bgd_array);
    compare(opt.C) = struct();
    costcompare = zeros(1,opt.C);
    for i = 1:opt.C
        opt.c = i;
        opt.battgriddur = opt.bgd_array(i);
        [compare(i).output,compare(i).opt] = ...
            optWind(opt,data,atmo,batt,econ,uc,turb,p);
        costcompare(i) = compare(i).output.min.cost;
    end
    [~,min_ind] = min(costcompare(:));
    output = compare(min_ind).output;
    opt = compare(min_ind).opt;
    opt.battgriddur = opt.bgd_array(min_ind);
else
    [output,opt] = optWind(opt,data,atmo,batt,econ,uc,turb,p);
end
       
%print status to command window
if opt.mult
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' complete after ' num2str(round(toc(tOpt),2)) ' seconds.'])
else
    disp(['Optimization complete after ' ... 
        num2str(round(toc(tTot),2)) ' seconds.'])
end
output.min %print nelder mead min values
opt.kW_init; %print initial kW value
opt.Smax_init; %print inial Smax value

end


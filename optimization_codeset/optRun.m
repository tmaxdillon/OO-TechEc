function [output,opt] = optRun(pm,opt,data,atmo,batt,econ,uc,bc,inso, ...
    turb,wave,dies)

%curve-fit device scatters, find polyvals
opt.p_dev.t = calcDeviceVal('turbine',[],econ.wind_n);
opt.p_dev.d_cost = calcDeviceVal('dieselcost',[],econ.diescost_n);
opt.p_dev.d_mass = calcDeviceVal('dieselmass',[],econ.diesmass_n);
opt.p_dev.d_size = calcDeviceVal('dieselsize',[],econ.diessize_n);
opt.p_dev.d_burn = calcDeviceVal('dieselburn',[],econ.diesburn_n);
[opt.p_dev.b,~,opt.p_dev.kWhmax] = calcDeviceVal('agm',[],econ.batt_n);

if pm == 1 %WIND
    data = prepWind(data,uc);
    [output,opt] = optWind(opt,data,atmo,batt,econ,uc,bc,turb);
elseif pm == 2 %SOLAR
    [data,econ] = prepInso(data,inso,econ,uc);
    [output,opt] = optInso(opt,data,atmo,batt,econ,uc,bc,inso);
elseif pm == 3 %WAVE
    opt = prepWave(data,opt,wave,atmo,uc);
    if opt.V == 1 %optimization version 1: nelder-mead
        if opt.nm.many
            opt.C = length(opt.nm.bgd_array);
            compare(opt.C) = struct();
            costcompare = zeros(1,opt.C);
            for i = 1:opt.C
                opt.c = i;
                opt.nm.battgriddur = opt.nm.bgd_array(i);
                [compare(i).output,compare(i).opt] = ...
                    optWave_nm(opt,data,atmo,batt,econ,uc,bc,wave);
                costcompare(i) = compare(i).output.min.cost;
            end
            [~,min_ind] = min(costcompare(:));
            output = compare(min_ind).output;
            opt = compare(min_ind).opt;
            opt.nm.battgriddur = opt.nm.bgd_array(min_ind);
        else
            [output,opt] = optWave_nm(opt,data,atmo,batt,econ,uc,bc,wave);
        end
    elseif opt.V == 2 %optimization version 2: brute force
        [output,opt] = optWave(opt,data,atmo,batt,econ,uc,bc,wave);
    end
    results.width = output.min.width;
    results.cw_avg = output.min.cw_avg;
    results.cwr_avg = output.min.cwr_avg;
elseif pm == 4 %DIESEL
    data = prepDies(data,econ,uc);
    [output,opt] = optDies(opt,data,atmo,batt,econ,uc,bc,dies);
end

%print min values
results.kW = output.min.kW;
results.Smax = output.min.Smax;
results.cost = output.min.cost;
results.CapEx = output.min.CapEx;
results.OpEx = output.min.OpEx;
results.nvi = output.min.nvi;
results.CF = output.min.CF;
results.batt_L_max = max(output.min.batt_L);
results

end


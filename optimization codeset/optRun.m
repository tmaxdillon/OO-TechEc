function [output,opt] = optRun(pm,opt,data,atmo,batt,econ,uc,bc,inso, ...
    turb,wave,dies)

%curve-fit device scatters, find polyvals
opt.p_dev.t = calcDeviceVal('turbine',[],econ.wind_n);
opt.p_dev.d_cost = calcDeviceVal('dieselcost',[],econ.diescost_n);
opt.p_dev.d_mass = calcDeviceVal('dieselmass',[],econ.diesmass_n);
opt.p_dev.d_size = calcDeviceVal('dieselsize',[],econ.diessize_n);
opt.p_dev.d_burn = calcDeviceVal('dieselburn',[],econ.diesburn_n);
[opt.p_dev.b,~,opt.p_dev.kWhmax] = calcDeviceVal('agm',[],econ.batt_n);

%WIND
if pm == 1
    if opt.nm.many
        opt.C = length(opt.nm.bgd_array);
        compare(opt.C) = struct();
        costcompare = zeros(1,opt.C);
        for i = 1:opt.C
            opt.c = i;
            opt.nm.battgriddur = opt.nm.bgd_array(i);
            [compare(i).output,compare(i).opt] = ...
                optWind(opt,data,atmo,batt,econ,uc,bc,turb);
            costcompare(i) = compare(i).output.min.cost;
            %                 %print nelder mead comparison values
            %                 results.kW = compare(i).output.min.kW;
            %                 results.Smax = compare(i).output.min.Smax;
            %                 results.cost = compare(i).output.min.cost;
            %                 results.CapEx = compare(i).output.min.CapEx;
            %                 results.OpEx = compare(i).output.min.OpEx;
            %                 results.nvi = compare(i).output.min.nvi;
            %                 results.CF = compare(i).output.min.CF;
            %                 results
        end
        [~,min_ind] = min(costcompare(:));
        output = compare(min_ind).output;
        opt = compare(min_ind).opt;
        opt.nm.battgriddur = opt.nm.bgd_array(min_ind);
    else
        [output,opt] = optWind(opt,data,atmo,batt,econ,uc,bc,turb);
    end
    %SOLAR
elseif pm == 2
    data = prepInso(data,inso,uc);
    if opt.nm.many
        opt.C = length(opt.nm.bgd_array);
        compare(opt.C) = struct();
        costcompare = zeros(1,opt.C);
        for i = 1:opt.C
            opt.c = i;
            opt.nm.ratedpowermultiplier = opt.nm.rpm_array(i);
            [compare(i).output,compare(i).opt] = ...
                optInso(opt,data,atmo,batt,econ,uc,bc,inso);
            costcompare(i) = compare(i).output.min.cost;
        end
        [~,min_ind] = min(costcompare(:));
        output = compare(min_ind).output;
        opt = compare(min_ind).opt;
        opt.nm.ratedpowermultiplier = opt.nm.rpm_array(min_ind);
    else
        [output,opt] = optInso(opt,data,atmo,batt,econ,uc,bc,inso);
    end
    %WAVE
elseif pm == 3
    opt = prepWave(data,opt,wave,atmo);
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
    %DIESEL
elseif pm == 4
    data = prepDies(data,uc);
    if opt.nm.many
        opt.C = length(opt.nm.bgd_array);
        compare(opt.C) = struct();
        costcompare = zeros(1,opt.C);
        for i = 1:opt.C
            opt.c = i;
            opt.nm.battgriddur = opt.nm.bgd_array(i);
            [compare(i).output,compare(i).opt] = ...
                optDies(opt,data,atmo,batt,econ,uc,bc,dies);
            costcompare(i) = compare(i).output.min.cost;
        end
        [~,min_ind] = min(costcompare(:));
        output = compare(min_ind).output;
        opt = compare(min_ind).opt;
        opt.nm.battgriddur = opt.nm.bgd_array(min_ind);
    else
        [output,opt] = optDies(opt,data,atmo,batt,econ,uc,bc,dies);
    end
end


%print nelder mead min values
results.kW = output.min.kW;
results.Smax = output.min.Smax;
results.cost = output.min.cost;
results.CapEx = output.min.CapEx;
results.OpEx = output.min.OpEx;
results.nvi = output.min.nvi;
results.CF = output.min.CF;
results.cyc60 = output.min.cyc60;
results

end


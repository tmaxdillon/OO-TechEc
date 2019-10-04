function [output,opt] = optRun(loc,pm,c,opt,data,atmo,batt,econ,uc,inso, ...
    turb,wave,tTot)

%print status to command window
if opt.sens
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' beginning after ' num2str(round(toc(tTot),2)) ' seconds. ' ...
        opt.tuned_parameter ' tuned to ' ...
        num2str(opt.tuning_array(opt.s)) '.'])
elseif opt.alldim
    disp(['Optimization at ' char(opt.locations(loc)) ' using ' ...
        char(opt.powermodules(pm)) ' for ' char(opt.usecases(c)) ...
        ' application beginning after ' num2str(round(toc(tTot),2)) ...
        ' seconds.'])
elseif opt.wavescen
    disp(['Optimization at ' char(opt.locations(loc))  ... 
        ' using wave scenario ' num2str(econ.wave.scen) ' for ' ...
        char(opt.usecases(c)) ' application beginning after ' ... 
        num2str(round(toc(tTot),2)) ' seconds.'])
else
    disp(['Optimization (' char(loc) ', ' num2str(pm) ...
        ', ' num2str(c) ') beginning'])
end
tOpt = tic;

%curve-fit devices, find polyvals
opt.p_dev.t = calcDeviceCost('turbine',[],econ.wind_n);
[opt.p_dev.b,~,opt.p_dev.kWhmax] = calcDeviceCost('battery',[],econ.batt_n);

if pm == 1
    if opt.v2
        [output,opt] = optWind_v2(opt,data,atmo,batt,econ,uc,turb);
    else
        if opt.nm.many
            opt.C = length(opt.nm.bgd_array);
            compare(opt.C) = struct();
            costcompare = zeros(1,opt.C);
            for i = 1:opt.C
                opt.c = i;
                opt.nm.battgriddur = opt.nm.bgd_array(i);
                [compare(i).output,compare(i).opt] = ...
                    optWind(opt,data,atmo,batt,econ,uc,turb);
                costcompare(i) = compare(i).output.min.cost;
            end
            [~,min_ind] = min(costcompare(:));
            output = compare(min_ind).output;
            opt = compare(min_ind).opt;
            opt.nm.battgriddur = opt.nm.bgd_array(min_ind);
        else
            [output,opt] = optWind(opt,data,atmo,batt,econ,uc,turb);
        end
    end
elseif pm == 2
    %if solar timeseries is shorter than a year, elongate
    if length(data.met.shortwave_irradiance) < 8760
        [data.met.shortwave_irradiance, ...
            data.met.time] = elongateInso(data.met.shortwave_irradiance, ...
            data.met.time);
    end
    if opt.nm.many
        opt.C = length(opt.nm.bgd_array);
        compare(opt.C) = struct();
        costcompare = zeros(1,opt.C);
        for i = 1:opt.C
            opt.c = i;
            opt.nm.battgriddur = opt.nm.bgd_array(i);
            [compare(i).output,compare(i).opt] = ...
                optInso(opt,data,atmo,batt,econ,uc,inso);
            costcompare(i) = compare(i).output.min.cost;
        end
        [~,min_ind] = min(costcompare(:));
        output = compare(min_ind).output;
        opt = compare(min_ind).opt;
        opt.nm.battgriddur = opt.nm.bgd_array(min_ind);
    else
        [output,opt] = optInso(opt,data,atmo,batt,econ,uc,inso);
    end
elseif pm == 3
    %determine median, resonant and rated wave conditions
    opt.wave.Tpm = median(data.wave.peak_wave_period);
    opt.wave.Hsm = median(data.wave.significant_wave_height);
    rho = 1020;
    g = 9.81;
    opt.wave.wavepower_ra = (1/(16*4*pi))*rho*g^2* ...
        (wave.hs_rated*opt.wave.Hsm)^2 ...
        *(wave.tp_rated*opt.wave.Tpm); %[W], wave power at rated
    opt.wave.hs_eff_ra = exp(-1.*((wave.hs_rated*opt.wave.Hsm- ...
        wave.hs_res*opt.wave.Hsm).^2) ...
        ./wave.w); %Hs eff at rated power
    %find skewed gaussian fit to find tp efficiency at resonance
    c0 = [0.5 60];
    Tpm = opt.wave.Tpm;
    fun = @(c)findSkewedSS(linspace(0,2*Tpm,wave.tp_N),c,wave,Tpm);
    options = optimset('MaxFunEvals',10000,'MaxIter',10000, ...
        'TolFun',.0001,'TolX',.0001);
    opt.wave.c = fminsearch(fun,c0,options);
    opt.wave.tp_eff_ra = skewedGaussian(wave.tp_rated*opt.wave.Tpm, ...
        opt.wave.c(1),opt.wave.c(2))/ ...
        skewedGaussian(wave.tp_res*opt.wave.Tpm, ...
        opt.wave.c(1),opt.wave.c(2)); %Tp eff at rated power
    if opt.nm.many
        opt.C = length(opt.nm.bgd_array);
        compare(opt.C) = struct();
        costcompare = zeros(1,opt.C);
        for i = 1:opt.C
            opt.c = i;
            opt.nm.battgriddur = opt.nm.bgd_array(i);
            [compare(i).output,compare(i).opt] = ...
                optWave(opt,data,atmo,batt,econ,uc,wave);
            costcompare(i) = compare(i).output.min.cost;
        end
        [~,min_ind] = min(costcompare(:));
        output = compare(min_ind).output;
        opt = compare(min_ind).opt;
        opt.nm.battgriddur = opt.nm.bgd_array(min_ind);
    else
        [output,opt] = optWave(opt,data,atmo,batt,econ,uc,wave);
    end
end

%print status to command window
if opt.sens
    disp(['Optimization ' num2str(opt.s) ' out of ' num2str(opt.S) ...
        ' complete after ' num2str(round(toc(tOpt),2)) ' seconds.'])
elseif opt.alldim
    disp(['Optimization at ' char(opt.locations(loc)) ' using ' ...
        char(opt.powermodules(pm)) ' for ' char(opt.usecases(c)) ...
        ' application complete after ' num2str(round(toc(tTot),2)) ...
        ' seconds.'])
elseif opt.wavescen
    disp(['Optimization at ' char(opt.locations(loc)) ...
        ' using wave scenario ' num2str(econ.wave.scen) ' for ' ...
        char(opt.usecases(c)) ' application complete after ' ...
        num2str(round(toc(tTot),2)) ' seconds.'])
else
    disp(['Optimization complete after ' ...
        num2str(round(toc(tTot),2)) ' seconds.'])
end

%print nelder mead min values
results.kW = output.min.kW;
results.Smax = output.min.Smax;
results.cost = output.min.cost;
results.CapEx = output.min.CapEx;
results.OpEx = output.min.OpEx;
results.trips = output.min.trips;
results.CF = output.min.CF;
results

end


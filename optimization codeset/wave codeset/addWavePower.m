function [opt] = addWavePower(data,opt,wave)

rho = 1020;
g = 9.81;
%determine median, resonant and rated wave conditions
opt.wave.Tpm = median(data.wave.peak_wave_period);
opt.wave.Hsm = median(data.wave.significant_wave_height);
if wave.enf_wave_med
    opt.wave.Tpm = 7;
    opt.wave.Hsm = 1;
end
opt.wave.wavepower_ra = (1/(16*4*pi))*rho*g^2* ...
    (wave.hs_rated*opt.wave.Hsm)^2 ...
    *(wave.tp_rated*opt.wave.Tpm); %[W], wave power at rated
%     opt.wave.hs_eff_ra = exp(-1.*((wave.hs_rated*opt.wave.Hsm- ...
%         wave.hs_res*opt.wave.Hsm).^2)./wave.w); %Hs eff at rated power
opt.wave.hs_eff_ra = 1; %assume no Hs dependence
%find skewed gaussian fit to find tp efficiency at resonance
c0 = [0.5 60];
Tpm = opt.wave.Tpm;
fun = @(c)findSkewedSS_oo(linspace(0,2*Tpm,wave.tp_N),c,wave,Tpm);
options = optimset('MaxFunEvals',10000,'MaxIter',10000, ...
    'TolFun',.0001,'TolX',.0001);
opt.wave.c = fminsearch(fun,c0,options);
[~,opt.wave.tp_eff_max] = ...
    skewedGaussian_oo(opt.wave.Tpm*wave.tp_res, ...
    opt.wave.c(1),opt.wave.c(2),1); %maximum Tp efficiency
opt.wave.tp_eff_ra = skewedGaussian_oo(wave.tp_rated*opt.wave.Tpm, ...
    opt.wave.c(1),opt.wave.c(2), ...
    opt.wave.tp_eff_max); %Tp eff at rated power
%extract data
Hs = data.wave.significant_wave_height; %[m]
Tp = data.wave.peak_wave_period; %[s]
T = min(length(Hs),length(Tp)); %total time steps
%preallocate
opt.wave.hs_eff = ones(1,T); %assume no Hs dependence
opt.wave.tp_eff = zeros(1,T);
opt.wave.wavepower = zeros(1,T);
for t = 1:T
    %         opt.wave.hs_eff(t) =  ...
    %             exp(-1.*((Hs(t)-wave.hs_res*opt.wave.Hsm).^2) ...
    %             ./wave.w); %Hs efficiency
    opt.wave.tp_eff(t) = ...
        skewedGaussian_oo(Tp(t),opt.wave.c(1),opt.wave.c(2), ...
        opt.wave.tp_eff_max); %Tp efficiency
    opt.wave.wavepower(t) = ...
        (1/(16*4*pi))*rho*g^2*Hs(t)^2*Tp(t)/1000; %[kW]
end
end


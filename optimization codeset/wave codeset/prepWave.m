function [opt] = prepWave(data,opt,wave,atmo)

opt.wave.wavepower_ra = (1/(16*4*pi))*atmo.rho_w*atmo.g^2* ...
    (wave.Hs_ra)^2*(wave.Tp_ra); %[W], wave power at rated
wsr = load(wave.wsr);
wsr = wsr.(wave.wsr);
opt.wave.Tp_ws = unique(wsr.T); %Tp wec sim array
Hs = unique(wsr.H); %all Hs
[~,Hs_ind] = min(abs(Hs - wave.wsHs)); %index of Hs closest to target Hs
opt.wave.Hs_ws = Hs(Hs_ind); %Hs wec sim

%preallocate
opt.wave.cwr_b_ws = zeros(length(opt.wave.Tp_ws),1);
%caculate capture width ratio
for i = 1:length(opt.wave.Tp_ws) %across all tp
    J = (1/(64*pi))*atmo.rho_w*atmo.g^2*opt.wave.Hs_ws^2*opt.wave.Tp_ws(i);
    opt.wave.cwr_b_ws(i) = wsr.mat(Hs_ind,i)/(J*wsr.B^2); %cwr/b from ws
end

%extract data
Hs = data.wave.significant_wave_height; %[m]
Tp = data.wave.peak_wave_period; %[s]

%compute timeseries
opt.wave.cwr_b_ts = interp1(opt.wave.Tp_ws, ...
    opt.wave.cwr_b_ws,Tp,'spline'); %timeseries of cwr/b
opt.wave.wavepower_ts = (1/(16*4*pi))*atmo.rho_w*atmo.g^2* ...
    Hs.^2.*Tp./1000; %[kW] %timeseries of wavepower

end


function [kWmax] = findMaxWecPower(Hs,Tp,load,wave)

rho = 1020;
g = 9.81;
power = load;

%find width through resonance onditions
wavepower = (1/(16*4*pi))*rho*g^2*(Hs)^2*(Tp); %[W], power of given conditions
hs_eff = exp(-1.*((Hs-opt.wave.Hsm).^2)./wave.w); %Hs eff (given conditions)
tp_eff = skewedGaussian(Tp,c(1),c(2))/ ...
    skewedGaussian(wave.tp_res*opt.wave.Tpm,c(1),c(2)); %Tp eff (given conditions)
width = power/(wave.eta_ct*hs_eff*tp_eff*wavepower - ...
    1000*rated*wave.house); %[m]

%this gets tricky because we do not know rated power for house load (above)

%use capture width to find rated power
hs_eff_r = exp(-1.*((wave.hs_res*opt.wave.Hsm-opt.wave.Hsm).^2) ...
    ./wave.w); %Hs eff (resonance)
tp_eff_r = skewedGaussian(wave.tp_res*opt.wave.Tpm,c(1),c(2))/ ...
    skewedGaussian(wave.tp_res*opt.wave.Tpm,c(1),c(2)); %Tp eff (resonance)
wavepower_r = (1/(16*4*pi))*rho*g^2*(wave.hs_res*opt.wave.Hsm)^2 ...
    *(wave.tp_res*opt.wave.Tpm); %[W], wave power at resonance
kWhmax = wave.eta_ct*width*efficiency*wavepower - rated*wave.house; %[kW]

end


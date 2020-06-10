%for use in OO tech ec codeset

function [power,width] = powerFromWEC_oo(Hs,Tp,rated,wave,opt,width)

rho = 1020;
g = 9.81;

%compute power
hs_eff = exp(-1.*((Hs-wave.hs_res*opt.wave.Hsm).^2)./wave.w); %Hs efficiency
tp_eff = skewedGaussian_oo(Tp,opt.wave.c(1),opt.wave.c(2), ... 
    opt.wave.tp_eff_max); %Tp efficiency
wavepower = (1/(16*4*pi))*rho*g^2*Hs^2*Tp/1000; %[kW]
power = wave.eta_ct*width*hs_eff*tp_eff*wavepower - ...
    rated*wave.house; %[kW]

%cut out if wave power times width is X times larger than rated power
if wavepower*width > wave.cutout*rated
    power = 0;
end

%scale to rated power and revmove negative power
power(power<0) = 0;
power(power>rated) = rated; %[kW]

% H/L > 0.14 then waves break (deep water assumption)
L = g*Tp^2/(2*pi);
if Hs/L > .14
    power = 0;
end

end


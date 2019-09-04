function [kWmax] = findMaxWecPower(Hs,Tp,load,wave)

rho = 1020;
g = 9.81;
power = load;

%use power requirement to find capture width
gausseff = exp(-1*((Tp-wave.Tpc)^2+(Hs-wave.Hsc)^2)/wave.w); 
wavepower = (1/(16*4*pi))*rho*g^2*Hs^2*Tp; %[W]
cw = power/(wave.eta_ct*gausseff*wavepower); %[m]

%use capture width to find power at peak
gausseff_c = 1;
wavepower_c = (1/(16*4*pi))*rho*g^2*wave.Hsc^2*wave.Tpc; %[W]
kWmax = cw*wave.eta_ct*gausseff_c*wavepower_c/1000; %[kW]

end


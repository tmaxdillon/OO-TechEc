function [power,cw] = powerFromWEC(Hs,Tp,kWmax,wave)

rho = 1020;
g = 9.81;

%use power at centroid to find capture width
gausseff_c = 1;
wavepower_c = (1/(16*4*pi))*rho*g^2*wave.Hsc^2*wave.Tpc; %[W]
cw = 1000*kWmax/(wave.eta_ct*gausseff_c*wavepower_c); %[m]

%use capture width to find power at input conditions
gausseff = exp(-1*((Tp-wave.Tpc)^2+(Hs-wave.Hsc)^2)/wave.w);
wavepower = (1/(16*4*pi))*rho*g^2*Hs^2*Tp; %[W]
power = wave.eta_ct*cw*gausseff*wavepower/1000; %[kW]

%scale to rated power
power(power>kWmax) = kWmax; %[kW]

end


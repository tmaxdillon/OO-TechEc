function [cw] = findCaptureWidth(Hs,Tp,power,wec)
rho = 1020;
g = 9.81;
%normal distribution based around given apex, width and rated power
gausseff = exp(-1*((Tp-wec.Tpc)^2+(Hs-wec.Hsc)^2)/wec.w);
wavepower = (1/(16*4*pi))*rho*g^2*Hs^2*Tp;

cw = power/(wec.eta_ct*gausseff*wavepower);

end


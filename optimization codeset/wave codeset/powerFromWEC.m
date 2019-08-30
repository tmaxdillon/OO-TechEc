function [power] = powerFromWEC(Hs,Tp,kmax,wec)
rho = 1020;
g = 9.81;

cw = findCaptureWidth(Hs,Tp,uc.draw);
%normal distribution based around given apex, width and rated power
gausseff = cw*exp(-1*((Tp-wec.Tpc)^2+(Hs-wec.Hsc)^2)/wec.w);
wavepower = (1/(16*4*pi))*rho*g^2*Hs^2*Tp;

power = wec.eta_ct*gausseff*wavepower;

%scale to rated power
power(power>kmax) = kmax;

end


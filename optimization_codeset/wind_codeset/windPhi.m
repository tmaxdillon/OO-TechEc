function [phi] = windPhi(kW,Smax,data,atmo,batt,uc,turb)

%extract data
wind = data.met.wind_spd; %[m/s]
if atmo.dyn_h %use log law to adjust height dynamically basec on size
    for i = 1:length(wind)
        wind(i) = adjustHeight(wind(i),data.met.wind_ht, ...
            turb.clearance + sqrt(1000*2*kW/(atmo.rho*pi*turb.ura^3)), ...
            'log',atmo.zo);
    end
end
dt = 24*(data.met.time(2) - data.met.time(1)); %time in hours

%initialize
S = zeros(1,length(wind));
S(1) = Smax*1000;

%run simulation
for t = 1:length(wind)
    %find power from turbine
    if wind(t) < turb.uci
        P = 0; %[W]
    elseif turb.uci < wind(t) && wind(t) <= turb.ura
        P = kW*1000*wind(t)^3/turb.ura^3; %[W]
    elseif turb.ura < wind(t) && wind(t) <= turb.uco
        P = kW*1000; %[W]
    else
        P = 0; %[W]
    end
    %find next storage state
    sd = S(t)*(batt.sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
    S(t+1) = dt*(P - uc.draw) + S(t) - sd; %[Wh]
    if S(t+1) > Smax*1000 %dump power if over limit
        S(t+1) = Smax*1000; %[Wh]
    elseif S(t+1) <= 0 %bottomed out
        S(t+1) = 0; %no less than bottom
    end
end

phi = Smax/(Smax - (min(S)/1000)); %extra depth

end


function [data] = prepWind(data,uc)

%make time series data adequately long
[data.met.wind_spd,data.met.time] = ...
    extendToLifetime(data.met.wind_spd,data.met.time,uc.lifetime);

end


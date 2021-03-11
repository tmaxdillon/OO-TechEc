function [dp] = getInsoDiameter(kW,inso)

A = kW/(inso.eff*inso.rated);
dp = 2*sqrt(A/pi);

end


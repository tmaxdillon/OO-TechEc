function [data] = prepDies(data,uc)

%make time series adequately long
tStart = datevec(data.met.time(1));
tEnd = tStart;
tEnd(1) = tStart(1) + uc.lifetime; %extend to lifetime of system
data.time = data.met.time(1):1/24:datenum(tEnd);

end


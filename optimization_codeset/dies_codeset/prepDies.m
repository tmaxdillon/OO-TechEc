function [data] = prepDies(data,econ,uc)

%make time series adequately long
tStart = datevec(data.met.time(1));
tEnd = tStart;
tEnd(1) = tStart(1) + uc.lifetime; %extend to lifetime of system
data.time = data.met.time(1):1/24:datenum(tEnd);

%set mooring system
econ.platform.inso.depth(:,4) = econ.platform.inso.depth(:,1);
econ.platform.inso.diameter(:,4) =  ...
    econ.platform.inso.boundary_di.*ones(5,1);
econ.platform.inso.cost(:,4) = ...
    econ.platform.inso.cost(:,3).*econ.platform.inso.boundary_mf;


end


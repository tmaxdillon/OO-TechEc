function [cost] = calcTurbineCost(kW)

turbineLibrary

%preallocate
x = zeros(1,length(turbineLib))';
y = zeros(1,length(turbineLib))';

%unpack into arrays
for i = 1:length(turbineLib)
    y(i) = turbineLib(i).cost;
    x(i) = turbineLib(i).kW;
end
%renomve nans
y = y(~isnan(y));
x = x(~isnan(y));

n = 1; %polynomial fit, (see visTurbineCost for tuning)

%set up least squares non negative fit
V = [];
V(:,n+1) = ones(length(x),1,class(x));
for j = n:-1:1
    V(:,j) = x.*V(:,j+1);
end
C = V;
d = y;
p = lsqnonneg(C,d);

cost = polyval(p,kW);

end


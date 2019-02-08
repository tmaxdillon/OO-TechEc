function [p,cost] = calcDeviceCost(type,xq,n)

%code inspired by: http://maggotroot.blogspot.com/2013/11/constrained-linear-
%least-squares-in.html
%and: https://www.mathworks.com/matlabcentral/answers/94272-how-do-i-constrain-
%a-fitted-curve-through-specific-points-like-the-origin-in-matlab

if isequal(type,'turbine')
    turbineLibrary
    x = zeros(1,length(turbineLib));
    y = zeros(1,length(turbineLib));
    %unpack into arrays
    for i = 1:length(turbineLib)
        x(i) = turbineLib(i).kW;
        y(i) = turbineLib(i).cost;
    end
end
if isequal(type,'battery')
    batteryLibrary
    x = zeros(1,length(batteryLib));
    y = zeros(1,length(batteryLib));
    %unpack into arrays
    for i = 1:length(batteryLib)
        x(i) = batteryLib(i).kWh;
        y(i) = batteryLib(i).cost;
    end
end

%clear out missing cost values
x = x(~isnan(y)); %must do x firest
y = y(~isnan(y));

V = [];
V(:,n+1) = ones(length(x),1,class(x));
for j = n:-1:1
    V(:,j) = x'.*V(:,j+1);
end
C = V;
d = y';
p = lsqnonneg(C,d);

if exist('xq','var')
    cost = polyval(p,xq);
end

end



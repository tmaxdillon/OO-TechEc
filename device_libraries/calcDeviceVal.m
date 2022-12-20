function [p,val,xmax] = calcDeviceVal(type,xq,n)

%code inspired by: http://maggotroot.blogspot.com/2013/11/constrained-linear-
%least-squares-in.html
%and: https://www.mathworks.com/matlabcentral/answers/94272-how-do-i-constrain-
%a-fitted-curve-through-specific-points-like-the-origin-in-matlab

%inflaton updates:
turb_inf = 1.19; %turbine inflation 2018 -> 2022
dgen_inf = 1.15; %diesel generator inflation 2020 -> 2022

if isequal(type,'turbine')
    turbineLibrary
    x = zeros(1,length(turbineLib));
    y = zeros(1,length(turbineLib));
    %unpack into arrays
    for i = 1:length(turbineLib)
        x(i) = turbineLib(i).kW;
        y(i) = turbineLib(i).cost*turb_inf;
    end
elseif isequal(type,'agm')
    batteryLibrary_agm
    x = zeros(1,length(batteryLib));
    y = zeros(1,length(batteryLib));
    %unpack into arrays
    for i = 1:length(batteryLib)
        x(i) = batteryLib(i).kWh;
        y(i) = batteryLib(i).cost;
    end
    xmax = max(x);
    if xq > xmax & n > 1
        linmult = xq/xmax;
        xq = xmax;
    end
elseif isequal(type,'lfp')
    batteryLibrary_lfp
    x = zeros(1,length(batteryLib));
    y = zeros(1,length(batteryLib));
    %unpack into arrays
    for i = 1:length(batteryLib)
        x(i) = batteryLib(i).kWh;
        y(i) = batteryLib(i).cost;
    end
    xmax = max(x);
    if xq > xmax & n > 1
        linmult = xq/xmax;
        xq = xmax;
    end
elseif isequal(type,'dieselcost')
    dieselLibrary
    x = zeros(1,length(diesLib));
    y = zeros(1,length(diesLib));
    %unpack into arrays
    for i = 1:length(diesLib)
        x(i) = diesLib(i).kW;
        y(i) = diesLib(i).cost*dgen_inf;
    end
elseif isequal(type,'dieselmass')
    dieselLibrary
    x = zeros(1,length(diesLib));
    y = zeros(1,length(diesLib));
    %unpack into arrays
    for i = 1:length(diesLib)
        x(i) = diesLib(i).kW;
        y(i) = diesLib(i).m;
    end
elseif isequal(type,'dieselsize')
    dieselLibrary
    x = zeros(1,length(diesLib));
    y = zeros(1,length(diesLib));
    %unpack into arrays
    for i = 1:length(diesLib)
        x(i) = diesLib(i).kW;
        y(i) = diesLib(i).d;
    end
elseif isequal(type,'dieselburn')
    dieselLibrary
    x = zeros(1,length(diesLib));
    y = zeros(1,length(diesLib));
    %unpack into arrays
    for i = 1:length(diesLib)
        x(i) = diesLib(i).kW;
        y(i) = diesLib(i).c;
    end
end

%clear out missing cost values
x = x(~isnan(y)); %must do x first
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
    val = polyval(p,xq);
end

if exist('linmult','var')
    val = val*linmult;
end

end



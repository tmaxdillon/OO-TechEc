function [] = visFoundSubCost(econ,xmax)

%foundsub cost
x = 0:1:xmax;
y = zeros(size(x));
for i=1:length(x)
    y(i) = applyScaleFactor(econ.wind.foundsub.cost,5640,x(i), ...
        econ.wind.foundsub.sf);
end

%curve-fit devices, find polyvals
opt.p.t = calcDeviceCost('turbine',[],econ.wind_n);
[opt.p.b,~,opt.p.kWhmax] = calcDeviceCost('battery',[],econ.batt_n);

%cap ex
CapEx = zeros(size(x));
for i=1:length(CapEx)
    %economic modeling
    kWcost = polyval(opt.p.t,x(i))*econ.wind.marinization; %cost of turbine
    Icost = (econ.wind.installed - kWcost/ ...
        (x(i)*econ.wind.marinization))*x(i); %cost of installation
    if Icost < 0, Icost = 0; end
    %compute foundation costs using scale factor
    FScost = y(i)*x(i);
    CapEx(i) =  FScost + Icost + kWcost;
end

ind = find(x == 5640);

figure
subplot(2,1,1)
plot(x,y,'r','LineWidth',1.5)
hold on
scatter(5640,econ.wind.foundsub.cost,'k','filled')
xlabel('kW')
ylabel('[$/kW]')
ylim([0 max(y)*1.25])
set(gca,'FontSize',12)
grid on

title('Foundation/Substructure: Cost per kW (top), Total Cost (bottom)','FontSize',12)
subplot(2,1,2)
plot(x,y.*x/1000,'r','LineWidth',1.5)
hold on
scatter(5640,econ.wind.foundsub.cost*5640/1000,'k','filled')
xlabel('kW')
ylabel('[$1000]')
set(gca,'FontSize',12)
grid on

% subplot(3,1,3)
% plot(x,y.*x./CapEx*100,'r','LineWidth',1.5)
% hold on
% scatter(5640,econ.wind.foundsub.cost*5640/CapEx(x==5640)*100,'k','filled')
% xlabel('kW')
% ylabel('[%]')
% ylim([0 1.25*max(y.*x./CapEx*100)])
% set(gca,'FontSize',12)
% grid on

end


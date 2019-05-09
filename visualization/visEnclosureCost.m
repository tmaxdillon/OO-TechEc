function [] = visEnclosureCost(econ,batt,xmax)

ref_cost = econ.batt.encl.cost*econ.batt.encl.scale; %[$]
ref_cap = 10;

%enclosure cost
x = 0:1:xmax;
y = zeros(size(x));
for i=1:length(x)
    y(i) = applyScaleFactor(econ.batt.encl.cost,econ.batt.encl.scale, ... 
    x(i)*10^3/(batt.ed*batt.V/1.638e-5),.9995)*batt.ed^-1*batt.V^-1*1.638e-5;
end

ind = find(x == econ.batt.encl.scale);

figure
subplot(2,1,1)
plot(x,y,'r','LineWidth',1.5)
hold on
scatter(ref_cap, ... 
    ref_cost/(ref_cap*1e3),'k','filled')
xlabel('kWh')
ylabel('[$/kWh]')
ylim([0 max(y)*1.25])
set(gca,'FontSize',12)
grid on

title('Enclosure: Cost per kW (top), Total Cost (bottom)','FontSize',12)
subplot(2,1,2)
plot(x,y.*x*10^3,'r','LineWidth',1.5)
hold on
scatter(ref_cap, ... 
    ref_cost,'k','filled')
xlabel('kWh')
ylabel('[$]')
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


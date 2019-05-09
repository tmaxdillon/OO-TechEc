function [] = visSolarBargeCost(kW,inso)

area = kW/(inso.eff*inso.rated); %[m^3] find area of panels for capacity
mass = inso.wf*area; %[kg] compute mass from area using weight factor
c = zeros(size(kW));
t = zeros(size(kW));
d = zeros(size(kW));
r = zeros(size(kW));
for i = 1:length(kW)
    [c(i),t(i),d(i),r(i)] = calcBargeCost(area(i),mass(i));
end

figure
ax(1) = subplot(6,1,1);
plot(kW,area,'r','LineWidth',1.5)
ylabel('[m^2]')
legend('Area','Location','Southeast')
title('Cylindrical Barge for PV')
grid on
ax(2) = subplot(6,1,2);
plot(kW,mass,'r','LineWidth',1.5)
ylabel('[kg]')
legend('Mass','Location','Southeast')
grid on
ax(3) = subplot(6,1,3);
plot(kW,t,'r','LineWidth',1.5)
ylabel('[m]')
legend('Wall Thickness','Location','Southeast')
grid on
ax(4) = subplot(6,1,4);
plot(kW,d,'r','LineWidth',1.5)
ylabel('[m]')
legend('Draft','Location','Southeast')
grid on
ax(5) = subplot(6,1,5);
plot(kW,r,'r','LineWidth',1.5)
ylabel('[m]')
legend('Barge Radius','Location','Southeast')
grid on
ax(6) = subplot(6,1,6);
plot(kW,c/1000,'g','LineWidth',1.5)
ylabel('[$1000]')
xlabel('PV Capacity [kW]')
legend('Cost in Thousands','Location','Southeast')
grid on

set(gcf, 'Position', [100, 100, 600, 800])

set(ax,'FontSize',14)
set(ax,'LineWidth',1.3)
linkaxes(ax,'x')
end


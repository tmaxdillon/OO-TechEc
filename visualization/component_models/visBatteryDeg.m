function [] = visBatteryDeg(phis,battlc_nom,batt)

battlc = phis.^(batt.beta)*battlc_nom;
battlc(battlc > batt.lc_max) = batt.lc_max;

figure
plot(phis,battlc,'LineWidth',1.4)
ylabel('battery life cycle [months]')
xlabel('S_m/d_{max}')
set(gca,'FontSize',14,'LineWidth',1.4)
ylim([0 max(battlc)*1.1])
grid on

end


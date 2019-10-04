function [] = visBatteryDeg(phis,battlc_nom,batt)

battlc = phis.^(batt.beta)*battlc_nom;
battlc(battlc > batt.lc_max) = batt.lc_max;

figure
plot(phis,battlc)
ylabel('battery life cycle')
xlabel('extra depth (phi)')
set(gca,'FontSize',14,'LineWidth',1.4)
ylim([0 inf])
grid on

end


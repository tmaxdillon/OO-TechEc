function [] = visBatteryDeg(maxdod,battlc_nom,batt)

batt.beta = .5;

battlc = (1./maxdod).^(batt.beta)*battlc_nom;
battlc(battlc > batt.lc_max) = batt.lc_max;

figure
plot(maxdod*100,battlc,'k','LineWidth',1.4)
%ylabel('battery life cycle [months]')
%xlabel('S_m/d_{max}')
set(gca,'FontSize',14,'LineWidth',1.4)
ylim([0 max(battlc)*1.1])
set(gcf,'color','w')
grid on

% battlc = (phis).^(batt.beta)*battlc_nom;
% battlc(battlc > batt.lc_max) = batt.lc_max;
% 
% figure
% plot(phis,battlc,'k','LineWidth',1.4)
% ylabel('battery life cycle [months]')
% xlabel('S_m/d_{max}')
% set(gca,'FontSize',14,'LineWidth',1.4)
% ylim([0 max(battlc)*1.1])
% grid on

end


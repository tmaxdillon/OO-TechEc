function [] = visBatteryDeg(excess,battlc_nom,batt)

%set(0,'defaulttextinterpreter','none')
set(0,'defaulttextinterpreter','latex')

batt.beta = 1;

battlc = (1./(1-excess)).^(batt.beta)*battlc_nom;
battlc(battlc > batt.lc_max) = batt.lc_max;

figure
plot(excess*100,battlc,'k','LineWidth',1.4)
ylabel('$L_{batt}$ [mo]')
xlabel('$e$ [\%]')
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ... 
    'HorizontalAlignment','right')
set(gca,'FontSize',14,'LineWidth',1.4)
ylim([0 max(battlc)*1.1])
set(gcf,'color','w')
grid on

set(gcf, 'Position', [100, 100, 600, 200])

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


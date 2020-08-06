function [] = visBatteryDeg(excess,battlc_nom,batt)

set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'helvetica')
set(0,'DefaultAxesFontName', 'helvetica')

batt.beta = 1;

battlc = (1./(1-excess)).^(batt.beta)*battlc_nom;
battlc(battlc > batt.lc_max) = batt.lc_max;

batterylc = figure;
plot(excess*100,battlc,'k','LineWidth',1.4)
hold on
yline(60,'--k','System Lifetime', ...
    'LabelHorizontalAlignment','left','FontSize',12, ...
    'LineWidth',1.4)
ax = gca;
ax.YLabel.String = 'L_{batt} [mo]';
ax.YLabel.Interpreter = 'tex';
ax.XLabel.String = 'e [%]';
ax.XLabel.Interpreter = 'tex';
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ... 
    'HorizontalAlignment','right')
set(gca,'FontSize',12,'LineWidth',1.4)
ylim([0 80])
xlim([0 100])
set(gcf,'color','w')
grid on

set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 4, 1.75])

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

print(batterylc,'../Research/OO-TechEc/paper_figures/battlc', '-dpng','-r600')

end


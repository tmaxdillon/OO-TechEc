set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'helvetica')
set(0,'DefaultAxesFontName', 'helvetica')

%data/info
optInputs
load('S_for_vis')
batt = lfp;
excess = linspace(0,1,10000);
battlc_nom = 18;
x1 = 1200;
x2 = x1+1000;
batt.beta = 1;

%computation
battlc = (1./(1-excess)).^(batt.beta)*battlc_nom;
battlc(battlc > batt.lc_max) = batt.lc_max;

%plot settings
batterylc = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 1.75])
fs1 = 10;
lw1 = 1.2;


ax(1) = subplot(1,2,2);
plot(excess*100,battlc,'k','LineWidth',1.4)
hold on
yline(60,'--k','System Lifetime', ...
    'LabelHorizontalAlignment','left','FontSize',fs1, ...
    'LineWidth',lw1)
ax = gca;
ax.YLabel.String = 'L_{batt} [mo]';
ax.YLabel.Interpreter = 'tex';
ax.XLabel.String = 'e [%]';
ax.XLabel.Interpreter = 'tex';
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ... 
    'HorizontalAlignment','right')
set(gca,'FontSize',fs1,'LineWidth',lw1)
ylim([0 80])
xlim([0 100])
set(gcf,'color','w')
grid on
ax(2) = subplot(1,2,1);
x = 1:1:length(S_for_vis(x1:x2));
plot(x,S_for_vis(x1:x2)/max(S_for_vis),'Color',[255,69,0]/256, ... 
    'DisplayName','Battery Storage','LineWidth',2)
grid on
ylim([0 1])
xlim([0 x(end)])
ax = gca;
ax.XLabel.String = 'Time';
ax.XTick = [0 x(end)];
ax.XTickLabel = {'t = 0','t = T'};
ax.YLabel.String = '[kWh]';
ax.YTick = [0 1];
ax.YTickLabel = {'0','S_{m}'};
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ... 
    'HorizontalAlignment','right')
set(gca,'FontSize',fs1,'LineWidth',lw1)

print(batterylc,'../Research/OO-TechEc/paper_figures/battlc', ...
    '-dpng','-r600')

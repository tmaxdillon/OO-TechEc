set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

%data/info
optInputs
load('S_for_vis')
batt = lfp;
excess = linspace(0,1,10000);
battlc_nom = 18;
x1 = 200;
x2 = x1+3000;
batt.beta = 1;

%computation of life cycle
battlc = (1./(1-excess)).^(batt.beta)*battlc_nom;
battlc(battlc > batt.lc_max) = batt.lc_max;

%excess battery annotation identification
S = S_for_vis(x1:x2);
[~,e_x_ind] = min(S);

%plot settings
batterylc = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 3, 3])
fs1 = 10;
lw1 = 1.1;

ax(1) = subplot(2,1,1);
plot(excess*100,battlc,'k','LineWidth',1.4)
set(gca,'xdir','reverse')
hold on
yl = yline(60,'--k','System Lifetime', ...
    'LabelHorizontalAlignment','right','FontSize',fs1, ...
    'LineWidth',lw1,'FontName','cmr10');
ax(1).YLabel.String = '$L_{\mathrm{batt}}$ [mo]';
ax(1).YLabel.Interpreter = 'latex';
ax(1).XLabel.String = '$e$ [\%]';
ax(1).XTick = [0 20 40 60 80 100];
ax(1).XLabel.Interpreter = 'latex';
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ... 
    'HorizontalAlignment','right')
set(gca,'FontSize',fs1,'LineWidth',lw1)
ylim([0 80])
xlim([0 100])
set(gcf,'color','w')
text(.025,.05,'(a)','Units','Normalized', ...
            'VerticalAlignment','bottom','FontWeight','normal', ...
            'HorizontalAlignment','left','FontSize',fs1, ...
            'Color','k');
grid on
ax(2) = subplot(2,1,2);
x = 1:1:length(S_for_vis(x1:x2));
area(x,S_for_vis(x1:x2)/max(S_for_vis),'FaceColor',[221, 251, 221]/256, ... 
    'DisplayName','Battery Storage','LineWidth',.3)
grid on
ylim([0 1])
xlim([0 x(end)])
ax(2).XLabel.String = 'Time';
pos = get(ax(2).XLabel,'Position');
pos(2) = pos(2)+.05;
set(ax(2).XLabel,'Position',pos)
ax(2).XTick = [100 x(end-100)];
ax(2).XTickLabel = {'$t$ = 0','$t = N$'};
ax(2).TickLabelInterpreter = 'latex';
% ax.YLabel.String = '$S$ [kWh]';
ax(2).YLabel.String = {'Energy', 'Storage'};
ax(2).YLabel.Interpreter = 'tex';
ax(2).YTick = [0 1];
ax(2).YTickLabel = {'0','$S_{m}$'};
ax(2).TickLabelInterpreter = 'latex';
ax(2).TickLength = [0 0];
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ... 
    'HorizontalAlignment','right')
set(gca,'FontSize',fs1,'LineWidth',lw1)
text(.025,.05,'(b)','Units','Normalized', ...
            'VerticalAlignment','bottom','FontWeight','normal', ...
            'HorizontalAlignment','left','FontSize',fs1, ...
            'Color','k');
drawnow
%add annotation
x_arr = e_x_ind;
pos = get(ax(2),'Position');
X = pos(1) + [x_arr x_arr].*(pos(3)/ax(2).XLim(2));
Y = pos(2) + [0.04 .96*S(e_x_ind)/max(S)].*(pos(4)/ax(2).YLim(2));
arrow = annotation('doublearrow',X,Y);
arrow.Head1Style = 'plain';	
arrow.Head2Style = 'plain';	
arrow.Head1Width = 3;	
arrow.Head1Length = 3;
arrow.Head2Width = 3;	
arrow.Head2Length = 3;
%add text
x_tex = e_x_ind;
X_t = pos(1) + x_tex*(pos(3)/ax(2).XLim(2));
dim = [X_t mean(Y)*.95 .5 .05];
anntext = annotation('textbox',dim,'String','$e$ \%', ... 
    'VerticalAlignment','top','Interpreter','latex');
anntext.EdgeColor = 'none';

print(batterylc,'../Research/OO-TechEc/paper_figures/battlc', ...
    '-dpng','-r600')

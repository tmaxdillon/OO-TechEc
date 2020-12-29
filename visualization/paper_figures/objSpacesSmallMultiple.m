clc, close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

%load allStruct
if ~exist('array','var')
    load('waveoptd')
    load('waveoptc')
    load('wavecons')
    allStruct = mergeWaWaWa(waveoptd,waveoptc,wavecons);
    %shape allStruct into an array
    nc = size(allStruct,3);
    ns = size(allStruct,2);
    nl = size(allStruct,1);
    for c = 1:nc %use case
        for s = 1:ns %scenario
            for l = 1:nl %location
                i = l+nl*(s-1)+(ns*nl)*(c-1);
                array(i) = allStruct(l,s,c);
            end
        end
    end
end
clearvars -except array nc ns nl ax

%plot setup
objSpacesSM = figure;
set(gcf,'Units','inches','Color','w')
set(gcf,'Position', [0.1, 1, 6.5, 5.5])
% axcol = [.65 .65 .65];
axcol = [0 0 0];
lw = 0.45;
fs = 8; %titles
fs2 = 7; %tick lables
fs3 = 10; %annotations
fs4 = 5.5; %colorbar tick labels
Sm_max = 300; %[kWh]
Gr_max = 4; %[kW]
ytpos = [0.215 2 4];
ytl = {'0.215','2','4'};
xtpos = [1 150 300];
xtl = {'1','150','300'};

Xwidth = .65; %subplot width
Yheight = .65; 
XmargW = 0.3;
YmargW = 0.05;
Yoff = 0.8;
Xoff = 0.7;
Cbwidth = 0.03;
Cbyroom = -0.1;

xlabdshift = 2; %shift xlabel down
ylablshift = 250; %shift ylabel left
ylabdshift = 4; %shift ylabel down
locations{1} = {'Argentine Basin'};
locations{2} = {'Coastal Endurance'};
locations{3} = {'Coastal Pioneer'};
locations{4} = {'Irminger Sea'};
locations{5} = {'Southern Ocean'};
ann_sp = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(j)', ...
    '(k)','(l)','(m)','(n)','(o)','(p)','(q)','(r)','(s)','(t)','(u)', ...
    '(v)','(w)','(x)','(y)','(z)','(aa)','(ab)','(ac)','(ad)'};

ann = { ...
    '\begin{tabular}{l} Short-Term \\ Optimistic \\ Durability \end{tabular}', ...
    '\begin{tabular}{l} Short-Term \\ Optimistic \\ Cost \end{tabular}', ...
    '\begin{tabular}{l} Short-Term \\ Conservative \end{tabular}', ...
    '\begin{tabular}{l} Long-Term \\ Optimistic \\ Durability \end{tabular}', ...
    '\begin{tabular}{l} Long-Term \\ Optimistic \\ Cost \end{tabular}', ...
    '\begin{tabular}{l} Long-Term \\ Conservative \end{tabular}'};

for i = 1:length(array)
    
    optStruct = array(i);
    opt = optStruct.opt;
    output = optStruct.output;
    %adjust cost to thousands
    output.cost = output.cost/1000;
    output.surv(isnan(output.cost)) = 0;
    output.cost(isnan(output.cost)) = 0;
    %create grid
    [Smaxgrid,kWgrid] = meshgrid(opt.Smax,opt.kW);
    %remove failure configurations
    a_sat = output.cost; %availability satisfied
    a_sat(output.surv == 0) = nan; 
    
    ax(i) = subplot(nc*ns,nl,i);
    sb = surf(Smaxgrid,kWgrid,output.cost,1.*ones(length(Smaxgrid), ...
        length(kWgrid),3)); %white
    sb.EdgeColor = 'none';
    sb.FaceColor = 'flat';
    hold on
    sa = surf(Smaxgrid,kWgrid,a_sat);
    sa.EdgeColor = 'none';
    sa.FaceColor = 'flat';
    view(0,90)
    ylim([0.215 Gr_max])
    xlim([1 Sm_max])
    set(gca,'FontSize',fs2)
    set(gca,'XTick',xtpos)
    set(gca,'YTick',ytpos)
    set(gca,'XTickLabels',[])
    set(gca,'YTickLabels',[])
    
    %titles and annotations
    hold on
    if i < 6
        tt = title(locations{i},'FontWeight','normal','FontSize',fs);
        tt.Position(2) = tt.Position(2)*1.25;
        tt.Units = 'normalized';
        tt.HorizontalAlignment = 'center';
        tt.Position(1) = 0.6;
    end
    if rem(i,nl) == 0
        text(1.65,.5,ann{i/5},'Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'HorizontalAlignment','left','FontSize',fs, ...
            'Color','k','Interpreter','latex');
    end
    axis manual
    
    set(gca,'LineWidth',lw)
    set(gca,'XColor',axcol,'YColor',axcol)
    set(gca,'TickLength',[0.025 1])
    set(gca, 'Layer', 'top')
        
    %find maximums and minimum for colorbar
    a_max(i) = max(a_sat(:)); %actual max
    p_max(i) = max(max(sb.ZData(sb.YData(:,1) < Gr_max, ... 
        sb.XData(1,:) < Sm_max))); %plot max
    a_min(i) = min(a_sat(:));
    
    lb(i) = a_min(i)/p_max(i);
    lb(i) = 0;
    colormap(ax(i),AdvancedColormap('kkgw glw lww r',1000, ...
        [lb(i),lb(i)+.05*(1-lb(i)),lb(i)+0.15*(1-lb(i)),1]));
    set(ax(i),'CLim',[a_min(i) p_max(i)])
    c(i) = colorbar(ax(i),'location','eastoutside');
    c(i).Ticks = [a_min(i) p_max(i)];
    c(i).TickLabels = {['$' num2str(round(c(i).Ticks(1)/1000,2)) 'M'], ...
        ['$' num2str(round(c(i).Ticks(2)/1000,2)) 'M']};
    c(i).Box = 'off';
end

%reposition figures add labels
for i=1:length(array)
    axes(ax(i))
    %set axes position
    ax(i).Units = 'inches';
    ax(i).Position = [Xoff + rem(i-1,5)*(XmargW+Xwidth), ...
        Yoff + floor((30-i)/5)*(YmargW+Yheight), Xwidth, Yheight];
    %set colorbar position
    c(i).Units = 'inches';
    c(i).Position = ...
        [Xoff + Xwidth + rem(i-1,5)*(XmargW+Xwidth) + Cbwidth, ...
        Yoff + floor((30-i)/5)*(YmargW+Yheight) - Cbyroom, ...
        Cbwidth, Yheight + Cbyroom*2];
    %set colorbar tick labels
    ctl = c(i).TickLabels;
    c(i).TickLabels = [];
    ctickpos = get(c(i),'Ticks');
    ct(1) = text(0,0,ctl{1});
    ct(1).Units = 'inches';
    set(ct(1),'Units','Inches','Position', ...
        [Xwidth + Cbwidth,0], ...
        'FontSize',fs4,'VerticalAlignment','bottom', ...
        'HorizontalAlignment','left','Color',[.25 .25 .25]);
    ct(2) = text(0,0,ctl{2});
    ct(2).Units = 'inches';
    set(ct(2),'Units','Inches','Position', ...
        [Xwidth + Cbwidth,Yheight + Cbyroom], ...
        'FontSize',fs4,'VerticalAlignment','bottom', ...
        'HorizontalAlignment','left','Color',[.25 .25 .25]);
    %set subplot annotation
    ha = {'left','center','right'};
    va = {'bottom','middle','top'};
    text(.975,.775,ann_sp{i},'Units','Normalized', ...
        'VerticalAlignment','bottom','FontWeight','normal', ...
        'HorizontalAlignment','right','FontSize',fs, ...
        'Color',[1 1 1]);
    %y axes
    if rem(i,nl) == 1
        t = text(zeros(1,length(ytpos)),ytpos, ytl, ...
            'FontSize',fs2,'HorizontalAlignment','right');
        for ti = 1:length(t)
            set(t(ti), 'Units','pixels','VerticalAlignment',va{ti});
            set(t(ti), 'Position', get(t(ti),'Position')-[2 0 0]);
        end
    end
    %x axes
    if i > 25
        t = text(xtpos,zeros(1,length(xtpos)), xtl, ...
            'FontSize',fs2,'HorizontalAlignment','center');
        for ti = 1:length(t)
            set(t(ti), 'Units','pixels','HorizontalAlignment',ha{ti});
            set(t(ti), 'Position', get(t(ti),'Position')-[0 5 0]);
        end
    end
end

%colorbar legend
i = 26;
cleg = colorbar(ax(i),'location','southoutside');
cbtlabel = ...
    {'\begin{tabular}{c} Objective Space \\ Minimum \end{tabular}'; ...
    '\begin{tabular}{c} Objective Space \\ Maximum \end{tabular}'};
set(cleg,'Position',[.775 .06 .15 .01],'box','off', ...
    'Limits',[a_min(i) a_max(i)],'Ticks',[a_min(i) a_max(i)], ...
    'TickLabels',cbtlabel,'TickLabelInterpreter','latex', ...
    'Color',[0 0 0],'LineWidth',.01,'FontSize',fs2)
set(cleg.Label,'String','Model Output [$]','FontSize',fs)
cleg.Label.Units = 'normalized';
clabpos = get(cleg.Label,'Position');
clabpos(2) = 4;
set(cleg.Label,'Position',clabpos)

%add labels
axes(ax(28))
xlabdim = [0.3 -0.75*Xoff];
xlab = 'Battery Storage Capacity [kWh]';
xl = text(0,0,xlab);
set(xl,'Units','inches','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'Rotation',0);
axes(ax(16))
ylabdim = [-0.75*Xoff .75];
ylab = 'WEC Rated Power Output [kW]';
yl = text(0,0,ylab);
set(yl,'Units','inches','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'Rotation',90);

print(objSpacesSM,['~/Dropbox (MREL)/Research/OO-TechEc/' ...
    'paper_figures/objspacessm'],'-dpng','-r600')



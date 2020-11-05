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
clearvars -except array nc ns nl

%plot setup
objSpacesSM = figure;
set(gcf,'Units','inches','Color','w')
set(gcf,'Position', [0.1, 1, 6, 6])
% axcol = [.65 .65 .65];
axcol = [0 0 0];
lw = 0.25;
fs = 8; %titles
fs2 = 7; %tick lables
fs3 = 10; %annotations
Sm_max = 500; %[kWh]
Gr_max = 8; %[kW]
ytpos = [0.15 4 8];
ytl = {'0.15','4','8'};
xtpos = [1 250 500];
xtl = {'1','250','500'};
rshift = 0; %shift axis right
xshrink = 1.2; %shrink size of x axis
ygrow = 1.35; %expand size of y axis
dshift = 5; %shift axes down
xlabdshift = 2; %shift xlabel down
ylablshift = 250; %shift ylabel left
ylabdshift = 4; %shift ylabel down
locations{1} = {'Argentine Basin'};
locations{2} = {'Coastal Endurance'};
locations{3} = {'Coastal Pioneer'};
locations{4} = {'Irminger Sea'};
locations{5} = {'Southern Ocean'};

ann = { ...
    '\begin{tabular}{l} Short-Term \\ Optimistic Durability \end{tabular}', ...
    '\begin{tabular}{l} Short-Term \\ Optimistic Cost \end{tabular}', ...
    '\begin{tabular}{l} Short-Term \\ Conservative \end{tabular}', ...
    '\begin{tabular}{l} Long-Term \\ Optimistic Durability \end{tabular}', ...
    '\begin{tabular}{l} Long-Term \\ Optimistic Cost \end{tabular}', ...
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
    ylim([0.15 Gr_max])
    xlim([1 Sm_max])
    set(gca,'FontSize',fs2)
    set(gca,'XTick',xtpos)
    set(gca,'YTick',ytpos)
    set(gca,'XTickLabels',[])
    set(gca,'YTickLabels',[])
    hold on
    if i < 6
        t = title(locations{i},'FontWeight','normal','FontSize',fs);
        t.Position(2) = t.Position(2)*1.1;
    end
    if rem(i,nl) == 0
        text(1.05,.5,ann{i/5},'Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'HorizontalAlignment','left','FontSize',fs, ...
            'Color','k','Interpreter','latex');
    end
    if i > 25
        if rem(i,nl) == 3
%             xl = xlabel('Battery Storage Capacity [kWh]','FontSize',fs3);
%             xlpos = get(xl,'Position');    
%             xlpos(2) = xlpos(2) - xlabdshift;
%             set(xl,'Position',xlpos)
        end
%         set(gca,'XTick',[10 460])
%         set(gca,'XTickLabels',{'1','500'})
    end
    if rem(i,nl) == 1
        if i == 11
%             yl = ylabel({'WEC Rated Power [kW]'},'FontSize',fs3);
%             ylpos = get(yl,'Position');    
%             ylpos(2) = ylpos(2) - ylabdshift;
%             ylpos(1) = ylpos(1) - ylablshift;
%             set(yl,'Position',ylpos)
        end
%         set(gca,'YTick',ytpos)
        %set(gca,'YTickLabels',{'0.15','8'})
%         t = text([0 0],ytpos, ytl, ...
%             'FontSize',fs2,'HorizontalAlignment','right');
%         for ti = 1:length(t)
%             set(t(ti), 'Units','pixels');
%             set(t(ti), 'Position', get(t(ti),'Position')-[7.5 0 0]);
%         end
    end
    axis manual
    
    set(gca,'LineWidth',lw)
    set(gca,'XColor',axcol,'YColor',axcol)
    set(gca,'TickLength',[0.025 1])
    set(gca, 'Layer', 'top')
    
    %get axespositions for adjustmet later
    set(ax(i),'Units','pixels');
    axpos(:,i) = get(ax(i),'Position');
    axpos(1,i) = axpos(1,i)+rshift;
    axpos(3,i) = xshrink*axpos(3,i);
    axpos(4,i) = ygrow*axpos(4,i);
    axpos(2,i) = axpos(2,i)-dshift*(ceil(i/nl)-1);
        
    %find maximums and minimum for colorbar
    a_max(i) = max(a_sat(:)); %actual max
    p_max(i) = max(max(sb.ZData(sb.YData(:,1) < Gr_max, ... 
        sb.XData(1,:) < Sm_max))); %plot max
    a_min(i) = min(a_sat(:));
end
drawnow

%add room to bottom of plot
addbottom = 0.5; %[in]
addright = 1; %[in]
set(gcf,'Position', [0.1, 1, 6+addright, 6+addbottom])
%reposition figures and add labels
for i=1:length(array)
    axes(ax(i))
    set(gca,'Position',axpos(:,i))
    set(gca,'Units','Inches')
    axpos_in = get(gca,'Position');
    axpos_in(2) = axpos_in(2)+addbottom;
    set(gca,'Position',axpos_in)
    ha = {'left','center','right'};
    va = {'bottom','middle','top'};
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

%colormap and bar
for i=1:length(array)        
    lb(i) = a_min(i)/p_max(i);
    colormap(ax(i),AdvancedColormap('bg l w r',1000, ...
        [lb(i),lb(i)+.05*(1-lb(i)),lb(i)+0.15*(1-lb(i)),1]));
    %c(i) = colorbar(ax(i));
    %set(c(i).Label,'String','[$k]','Rotation',0,'Units','Pixels') 
    %clabrspot = 38;
    %clpos = get(c(i).Label,'Position');
    %clpos(1) = clabrspot;
    %set(c(i).Label,'Position',clpos)
    set(ax(i),'CLim',[-inf p_max(i)])
    %set(c(i),'Limits',[0 pmax(i)])
    if i == 26
        c = colorbar(ax(i),'location','southoutside');
        cbtlabel = ...
            {'\begin{tabular}{c} Global \\ Minimum \end{tabular}'; ...
            '\begin{tabular}{c} Global \\ Maximum \end{tabular}'};
        set(c,'Position',[.05 .045 .15 .01],'box','off', ...
            'Limits',[a_min(i) a_max(i)],'Ticks',[a_min(i) a_max(i)], ...
            'TickLabels',cbtlabel,'TickLabelInterpreter','latex', ...
            'Color',[0 0 0],'LineWidth',.01,'FontSize',fs2)
        set(c.Label,'String','Model Output [$]','FontSize',fs)
        clabpos = get(c.Label,'Position');
        clabpos(2) = clabpos(2)+8.5;
        set(c.Label,'Position',clabpos)
    end
end

%add labels
xlabdim = [0.2 -0.1 6 .5];
xlab = 'Battery Storage Capacity [kWh]';
xl = annotation('textbox',[0 0 0 0],'String',xlab);
set(xl,'Units','inches','Position',xlabdim,'FitBoxToText','on', ...
    'HorizontalAlignment','center','FontSize',fs,'EdgeColor',[1 1 1]);
axes(ax(16))
ylabdim = [-0.6 .9];
ylab = 'WEC Rated Power Output [kW]';
yl = text(0,0,ylab);
set(yl,'Units','inches','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'Rotation',90);
print(objSpacesSM,['~/Dropbox (MREL)/Research/OO-TechEc/' ...
    'paper_figures/objspacessm'],'-dpng','-r600')



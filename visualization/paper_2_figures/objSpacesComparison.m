%clc, close all, clear ax
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

printon = true;

%load allStruct
if ~exist('array_os','var')
    allStruct = mergeEight(inau,inhu,wiod,wico,dgen,wodu,woco,wcon);
    allStruct([3 5],:,:) = []; %drop locations
    allStruct = allStruct(:,[1 2 3 4 6 7 8 5],:); %switch diesel and wave
    allStruct(:,[2 3 5 6],:) = []; %drop scenarios
    %shape allStruct into an array
    nc = size(allStruct,3);
    ns = size(allStruct,2);
    nl = size(allStruct,1);
    for l = 1:nl %location
        for c = 1:nc %use case
            for s = 1:ns %resource
                %i = l+nl*(s-1)+(ns*nl)*(c-1);
                i = s+ns*(c-1)+(nc*ns)*(l-1);
                array_os(i) = allStruct(l,s,c);
            end
        end
    end
end
clearvars -except array_os nc ns nl printon

%plot setup
objSpacesSM = figure;
set(gcf,'Units','inches','Color','w')
set(gcf,'Position', [0.1, 1, 6.5, 5.75])
% axcol = [.65 .65 .65];
axcol = [0 0 0];
lw = 0.45;
fs = 9; %titles
fs2 = 7; %tick lables
fs3 = 8; %annotations
fs4 = 5.5; %colorbar tick labels
Sm_max = [250]; %[kWh]
Sm_min = 1;
Gr_max = [12 4 4 15]; %[kW]
Gr_min = [0.5 .1 .2 1];
ytpos = [0.5 6 12;
    0.1 2 4;
    0.2 2 4;
    1 7 14];
ytl = {'0.5' '6' '12';
    '0.1' '2' '4';
    '0.2' '2' '4';
    '1' '7' '14'};
xtpos = [1 125 250];
xtl = {'1','125','250'};

%WSC = with subplot colorbar
Xwidth = .76; %WOSC = .725
Yheight = .72; 
XmargW = 0.5; %WOSC = .16
YmargW = 0.05; %WOSC = 0.1
Yoff = .7; %WOSC = 0.8
Xoff = .7; %WOSC = 0.95 ?
Cbwidth = 0.03;
Cbyroom = -0.1;

% xlabdshift = 2; %shift xlabel down
% ylablshift = 750; %shift ylabel left
% ylabdshift = 4; %shift ylabel down
titles{1} = {'\begin{tabular}{c} Solar \\ Automated \end{tabular}'};
titles{2} = {'\begin{tabular}{c} Wind \\ Conservative \end{tabular}'};
titles{3} = {'\begin{tabular}{c} Wave \\ Conservative \end{tabular}'};
titles{4} = {'\begin{tabular}{c} Diesel \end{tabular}'};
ann_sp = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(j)', ...
    '(k)','(l)','(m)','(n)','(o)','(p)','(q)','(r)','(s)','(t)','(u)', ...
    '(v)','(w)','(x)','(y)','(z)','(aa)','(ab)','(ac)','(ad)'};

ann = { ...
    '\begin{tabular}{l} Argentine \\ Basin \\ Short-Term \end{tabular}', ...
    '\begin{tabular}{l} Argentine \\ Basin \\ Long-Term \end{tabular}', ...
    '\begin{tabular}{l} Coastal \\ Endurance \\ Short-Term \end{tabular}', ...
    '\begin{tabular}{l} Coastal \\ Endurance \\ Long-Term \end{tabular}', ...
    '\begin{tabular}{l} Irminger \\ Sea \\ Short-Term \end{tabular}', ...
    '\begin{tabular}{l} Irminger \\ Sea \\ Long-Term \end{tabular}'};

for i = 1:length(array_os)
    
    optStruct = array_os(i);
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
    
    ax(i) = subplot(nc*nl,ns,i);
    sb = surf(Smaxgrid,kWgrid,output.cost,1.*ones(length(Smaxgrid), ...
        length(kWgrid),3)); %white
%     colordata = permute(repmat([255 255 245]'./256,[1,500,500]),[3 2 1]);
%     sb = surf(Smaxgrid,kWgrid,output.cost,colordata); %offwhite
    sb.EdgeColor = 'none';
    sb.FaceColor = 'flat';
    hold on
    sa = surf(Smaxgrid,kWgrid,a_sat);
    sa.EdgeColor = 'none';
    sa.FaceColor = 'flat';
    view(0,90)
    i_conv = i - floor((i-1)/ns)*ns;
    ylim([Gr_min(i_conv) Gr_max(i_conv)]) 
    xlim([Sm_min Sm_max]) 
    set(gca,'FontSize',fs2)
    set(gca,'XTick',xtpos)
    set(gca,'YTick',ytpos(i_conv,:))
    set(gca,'XTickLabels',[])
    set(gca,'YTickLabels',[])
    
    %titles and annotations
    hold on
    if i < 5
        tt = title(titles{i},'FontWeight','normal','FontSize',fs, ...
            'Interpreter','latex','VerticalAlignment','middle');
        tt.Position(2) = tt.Position(2)*1.25;
        tt.Units = 'normalized';
        tt.HorizontalAlignment = 'center';
        tt.Position(1) = 0.6;
    end
    if rem(i,ns) == 0
        %orig = 1.65
        text(1.55,.5,ann{i/ns},'Units','Normalized', ...
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
    p_max(i) = max(max(sb.ZData(sb.YData(:,1) < Gr_max(i_conv), ... 
        sb.XData(1,:) < Sm_max))); %plot max
    a_min(i) = min(a_sat(:));
    p_max_mult(i) = p_max(i)/a_min(i);
    lb(i) = 0;
    
    %add circle
    s = scatter3(output.min.Smax,output.min.kW,a_min(i)*2,18,'ko', ...
        'MarkerEdgeAlpha',.8);  
end

%add colorbar, reposition figures, add labels
for i=1:length(array_os)
    axes(ax(i))
    %set colorbar limits
    if exist('p_max_mult','var')
        colormap(ax(i),AdvancedColormap('kkgw glww lww r rk k',1000, ...
            [lb(i),lb(i)+.025*(1-lb(i)),lb(i)+0.1*(1-lb(i)),.35,.7,1]));
        set(ax(i),'CLim',[a_min(i) ceil(max(p_max_mult)*a_min(i))])
        c(i) = colorbar(ax(i),'location','eastoutside');
        c(i).Ticks = [a_min(i) p_max(i)];
        c(i).Limits = c(i).Ticks;
        c(i).TickLabels = {['$' num2str(round(c(i).Ticks(1)/1000,2)) 'M'], ...
            ['$' num2str(round(c(i).Ticks(2)/1000,2)) 'M']};
        c(i).Box = 'off';
        ax(i).CLim = [a_min(i) max(p_max_mult)*a_min(i)];
    end
    %set axes position
    ax(i).Units = 'inches';
    ax(i).Position = [Xoff + rem(i-1,ns)*(XmargW+Xwidth), ...
        Yoff + floor((ns*nc*nl-i)/ns)*(YmargW+Yheight), Xwidth, Yheight];
    %set colorbar position
    c(i).Units = 'inches';
    c(i).Position = ...
        [Xoff + Xwidth + rem(i-1,ns)*(XmargW+Xwidth) + Cbwidth, ...
        Yoff + floor((ns*nc*nl-i)/ns)*(YmargW+Yheight) - Cbyroom, ...
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
        'HorizontalAlignment','left','Color',[0 0 0]);
    ct(2) = text(0,0,ctl{2});
    ct(2).Units = 'inches';
    set(ct(2),'Units','Inches','Position', ...
        [Xwidth + Cbwidth,Yheight + Cbyroom], ...
        'FontSize',fs4,'VerticalAlignment','bottom', ...
        'HorizontalAlignment','left','Color',[0 0 0]);
    %set subplot annotation
    ha = {'left','center','right'};
    va = {'bottom','middle','top'};
    tasp = text(.975,.775,ann_sp{i},'Units','Normalized', ...
        'VerticalAlignment','bottom','FontWeight','normal', ...
        'HorizontalAlignment','right','FontSize',fs3, ...
        'Color',[1 1 1]);
    %change annotation green background
    if p_max_mult(i) < 3.5 || rem(i,4) == 0
        tasp.Color = [0 0 0];
    end
    %y axes
    i_conv = i - floor((i-1)/ns)*ns;
    t = text(zeros(1,length(ytpos(i_conv,:))), ...
        ytpos(i_conv,:), ytl(i_conv,:), ...
        'FontSize',fs2,'HorizontalAlignment','right');
    for ti = 1:length(t)
        set(t(ti), 'Units','pixels','VerticalAlignment',va{ti});
        set(t(ti), 'Position', get(t(ti),'Position')-[2 0 0]);
    end
    %x axes
    if i > 20
        t = text(xtpos,zeros(1,length(xtpos)), xtl, ...
            'FontSize',fs2,'HorizontalAlignment','center');
        for ti = 1:length(t)
            set(t(ti), 'Units','pixels','HorizontalAlignment',ha{ti});
            set(t(ti), 'Position', get(t(ti),'Position')-[0 5 0]);
        end
    end
end

%colorbar legend
i = 21;
cleg = colorbar(ax(i),'location','southoutside');
cbtlabel = {'min.','3xmin.','5xmin.','7xmin.','9xmin.'};
cticks = linspace(a_min(i),floor(max(p_max_mult))*a_min(i),9);
cticks = cticks([1,3,5,7,9]);
set(cleg,'Position',[.59 .03 .375 .01],'box','off', ...
    'Limits',[a_min(i) floor(max(p_max_mult))*a_min(i)],'Ticks', ...
    linspace(a_min(i),floor(max(p_max_mult))*a_min(i),5), ...
    'TickLabels',cbtlabel,'TickLabelInterpreter','latex', ...
    'Color',[0 0 0],'LineWidth',.01,'FontSize',fs2)
set(cleg.Label,'String','Model Output [$]','FontSize',fs2)
cleg.Label.Units = 'normalized';
clabpos = get(cleg.Label,'Position');
clabpos(2) = 4;
set(cleg.Label,'Position',clabpos)

%add labels
axes(ax(23))
xlabdim = [-.375 -0.45*Xoff];
xlab = 'Battery Storage Capacity [kWh]';
xl = text(0,0,xlab);
set(xl,'Units','inches','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'Rotation',0);
axes(ax(13))
ylabdim = [-0.5*Xoff .75];
ylab = 'Rated Generation [kW]';
yl = text(0,0,ylab);
set(yl,'Units','inches','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'Rotation',90);

%add horizontal lines
annotation(gcf,'line',[.855 .99],[.385 .385], ...
    'Color',[.4 .4 .4],'LineWidth',.7)
annotation(gcf,'line',[.855 .99],[.653 .653], ...
    'Color',[.4 .4 .4],'LineWidth',.7)

if printon
%     print(objSpacesSM,['~/Dropbox (MREL)/Research/OO-TechEc/' ...
%         '/wave-comparison/paper_figures/objspacessm'],'-dpng','-r600')

print(objSpacesSM, ...
    '~/Documents/OO-TechEc/paper_figures/objspacessm',  ...
    '-dpng','-r600')
end



set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

%load multStruct
if ~exist('multStruct','var')
    multStruct = wavecons_bigos(:,1);
end
clearvars -except multStruct

multStruct_c = multStruct;
multStruct_c(3) = multStruct_c(2);

%plot setup
objSpacesLoc = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [0.1, 1, 3, 8])
lw = 1.1;
fs = 10;
Sm_max = [250 300 350 125 200]; %[kWh]
Gr_max = [2 4 5 1 2]; %[kW]
C_max = 1500;
rshift = 20; %shift axis right
xshrink = .9; %shrink size of x axis
ygrow = 1.2; %expand size of y axis
dshift = 5; %shift axes down

ann = {'(a)','(b)','(c)','(d)','(e)'};

for i = 1:length(multStruct)
    
    optStruct = multStruct(i);
    opt = optStruct.opt;
    output = optStruct.output;
    %adjust cost to thousands
    output.cost = output.cost/1000;
    %create grid
    [Smaxgrid,kWgrid] = meshgrid(opt.Smax,opt.kW);
    %remove failure configurations
    a_sat = output.cost; %availability satisfied
    a_sat(output.surv == 0) = nan;
    
    ax(i) = subplot(length(multStruct),1,i);
    sb = surf(Smaxgrid,kWgrid,output.cost,zeros(length(Smaxgrid), ...
        length(kWgrid),3)); %black
    sb.EdgeColor = 'none';
    sb.FaceColor = 'flat';
    hold on
    sa = surf(Smaxgrid,kWgrid,a_sat);
    sa.EdgeColor = 'none';
    sa.FaceColor = 'flat';
    view(0,90)
    hold on
    text(.02,.04,ann{i},'Units','Normalized', ...
            'VerticalAlignment','bottom','FontWeight','normal', ...
            'HorizontalAlignment','left','FontSize',fs, ...
            'Color','w');
    if i == 5
        xlabel('S_m [kWh]','interpreter','tex')
    end
    ylabel({'G_r','[kW]'},'interpreter','tex')
    hYLabel = get(gca,'YLabel');
    set(hYLabel,'rotation',0,'VerticalAlignment','middle', ...
        'HorizontalAlignment','center','Units','Normalized')
    ylabpos = get(hYLabel,'Position');
    ylabpos(1) = -.3;
    set(hYLabel,'Position',ylabpos)
    axis manual
    ylim([-inf Gr_max(i)])
    xlim([-inf Sm_max(i)])
    set(gca,'FontSize',fs)
    set(gca,'LineWidth',lw)
    
    %get axespositions for adjustmet later
    set(ax(i),'Units','pixels');
    axpos(:,i) = get(ax(i),'Position');
    axpos(1,i) = axpos(1,i)+rshift;
    axpos(3,i) = xshrink*axpos(3,i);
    axpos(4,i) = ygrow*axpos(4,i);
    axpos(2,i) = axpos(2,i)-dshift*(i-1);
        
    
    %find maximums and minimum for colorbar
    a_max(i) = max(a_sat(:)); %actual max
    p_max(i) = max(max(sb.ZData(sb.YData(:,1) < Gr_max(i), ... 
        sb.XData(1,:) < Sm_max(i)))); %plot max
    a_min(i) = min(a_sat(:));
end
drawnow

%reposition figures
for i=1:length(multStruct)
    set(ax(i),'Position',axpos(:,i))
end

%final adjustments
for i=1:length(multStruct)        
    lb(i) = a_min(i)/p_max(i);
    colormap(ax(i),AdvancedColormap('bg l w r',1000, ...
        [lb(i),lb(i)+.05*(1-lb(i)),lb(i)+0.15*(1-lb(i)),1]));
    c(i) = colorbar(ax(i));
    set(c(i).Label,'String','[$k]','Rotation',0,'Units','Pixels') 
    clabrspot = 44;
    clpos = get(c(i).Label,'Position');
    clpos(1) = clabrspot;
    set(c(i).Label,'Position',clpos)
    set(ax(i),'CLim',[-inf p_max(i)])
    %set(c(i),'Limits',[0 pmax(i)])
end

%fix third subplot colorbar
set(c(3),'Units','Pixels')
set(c(2),'Units','Pixels')
cpos3 = get(c(3),'Position');
cpos2 = get(c(2),'Position');
cpos3(1) = cpos2(1);
set(c(3),'Position',cpos3);
pos3 = get(ax(3),'Position');
pos2 = get(ax(2),'Position');
pos3(3) = pos2(3);
set(ax(3),'Position',pos3);

print(objSpacesLoc,'../Research/OO-TechEc/paper_figures/objspaces', ...
    '-dpng','-r600')



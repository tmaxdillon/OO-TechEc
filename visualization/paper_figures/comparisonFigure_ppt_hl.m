clearvars -except allStruct
close all

set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

if ~exist('allStruct','var')
    load('wind')
    load('waveoptc')
    load('inso')
    load('dies')
    allStruct = mergeWiWaDiIn(wind,waveoptc,dies,inso);
    %rearrange
    asadj(:,1,:) = allStruct(:,4,:);
    asadj(:,2,:) = allStruct(:,3,:);
    asadj(:,3,:) = allStruct(:,2,:);
    asadj(:,4,:) = allStruct(:,1,:);
    allStruct = asadj;
end

np = 4; %number of power modules
nc = 2; %number of costs
nl = size(allStruct,1); %number of locations
nu = size(allStruct,3); %number of use cases

%initialize/preallocate
costdata = zeros(nl,np,nc,nu);
gendata = zeros(nl,np,1,nu);
stordata = zeros(nl,np,1,nu);
Ldata = zeros(nl,np,1,nu);
cfdata = zeros(nl,np,1,nu);
massdata = zeros(nl,np,1,nu);
dpdata = zeros(nl,np,1,nu);

%unpack allStruct into costdata
opt = allStruct(1,1,1).opt;
for loc = 1:nl
    for pm = 1:np
        for c = 1:nu
            costdata(loc,pm,1,c) = ... %capex
                allStruct(loc,pm,c).output.min.Pinst/1000 + ...
                allStruct(loc,pm,c).output.min.Pmooring/1000 + ...
                allStruct(loc,pm,c).output.min.Scost/1000 + ...
                allStruct(loc,pm,c).output.min.battencl/1000;
            costdata(loc,pm,2,c) = ... %opex
                allStruct(loc,pm,c).output.min.vesselcost/1000 + ...
                allStruct(loc,pm,c).output.min.battreplace/1000;                
            if pm == 4 %wind-specific
                costdata(loc,pm,1,c) = costdata(loc,pm,1,c) + ... 
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,2,c) = costdata(loc,pm,2,c) + ... 
                    allStruct(loc,pm,c).output.min.turbrepair/1000;            
            end
            if pm == 1 %inso-specific
                costdata(loc,pm,1,c) = costdata(loc,pm,1,c) + ... 
                    allStruct(loc,pm,c).output.min.Mcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Ecost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000 + ...
                    allStruct(loc,pm,c).output.min.Strcost/1000;
            end
            if pm == 3 %wave-specific
                costdata(loc,pm,1,c) = costdata(loc,pm,1,c) + ... 
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,2,c) = costdata(loc,pm,2,c) + ... 
                    allStruct(loc,pm,c).output.min.wecrepair/1000;
            end
            if pm == 2 %dies-specific 
                costdata(loc,pm,1,c) = costdata(loc,pm,1,c) + ... 
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.genencl/1000;
                costdata(loc,pm,2,c) = costdata(loc,pm,2,c) + ... 
                    allStruct(loc,pm,c).output.min.genrepair/1000 + ...
                    allStruct(loc,pm,c).output.min.fuel/1000;
            end
            gendata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.kW;
            stordata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.Smax;
            Ldata(loc,pm,1,c) = ...
                100*max(allStruct(loc,pm,c).output.min.batt_L);
            cfdata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.CF;
            massdata(loc,pm,1,c) = ...
                1000*allStruct(loc,pm,c).output.min.Smax/ ...
                (allStruct(loc,pm,c).batt.V*allStruct(loc,pm,c).batt.se);
            dpdata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.dp;
        end
    end
end

%plotting setup
comparison_results_hl = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 10, 12])
fs = 9; %annotation font size
fs2 = 11; %axis font size
yaxhpos = -.25; %
cmult = 1.15; %cost axis multiplier
gmult = 1.8; %generation axis multiplier
bmult = 2; %battery axis multiplier
blmult = 3; %battery cycle axis multiplier 
cfmult = 1.4; %capacity factor axis multiplier
cbuff = 5; %cost text buffer
gbuff = 1.5; %generation text buffer
bbuff = 3;  %battery text buffer
blbuff = 1.5; %battery cycle text buffer
cfbuff = .03; %capacity factor text buffer

%titles and labels
stt = {'Short-Term Instrumentation';'(six month service interval)'};
ltt = {'Long-Term Instrumentation';'(no service interval)'};
titles = {stt,ltt};
xlab = {'\begin{tabular}{l} Argentine \\ Basin \end{tabular}'; ...
    '\begin{tabular}{l} Coastal \\ Endurance \end{tabular}'; ...
    '\begin{tabular}{l} Coastal \\ Pioneer \end{tabular}'; ...
    '\begin{tabular}{l} Irminger \\ Sea \end{tabular}'; ...
    '\begin{tabular}{l} Southern \\ Ocean \end{tabular}'};
pms = {'Solar','Diesel','Wave','Wind'};
leg = {'CapEx','OpEx'};

%colors
cols = 2;
col(1,:,1) = [255 130 130]/256; %inso capex
col(2,:,1) = [255 204 204]/256; %inso opex
col(1,:,2) = [160 160 160]/256; %dies capex
col(2,:,2) = [220 220 220]/256; %dies opex
col(1,:,3) = [153,153,255]/256; %wave capex
col(2,:,3) = [204 204 255]/256; %wave opex
col(1,:,4) = [132 235 163]/256; %wind capex
col(2,:,4) = [204 255 204]/256; %wind opex
orpink(1,:) = [255,170,150];
orpink(2,:) = [255,170,159];
orpink(3,:) = [255,170,179];
orpink(4,:) = [255,170,195];
gcol = orpink(1,:);
bcol = gcol;
cycol = orpink(4,:);
cfcol = cycol;

%bar chart settings
NumGroupsPerAxis = size(costdata(:,:,:,1), 1);
NumStacksPerGroup = size(costdata(:,:,:,1), 2);
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.75;
groupOffset = MaxGroupWidth/NumStacksPerGroup;

%plot
for c = 1:nu
    
    ax(1,c) = subplot(7,nu,c+[0 2 4]);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(costdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h(i,:,c),'BarWidth',groupOffset);
        set(h(i,:,c),'XData',groupDrawPos);
        x = get(h(i,c),'XData');
        for j = 1:size(Y,1)
            text(x(j),sum(Y(j,:))+cbuff,pms{i}, ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
        %set colors and legend
        for lay = 1:cols
            h(i,lay,c).CData = col(lay,:,i);
        end
        if c == 1 && i == np
            leg = legend(h(:,1,c),pms,'Location','northeast');
            leg.FontSize = fs2;
            leg.Position(1) = .35;
            leg.Position(2) = .8;
            leg.Color = [255 255 245]/256;
        end
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    set(gca,'XTickLabel',[]);
    set(gca,'FontSize',fs2)
    if c == 1
        title(stt,'FontWeight','normal')
        drawnow
    else
        title(ltt,'FontWeight','normal')
    end
    set(gca,'Units','pixels')
    if c == 1
        ylabel({'Total','Estimated','Cost','[$1000s]'},'FontSize',fs2);
        ylh = get(gca,'ylabel');
        set(ylh,'Rotation',0,'Units', ...
            'Normalized','Position',[yaxhpos .5 -1], ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
    end
    grid on
    ylim([0 cmult*max(max(max(sum(costdata,3))))])
    linkaxes(ax(1,:),'y')
    
    ax(2,c) = subplot(7,nu,6+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(gendata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h2(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h2(i,c),'BarWidth',groupOffset);
        set(h2(i,c),'XData',groupDrawPos);
        h2(i,c).CData = gcol/256;
        x = get(h2(i,c),'XData');
        for j = 1:length(Y)
            tx = dpdata(j,i,1,c);
            text(x(j),Y(j)+gbuff,[ num2str(tx,3) ' m'], ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    %set(gca,'XTickLabel',opt.locations);
    set(gca,'FontSize',fs2)
    xtickangle(45)
    set(gca,'Units','pixels')
    if c == 1
        ylabel({'Cost-','Optimal','Generation','Capacity','[kW]'}, ...
            'FontSize',fs2);
        ylh = get(gca,'ylabel');
        set(ylh,'Rotation',0,'Units', ...
            'Normalized','Position',[yaxhpos .5 -1], ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
    end
    grid on
    ylim([0 gmult*max(gendata(:))])
    set(gca,'YTick',[0 10 20 30])
    linkaxes(ax(2,:),'y')
    
    ax(3,c) = subplot(7,nu,8+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(stordata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h3(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h3(i,c),'BarWidth',groupOffset);
        set(h3(i,c),'XData',groupDrawPos);
        h3(i,c).CData = bcol/256;
        x = get(h3(i,c),'XData');
        for j = 1:length(Y)
            tx = round(massdata(j,i,1,c));
            text(x(j),Y(j)+bbuff,[ num2str(tx,'%i') ' kg'], ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    %set(gca,'XTickLabel',opt.locations);
    set(gca,'FontSize',fs2)
    xtickangle(45)
    set(gca,'Units','pixels')
    if c == 1
        ylabel({'Cost-','Optimal','Storage','Capacity','[kWh]'}, ...
            'FontSize',fs2);
        ylh = get(gca,'ylabel');
        set(ylh,'Rotation',0,'Units', ...
            'Normalized','Position',[yaxhpos .5 -1], ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
    end
    grid on
    ylim([0 bmult*max(stordata(:))])
    set(gca,'YTick',[0 20 40 60 80 100])
    linkaxes(ax(3,:),'y')
    
    ax(4,c) = subplot(7,nu,10+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(Ldata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h4(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h4(i,c),'BarWidth',groupOffset);
        set(h4(i,c),'XData',groupDrawPos);
        h4(i,c).CData = cycol/256;
        x = get(h4(i,c),'XData');
        for j = 1:length(Y)
            tx = round(Y(j),1);
            text(x(j),Y(j)+blbuff,num2str(tx), ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
    yl = yline(20,'--','Battery End of Life = 20%', ...
        'Color',[0 0 0],'LabelVerticalAlignment', ...
        'top','LabelHorizontalAlignment','left','FontSize',fs, ...
        'LineWidth',.75,'FontName','calibri');
    if c == 2
        yl.Label = '';
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    set(gca,'FontSize',fs2)
    %set(gca,'XTickLabel',opt.locations);
    xtickangle(45)
    set(gca,'Units','pixels')
    axpos(4,c,:) = get(gca,'Position');
    if c == 1
        ylabel({'Battery','Capacity','Fade','[%]'},'FontSize',fs2);
        ylh = get(gca,'ylabel');
        set(ylh,'Rotation',0,'Units', ...
            'Normalized','Position',[yaxhpos .5 -1], ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
    end
    grid on
    ylim([0 blmult*max(Ldata(:))])
    set(gca,'XTickLabels',[])    
    linkaxes(ax(4,:),'y')
    
    ax(5,c) = subplot(7,nu,12+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(cfdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h5(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h5(i,c),'BarWidth',groupOffset);
        set(h5(i,c),'XData',groupDrawPos);
        h5(i,c).CData = cfcol/256;
        x = get(h5(i,c),'XData');
        for j = 1:length(Y)
            tx = round(Y(j),2);
            text(x(j),Y(j)+cfbuff,num2str(tx), ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
%     set(gca,'FontSize',fs2)
%     set(gca,'XTickLabel',xlab,'TickLabelInterpreter','latex', ...
%         'FontName','Calibri');
%     xtickangle(45)
    set(gca,'Units','pixels')
    if c == 1
        ylabel({'Capacity','Factor'},'FontSize',fs2);
        ylh = get(gca,'ylabel');
        set(ylh,'Rotation',0,'Units', ...
            'Normalized','Position',[yaxhpos .5 -1], ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
    end
    grid on
    ylim([0 cfmult*max(cfdata(:))])
    linkaxes(ax(5,:),'y')
    
end

set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 245]/256)
print(comparison_results_hl, ...
    '~/Dropbox (MREL)/Research/General Exam/pf/comparison_results_hl',  ...
    '-dpng','-r600')



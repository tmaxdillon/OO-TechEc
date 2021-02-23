clearvars -except allStruct
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

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
nc = 6; %number of costs
nl = size(allStruct,1); %number of locations
fixer = [1 2 3 4 5]; %select which locations to include 1:1:5 means all
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
            costdata(loc,pm,1,c) = ... %platform
                allStruct(loc,pm,c).output.min.Pinst/1000 + ...
                allStruct(loc,pm,c).output.min.Pmooring/1000;
            costdata(loc,pm,6,c) = ... %vessel
                allStruct(loc,pm,c).output.min.vesselcost/1000;
            costdata(loc,pm,3,c) = ... %storage capex
                allStruct(loc,pm,c).output.min.Scost/1000 + ...
                allStruct(loc,pm,c).output.min.battencl/1000;
            costdata(loc,pm,5,c) = ... %storage opex
                allStruct(loc,pm,c).output.min.battreplace/1000;
            if pm == 4 %wind-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.turbrepair/1000;            
            end
            if pm == 1 %inso-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.Mcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Ecost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000 + ...
                    allStruct(loc,pm,c).output.min.Strcost/1000;
            end
            if pm == 3 %wave-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.wecrepair/1000;
            end
            if pm == 2 %dies-specific 
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.genencl/1000;
                costdata(loc,pm,4,c) = ... %gen opex
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
comparison_results = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 6.5, 5.5])
fs = 6; %annotation font size
fs2 = 8; %axis font size
fs3 = 4; %eol font size
yaxhpos = -.25; %
cmult = 1.1; %cost axis multiplier
gmult = 1.9; %generation axis multiplier
bmult = 2.1; %battery axis multiplier
blmult = 3; %cycles axis multiplier 
cfmult = 1.5; %capacity factor axis multiplier
cbuff = 10; %cost text buffer
gbuff = 2; %generation text buffer
bbuff = 3;  %battery text buffer
blbuff = 1.5; %battery cycle text buffer
cfbuff = .05; %capacity factor text buffer

%titles and labels
stt = {'Short-Term Instrumentation'};
ltt = {'Long-Term Instrumentation'};
titles = {stt,ltt};
xlab = {'\begin{tabular}{l} Argentine \\ Basin \end{tabular}'; ...
    '\begin{tabular}{l} Coastal \\ Endurance \end{tabular}'; ...
    '\begin{tabular}{l} Coastal \\ Pioneer \end{tabular}'; ...
    '\begin{tabular}{l} Irminger \\ Sea \end{tabular}'; ...
    '\begin{tabular}{l} Southern \\ Ocean \end{tabular}'};
pms = {'Solar','Diesel','Wave','Wind'};
leg = {'Mooring','Gen CapEx','Battery CapEx','Gen OpEx', ...
    'Battery OpEx','Vessel'};

%colors
cols = 6;
col(1,:) = [0,0,51]/256; %platform cost
col([2 4],:) = flipud(brewermap(2,'purples')); %generation cost
col([3 5],:) = flipud(brewermap(2,'blues')); %storage cost
col(6,:) = [238,232,170]/256; %vessel cost
%gscol(1:5,:) = flipud(brewermap(5,'reds')); %generation capacity
%gscol(6:10,:) = flipud(brewermap(5,'oranges')); %storage capacity
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
    
    ax(1,c) = subplot(5,nu,c+[0 2 4]);
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
            h(i,lay,c).CData = col(lay,:);
        end
        if c == 1 && i == np
            leg = legend(h(i,:,c),leg,'Location','northeast');
            leg.FontSize = fs;
%             leg.Position(1) = .2;
%             leg.Position(2) = .72;
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
    
    ax(2,c) = subplot(5,nu,6+c);
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
    linkaxes(ax(2,:),'y')
    
    ax(3,c) = subplot(5,nu,8+c);
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
    set(gca,'XTickLabel',xlab,'TickLabelInterpreter','latex');
    set(gca,'FontSize',fs2)
    xtickangle(45)
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
    
end

print(comparison_results,['~/Dropbox (MREL)/Research/OO-TechEc/' ...
    'paper_figures/comparison_results_genex'],'-dpng','-r600')
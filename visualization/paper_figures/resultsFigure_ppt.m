clearvars -except wave_optd wave_optc wave_cons allStruct
close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

if ~exist('allStruct','var')
    load('waveoptd')
    load('waveoptc')
    load('wavecons')
    allStruct = mergeWaWaWa(waveoptd,waveoptc,wavecons);
end

np = 3; %number of power modules
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
                allStruct(fixer(loc),pm,c).output.min.Pinst/1000 + ...
                allStruct(fixer(loc),pm,c).output.min.Pmooring/1000;
            costdata(loc,pm,6,c) = ... %vessel
                allStruct(fixer(loc),pm,c).output.min.vesselcost/1000;
            costdata(loc,pm,3,c) = ... %storage capex
                allStruct(fixer(loc),pm,c).output.min.Scost/1000 + ...
                allStruct(fixer(loc),pm,c).output.min.battencl/1000;
            costdata(loc,pm,5,c) = ... %storage opex
                allStruct(fixer(loc),pm,c).output.min.battreplace/1000;
            costdata(loc,pm,2,c) = ... %gen capex
                allStruct(fixer(loc),pm,c).output.min.kWcost/1000 + ...
                allStruct(fixer(loc),pm,c).output.min.Icost/1000;
            costdata(loc,pm,4,c) = ... %gen opex
                allStruct(fixer(loc),pm,c).output.min.wecrepair/1000;
            gendata(loc,pm,1,c) =  ...
                allStruct(fixer(loc),pm,c).output.min.kW;
            stordata(loc,pm,1,c) = ...
                allStruct(fixer(loc),pm,c).output.min.Smax;
            Ldata(loc,pm,1,c) = ...
                100*max(allStruct(fixer(loc),pm,c).output.min.batt_L);
            cfdata(loc,pm,1,c) = ...
                allStruct(fixer(loc),pm,c).output.min.CF;
            massdata(loc,pm,1,c) = ...
                1000*allStruct(fixer(loc),pm,c).output.min.Smax/ ...
                (allStruct(fixer(loc),pm,c).batt.V* ...
                allStruct(fixer(loc),pm,c).batt.se);
            dpdata(loc,pm,1,c) =  ...
                allStruct(fixer(loc),pm,c).output.min.width;
        end
    end
end

%plotting setup
full_results = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 10, 6])
fs = 9; %annotation font size
fs2 = 11; %axis font size
yaxhpos = -.25; %
cmult = 1.35; %cost axis multiplier
gmult = 1.9; %generation axis multiplier
bmult = 2.1; %battery axis multiplier
blmult = 3; %battery cycle axis multiplier 
cfmult = 1.5; %capacity factor axis multiplier
cbuff = 10; %cost text buffer
gbuff = .23; %generation text buffer
bbuff = 5;  %battery text buffer
blbuff = 1.5; %battery cycle text buffer
cfbuff = .05; %capacity factor text buffer

%titles and labels
stt = {'Short-Term Instrumentation';'(planned interventions every six months)'};
ltt = {'Long-Term Instrumentation';'(no planned interventions)'};
titles = {stt,ltt};
xlab = {'\begin{tabular}{l} Argentine \\ Basin \end{tabular}'; ...
    '\begin{tabular}{l} Coastal \\ Endurance \end{tabular}'; ...
    '\begin{tabular}{l} Coastal \\ Pioneer \end{tabular}'; ...
    '\begin{tabular}{l} Irminger \\ Sea \end{tabular}'; ...
    '\begin{tabular}{l} Southern \\ Ocean \end{tabular}'};
pms = {'Optimistic Durability','Optimistic Cost','Conservative'};
leg = {'Mooring','WEC CapEx','Battery CapEx','WEC OpEx', ...
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
            h(i,lay,c).CData = col(lay,:);
        end
        if c == 1 && i == np
            leg = legend(h(i,:,c),leg,'Location','northeast', ...
                'Color',[255 255 245]/256);
            leg.FontSize = fs;
            leg.Position(1) = .345;
            leg.Position(2) = .8;
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
%         for j = 1:length(Y)
%             tx = dpdata(j,i,1,c);
%             text(x(j),Y(j)+gbuff,[ num2str(tx,3) ' m'], ...
%                 'Rotation',90, ...
%                 'HorizontalAlignment','left', ...
%                 'verticalAlignment','middle', ...
%                 'FontSize',fs)
%         end
    end
    yl = yline(.2,'--','200 W', ...
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
    %ylim([0 gmult*max(gendata(:))])
    ylim([0 3])
    %set(gca,'YTick',[0 1 2 3 4 5])
    set(gca,'XTickLabels',[])    
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
%         for j = 1:length(Y)
%             tx = round(massdata(j,i,1,c));
%             text(x(j),Y(j)+bbuff,[ num2str(tx,'%i') ' kg'], ...
%                 'Rotation',90, ...
%                 'HorizontalAlignment','left', ...
%                 'verticalAlignment','middle', ...
%                 'FontSize',fs)
%         end
    end
    yl = yline(50,'--','EV Battery Size', ...
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
    %set(gca,'XTickLabel',opt.locations);
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
    %ylim([0 bmult*max(stordata(:))])
    ylim([0 65])
    set(gca,'YTick',[0 20 40 60])
    set(gca,'XTickLabels',[])    
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
            text(x(j),Y(j)+blbuff,[num2str(tx) '%'], ...
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
            text(x(j),Y(j)+cfbuff,[num2str(tx)], ...
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
    set(gca,'FontSize',fs2)
    set(gca,'XTickLabel',xlab,'TickLabelInterpreter','latex');
    xtickangle(45)
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
print(full_results,'~/Dropbox (MREL)/Research/General Exam/pf/detailed_results',  ...
    '-dpng','-r600')
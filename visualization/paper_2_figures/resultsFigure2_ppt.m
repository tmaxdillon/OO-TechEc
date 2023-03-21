clearvars -except inau inhu wiod wico wodu woco wcon dgen allStruct
%close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

if ~exist('allStruct','var')
    allStruct = mergeEight(inau,inhu,wiod,wico,dgen,wodu,woco,wcon);
    allStruct([3 5],:,:) = []; %drop locations
    allStruct = allStruct(:,[1 2 3 4 6 7 8 5],:); %switch diesel and wave
    allStruct(:,[2 3 5 7],:) = []; %drop scenarios
    allStruct = allStruct(:,[3 1 2 4],:); %switch to ppt order
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
                allStruct(loc,pm,c).output.min.Pmtrl/1000 + ...
                allStruct(loc,pm,c).output.min.Pinst/1000 + ...
                allStruct(loc,pm,c).output.min.Pmooring/1000 + ...
                allStruct(loc,pm,c).output.min.Scost/1000 + ...
                allStruct(loc,pm,c).output.min.battencl/1000;
            costdata(loc,pm,2,c) = ... %opex
                allStruct(loc,pm,c).output.min.vesselcost/1000 + ...
                allStruct(loc,pm,c).output.min.battreplace/1000;
            if pm == 2 %inso-specific
                costdata(loc,pm,1,c) = costdata(loc,pm,1,c) + ... 
                    allStruct(loc,pm,c).output.min.Mcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Ecost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000 + ...
                    allStruct(loc,pm,c).output.min.Strcost/1000;
            end
            if pm == 3 %wind-specific
                costdata(loc,pm,1,c) = costdata(loc,pm,1,c) + ... 
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,2,c) = costdata(loc,pm,2,c) + ... 
                    allStruct(loc,pm,c).output.min.turbrepair/1000;            
            end
            if pm == 4 %dies-specific 
                costdata(loc,pm,1,c) = costdata(loc,pm,1,c) + ... 
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.genencl/1000;
                costdata(loc,pm,2,c) = costdata(loc,pm,2,c) + ... 
                    allStruct(loc,pm,c).output.min.genrepair/1000 + ...
                    allStruct(loc,pm,c).output.min.fuel/1000;
            end
            if pm == 1 %wave-specific 
                costdata(loc,pm,1,c) = costdata(loc,pm,1,c) + ... 
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,2,c) = costdata(loc,pm,2,c) + ... 
                    allStruct(loc,pm,c).output.min.wecrepair/1000;
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
results = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 6.5, 7])
fs = 8; %annotation font size
fs2 = 9; %axis font size
fs3 = 5.5; %eol font size
fs4 = 8; %legend font size
yaxhpos = -.2; %
cmult = 1.2; %cost axis multiplier
gmult = 2.5; %generation axis multiplier
bmult = 1.3; %battery axis multiplier
dmult = 1.1; %diameter axis multiplier
blmult = 2.1; %battery cycle axis multiplier 
cfmult = 1; %capacity factor axis multiplier
cbuff = 10; %cost text buffer
gbuff = .5; %generation text buffer
bbuff = 10;  %battery text buffer
dbuff = .35; %diameter text buffer
blbuff = 1.3; %battery cycle text buffer
cfbuff = .025; %capacity factor text buffer

%titles and labels
stt = {'Short-Term Instrumentation'};
ltt = {'Long-Term Instrumentation'};
titles = {stt,ltt};
xlab = {'\begin{tabular}{c} \\ Argentine \\ Basin \end{tabular}'; ...
    '\begin{tabular}{c} \\ Coastal \\ Endurance \end{tabular}'; ...
    '\begin{tabular}{c} \\ Irminger \\ Sea \end{tabular}'};
pms = {'Wave','Solar','Wind','Diesel'};
% leg = {'Mooring','Generation CapEx','Battery CapEx','Generation OpEx', ...
%     'Battery OpEx','Vessel'};

%colors
% cols = 6;
% col(1,:) = [0,0,51]/256; %platform cost
% col([2 4],:) = flipud(brewermap(2,'purples')); %generation cost
% col([3 5],:) = flipud(brewermap(2,'blues')); %storage cost
% col(6,:) = [238,232,170]/256; %vessel cost
cols = 2;
col(1,:,1) = [125,125,255]/256; %wave capex
col(2,:,1) = [200 200 255]/256; %wave opex
col(1,:,2) = [255 100 100]/256; %inso capex
col(2,:,2) = [255 170 170]/256; %inso opex
col(1,:,3) = [50 200 80]/256; %wind capex
col(2,:,3) = [200 255 200]/256; %wind opex
col(1,:,4) = [100 100 100]/256; %dies capex
col(2,:,4) = [175 175 175]/256; %dies opex
% orpink(1,:) = [255,170,150];
% orpink(2,:) = [255,170,159];
% orpink(3,:) = [255,170,179];
% orpink(4,:) = [255,170,195];
% gcol = orpink(1,:);
% bcol = gcol;
% cycol = orpink(4,:);
% cfcol = cycol;

%bar chart settings
NumGroupsPerAxis = size(costdata(:,:,:,1), 1);
NumStacksPerGroup = size(costdata(:,:,:,1), 2);
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.75;
groupOffset = MaxGroupWidth/NumStacksPerGroup;
% %SET BARS HARD CODE
% xbase = [0 3 6];
% subgap = .25;
% groupgap = .1;
% bwidth = 0.075;

%plot
for c = 1:nu
    
    ax(1,c) = subplot(8,nu,c+[0 2 4]);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(costdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h(i,:,c),'BarWidth',groupOffset);
        set(h(i,:,c),'XData',groupDrawPos);
%         if i == 1
%             xdatpos = xbase;
%         elseif i == 2
%             xdatpos = subgap+xbase;
%         elseif i == 3
%             xdatpos = 2*subgap+groupgap+xbase;
%         elseif i == 4
%             xdatpos = 3*subgap+groupgap+xbase;
%         elseif i == 5
%             xdatpos = 4*subgap+2*groupgap+xbase;
%         elseif i == 6
%             xdatpos = 5*subgap+2*groupgap+xbase;
%         elseif i == 7
%             xdatpos = 6*subgap+2*groupgap+xbase;
%         elseif i == 8
%             xdatpos = 7*subgap+3*groupgap+xbase;
%         end
%         set(h(i,:,c),'XData',xdatpos);
        %set colors
        for lay = 1:cols
            h(i,lay,c).CData = col(lay,:,i);
        end
        %set legend
        if c == 1 && i == np
            leg = legend(h(:,1,c),pms,'Location','northeast');
            leg.FontSize = fs4;
            leg.Position(1) = .35;
            leg.Position(2) = .85;
            leg.Color = [255 255 245]/256;
        end
        %set text
        x = get(h(i,c),'XData');
        for j = 1:size(Y,1)
            text(x(j),sum(Y(j,:))+cbuff,pms{i}, ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
%     xlim([-0.5 8.5])
%     set(h(:,:,c),'Barwidth',bwidth)
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);    
    set(gca,'XTickLabelMode','manual');
    set(gca,'XTickLabel',[]);
    set(gca,'FontSize',fs2)
%     if c == 1
%         title(stt,'FontWeight','normal')
%         drawnow
%     else
%         title(ltt,'FontWeight','normal')
%     end
    if c == 1
        ylabel({'Total','Estimated','Cost','[$1000s]'},'FontSize',fs2);
        ylh = get(gca,'ylabel');
        set(ylh,'Rotation',0,'Units', ...
            'Normalized','Position',[yaxhpos .5 -1], ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
    else
%         text(1.05,.5,'(a)','Units','Normalized', ...
%             'VerticalAlignment','middle','FontWeight','normal', ...
%             'FontSize',fs2);
        set(gca,'YTickLabel',[])
    end
    grid on
    ylim([0 cmult*max(max(max(sum(costdata,3))))])
    linkaxes(ax(1,:),'y')
    
    ax(2,c) = subplot(8,nu,6+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(gendata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h2(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h2(i,c),'BarWidth',groupOffset);
        set(h2(i,c),'XData',groupDrawPos);
%         if i == 1
%             xdatpos = xbase;
%             barcol = insocol;
%         elseif i == 2
%             xdatpos = subgap+xbase;
%             barcol = insocol;
%         elseif i == 3
%             xdatpos = 2*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 4
%             xdatpos = 3*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 5
%             xdatpos = 4*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 6
%             xdatpos = 5*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 7
%             xdatpos = 6*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 8
%             xdatpos = 7*subgap+3*groupgap+xbase;
%             barcol = dgencol;
%         end
%         set(h2(i,c),'XData',xdatpos);
        %set colors
        h2(i,c).CData = col(1,:,i);
        x = get(h2(i,c),'XData');
        for j = 1:length(Y)
            %tx = dpdata(j,i,1,c);
            tx = gendata(j,i,1,c);
            text(x(j),Y(j)+gbuff,[ num2str(tx,2) ' kW'], ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
%     xlim([-0.5 8.5])
%     set(h2(:,c),'Barwidth',bwidth)
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
    else
%         text(1.05,.5,'(b)','Units','Normalized', ...
%             'VerticalAlignment','middle','FontWeight','normal', ...
%             'FontSize',fs2);
        set(gca,'YTickLabel',[])
    end
    grid on
    ylim([0 gmult*max(gendata(:))])
    set(gca,'YTick',[0 5 10])
    linkaxes(ax(2,:),'y')
    
    ax(3,c) = subplot(8,nu,8+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(stordata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h3(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h3(i,c),'BarWidth',groupOffset);
        set(h3(i,c),'XData',groupDrawPos);
%         if i == 1
%             xdatpos = xbase;
%             barcol = insocol;
%         elseif i == 2
%             xdatpos = subgap+xbase;
%             barcol = insocol;
%         elseif i == 3
%             xdatpos = 2*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 4
%             xdatpos = 3*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 5
%             xdatpos = 4*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 6
%             xdatpos = 5*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 7
%             xdatpos = 6*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 8
%             xdatpos = 7*subgap+3*groupgap+xbase;
%             barcol = dgencol;
%         end
%         set(h3(i,c),'XData',xdatpos);
        %set colors
        h3(i,c).CData = col(1,:,i);
        x = get(h3(i,c),'XData');
        for j = 1:length(Y)
            tx = round(stordata(j,i,1,c));
            text(x(j),Y(j)+bbuff,[ num2str(tx,'%i') ' kWh'], ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
%     xlim([-0.5 8.5])
%     set(h4(:,c),'Barwidth',bwidth)
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
    else
%         text(1.05,.5,'(c)','Units','Normalized', ...
%             'VerticalAlignment','middle','FontWeight','normal', ...
%             'FontSize',fs2);
        set(gca,'YTickLabel',[])
    end
    grid on
    ylim([0 bmult*max(stordata(:))])
    set(gca,'YTick',[0 100 200 300 400 500])
    linkaxes(ax(3,:),'y')
    
    ax(4,c) = subplot(8,nu,10+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(dpdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h4(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h4(i,c),'BarWidth',groupOffset);
        set(h4(i,c),'XData',groupDrawPos);
%         if i == 1
%             xdatpos = xbase;
%             barcol = insocol;
%         elseif i == 2
%             xdatpos = subgap+xbase;
%             barcol = insocol;
%         elseif i == 3
%             xdatpos = 2*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 4
%             xdatpos = 3*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 5
%             xdatpos = 4*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 6
%             xdatpos = 5*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 7
%             xdatpos = 6*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 8
%             xdatpos = 7*subgap+3*groupgap+xbase;
%             barcol = dgencol;
%         end
%         set(h4(i,c),'XData',xdatpos);
        %set colors
        h4(i,c).CData = col(1,:,i);
        x = get(h4(i,c),'XData');
        for j = 1:length(Y)
            tx = dpdata(j,i,1,c);
            text(x(j),Y(j)+dbuff,[num2str(tx,2) ' m'], ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
%     xlim([-0.5 8.5])
%     set(h4(:,c),'Barwidth',bwidth)
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    %set(gca,'XTickLabel',opt.locations);
    set(gca,'FontSize',fs2)
    xtickangle(45)
    if c == 1
        ylabel({'Cost-','Optimal','Platform','Diameter','[m]'}, ...
            'FontSize',fs2);
        ylh = get(gca,'ylabel');
        set(ylh,'Rotation',0,'Units', ...
            'Normalized','Position',[yaxhpos .5 -1], ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
    else
%         text(1.05,.5,'(d)','Units','Normalized', ...
%             'VerticalAlignment','middle','FontWeight','normal', ...
%             'FontSize',fs2);
        set(gca,'YTickLabel',[])
    end
    grid on
    ylim([0 dmult*max(dpdata(:))])
    set(gca,'YTick',[0 2.5 5 7.5 10])
    linkaxes(ax(4,:),'y')
    
    ax(5,c) = subplot(8,nu,12+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(Ldata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h5(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h5(i,c),'BarWidth',groupOffset);
        set(h5(i,c),'XData',groupDrawPos);
%         if i == 1
%             xdatpos = xbase;
%             barcol = insocol;
%         elseif i == 2
%             xdatpos = subgap+xbase;
%             barcol = insocol;
%         elseif i == 3
%             xdatpos = 2*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 4
%             xdatpos = 3*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 5
%             xdatpos = 4*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 6
%             xdatpos = 5*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 7
%             xdatpos = 6*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 8
%             xdatpos = 7*subgap+3*groupgap+xbase;
%             barcol = dgencol;
%         end
%         set(h6(i,c),'XData',xdatpos);
        %set colors
        h5(i,c).CData = col(1,:,i);
        x = get(h5(i,c),'XData');
        for j = 1:length(Y)
            tx = round(Y(j),1);
            text(x(j),Y(j)+blbuff,num2str(tx), ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
%     xlim([-0.5 8.5])
%     set(h6(:,c),'Barwidth',bwidth)
    yl = yline(20,'--','Battery End of Life, \sigma_{EoL} = 20%', ...
        'Color',[.9 0 .2],'LabelVerticalAlignment', ...
    'bottom','LabelHorizontalAlignment','left','FontSize',fs3, ...
    'LineWidth',.75,'FontName','cmr10');
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
    else
%         text(1.05,.5,'(e)','Units','Normalized', ...
%             'VerticalAlignment','middle','FontWeight','normal', ...
%             'FontSize',fs2);
        set(gca,'YTickLabel',[])
    end
    grid on
    ylim([0 blmult*max(Ldata(:))])
    %set(gca,'YTick',[0 10 20 30 40])
    set(gca,'XTickLabels',[])
    linkaxes(ax(5,:),'y')
    
    ax(6,c) = subplot(8,nu,14+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(cfdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h6(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h6(i,c),'BarWidth',groupOffset);
        set(h6(i,c),'XData',groupDrawPos);
%         if i == 1
%             xdatpos = xbase;
%             barcol = insocol;
%         elseif i == 2
%             xdatpos = subgap+xbase;
%             barcol = insocol;
%         elseif i == 3
%             xdatpos = 2*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 4
%             xdatpos = 3*subgap+groupgap+xbase;
%             barcol = windcol;
%         elseif i == 5
%             xdatpos = 4*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 6
%             xdatpos = 5*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 7
%             xdatpos = 6*subgap+2*groupgap+xbase;
%             barcol = wavecol;
%         elseif i == 8
%             xdatpos = 7*subgap+3*groupgap+xbase;
%             barcol = dgencol;
%         end
%         set(h6(i,c),'XData',xdatpos);
        %set colors
        h6(i,c).CData = col(1,:,i);
        x = get(h6(i,c),'XData');
        for j = 1:length(Y)
            tx = round(Y(j),2);
            text(x(j),Y(j)+cfbuff,num2str(tx,3), ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
%     xlim([-0.5 8.5])
%     set(h6(:,c),'Barwidth',bwidth)
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    set(gca,'FontSize',fs2)
    set(gca,'XTickLabel',xlab,'TickLabelInterpreter','latex');
    xtickangle(0)
    if c == 1
        ylabel({'Capacity','Factor'},'FontSize',fs2);
        ylh = get(gca,'ylabel');
        set(ylh,'Rotation',0,'Units', ...
            'Normalized','Position',[yaxhpos .5 -1], ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center')
    else
%         text(1.05,.5,'(f)','Units','Normalized', ...
%             'VerticalAlignment','middle','FontWeight','normal', ...
%             'FontSize',fs2);
        set(gca,'YTickLabel',[])
    end
    grid on
    ylim([0 cfmult*max(cfdata(:))])
    set(gca,'YTick',[0 .2 .4 .6 ])
    linkaxes(ax(6,:),'y')
    
end

%widen axes
for i = 1:size(ax,1)
    xw = 2.6;
    set(ax(i,:),'Units','Inches')
    axdim1 = get(ax(i,1),'Position');
    set(ax(i,1),'Position',[axdim1(1) axdim1(2) xw axdim1(4)])
    axdim2 = get(ax(i,2),'Position');
    set(ax(i,2),'Position',[axdim1(1)+xw+0.1 axdim2(2) xw axdim2(4)])
end

%heighten axes
for i = size(ax,1):-1:1
    yh = .65;
    yo = .5;
    ym = .2;
    set(ax(i,:),'Units','Inches')
    axdim1 = get(ax(i,1),'Position');
    if i == 1
        set(ax(i,1),'Position',[axdim1(1) yo+(6-i)*(yh+ym) axdim1(3) 3*yh])
    else
        set(ax(i,1),'Position',[axdim1(1) yo+(6-i)*(yh+ym) axdim1(3) yh])
    end
    axdim2 = get(ax(i,2),'Position');
    if i == 1
        set(ax(i,2),'Position',[axdim2(1) yo+(6-i)*(yh+ym) axdim2(3) 3*yh])
    else
        set(ax(i,2),'Position',[axdim2(1) yo+(6-i)*(yh+ym) axdim2(3) yh])
    end
end

%turn off ticks
for i = 1:size(ax,1)
    for j = 1:size(ax,2)
        ax(i,j).TickLength = [0 0];
    end
end


set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 245]/256)
print(results,['~/Dropbox (MREL)/Research/Defense/' ...
    'presentation_figures/results_1'],'-dpng','-r600')


function [] = visEight(pm1,pm2,pm3,pm4,pm5,pm6,pm7,pm8)

allStruct = mergeEight(pm1,pm2,pm3,pm4,pm5,pm6,pm7,pm8);

np = 8; %number of power modules
nc = 6; %number of costs
nl = size(pm1,1); %number of locations
nu = size(pm1,2); %number of use cases

%initialize/preallocate
costdata = zeros(nl,np,nc,nu);
gendata = zeros(nl,np,nc,nu);
stordata = zeros(nl,np,nc,nu);
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
                allStruct(loc,pm,c).output.min.Pmtrl/1000 + ...
                allStruct(loc,pm,c).output.min.Pinst/1000 + ...
                allStruct(loc,pm,c).output.min.Pmooring/1000;
            costdata(loc,pm,6,c) = ... %vessel
                 allStruct(loc,pm,c).output.min.vesselcost/1000;
            costdata(loc,pm,3,c) = ... %storage capex
                allStruct(loc,pm,c).output.min.Scost/1000 + ...
                allStruct(loc,pm,c).output.min.battencl/1000;
            costdata(loc,pm,5,c) = ... %storage opex
                allStruct(loc,pm,c).output.min.battreplace/1000;
            if pm == 1 || pm == 2 %inso-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.Mcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Ecost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000 + ...
                    allStruct(loc,pm,c).output.min.Strcost/1000;
            end
            if pm == 3 || pm == 4 %wind-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.turbrepair/1000;            
            end
            if pm == 5 %dies-specific 
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.genencl/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.genrepair/1000 + ...
                    allStruct(loc,pm,c).output.min.fuel/1000;
            end
            if pm == 6 || pm == 7 || pm == 8 %wave-specific 
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,4,c) = ... %gen opex
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

figure
set(gcf, 'Position', [850, 100, 1100, 1100])
fs = 6; %annotation font size
fs2 = 8; %axis font size
fs3 = 4; %eol font size
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

%plotting setup
NumGroupsPerAxis = size(costdata(:,:,:,1), 1);
NumStacksPerGroup = size(costdata(:,:,:,1), 2);
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.75;
groupOffset = MaxGroupWidth/NumStacksPerGroup;
titles = {'Short Term Instrumentation'; ...
    'Long Term Instrumentation'};
pms = {'Solar: Auto','Solar: Human','Wind: OptD','Wind: Cons', ...
    'Diesel','WEC: OptD','WEC: OptC','WEC: Cons'};
leg = {'Mooring','Generation CapEx', ...
    'Battery CapEx','Generation OpEx', ...
    'Battery OpEx','Vessel'};

%colors
cols = 6;
col(1,:) = [0,0,51]/256; %platform cost
col([2 4],:) = flipud(brewermap(2,'purples')); %generation cost
col([3 5],:) = flipud(brewermap(2,'blues')); %storage cost
col(6,:) = [238,232,170]/256; %vessel cost
orpink(1,:) = [255,170,150];
orpink(2,:) = [255,170,159];
orpink(3,:) = [255,170,179];
orpink(4,:) = [255,170,195];
gcol = orpink(1,:);
bcol = gcol;
cycol = orpink(4,:);
cfcol = cycol;

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
        if c == 2 && i == np
            legend(h(i,:,c),leg,'Location','best')
        end
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    set(gca,'XTickLabel',[]);
    %set(gca,'XTickLabel',opt.locations);
    xtickangle(45)
    title(titles(c))
    if c == 1
        ylabel('Total Cost [$1000]')
    end
    grid on
    
    ax(2,c) = subplot(7,nu,6+c);
    hold on
    for i = 1:NumStacksPerGroup        
        Y = squeeze(gendata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h2(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h2(i,:,c),'BarWidth',groupOffset);
        set(h2(i,:,c),'XData',groupDrawPos);
        h2(i,1,c).CData = gcol/256;
        x = get(h2(i,c),'XData');
        for j = 1:size(Y,1)
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
    set(gca,'XTickLabel',[]);
    %set(gca,'XTickLabel',opt.locations);
    xtickangle(45)
    if c == 1
        ylabel({'Generation','Capacity [kW]'})
    end
    grid on
    
    ax(3,c) = subplot(7,nu,8+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(stordata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h3(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h3(i,:,c),'BarWidth',groupOffset);
        set(h3(i,:,c),'XData',groupDrawPos);
        h3(i,1,c).CData = bcol/256;
        x = get(h3(i,c),'XData');
        for j = 1:size(Y,1)
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
    set(gca,'XTickLabel',[]);
    xtickangle(45)
    if c == 1
        ylabel({'Storage','Capacity [kWh]'})
    else
        ylabel({''})
    end
    grid on
    
    ax(4,c) = subplot(7,nu,10+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(Ldata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h4(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h4(i,:,c),'BarWidth',groupOffset);
        set(h4(i,:,c),'XData',groupDrawPos);
        h4(i,c).CData = cycol/256;
        x = get(h4(i,c),'XData');
        for j = 1:size(Y,1)
            tx = round(Y(j),1);
            text(x(j),Y(j)+blbuff,num2str(tx), ...
                'Rotation',90, ...
                'HorizontalAlignment','left', ...
                'verticalAlignment','middle', ...
                'FontSize',fs)
        end
    end
    yl = yline(20,'--','Battery End of Life, \sigma_{EoL} = 20%', ...
        'Color',[.9 0 .2],'LabelVerticalAlignment', ...
    'top','LabelHorizontalAlignment','left','FontSize',fs, ...
    'LineWidth',.75,'FontName','cmr10');
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    set(gca,'XTickLabel',[]);
    xtickangle(45)
    if c == 1
        ylabel({'Battery','Capacity','Fade','[%]'})
    end
    grid on
    
    ax(5,c) = subplot(7,nu,12+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(cfdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h5(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h5(i,:,c),'BarWidth',groupOffset);
        set(h5(i,:,c),'XData',groupDrawPos);
        h5(i,c).CData = cfcol/256;
        x = get(h5(i,c),'XData');
        for j = 1:size(Y,1)
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
    set(gca,'XTickLabel',opt.locations);
    xtickangle(45)
    if c == 1
        ylabel({'Capacity','Factor'})
    end
    grid on
    
end

end


function [] = visWaveWindInso(allDimStruct,waveScenStruct)

%merge to one structure
allStruct = mergeStructures(allDimStruct,waveScenStruct);

%initialize/preallocate
n = 5;
costdata = zeros(size(allStruct,1),size(allStruct,2),n,size(allStruct,3));
gendata = zeros(size(allStruct,1),size(allStruct,2),size(allStruct,2), ... 
    size(allStruct,3));
stordata = zeros(size(allStruct,1),size(allStruct,2),size(allStruct,2), ... 
    size(allStruct,3));

%unpack inso/
opt = allStruct(1,1,1).opt;
for loc = 1:size(allStruct,1)
    for pm = 1:size(allStruct,2)
        for c = 1:size(allStruct,3)
            costdata(loc,pm,2,c) = ... %storage capex
                allStruct(loc,pm,c).output.min.Scost/1000 + ...
                allStruct(loc,pm,c).output.min.platform/1000 + ...
                allStruct(loc,pm,c).output.min.battencl/1000;
            costdata(loc,pm,4,c) = ... %storage opex
                allStruct(loc,pm,c).output.min.battreplace/1000; %storage op
            costdata(loc,pm,5,c) = ... %vessel
                 allStruct(loc,pm,c).output.min.vesselcost/1000;
            if pm == 2 %wind-specific
                costdata(loc,pm,1,c) = ...
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.FScost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,3,c) = ...
                    allStruct(loc,pm,c).output.min.turbrepair/1000 + ...
                    allStruct(loc,pm,c).output.min.maint/1000;
            end
            if pm == 1 %inso-specific
                costdata(loc,pm,1,c) = ...
                    allStruct(loc,pm,c).output.min.Mcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Ecost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,3,c) = ...
                    allStruct(loc,pm,c).output.min.PVreplace/1000 + ...
                    allStruct(loc,pm,c).output.min.maint/1000;
            end
            if pm == 3 || pm == 4 %wave conservative-specific
                costdata(loc,pm,1,c) = ...
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.FScost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000; %wec cap
                costdata(loc,pm,3,c) = ...
                    allStruct(loc,pm,c).output.min.wecrepair/1000 + ...
                    allStruct(loc,pm,c).output.min.maint/1000; %wec op
            end
            gendata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.kW;
            stordata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.Smax;
        end
    end
end

%plotting setup
NumGroupsPerAxis = size(costdata(:,:,:,1), 1);
NumStacksPerGroup = size(costdata(:,:,:,1), 2);
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.75;
groupOffset = MaxGroupWidth/NumStacksPerGroup;
titles = {'Short Term Instrumentation'; ...
    'Long Term Instrumentation';'Infrastructure'};
leg = {'Generation CapEx','Storage CapEx','Generation OpEx', ...
    'Storage OpEx','Vessel'};

%colors
cols = 5;
col([1 3],:) = flipud(colormap(brewermap(2,'purples'))); %generation cost
col([2 4],:) = flipud(colormap(brewermap(2,'blues'))); %storage cost
col(5,:) = [238,232,170]/256; %vessel cost

gscol(1:5,:) = flipud(colormap(brewermap(5,'reds'))); %generation capacity
gscol(6:10,:) = flipud(colormap(brewermap(5,'oranges'))); %storage capacity


%plot
figure
set(gcf, 'Position', [850, 100, 1100, 1100])
for c = 1:size(allStruct,3)
    ax(1,c) = subplot(6,3,c+[0 3 6 9]);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(costdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h(i,:,c),'BarWidth',groupOffset);
        set(h(i,:,c),'XData',groupDrawPos);
        %set colors and legend
        for lay = 1:cols
            h(i,lay,c).CData = col(lay,:);
        end
        if c == 2 && i == size(allStruct,2)
            legend(h(i,:,c),leg,'Location','best')
        end
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    %set(gca,'XTickLabel',opt.locations);
    xtickangle(45)
    title(titles(c))
    if c == 1
        ylabel('Total Cost [$1000]')
    end
    grid on
    
    ax(2,c) = subplot(6,3,12+c);
    hold on
    for i = 1:NumStacksPerGroup        
        Y = squeeze(gendata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h2(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h2(i,:,c),'BarWidth',groupOffset);
        set(h2(i,:,c),'XData',groupDrawPos);
        for lay = 1:NumStacksPerGroup
%             colind = [4 4 4 4];
%             h2(i,lay,c).CData = gscol(colind(lay),:);
	            h2(i,lay,c).CData = [255,170,150]/256;
        end
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    %set(gca,'XTickLabel',opt.locations);
    xtickangle(45)
    if c == 1
        ylabel({'Generation','Capacity [kW]'})
    end
    grid on
    
    ax(3,c) = subplot(6,3,15+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(stordata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h3(i,:,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h3(i,:,c),'BarWidth',groupOffset);
        set(h3(i,:,c),'XData',groupDrawPos);
        for lay = 1:NumStacksPerGroup
%             colind = [3 3 3 3];
%             h3(i,lay,c).CData = gscol(colind(lay),:);
            h3(i,lay,c).CData = [255,170,159]/256;
        end
    end
    hold off;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:NumGroupsPerAxis);
    set(gca,'XTickLabelMode','manual');
    set(gca,'XTickLabel',opt.locations);
    xtickangle(45)
    if c == 1
        ylabel({'Storage','Capacity [kWh]'})
    end
    grid on
    
end







end


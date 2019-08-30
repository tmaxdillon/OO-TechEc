function [] = useCaseBars(allDimStruct,detail)
if ~detail
    costdata = zeros(size(allDimStruct,1),size(allDimStruct,2),4, ...
        size(allDimStruct,3));
else
    costdata = zeros(size(allDimStruct,1),size(allDimStruct,2),7, ...
        size(allDimStruct,3));
end
gendata = zeros(size(allDimStruct));
stordata = zeros(size(allDimStruct));
%unpack
opt = allDimStruct(1,1,1).opt;
for loc = 1:size(allDimStruct,1)
    for pm = 1:size(allDimStruct,2)
        for c = 1:size(allDimStruct,3)
            if ~detail
                if pm == 1
                    costdata(loc,pm,1,c) = ... 
                        allDimStruct(loc,pm,c).output.min.CapEx/1000;
                    costdata(loc,pm,2,c) = ... 
                        allDimStruct(loc,pm,c).output.min.OpEx/1000;
                    gendata(loc,pm,1,c) = ...
                        allDimStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,1,c) = ...
                        allDimStruct(loc,pm,c).output.min.Smax; %storage capacity
                elseif pm == 2
                    costdata(loc,pm,3,c) = ...
                        allDimStruct(loc,pm,c).output.min.CapEx/1000;
                    costdata(loc,pm,4,c) = ... 
                        allDimStruct(loc,pm,c).output.min.OpEx/1000;
                    gendata(loc,pm,2,c) = ...
                        allDimStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,2,c) = ...
                        allDimStruct(loc,pm,c).output.min.Smax; %storage capacity
                end
            else
                costdata(loc,pm,3,c) = ...
                    allDimStruct(loc,pm,c).output.min.Scost/1000 + ...
                    allDimStruct(loc,pm,c).output.min.platform/1000 + ...
                    allDimStruct(loc,pm,c).output.min.battencl/1000; %storage cap
                costdata(loc,pm,6,c) = ...
                    allDimStruct(loc,pm,c).output.min.battreplace/1000; %storage op
                costdata(loc,pm,7,c) = ...
                    allDimStruct(loc,pm,c).output.min.vesselcost/1000; %vessel ops
                if pm == 1
                    costdata(loc,pm,1,c) = ...
                        allDimStruct(loc,pm,c).output.min.kWcost/1000 + ...
                        allDimStruct(loc,pm,c).output.min.FScost/1000 + ...
                        allDimStruct(loc,pm,c).output.min.Icost/1000; %wind cap
                    costdata(loc,pm,4,c) = ...
                        allDimStruct(loc,pm,c).output.min.turbrepair/1000 + ...
                        allDimStruct(loc,pm,c).output.min.maint/1000; %wind op
                    gendata(loc,pm,1,c) = ...
                        allDimStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,1,c) = ...
                        allDimStruct(loc,pm,c).output.min.Smax; %storage capacity
                elseif pm == 2
                    costdata(loc,pm,2,c) = ...
                        allDimStruct(loc,pm,c).output.min.Mcost/1000 + ...
                        allDimStruct(loc,pm,c).output.min.Ecost/1000 + ...
                        allDimStruct(loc,pm,c).output.min.Icost/1000; %solar cap
                    costdata(loc,pm,5,c) = ...
                        allDimStruct(loc,pm,c).output.min.PVreplace/1000 + ...
                        allDimStruct(loc,pm,c).output.min.maint/1000; %solar op
                    gendata(loc,pm,2,c) = ...
                        allDimStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,2,c) = ...
                        allDimStruct(loc,pm,c).output.min.Smax; %storage capacity
                end
            end
        end
    end
end

%plotting
NumGroupsPerAxis = size(costdata(:,:,:,1), 1);
NumStacksPerGroup = size(costdata(:,:,:,1), 2);
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.75;
groupOffset = MaxGroupWidth/NumStacksPerGroup;
titles = {'Short Term Instrumentation'; ...
    'Long Term Instrumentation';'Infrastructure'};
if ~detail
    leg = {'Wind System CapEx','Wind System OpEx', ...
        'Solar System CapEx','Solar System OpEx'};
else
    leg = {'Wind CapEx','Solar CapEx','Storage CapEx','Wind OpEx', ...
    'Solar OpEx','Storage OpEx','Vessel'};
end

%colors
cols = 4;
col(1:2,:) = flipud(colormap(brewermap(2,'greens')));
col(3:4,:) = flipud(colormap(brewermap(2,'reds')));
dcols = 7;
dcol([1 4],:) = flipud(colormap(brewermap(2,'greens')));
dcol([2 5],:) = flipud(colormap(brewermap(2,'reds')));
dcol([3 6],:) = flipud(colormap(brewermap(2,'blues')));
dcol(7,:) = [238,232,170]/256;

figure
set(gcf, 'Position', [850, 100, 800, 1100])
for c = 1:size(allDimStruct,3)
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
        if ~detail
            for lay = 1:cols
                h(i,lay,c).CData = col(lay,:);
            end
            if c == 1
                legend(h(1,:,c),leg,'Location','northeast')
            end
        else
            for lay = 1:dcols
                h(i,lay,c).CData = dcol(lay,:);
            end
            if c == 1 && i == 2
                legend(h(i,:,c),leg,'Location','best')
            end
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
        for lay = 1:2
            colind = 1:2;
            %col2(1,:) = [88,205,75]/256;
            %col2(2,:) = [255,69,0]/256;
            h2(i,lay,c).CData = dcol(colind(lay),:);
            %h2(i,lay,c).CData = col2(lay,:);
        end
        if c == 1
            legend(h2(1,[1 2],c),'Wind','Solar','location','best')
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
        for lay = 1:2
            colind = [3 3];
            h3(i,lay,c).CData = dcol(colind(lay),:);
            %h3(i,lay,c).CData = [100,149,237]/256;
        end
        if c == 1
            legend(h3(1,1,c),'Storage','location','northwest')
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




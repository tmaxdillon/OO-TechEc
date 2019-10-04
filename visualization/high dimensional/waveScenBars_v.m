function [] = waveScenBars_v(waveScenStruct,detail)

detail_n = 5;
simple_n = 2;

if ~detail
    costdata = zeros(size(waveScenStruct,1),size(waveScenStruct,2),simple_n, ...
        size(waveScenStruct,3));
else
    costdata = zeros(size(waveScenStruct,1),size(waveScenStruct,2),detail_n, ...
        size(waveScenStruct,3));
end
gendata = zeros(size(waveScenStruct));
stordata = zeros(size(waveScenStruct));
%unpack
opt = waveScenStruct(1,1,1).opt;
for loc = 1:size(waveScenStruct,1)
    for pm = 1:size(waveScenStruct,2)
        for c = 1:size(waveScenStruct,3)
            if ~detail
                costdata(loc,pm,1,c) = ...
                    waveScenStruct(loc,pm,c).output.min.CapEx/1000;
                costdata(loc,pm,2,c) = ... 
                        waveScenStruct(loc,pm,c).output.min.OpEx/1000;
                if pm == 1
                    gendata(loc,pm,1,c) = ...
                        waveScenStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,1,c) = ...
                        waveScenStruct(loc,pm,c).output.min.Smax; %storage capacity
                elseif pm == 2
                    gendata(loc,pm,2,c) = ...
                        waveScenStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,2,c) = ...
                        waveScenStruct(loc,pm,c).output.min.Smax; %storage capacity
                elseif pm == 3
                    gendata(loc,pm,3,c) = ...
                        waveScenStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,3,c) = ...
                        waveScenStruct(loc,pm,c).output.min.Smax; %storage capacity
                end
            else
                costdata(loc,pm,1,c) = ...
                    waveScenStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    waveScenStruct(loc,pm,c).output.min.FScost/1000 + ...
                    waveScenStruct(loc,pm,c).output.min.Icost/1000; %wec cap
                costdata(loc,pm,3,c) = ...
                    waveScenStruct(loc,pm,c).output.min.wecrepair/1000 + ...
                    waveScenStruct(loc,pm,c).output.min.maint/1000; %wec op
                costdata(loc,pm,2,c) = ...
                    waveScenStruct(loc,pm,c).output.min.Scost/1000 + ...
                    waveScenStruct(loc,pm,c).output.min.platform/1000 + ...
                    waveScenStruct(loc,pm,c).output.min.battencl/1000; %storage cap
                costdata(loc,pm,4,c) = ...
                    waveScenStruct(loc,pm,c).output.min.battreplace/1000; %storage op
                costdata(loc,pm,5,c) = ...
                    waveScenStruct(loc,pm,c).output.min.vesselcost/1000; %vessel ops
                if pm == 1
                    gendata(loc,pm,1,c) = ...
                        waveScenStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,1,c) = ...
                        waveScenStruct(loc,pm,c).output.min.Smax; %storage capacity
                elseif pm == 2
                    gendata(loc,pm,2,c) = ...
                        waveScenStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,2,c) = ...
                        waveScenStruct(loc,pm,c).output.min.Smax; %storage capacity
                elseif pm == 3
                    gendata(loc,pm,3,c) = ...
                        waveScenStruct(loc,pm,c).output.min.kW; %generation capacity
                    stordata(loc,pm,3,c) = ...
                        waveScenStruct(loc,pm,c).output.min.Smax; %storage capacity
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
    leg = {'System CapEx','System OpEx'};
else
    leg = {'WEC CapEx','Storage CapEx','WEC OpEx','Storage OpEx','Vessel'};
end

%colors
cols = 2;
col(1:2,:) = flipud(colormap(brewermap(2,'purples')));
dcols = 5;
dcol([1 3],:) = flipud(colormap(brewermap(2,'purples')));
dcol([2 4],:) = flipud(colormap(brewermap(2,'blues')));
dcol(5,:) = [238,232,170]/256;

figure
set(gcf, 'Position', [850, 100, 800, 1100])
for c = 1:size(waveScenStruct,3)
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
            if c == 2
                legend(h(1,:,c),leg,'Location','northeast')
            end
        else
            for lay = 1:dcols
                h(i,lay,c).CData = dcol(lay,:);
            end
            if c == 2 && i == 3
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
        for lay = 1:NumStacksPerGroup
            colind = [1 1 1];
            %col2(1,:) = [88,205,75]/256;
            %col2(2,:) = [255,69,0]/256;
            h2(i,lay,c).CData = dcol(colind(lay),:);
            %h2(i,lay,c).LineWidth = 1.5;
            %h2(i,lay,c).EdgeColor = dcol(colind(lay),:);
            %h2(i,lay,c).CData = col2(lay,:);
        end
        if c == 1
            %legend(h2(1,[1 2],c),'Conservative','Solar','location','best')
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
            colind = [2 2 2];
            h3(i,lay,c).CData = dcol(colind(lay),:);
            %h3(i,lay,c).LineWidth = 1.5;
            %h3(i,lay,c).EdgeColor = dcol(colind(lay),:);
            %h3(i,lay,c).CData = [100,149,237]/256;
        end
        if c == 1
            %legend(h3(1,1,c),'Storage','location','northwest')
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




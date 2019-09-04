function [] = waveScenBars_h(waveScenStruct,detail)

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
    for scen = 1:size(waveScenStruct,2)
        for c = 1:size(waveScenStruct,3)
            if ~detail
                costdata(loc,scen,1,c) = ...
                    waveScenStruct(loc,scen,c).output.min.CapEx/1000;
                costdata(loc,scen,2,c) = ... 
                        waveScenStruct(loc,scen,c).output.min.OpEx/1000;
                if scen == 1
                    gendata(loc,scen,1,c) = ...
                        waveScenStruct(loc,scen,c).output.min.kW; %generation capacity
                    stordata(loc,scen,1,c) = ...
                        waveScenStruct(loc,scen,c).output.min.Smax; %storage capacity
                elseif scen == 2
                    gendata(loc,scen,2,c) = ...
                        waveScenStruct(loc,scen,c).output.min.kW; %generation capacity
                    stordata(loc,scen,2,c) = ...
                        waveScenStruct(loc,scen,c).output.min.Smax; %storage capacity
                elseif scen == 3
                    gendata(loc,scen,3,c) = ...
                        waveScenStruct(loc,scen,c).output.min.kW; %generation capacity
                    stordata(loc,scen,3,c) = ...
                        waveScenStruct(loc,scen,c).output.min.Smax; %storage capacity
                end
            else
                costdata(loc,scen,1,c) = ...
                    waveScenStruct(loc,scen,c).output.min.kWcost/1000 + ...
                    waveScenStruct(loc,scen,c).output.min.FScost/1000 + ...
                    waveScenStruct(loc,scen,c).output.min.Icost/1000; %wec cap
                costdata(loc,scen,3,c) = ...
                    waveScenStruct(loc,scen,c).output.min.wecrepair/1000 + ...
                    waveScenStruct(loc,scen,c).output.min.maint/1000; %wec op
                costdata(loc,scen,2,c) = ...
                    waveScenStruct(loc,scen,c).output.min.Scost/1000 + ...
                    waveScenStruct(loc,scen,c).output.min.platform/1000 + ...
                    waveScenStruct(loc,scen,c).output.min.battencl/1000; %storage cap
                costdata(loc,scen,4,c) = ...
                    waveScenStruct(loc,scen,c).output.min.battreplace/1000; %storage op
                costdata(loc,scen,5,c) = ...
                    waveScenStruct(loc,scen,c).output.min.vesselcost/1000; %vessel ops
                if scen == 1
                    gendata(loc,scen,1,c) = ...
                        waveScenStruct(loc,scen,c).output.min.kW; %generation capacity
                    stordata(loc,scen,1,c) = ...
                        waveScenStruct(loc,scen,c).output.min.Smax; %storage capacity
                elseif scen == 2
                    gendata(loc,scen,2,c) = ...
                        waveScenStruct(loc,scen,c).output.min.kW; %generation capacity
                    stordata(loc,scen,2,c) = ...
                        waveScenStruct(loc,scen,c).output.min.Smax; %storage capacity
                elseif scen == 3
                    gendata(loc,scen,3,c) = ...
                        waveScenStruct(loc,scen,c).output.min.kW; %generation capacity
                    stordata(loc,scen,3,c) = ...
                        waveScenStruct(loc,scen,c).output.min.Smax; %storage capacity
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
hold on
for c = 1:size(waveScenStruct,3)
    %ax(1,c) = subplot(6,3,c+[0 3 6 9]);
    ax(1,c) = subplot(3,6,(c-1)*6+[1:4]);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(costdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h(i,:,c) = barh(Y, 'stacked','FaceColor','flat');
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
            if c == 1 && i == 3
                legend(h(i,:,c),leg,'Location','best')
            end
        end
    end
    hold off;
    set(gca,'YTickMode','manual');
    set(gca,'YTick',1:NumGroupsPerAxis);
    set(gca,'YTickLabelMode','manual');
    set(gca,'YTickLabel',opt.locations);
    ytickangle(45)
    title(titles(c))
    if c == 3
        xlabel('Total Cost [$1000]')
    end
    grid on
    
    %ax(2,c) = subplot(6,3,12+c);
    ax(2,c) = subplot(3,6,(c-1)*6+5);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(gendata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h2(i,:,c) = barh(Y, 'stacked','FaceColor','flat');
        set(h2(i,:,c),'BarWidth',groupOffset);
        set(h2(i,:,c),'XData',groupDrawPos);
        for lay = 1:NumStacksPerGroup
            colind = [1,1,1];
            %col2(1,:) = [88,205,75]/256;
            %col2(2,:) = [255,69,0]/256;
            h2(i,lay,c).CData = dcol(colind(lay),:);
            %h2(i,lay,c).CData = col2(lay,:);
        end
    end
    hold off;
    set(gca,'YTickMode','manual');
    set(gca,'YTick',1:NumGroupsPerAxis);
    set(gca,'YTickLabelMode','manual');
    set(gca,'YTickLabel',[]);
    ytickangle(45)
    if c == 3
        xlabel({'Generation','Capacity [kW]'})
    end
    grid on
    
    %ax(3,c) = subplot(6,3,15+c);
    ax(3,c) = subplot(3,6,(c-1)*6+6);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(stordata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h3(i,:,c) = barh(Y, 'stacked','FaceColor','flat');
        set(h3(i,:,c),'BarWidth',groupOffset);
        set(h3(i,:,c),'XData',groupDrawPos);
        for lay = 1:NumStacksPerGroup
            colind = [2 2 2];
            h3(i,lay,c).CData = dcol(colind(lay),:);
            %h3(i,lay,c).CData = [100,149,237]/256;
        end
    end
    hold off;
    set(gca,'YTickMode','manual');
    set(gca,'YTick',1:NumGroupsPerAxis);
    set(gca,'YTickLabelMode','manual');
    set(gca,'YTickLabel',[]);
    ytickangle(45)
    if c == 3
        xlabel({'Storage','Capacity [kWh]'})
    end
    grid on
    
end
set(gcf, 'Position', [300, 100, 1100, 750])

end


function [] = visInInWiWaWaWa(pm1,pm2,pm3,pm4,pm5,pm6)

allStruct = mergeInInWiWaWaWa(pm1,pm2,pm3,pm4,pm5,pm6);

np = 6; %number of power modules
nc = 6; %number of costs
nl = size(pm1,1); %number of locations
nu = size(pm1,2); %number of use cases

%initialize/preallocate
costdata = zeros(nl,np,nc,nu);
gendata = zeros(nl,np,nc,nu);
stordata = zeros(nl,np,nc,nu);

%unpack allStruct into costdata
opt = allStruct(1,1,1).opt;
for loc = 1:nl
    for pm = 1:np
        for c = 1:nu
            costdata(loc,pm,1,c) = ... %platform
                allStruct(loc,pm,c).output.min.Pmtrl/1000 + ...
                allStruct(loc,pm,c).output.min.Pinst/1000 + ...
                allStruct(loc,pm,c).output.min.Pmoor/1000;
            costdata(loc,pm,6,c) = ... %vessel
                 allStruct(loc,pm,c).output.min.vesselcost/1000;
            costdata(loc,pm,3,c) = ... %storage capex
                allStruct(loc,pm,c).output.min.Scost/1000 + ...
                allStruct(loc,pm,c).output.min.battencl/1000;
            costdata(loc,pm,5,c) = ... %storage opex
                allStruct(loc,pm,c).output.min.battreplace/1000;
            if pm == 3 %wind-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.turbrepair/1000;            
            end
            if pm == 1 || pm == 2 %inso-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.Mcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Ecost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000 + ...
                    allStruct(loc,pm,c).output.min.Strcost/1000;
            end
            if pm == 4 || pm == 5 || pm == 6 %wave-specific 
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.wecrepair/1000;
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
    'Long Term Instrumentation'};
leg = {'Platform/Mooring','Generation CapEx','Storage CapEx','Generation OpEx', ...
    'Storage OpEx','Vessel'};

%colors
cols = 6;
col(1,:) = [0,0,51]/256; %platform cost
col([2 4],:) = flipud(brewermap(2,'purples')); %generation cost
col([3 5],:) = flipud(brewermap(2,'blues')); %storage cost
col(6,:) = [238,232,170]/256; %vessel cost

gscol(1:5,:) = flipud(brewermap(5,'reds')); %generation capacity
gscol(6:10,:) = flipud(brewermap(5,'oranges')); %storage capacity

%plot
figure
set(gcf, 'Position', [850, 100, 1100, 1100])
for c = 1:nu
    ax(1,c) = subplot(6,nu,c+[0 2 4 6]);
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
        if c == 2 && i == np
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
    
    ax(2,c) = subplot(6,nu,8+c);
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
    
    ax(3,c) = subplot(6,nu,10+c);
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


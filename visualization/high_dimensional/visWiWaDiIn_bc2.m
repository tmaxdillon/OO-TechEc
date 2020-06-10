function [] = visWiWaDiIn_bc2(pm1,pm2,pm3,pm4,pm5,pm6,pm7,pm8)

allStruct = mergeWiWiWaWaDiDiInIn(pm1,pm2,pm3,pm4,pm5,pm6,pm7,pm8);

np = 8; %number of power modules
nc = 6; %number of costs
nl = size(pm1,1); %number of locations
nu = size(pm1,2); %number of use cases

%initialize/preallocate
costdata = zeros(nl,np,nc,nu);
gendata = zeros(nl,np,1,nu);
stordata = zeros(nl,np,1,nu);
cycdata = zeros(nl,np,1,nu);
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
                allStruct(loc,pm,c).output.min.Pline/1000 + ...
                allStruct(loc,pm,c).output.min.Panchor/1000;
            costdata(loc,pm,6,c) = ... %vessel
                 allStruct(loc,pm,c).output.min.vesselcost/1000;
            costdata(loc,pm,3,c) = ... %storage capex
                allStruct(loc,pm,c).output.min.Scost/1000 + ...
                allStruct(loc,pm,c).output.min.battencl/1000;
            costdata(loc,pm,5,c) = ... %storage opex
                allStruct(loc,pm,c).output.min.battreplace/1000;
            if pm == 1 || pm == 2 %wind-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.turbrepair/1000;            
            end
            if pm == 7 || pm == 8 %inso-specific
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.Mcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Ecost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000 + ...
                    allStruct(loc,pm,c).output.min.Strcost/1000;
            end
            if pm == 3 || pm == 4 %wave-specific 
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.Icost/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.wecrepair/1000;
            end
            if pm == 5 || pm == 6 %dies-specific 
                costdata(loc,pm,2,c) = ... %gen capex
                    allStruct(loc,pm,c).output.min.kWcost/1000 + ...
                    allStruct(loc,pm,c).output.min.genencl/1000;
                costdata(loc,pm,4,c) = ... %gen opex
                    allStruct(loc,pm,c).output.min.genrepair/1000 + ...
                    allStruct(loc,pm,c).output.min.fuel/1000;
            end
            gendata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.kW;
            stordata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.Smax;
            cycdata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.cyc60;
            massdata(loc,pm,1,c) = ...
                1000*allStruct(loc,pm,c).output.min.Smax/ ...
                (allStruct(loc,pm,c).batt.V*allStruct(loc,pm,c).batt.se);
            dpdata(loc,pm,1,c) = allStruct(loc,pm,c).output.min.dp;
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
pms = {'Wind - AGM', 'Wind - LFP', 'Wave - AGM', 'Wave - LFP', ...
    'Diesel - AGM','Diesel - LFP', 'Solar - AGM', 'Solar - LFP'};
leg = {'Platform/Mooring','Generation CapEx', ...
    'Storage CapEx','Generation OpEx', ...
    'Storage OpEx','Vessel'};
fs = 7.5; %font size

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
set(gcf, 'Position', [100, 100, 1100, 800])
for c = 1:nu
    ax(1,c) = subplot(7,nu,c+[0 2 4 6]);
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
            text(x(j),sum(Y(j,:))+10,pms{i}, ...
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
            legend(h(i,:,c),leg,'Location','northeast')
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
    ylim([0 1.2*max(max(max(sum(costdata,3))))])
    linkaxes(ax(1,:),'y')
    
    ax(2,c) = subplot(7,nu,8+c);
    hold on
    for i = 1:NumStacksPerGroup        
        Y = squeeze(gendata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h2(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h2(i,c),'BarWidth',groupOffset);
        set(h2(i,c),'XData',groupDrawPos);
        h2(i,c).CData = [255,170,139]/256;
        x = get(h2(i,c),'XData');
        for j = 1:length(Y)
            tx = dpdata(j,i,1,c);
            text(x(j),Y(j)+1,[ num2str(tx,2) ' m'], ...
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
    xtickangle(45)
    if c == 1
        ylabel({'Generation','Capacity [kW]'})
    end
    grid on
    ylim([0 1.4*max(gendata(:))])
    linkaxes(ax(2,:),'y')
    
    ax(3,c) = subplot(7,nu,10+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(stordata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h3(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h3(i,c),'BarWidth',groupOffset);
        set(h3(i,c),'XData',groupDrawPos);
        h3(i,c).CData = [255,170,159]/256;
        x = get(h3(i,c),'XData');
        for j = 1:length(Y)
            tx = massdata(j,i,1,c);
            text(x(j),Y(j)+10,[ num2str(tx,4) ' kg'], ...
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
    xtickangle(45)
    if c == 1
        ylabel({'Storage','Capacity [kWh]'})
    end
    grid on
    ylim([0 1.8*max(stordata(:))])
    linkaxes(ax(3,:),'y')
    
    ax(4,c) = subplot(7,nu,12+c);
    hold on
    for i = 1:NumStacksPerGroup
        Y = squeeze(cycdata(:,i,:,c));
        internalPosCount = i - ((NumStacksPerGroup+1) / 2);
        groupDrawPos = (internalPosCount)* groupOffset + groupBins;
        h4(i,c) = bar(Y, 'stacked','FaceColor','flat');
        set(h4(i,c),'BarWidth',groupOffset);
        set(h4(i,c),'XData',groupDrawPos);
        h4(i,c).CData = [255,170,179]/256;
        x = get(h4(i,c),'XData');
        for j = 1:length(Y)
            text(x(j),Y(j)+35,num2str(Y(j)), ...
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
        ylabel({'60% Discharge','Cycles'})
    end
    grid on
    ylim([0 1.3*max(cycdata(:))])
    linkaxes(ax(4,:),'y')
    
end


% bar(x,y)
% for i1=1:numel(y)
%     text(x(i1),y(i1),num2str(y(i1),'%0.2f'),...
%                'HorizontalAlignment','center',...
%                'VerticalAlignment','bottom')
% end
end


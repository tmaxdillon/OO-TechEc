function [] = multScatter(allDimStruct,sort)
%unpack
opt = allDimStruct(1,1,1).opt;
for loc = 1:size(allDimStruct,1)
    for pm = 1:size(allDimStruct,2)
        for c = 1:size(allDimStruct,3)
            data(loc,pm,c,1) = allDimStruct(loc,pm,c).output.min.CapEx/1000;
            data(loc,pm,c,2) = allDimStruct(loc,pm,c).output.min.OpEx/1000;
            data(loc,pm,c,3) = data(loc,pm,c,1) + data(loc,pm,c,2);
            data(loc,pm,c,4) = allDimStruct(loc,pm,c).output.min.kW;
            data(loc,pm,c,5) = allDimStruct(loc,pm,c).output.min.Smax;
            data(loc,pm,c,6) = allDimStruct(loc,pm,c).output.min.CF;
        end
    end
    if isequal(sort,'dists')
        xind(loc) = allDimStruct(loc,pm,c).data.dist/1000; %[km]
        xlab = {'Distance to Coast [km]'};
    end
    if isequal(sort,'lats')
        xind(loc) = abs(allDimStruct(loc,pm,c).data.met.lat);
        xlab = {'Latitude, Absolute [deg]'};
    end
    if isequal(sort,'kwind')
        k = getPowerDensity(allDimStruct(loc,pm,c).data,'wind'); %[W]
        xind(loc) = mean(k(:,2))/1000;
        xlab = {'Wind Power Density [kW/m^2]'};
    end
    if isequal(sort,'kinso')
        k = getPowerDensity(allDimStruct(loc,pm,c).data,'inso'); %[W]
        xind(loc) = mean(k(:,2))/1000;
        xlab = {'Solar Power Density [kW/m^2]'};
    end
end

%plotting
col = {[60,179,113]/256,[178,34,34]/256};
ecol = {[144,238,144]/256,[240,128,128]/256};
mark = {'o','s','^'};
sz = {35,55,30};
lw = {1.5,1.8,1.5};
titles = {'Short Term Instrumentation'; ...
    'Long Term Instrumentation';'Infrastructure'};
ylabs = {'Cost [$1000]'; 'Generation Capacity [kW]'; 'Storage Capacity [kW]'; ...
    'Capacity Factor'};

ctot = size(allDimStruct,3);
xtot = 4;
ptot = size(allDimStruct,2);

figure
set(gcf, 'Position', [850, 100, 900, 800])
for c = 1:ctot
    for x = 1:xtot
        ax(c) = subplot(xtot,ctot,(x-1)*ctot+c);
        for pm = 1:ptot
            scatter(xind,data(:,pm,c,2+x),sz{c},mark{c},'MarkerEdgeColor',col{pm}, ... 
                'MarkerFaceColor',ecol{pm},'LineWidth',lw{c})
            ylim([0 inf])
            hold on
            grid on
            if c == 1
                ylabel(ylabs{x})
            end
            if x == xtot
                xlabel(xlab)
            end
            if x == 1
                title(titles{c})
            end
            if x < 4
                set(gca,'xticklabels',[]);
            end
        end
    end
end

end


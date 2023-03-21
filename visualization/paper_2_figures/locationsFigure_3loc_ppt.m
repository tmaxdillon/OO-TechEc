%Arg Basin Cos Endurance IrmSea
clearvars -except allData
close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','tex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

if ~exist('allData','var')
    %load data into structure
    %load('souOcean')
    load('argBasin')
    load('cosEndurance_wa')
    load('irmSea')
    %load('cosPioneer')
    allData.argBasin = argBasin;
    allData.cosEndurance = cosEndurance_wa;
    %allData.cosPioneer = cosPioneer;
    allData.irmSea = irmSea;
    %allData.souOcean = souOcean;
end

%retrieve fieldnames, number of locations and
fn = fieldnames(allData); %fieldnames
l = numel(fn); %locations
allData.cosEndurance.title = 'Coastal Endurance'; %adjust CE title

%initialize power densit
Kwave = cell(1,l);
kwind = cell(1,1);
Ksolar = cell(1,1);
Kwave_ts = cell(1,l);

%get monthly power densities
for i = 1:l
    Kwave{i} = getMonthlyK(allData.(fn{i}),'wave');
    Kwind{i} = getMonthlyK(allData.(fn{i}),'wind');
    Ksolar{i} = getMonthlyK(allData.(fn{i}), 'inso');
    Kwave_ts{i} = getPowerDensity(allData.(fn{i}),'wave');
    Kwind_ts{i} = getPowerDensity(allData.(fn{i}),'wind');
    Ksolar_ts{i} = getPowerDensity(allData.(fn{i}), 'inso');
end

%unpack data structure
lats = zeros(1,l);
lons = zeros(1,l);
maptitles = {};
labels = categorical;
dists = zeros(1,l);
depths = zeros(1,l);
Kmean_wave = zeros(l,3);
Kmean_wind = zeros(1,3);
Kmean_solar = zeros(1,3);
for i = l:-1:1
    lats(i) = allData.(fn{i}).lat;
    lons(i) = allData.(fn{i}).lon;
    maptitles{i} = allData.(fn{i}).title;
    labels(i) = allData.(fn{i}).title;
    dists(i) = allData.(fn{i}).dist;    
    depths(i) = allData.(fn{i}).depth;
    Kmean_wave(i,1) = mean(Kwave_ts{i}(:,2))/1000;
    Kmean_wave(i,2) = Kmean_wave(i,1) - prctile(Kwave_ts{i}(:,2),25)/1000;
    Kmean_wave(i,3) = prctile(Kwave_ts{i}(:,2),75)/1000 - Kmean_wave(i,1);
    Kmean_wind(i,1) = mean(Kwind_ts{i}(:,2))/1000;
    Kmean_wind(i,2) = Kmean_wind(i,1) - prctile(Kwind_ts{i}(:,2),25)/1000;
    Kmean_wind(i,3) = prctile(Kwind_ts{i}(:,2),75)/1000 - Kmean_wind(i,1);
    Kmean_solar(i,1) = mean(Ksolar_ts{i}(:,2),'omitnan')/1000;
    Kmean_solar(i,2) = Kmean_solar(i,1) - prctile(Ksolar_ts{i}(:,2),25)/1000;
    Kmean_solar(i,3) = prctile(Ksolar_ts{i}(:,2),75)/1000 - Kmean_solar(i,1);
end
%adjustments for plotting on map
maptitles{1} = {'Argentine','Basin'};
maptitles{2} = {'Coastal','Endurance'};
%maptitles{3} = {'Coastal','Pioneer'};
maptitles{4} = {'Irminger','Sea'};
%maptitles{5} = {'Southern','Ocean'};


%plot settings
datacomp = figure;
set(gcf,'Units','inches')
%set(gcf,'Position', [1, 1, 6.5, 3.25])
set(gcf,'Position', [1, 1, 5.5, 4])
set(gcf,'Color','w')
col = colormap(brewermap(l,'Pastel1')); %colors

%col = [col10(2,:); col10(4,:); col10(6,:); col10(8,:); col10(10,:);];
ms = 5; %marker size
mlw = .5; %marker line width
fs = 7; %font size
fs2 = 8; %map font size
fs3 = 8; %annotation font size
lw = 1.5; %line width
bw_adj = .7; %bar width adjustment
%ah_adj = .8; %axis height adjustment
ah_adj = .6; %axis height adjustment
xl_adj = 1.05; %xlabel height adjustment


% %MAP
% %ax(1) = subplot(4,5,[1:2;6:7;11:12;16:17]);
% ax(1) = subplot(5,6,[1:2;7:8;13:14]);
% set(gca,'Units','Normalized')
% wm = worldmap({'South America','Canada','Iceland'});
% hold on
% geoshow(ax(1),'landareas.shp','FaceColor',[0.93 0.93 0.93]);
% set(findall(wm,'Tag','PLabel'),'visible','off')
% set(findall(wm,'Tag','MLabel'),'visible','off')
% set(ax(1),'LineWidth',10)
% opos(1,:) = get(ax(1),'OuterPosition');
% opos(1,1) = 0.05;
% opos(1,3) = 0.29;
% opos(1,2) = 0.39;
% set(gca,'OuterPosition',opos(1,:))
% framem off %remove frame
% gridm off %remove grid
% %add point locations and text
% % posmod = [1.20 1.95 2.1 1.2 1.5 ; ...
% %     1.1 .9 .85 .9 1.25]; %modify text position placement
% posmod = [1.20 1.95 1.2 ; ...
%     1.1 .9 .9]; %modify text position placement
% for i = 1:l
%     %add point locations
%     pt = geoshow(lats(i),lons(i),'DisplayType','Point', 'Marker','o', ...
%         'MarkerFaceColor',col(i,:),'MarkerEdgeColor','k', ... 
%         'MarkerSize',ms,'LineWidth',mlw);
%     %add text
%     tx = text(pt.XData*posmod(1,i),pt.YData*posmod(2,i), ...
%         maptitles{i},'Interpreter','tex');
%     tx.FontSize = fs2;
% end

%DISTANCE
% %ax(2) = subplot(4,5,3:5);
ax(1) = subplot(5,1,1);
b = barh(labels,dists./1000);
b(1).BarWidth = b(1).BarWidth*bw_adj;
b(1).FaceColor = 'flat';
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(dists)/1000])
set(gca,'FontSize',fs)
ax(1).TickLabelInterpreter = 'tex';
xl = xlabel('Distance to Coast [km]','Fontsize',fs,'Interpreter','tex');
% pos(2,:) = get(gca,'Position');
% pos(2,4) = pos(2,4)*ah_adj;
% set(gca,'position',pos(2,:));
% opos(2,:) = get(gca,'OuterPosition');
% opos(2,3) = opos(1,3)*1.05;
% set(gca,'OuterPosition',opos(2,:));
% txann = text(1.05,.5,'(a)','Units','Normalized', ...
%     'VerticalAlignment','middle','FontWeight','normal', ...
%     'FontSize',fs3,'Interpreter','tex');
% xl.Units = 'normalized';
% xlpos = get(xl,'Position');
% xlpos(2) = xl_adj*xlpos(2);
% set(xl,'Position',xlpos)
grid on
%DEPTH
%ax(3) = subplot(4,5,8:10);
ax(2) = subplot(5,1,2);
b = barh(labels,depths);
b(1).BarWidth = b(1).BarWidth*bw_adj;
b(1).FaceColor = 'flat';
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(depths)])
set(gca,'FontSize',fs)
ax(2).TickLabelInterpreter = 'tex';
xl = xlabel('Depth [m]','Fontsize',fs,'Interpreter','tex');
% pos(3,:) = get(gca,'Position');
% pos(3,4) = pos(3,4)*ah_adj;
% set(gca,'position',pos(3,:));
% opos(3,:) = get(gca,'OuterPosition');
% opos(3,3) = opos(2,3);
% set(gca,'OuterPosition',opos(3,:));
% text(1.05,.5,'(b)','Units','Normalized', ...
%     'VerticalAlignment','middle','FontWeight','normal', ...
%     'FontSize',fs3,'Interpreter','tex');
% xl.Units = 'normalized';
% xlpos = get(xl,'Position');
% xlpos(2) = xl_adj*xlpos(2);
% set(xl,'Position',xlpos)
grid on

% %AVERAGE K - need to plot first to get the width value
ax(3) = subplot(5,1,3);
b = barh(labels,Kmean_wave(:,1));
hold on
e = errorbar(Kmean_wave(:,1),labels, ...
    Kmean_wave(:,2),Kmean_wave(:,3),'.', ...
    'horizontal','DisplayName','interquartile range');
e.Color = 'k';
e.LineStyle = 'none';
b(1).FaceColor = 'flat';
b(1).BarWidth = b(1).BarWidth*bw_adj;
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(Kmean_wave(:,1) + Kmean_wave(:,3))])
cax = gca;
cax.XLabel.String = ['Average Wave Power Density ' ...
    '[kWm^{-1}] (with Interquartile Range)'];
cax.XLabel.Interpreter = 'tex';
cax.FontSize = fs;
% opos(7,:) = get(gca, 'OuterPosition');
% opos(7,1) = opos(2,1)+opos(2,3)+0.05;
% set(gca,'OuterPosition',opos(7,:));
% pos(7,:) = get(gca,'Position');
% pos(7,3) = pos(2,3)*1.9;
% %pos(7,2) = pos(3,2);
% pos(7,4) = pos(2,4);
% set(gca,'position',pos(7,:));
% 
% text(1.05,.5,'(f)','Units','Normalized', ...
%     'VerticalAlignment','middle','HorizontalAlignment','center','FontWeight','normal', ...
%     'FontSize',fs3,'Interpreter','tex');
% xl.Units = 'normalized';
% xlpos = get(xl,'Position');
% xlpos(2) = xl_adj*xlpos(2);
% set(xl,'Position',xlpos)
grid on
% 
% %AVERAGE K - need to plot first to get the width value
ax(4) = subplot(5,1,4);
b = barh(labels,Kmean_wind(:,1));
hold on
e = errorbar(Kmean_wind(:,1), labels,...
    Kmean_wind(:,2),Kmean_wind(:,3),'.', ...
    'horizontal','DisplayName','interquartile range');
e.Color = 'k';
e.LineStyle = 'none';
b(1).FaceColor = 'flat';
b(1).BarWidth = b(1).BarWidth*bw_adj;
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(Kmean_wind(:,1) + Kmean_wind(:,3))])
cax = gca;
cax.XLabel.String = ['Average Wind Power Density ' ...
    '[kWm^{-2}] (with Interquartile Range)'];
cax.XLabel.Interpreter = 'tex';
cax.FontSize = fs;
% pos(8,:) = get(gca,'Position');
% pos(8,1) = pos(7,1);
% pos(8,3) = pos(7,3);
% pos(8,2) = pos(2,2);
% pos(8,4) = pos(8,4)*ah_adj;
% set(gca,'position',pos(8,:));
% 
% text(1.05,.5,'(g)','Units','Normalized', ...
%     'VerticalAlignment','middle','HorizontalAlignment','center','FontWeight','normal', ...
%     'FontSize',fs3,'Interpreter','tex');
% xl.Units = 'normalized';
% xlpos = get(xl,'Position');
% xlpos(2) = xl_adj*xlpos(2);
% set(xl,'Position',xlpos)
grid on

% %AVERAGE K - need to plot first to get the width value
ax(5) = subplot(5,1,5);
b = barh(labels,Kmean_solar(:,1));
hold on
e = errorbar(Kmean_solar(:,1), labels,...
    Kmean_solar(:,2),Kmean_solar(:,3),'.', ...
    'horizontal','DisplayName','interquartile range');
e.Color = 'k';
e.LineStyle = 'none';
b(1).FaceColor = 'flat';
b(1).BarWidth = b(1).BarWidth*bw_adj;
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(Kmean_solar(:,1) + Kmean_solar(:,3))])
cax = gca;
cax.XLabel.String = ['Average Solar Power Density ' ...
    '[kWm^{-2}] (with Interquartile Range)'];
cax.XLabel.Interpreter = 'tex';
cax.FontSize = fs;
% pos(9,:) = get(gca,'Position');
% pos(9,1) = pos(7,1);
% pos(9,3) = pos(7,3);
% pos(9,2) = pos(3,2);
% pos(9,4) = pos(9,4)*ah_adj;
% set(gca,'position',pos(9,:));
% text(1.05,.5,'(h)','Units','Normalized', ...
%     'VerticalAlignment','middle','HorizontalAlignment','center','FontWeight','normal', ...
%     'FontSize',fs3,'Interpreter','tex');
% xl.Units = 'normalized';
% xlpos = get(xl,'Position');
% xlpos(2) = xl_adj*xlpos(2);
% set(xl,'Position',xlpos)
grid on

% % MONTHLY K - WAVE
% ax(4) = subplot(5,6,3:6);
% xt = [];
% for i = 1:l
%     plot(datetime(Kwave{i}(:,1),'ConvertFrom','datenum'), ...
%         Kwave{i}(:,2)/1000,'Color',col(i,:), ...
%         'LineWidth',lw,'DisplayName',[allData.(fn{i}).title])
%     xt = [xt ; datetime(Kwave{i}(:,1),'ConvertFrom','datenum')];
%     hold on
% end
% %xl = xlabel('Time');
% xtickformat('yyyy');
% ylabel({'Wave','Power','Density'},'FontSize',fs,'interpreter','tex');
% %title('Wave','FontSize',fs,'interpreter','tex')
% ylh = get(ax(4),'ylabel');
% set(ylh,'Rotation',0,'Units','Normalized','Position',[-.275 .75 -1], ...
%     'VerticalAlignment','middle', ...
%     'HorizontalAlignment','center')
% text(-.275,.25,'$$\mathrm{\bigg[\frac{kW}{m}\bigg]}$$', ...
%     'Units','Normalized','Interpreter','tex', ...
%     'VerticalAlignment','middle','FontWeight','normal', ...
%     'HorizontalAlignment','center','FontSize',fs);
% ylim([0 inf])
% %drawnow
% hL = legend('show','location','eastoutside','box','off','Units','Inches');
% hLPos = get(hL,'Position');
% set(hL,'Position',[hLPos(1)+.34 hLPos(2)+.23 hLPos(3) 0])
% drawnow
% set(gca,'FontSize',fs)
% set(hL,'FontSize',fs)
% set(hL,'Interpreter','tex')
% ax(4).TickLabelInterpreter = 'tex';
% dx = pos(7,3)/2; %width of each quad
% pos(4,:) = get(ax(4),'Position');
% pos(4,1) = pos(7,1);
% pos(4,2) = pos(4,2)*1.02;
% pos(4,3) = dx-0.055;
% pos(4,4) = 0.14;
% set(ax(4),'Position',pos(4,:))
% 
% % Lpos = get(hL,'Position');
% % Lpos(4) = pos(4,4);
% % Lpos(2) = pos(4,2);
% % Lpos(3) = pos(4,3);
% % %Lpos(1) = opos(7,3)/2
% % Lpos(1) = pos(7,1)+pos(7,3)-Lpos(3);
% % set(hL,'Position',Lpos)
% %add axis annotation
% text(1.05, 0.5,'(c)','Units','Normalized', ...
%     'VerticalAlignment','middle','FontWeight','normal', ...
%     'FontSize',fs3,'Interpreter','tex')
% %adjust xlabel
% % xl.Units = 'normalized';
% % xlpos = get(xl,'Position');
% % xlpos(2) = xl_adj*xlpos(2);
% % set(xl,'Position',xlpos)
% grid on
% 
% % %MONTHLY K - WIND
% ax(5) = subplot(5,6,9:10);
% xt = [];
% for i = 1:l
%     plot(datetime(Kwind{i}(:,1),'ConvertFrom','datenum'), ...
%         Kwind{i}(:,2)/1000,'Color',col(i,:), ...
%         'LineWidth',lw,'DisplayName',[allData.(fn{i}).title])
%     xt = [xt ; datetime(Kwind{i}(:,1),'ConvertFrom','datenum')];
%     hold on
% end
% %xl = xlabel('Time');
% xtickformat('yyyy');
% ylabel({'Wind','Power','Density'},'FontSize',fs,'interpreter','tex');
% %title('Wind','FontSize',fs,'interpreter','tex')
% ylh = get(ax(5),'ylabel');
% set(ylh,'Rotation',0,'Units','Normalized','Position',[-.275 .75 -1], ...
%     'VerticalAlignment','middle', ...
%     'HorizontalAlignment','center')
% text(-.275,.25,'$$\mathrm{\bigg[\frac{kW}{m^2}\bigg]}$$', ...
%     'Units','Normalized','Interpreter','tex', ...
%     'VerticalAlignment','middle','FontWeight','normal', ...
%     'HorizontalAlignment','center','FontSize',fs);
% ylim([0 inf])
% set(gca,'FontSize',fs)
% ax(5).TickLabelInterpreter = 'tex';
% 
% pos(5,:) = get(gca,'Position');
% pos(5,1) = pos(7,1);
% pos(5,2) = pos(7,2)+pos(7,4)+0.075;
% pos(5,3) = pos(4,3);
% pos(5,4) = pos(4,4);
% set(gca,'Position',pos(5,:))
% 
% %add axis annotation
% text(1.05,.5,'(d)','Units','Normalized', ...
%     'VerticalAlignment','middle','FontWeight','normal', ...
%     'FontSize',fs3,'Interpreter','tex')
% %adjust xlabel
% % xl.Units = 'normalized';
% % xlpos = get(xl,'Position');
% % xlpos(2) = xl_adj*xlpos(2);
% % set(xl,'Position',xlpos)
% grid on
% 
% % %MONTHLY K - SOLAR
% ax(6) = subplot(5,6,11:12);
% xt = [];
% for i = 1:l
%     plot(datetime(Ksolar{i}(:,1),'ConvertFrom','datenum'), ...
%         Ksolar{i}(:,2)/1000,'Color',col(i,:), ...
%         'LineWidth',lw,'DisplayName',[allData.(fn{i}).title])
%     xt = [xt ; datetime(Ksolar{i}(:,1),'ConvertFrom','datenum')];
%     hold on
% end
% %xl = xlabel('Time');
% xtickformat('yyyy');
% ylabel({'Solar','Power','Density'},'FontSize',fs,'interpreter','tex');
% %title('Solar','FontSize',fs,'interpreter','tex')
% ylh = get(ax(6),'ylabel');
% set(ylh,'Rotation',0,'Units','Normalized','Position',[-.275 .75 -1], ...
%     'VerticalAlignment','middle', ...
%     'HorizontalAlignment','center')
% text(-.275,.25,'$$\mathrm{\bigg[\frac{kW}{m^2}\bigg]}$$', ...
%     'Units','Normalized','Interpreter','tex', ...
%     'VerticalAlignment','middle','FontWeight','normal', ...
%     'HorizontalAlignment','center','FontSize',fs);
% ylim([0 inf])
% set(gca,'FontSize',fs)
% ax(6).TickLabelInterpreter = 'tex';
% 
% pos(6,:) = get(gca,'Position');
% pos(6,1) = pos(6,1)+0.097;
% pos(6,2) = pos(5,2);
% pos(6,3) = pos(4,3);
% pos(6,4) = pos(4,4);
% set(gca,'Position',pos(6,:))
% 
% %add axis annotation
% text(1.05,.5,'(e)','Units','Normalized', ...
%     'VerticalAlignment','middle','FontWeight','normal', ...
%     'FontSize',fs3,'Interpreter','tex')
% %adjust xlabel
% % xl.Units = 'normalized';
% % xlpos = get(xl,'Position');
% % xlpos(2) = xl_adj*xlpos(2);
% % set(xl,'Position',xlpos)
% grid on
% % % 
% 
% opos(1,:) = get(ax(1),'OuterPosition');
% opos(1,1) = 0.05;
% opos(1,3) = 0.29;
% opos(1,2) = 0.34;
% set(ax(1),'OuterPosition',opos(1,:))

% % 
set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 245]/256)
print(datacomp,['~/Dropbox (MREL)/Research/Defense/' ...
    'presentation_figures/locations'],  ...
    '-dpng','-r600')

map = figure;
ax(1) = subplot(5,6,[1:2;7:8;13:14]);
set(gca,'Units','Normalized')
wm = worldmap({'South America','Canada','Iceland'});
hold on
geoshow(ax(1),'landareas.shp','FaceColor',[0.93 0.93 0.93]);
set(findall(wm,'Tag','PLabel'),'visible','off')
set(findall(wm,'Tag','MLabel'),'visible','off')
set(ax(1),'LineWidth',10)
opos(1,:) = get(ax(1),'OuterPosition');
opos(1,1) = 0.05;
opos(1,3) = 0.29;
opos(1,2) = 0.39;
set(gca,'OuterPosition',opos(1,:))
framem off %remove frame
gridm off %remove grid
%add point locations and text
% posmod = [1.20 1.95 2.1 1.2 1.5 ; ...
%     1.1 .9 .85 .9 1.25]; %modify text position placement
posmod = [1.20 1.95 1.2 ; ...
    1.1 .9 .9]; %modify text position placement
for i = 1:l
    %add point locations
    pt = geoshow(lats(i),lons(i),'DisplayType','Point', 'Marker','o', ...
        'MarkerFaceColor',col(i,:),'MarkerEdgeColor','k', ... 
        'MarkerSize',ms,'LineWidth',mlw);
    %add text
    tx = text(pt.XData*posmod(1,i),pt.YData*posmod(2,i), ...
        maptitles{i},'Interpreter','tex');
    tx.FontSize = 12;
end
%print(datacomp, '-dpng','-r600')

set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 245]/256)
print(map,['~/Dropbox (MREL)/Research/Defense/' ...
    'presentation_figures/map'],  ...
    '-dpng','-r600')

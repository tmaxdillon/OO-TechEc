clearvars -except allData
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

if ~exist('allData','var')
    %load data into structure
    load('souOcean')
    load('argBasin')
    load('cosEndurance_wa')
    load('irmSea')
    load('cosPioneer')
    allData.argBasin = argBasin;
    allData.cosEndurance = cosEndurance_wa;
    allData.cosPioneer = cosPioneer;
    allData.irmSea = irmSea;
    allData.souOcean = souOcean;
end

%retrieve fieldnames, number of locations and
fn = fieldnames(allData); %fieldnames
l = numel(fn); %locations
allData.cosEndurance.title = 'Coastal Endurance'; %adjust CE title

%initialize power densit
Kwave = cell(1,l);
Kwave_ts = cell(1,l);

%get monthly power densities
for i = 1:l
    Kwave{i} = getMonthlyK(allData.(fn{i}),'wave');
    Kwave_ts{i} = getPowerDensity(allData.(fn{i}),'wave');
end

%unpack data structure
lats = zeros(1,l);
lons = zeros(1,l);
maptitles = {};
labels = categorical;
dists = zeros(1,l);
depths = zeros(1,l);
Kmean_wave = zeros(l,3);
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
end
%adjustments for plotting on map
maptitles{1} = {'Argentine','Basin'};
maptitles{2} = {'Coastal','Endurance'};
maptitles{3} = {'Coastal','Pioneer'};
maptitles{4} = {'Irminger','Sea'};
maptitles{5} = {'Southern','Ocean'};

%plot settings
datacomp = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 3.25])
set(gcf,'Color','w')
col = colormap(brewermap(l,'Pastel1')); %colors

%col = [col10(2,:); col10(4,:); col10(6,:); col10(8,:); col10(10,:);];
ms = 5; %marker size
mlw = .5; %marker line width
fs = 6; %font size
fs2 = 8; %map font size
fs3 = 8; %annotation font size
lw = 1.5; %line width
bw_adj = .8; %bar width adjustment
ah_adj = .8; %axis height adjustment
xl_adj = 1.3; %xlabel height adjustment

%MAP
ax(1) = subplot(4,5,[1:2;6:7;11:12;16:17]);
wm = worldmap({'South America','Canada','Iceland'});
hold on
geoshow(ax,'landareas.shp','FaceColor',[0.93 0.93 0.93]);
opos = get(gca,'OuterPosition');
opos(1) = 0.05;
opos(3) = 0.26;
set(gca,'OuterPosition',opos)
set(findall(wm,'Tag','PLabel'),'visible','off')
set(findall(wm,'Tag','MLabel'),'visible','off')
set(ax,'LineWidth',10)
framem off %remove frame
gridm off %remove grid
%add point locations and text
posmod = [1.20 1.95 2.1 1.2 1.5 ; ...
    1.1 .9 .85 .9 1.25]; %modify text position placement
for i = 1:l
    %add point locations
    pt = geoshow(lats(i),lons(i),'DisplayType','Point', 'Marker','o', ...
        'MarkerFaceColor',col(i,:),'MarkerEdgeColor','k', ... 
        'MarkerSize',ms,'LineWidth',mlw);
    %add text
    tx = text(pt.XData*posmod(1,i),pt.YData*posmod(2,i), ...
        maptitles{i});
    tx.FontSize = fs2;
end
%DISTANCE
ax(2) = subplot(4,5,3:5);
b = barh(labels,dists./1000);
b(1).BarWidth = b(1).BarWidth*bw_adj;
b(1).FaceColor = 'flat';
for i = 1:l
    %     reds = colormap(brewermap(50,'reds'));
    %     array = linspace(0,max(dists),50);
    b(1).CData(i,:) = col(end+1-i,:);
    %[~,ind] = min(abs(array - dists(i)));
    %b(1).CData(i,:) = [255 0 0]/256;
end
xlim([0 1.1*max(dists)/1000])
set(gca,'FontSize',fs)
xl = xlabel('Distance to Coast [km]','Fontsize',fs);
pos(1,:) = get(gca,'Position');
pos(1,4) = pos(1,4)*ah_adj;
set(gca,'position',pos(1,:));
text(1.05,.5,'(a)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs3);
xl.Units = 'normalized';
xlpos = get(xl,'Position');
xlpos(2) = xl_adj*xlpos(2);
set(xl,'Position',xlpos)
grid on
%DEPTH
ax(3) = subplot(4,5,8:10);
b = barh(labels,depths);
b(1).BarWidth = b(1).BarWidth*bw_adj;
b(1).FaceColor = 'flat';
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(depths)])
set(gca,'FontSize',fs)
xl = xlabel('Depth [m]','Fontsize',fs);
pos(2,:) = get(gca,'Position');
pos(2,4) = pos(2,4)*ah_adj;
set(gca,'position',pos(2,:));
txann = text(1.05,.5,'(b)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs3);
xl.Units = 'normalized';
xlpos = get(xl,'Position');
xlpos(2) = xl_adj*xlpos(2);
set(xl,'Position',xlpos)
grid on
%MONTHLY K
ax(4) = subplot(4,5,13:15);
xt = [];
for i = 1:l
    plot(datetime(Kwave{i}(:,1),'ConvertFrom','datenum'), ...
        Kwave{i}(:,2)/1000,'Color',col(i,:), ...
        'LineWidth',lw,'DisplayName',[allData.(fn{i}).title])
    xt = [xt ; datetime(Kwave{i}(:,1),'ConvertFrom','datenum')];
    hold on
end
xl = xlabel('Time');
ylabel({'Power','Density'},'FontSize',fs,'interpreter','latex');
ylh = get(ax(4),'ylabel');
set(ylh,'Rotation',0,'Units','Normalized','Position',[-.225 .8 -1], ...
    'VerticalAlignment','middle', ...
    'HorizontalAlignment','center')
text(-.225,.2,'$$\mathrm{\bigg[\frac{kW}{m}\bigg]}$$', ...
    'Units','Normalized','Interpreter','latex', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'HorizontalAlignment','center','FontSize',fs);
ylim([0 inf])
drawnow
hL = legend('show','location','eastoutside');
drawnow
set(gca,'FontSize',fs)
%set(hL,'FontSize',fs)
%set y pos
pos(3,:) = get(ax(4),'Position');
pos(3,4) = pos(3,4)*ah_adj;
set(ax(4),'Position',pos(3,:));
Lpos = get(hL,'Position');
Lpos(4) = pos(3,4);
Lpos(2) = pos(3,2);
set(hL,'Position',Lpos)
%set xpos
dx = (pos(2,1)+pos(2,3)-(Lpos(1)+Lpos(3)));
pos(3,3) = pos(3,3)+dx;
set(ax(4),'Position',pos(3,:))
Lpos(1) = Lpos(1)+dx;
set(hL,'Position',Lpos)
%add axis annotation
txann.Units = 'inches';
text(txann.Position(1),txann.Position(2),'(c)','Units','inches', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs3)
%adjust xlabel
xl.Units = 'normalized';
xlpos = get(xl,'Position');
xlpos(2) = xl_adj*xlpos(2);
set(xl,'Position',xlpos)
grid on
%AVERAGE K
ax(5) = subplot(4,5,18:20);
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
set(gca,'FontSize',fs)
xl = xlabel(['Average Wave Power Density ' ...
    '$$\mathrm{\big[kWm^{-1}\big]}$$' ...
    ' (with Interquartile Range)'], ...
    'Fontsize',fs,'interpreter','latex');
pos(4,:) = get(gca,'Position');
pos(4,4) = pos(4,4)*ah_adj;
set(gca,'position',pos(4,:));
txann = text(1.05,.5,'(d)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs3);
xl.Units = 'normalized';
xlpos = get(xl,'Position');
xlpos(2) = xl_adj*xlpos(2);
set(xl,'Position',xlpos)
grid on

print(datacomp,'../Research/OO-TechEc/paper_figures/datacomp',  ...
    '-dpng','-r600')

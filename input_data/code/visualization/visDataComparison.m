function [] = visDataComparison(allData)

%MUST CHANGE THE AVERAGE POWER DENSITY SO THAT IT IS AVERAGE ANNUAL K (AS
%OPPOSED TO AVERAGE OVER WHOLE TIME SERIES, WHICH IS OFTEN LARGER THAN A
%SINGLE YEAR) - or - DO NOT DO THIS BECAUSE YOU RUN THE SIMULATION ON THE
%WHOLE TIME SERIES ???

fn = fieldnames(allData);
l = numel(fn);

allData.cosEndurance_wa.title = 'Coastal Endurance';

%initialize
Kwave = cell(1,l);
Kwind = cell(1,l);
Kinso = cell(1,l);
Kwave_ts = cell(1,l);
Kwind_ts = cell(1,l);
Kinso_ts = cell(1,l);

for i = 1:l
    Kwave{i} = getMonthlyK(allData.(fn{i}),'wave');
    Kwind{i} = getMonthlyK(allData.(fn{i}),'wind');
    Kinso{i} = getMonthlyK(allData.(fn{i}),'inso');
    Kwave_ts{i} = getPowerDensity(allData.(fn{i}),'wave');
    Kwind_ts{i} = getPowerDensity(allData.(fn{i}),'wind');
    Kinso_ts{i} = getPowerDensity(allData.(fn{i}),'inso');
end

fs = 14; %font size
lw = 2.5; %line width

figure
set(gcf, 'Position', [100, 100, 700, 700])
col = colormap(brewermap(l,'Set1'));
%WAVE
ax(1) = subplot(3,4,1:3);
xt = [];
for i = 1:l
    plot(datetime(Kwave{i}(:,1),'ConvertFrom','datenum'), ...
        Kwave{i}(:,2)/1000,'Color',col(i,:), ...
        'LineWidth',lw,'DisplayName',[allData.(fn{i}).title])
    xt = [xt ; datetime(Kwave{i}(:,1),'ConvertFrom','datenum')];
    hold on
end
hL = legend('show','location','eastoutside','Color',[255 255 245]/256);
%xlabel('Time')
ylabel({'Wave','[kW/m]'},'FontSize',14)
ylim([0 inf])
xl = xlim;
xtickangle(45)
%xticks(xt)
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
title({'Renewable Power Density (Monthly Avg)',''}, ...
    'FontSize',18)
grid on
%WIND SPEED
ax(2) = subplot(3,4,5:7);
xt = [];
for i = 1:l
    plot(datetime(Kwind{i}(:,1),'ConvertFrom','datenum'), ...
        Kwind{i}(:,2)/1000,'Color',col(i,:), ...
        'LineWidth',lw,'DisplayName',[allData.(fn{i}).title ... 
        ', mean = ' num2str(round(mean(Kwind{i}(:,2)),3,'significant'))])
    xt = [xt ; datetime(Kwave{i}(:,1),'ConvertFrom','datenum')];
    hold on
end
xlim(xl)
%xticks(xt)
%xlabel('Time')
ylabel({'Wind','[kW/m^2]'},'FontSize',14)
ylim([0 inf])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
%legend('show','Location','best')
grid on
%IRRADIANCE
ax(3) = subplot(3,4,9:11);
xt = [];
for i = 1:l
    plot(datetime(Kinso{i}(:,1),'ConvertFrom','datenum'), ...
        Kinso{i}(:,2)/1000,'Color',col(i,:), ...
        'LineWidth',lw,'DisplayName',[allData.(fn{i}).title ... 
        ', mean = ' num2str(round(mean(Kinso{i}(:,2)),3,'significant'))])
    xt = [xt ; datetime(Kwave{i}(:,1),'ConvertFrom','datenum')];
    hold on
end
xlim(xl)
%xticks(xt)
xtickangle(45)
xlabel('Time')
ylabel({'Solar','[kW/m^2]'},'FontSize',14)
ylim([0 inf])
set(gca,'FontSize',fs)
%legend('show','Location','best')
grid on

newPosition = [0.75 .5 0.2 0.01];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'FontSize',16);
set(gcf, 'Position', [10, 100, 1200, 700])

linkaxes(ax(1:3),'x')

set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 245]/256)
print(gcf,['~/Dropbox (MREL)/Research/General Exam/' ...
    'pf/datatimeseries'],  ...
    '-dpng','-r600')

%unpack data structure
dists = zeros(1,l);
labels = categorical;
lats = zeros(1,l);
Kmean_wave = zeros(3,l);
for i = l:-1:1
    dists(i) = allData.(fn{i}).dist;
    labels(i) = allData.(fn{i}).title;
    lats(i) = abs(allData.(fn{i}).lat);
    depths(i) = allData.(fn{i}).depth;
    Kmean_wave(i,1) = mean(Kwave_ts{i}(:,2))/1000;
    Kmean_wave(i,2) = Kmean_wave(i,1) - prctile(Kwave_ts{i}(:,2),25)/1000;
    Kmean_wave(i,3) = prctile(Kwave_ts{i}(:,2),75)/1000 - Kmean_wave(i,1);
    Kmean_wind(i,1) = mean(Kwind_ts{i}(:,2))/1000;
    Kmean_wind(i,2) = Kmean_wind(i,1) - prctile(Kwind_ts{i}(:,2),25)/1000;
    Kmean_wind(i,3) = prctile(Kwind_ts{i}(:,2),75)/1000 - Kmean_wind(i,1);
    Kmean_inso(i,1) = nanmean(Kinso_ts{i}(:,2))/1000;
    Kmean_inso(i,2) = Kmean_inso(i,1) - prctile(Kinso_ts{i}(:,2),25)/1000;
    Kmean_inso(i,3) = prctile(Kinso_ts{i}(:,2),75)/1000 - Kmean_inso(i,1);     
end

fs = 12;

figure
set(gcf, 'Position', [850, 100, 600, 600])
subplot(5,1,1)
%DISTANCE
b = barh(labels,dists./1000);
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
xlabel('Distance to Coast [km]','Fontsize',12)
grid on
%DEPTH
subplot(5,1,2)
b = barh(labels,depths);
b(1).FaceColor = 'flat';
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(depths)])
set(gca,'FontSize',fs)
xlabel('Depth [m]','Fontsize',12)
grid on
%LATITUDE
% subplot(5,1,6)
% b = barh(labels,lats);
% b(1).FaceColor = 'flat';
% for i = 1:l
%     b(1).CData(i,:) = col(end+1-i,:);
% end
% xlim([0 1.1*max(lats)])
% set(gca,'FontSize',fs)
% xlabel('Latitude, Absolute [deg]','Fontsize',10)
% grid on
%WAVE
subplot(5,1,3)
b = barh(labels,Kmean_wave(:,1));
hold on
e = errorbar(Kmean_wave(:,1),labels,Kmean_wave(:,2),Kmean_wave(:,3),'.', ...
    'horizontal','DisplayName','interquartile range');
e.Color = 'k';                            
e.LineStyle = 'none';  
b(1).FaceColor = 'flat';
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(Kmean_wave(:,1) + Kmean_wave(:,3))])
set(gca,'FontSize',fs)
xlabel('Average Monthly Wave Power Density [kW/m] (with interquartile range)','Fontsize',12)
grid on
%WIND
subplot(5,1,4)
b = barh(labels,Kmean_wind(:,1));
hold on
e = errorbar(Kmean_wind(:,1),labels,Kmean_wind(:,2),Kmean_wind(:,3),'.', ...
    'horizontal','DisplayName','interquartile range');
e.Color = 'k';                            
e.LineStyle = 'none';  
b(1).FaceColor = 'flat';
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(Kmean_wind(:,1) + Kmean_wind(:,3))])
set(gca,'FontSize',fs)
xlabel('Wind Power Density [kW/m]','Fontsize',10)
grid on
%SOLAR
subplot(5,1,5)
b = barh(labels,Kmean_inso(:,1));
hold on
e = errorbar(Kmean_inso(:,1),labels,Kmean_inso(:,2),Kmean_inso(:,3),'.', ...
    'horizontal','DisplayName','interquartile range');
e.Color = 'k';                            
e.LineStyle = 'none';  
b(1).FaceColor = 'flat';
for i = 1:l
    b(1).CData(i,:) = col(end+1-i,:);
end
xlim([0 1.1*max(Kmean_inso(:,1) + Kmean_inso(:,3))])
set(gca,'FontSize',fs)
xlabel('Solar Power Density [kW/m]','Fontsize',10)
grid on



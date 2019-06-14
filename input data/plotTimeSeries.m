function [] = plotTimeSeries(dataStruct)

fs = 14; %font size
lw = 1; %line width

%%%%%%%%%%% SET VALUES %%%%%%%%%%%%%%

pts = 1:length(dataStruct.met.time);

time = dataStruct.met.time(pts);
wind = dataStruct.met.wind_spd(pts);
inso = dataStruct.met.shortwave_irradiance(pts);
hs = zeros(length(time),1);
tp = zeros(length(time),1);
ht = dataStruct.met.wind_ht;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
set(gcf, 'Position', [100, 100, 1100, 650])
% %WAVE HEIGHT
ax(1) = subplot(4,1,1);
plot(datetime(time,'ConvertFrom','datenum'), ...
    hs,'Color',[100,149,237]/256, ...
    'LineWidth',lw,'DisplayName','Significant Wave Height')
hold on
offline = zeros(length(time),1);
offline(~isnan(hs)) = nan;
if sum(~isnan(offline(:))) > 0
    plot(datetime(time,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
end
%xlabel('Time')
ylabel({'[m]'},'FontSize',14)
xl = xlim;
%xt = xticks;
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
title([dataStruct.title ' Renewable Resources'],'FontSize',18)
legend('show')
grid on
%WAVE PERIOD
ax(2) = subplot(4,1,2);
plot(datetime(time,'ConvertFrom','datenum'), ...
    tp,'Color',[0,191,255]/256, ...
    'LineWidth',lw,'DisplayName','Peak Wave Period')
hold on
offline = zeros(length(time),1);
offline(~isnan(tp)) = nan;
if sum(~isnan(offline(:))) > 0
    plot(datetime(time,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
end
%xlabel('Time')
ylabel({'[s]'},'FontSize',14)
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
legend('show')
grid on
%WIND SPEED
ax(3) = subplot(4,1,3);
plot(datetime(time,'ConvertFrom','datenum'), ...
    wind,'Color',[50,205,50]/256, ...
    'LineWidth',lw,'DisplayName',['Wind Speed at ' ...
    num2str(ht) ' m'])
hold on
offline = zeros(length(time),1);
offline(~isnan(wind)) = nan;
off_pts = find(offline == 0);
if sum(~isnan(offline(:))) > 0
    plot(datetime(time,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
    interpolated = fillmissing(wind,'linear');
    plot(datetime(time(off_pts(:)), ... 
        'ConvertFrom','datenum'),interpolated(off_pts),'k.', ...
        'LineWidth',lw,'DisplayName','Linear Interpolation')
end
hold on
xlim(xl)
%xticks(xt)
%xlabel('Time')
ylabel({'[m/s]'},'FontSize',14)
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
legend('show')
grid on
%IRRADIANCE
ax(4) = subplot(4,1,4);
plot(datetime(time,'ConvertFrom','datenum'), ...
    inso/1000,'Color',[255,69,0]/256, ...
    'LineWidth',lw,'DisplayName','Shortwave Solar Irradiance')
hold on
offline = zeros(length(time),1);
offline(~isnan(inso)) = nan;
if sum(~isnan(offline(:))) > 0
    plot(datetime(time,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
end
xlim(xl)
%xticks(xt)
ylim([-0.5 2])
xlabel('Time')
ylabel({'[kW/m^2]'},'FontSize',14)
set(gca,'FontSize',fs)
legend('show')
grid on

linkaxes(ax,'x')

end


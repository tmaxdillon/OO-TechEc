function [] = plotTimeSeries(dataStruct)

fs = 14; %font size
lw = 1; %line width

figure
set(gcf, 'Position', [100, 100, 1100, 650])
%WAVE HEIGHT
ax(1) = subplot(4,1,1);
plot(datetime(dataStruct.wave.time,'ConvertFrom','datenum'), ...
    dataStruct.wave.significant_wave_height,'Color',[100,149,237]/256, ...
    'LineWidth',lw,'DisplayName','Significant Wave Height')
hold on
offline = zeros(length(dataStruct.wave.time),1);
offline(~isnan(dataStruct.wave.significant_wave_height)) = nan;
if sum(~isnan(offline(:))) > 0
    plot(datetime(dataStruct.wave.time,'ConvertFrom','datenum'), ...
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
plot(datetime(dataStruct.wave.time,'ConvertFrom','datenum'), ...
    dataStruct.wave.peak_wave_period,'Color',[0,191,255]/256, ...
    'LineWidth',lw,'DisplayName','Peak Wave Period')
hold on
offline = zeros(length(dataStruct.wave.time),1);
offline(~isnan(dataStruct.wave.peak_wave_period)) = nan;
if sum(~isnan(offline(:))) > 0
    plot(datetime(dataStruct.wave.time,'ConvertFrom','datenum'), ...
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
plot(datetime(dataStruct.met.time,'ConvertFrom','datenum'), ...
    dataStruct.met.wind_spd,'Color',[50,205,50]/256, ...
    'LineWidth',lw,'DisplayName',['Wind Speed at ' ...
    num2str(dataStruct.met.wind_ht) ' m'])
hold on
offline = zeros(length(dataStruct.met.time),1);
offline(~isnan(dataStruct.met.wind_spd)) = nan;
off_pts = find(offline == 0);
if sum(~isnan(offline(:))) > 0
    plot(datetime(dataStruct.met.time,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
    interpolated = fillmissing(dataStruct.met.wind_spd,'linear');
    plot(datetime(dataStruct.met.time(off_pts(:)), ... 
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
plot(datetime(dataStruct.met.time,'ConvertFrom','datenum'), ...
    dataStruct.met.shortwave_irradiance/1000,'Color',[255,69,0]/256, ...
    'LineWidth',lw,'DisplayName','Shortwave Solar Irradiance')
hold on
offline = zeros(length(dataStruct.met.time),1);
offline(~isnan(dataStruct.met.shortwave_irradiance)) = nan;
if sum(~isnan(offline(:))) > 0
    plot(datetime(dataStruct.met.time,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
end
xlim(xl)
%xticks(xt)
xlabel('Time')
ylabel({'[kW/m^2]'},'FontSize',14)
set(gca,'FontSize',fs)
legend('show')
grid on

linkaxes(ax,'x')

end


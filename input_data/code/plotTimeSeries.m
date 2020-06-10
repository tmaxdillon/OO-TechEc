function [] = plotTimeSeries(dataStruct,orig)

fs = 14; %font size
lw = 1; %line width

%%%%%%%%%%% SET VALUES %%%%%%%%%%%%%%

if isequal(orig,'orig')
    %must check to see if originals exist
    if isfield(dataStruct.met,'time_orig') %MET TIME
        time_met = dataStruct.met.time_orig;
    else
        time_met = dataStruct.met.time;
    end
    if isfield(dataStruct.wave,'time_orig') %WAVE TIME
        time_wave = dataStruct.wave.time_orig;
    else
        time_wave = dataStruct.wave.time;
    end
    if isfield(dataStruct.met,'wind_spd_orig') %WIND
        wind = dataStruct.met.wind_spd_orig;
    else
        wind = dataStruct.met.wind_spd;
    end
    if isfield(dataStruct.met,'shortwave_irradiance_orig') %INSO
        inso = dataStruct.met.shortwave_irradiance_orig;
    else
        inso = dataStruct.met.shortwave_irradiance;
    end
    if isfield(dataStruct.wave,'peak_wave_period_orig') %PERIOD
        tp = dataStruct.wave.peak_wave_period_orig;
    else
        tp = dataStruct.wave.peak_wave_period;
    end
    if isfield(dataStruct.wave,'significant_wave_height_orig') %HEIGHT
        hs = dataStruct.wave.significant_wave_height_orig;
    else
        hs = dataStruct.wave.significant_wave_height;
    end
    ht = dataStruct.met.wind_ht_orig;
else
    pts_met = 1:length(dataStruct.met.time);
    time_met = dataStruct.met.time(pts_met);
    time_wave = dataStruct.wave.time;
    wind = dataStruct.met.wind_spd(pts_met);
    inso = dataStruct.met.shortwave_irradiance(pts_met);
    tp = dataStruct.wave.peak_wave_period;
    ht = dataStruct.met.wind_ht;
    hs = dataStruct.wave.significant_wave_height;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
set(gcf, 'Position', [100, 100, 1100, 650])
% %WAVE HEIGHT
ax(1) = subplot(4,1,1);
plot(datetime(time_wave,'ConvertFrom','datenum'), ...
    hs,'Color',[100,149,237]/256, ...
    'LineWidth',lw,'DisplayName','Significant Wave Height')
hold on
offline = zeros(length(time_wave),1);
offline(~isnan(hs)) = nan;
if sum(~isnan(offline(:))) > 0
    plot(datetime(time_wave,'ConvertFrom','datenum'), ...
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
plot(datetime(time_wave,'ConvertFrom','datenum'), ...
    tp,'Color',[0,191,255]/256, ...
    'LineWidth',lw,'DisplayName','Peak Wave Period')
hold on
offline = zeros(length(time_wave),1);
offline(~isnan(tp)) = nan;
off_pts = find(offline == 0);
if sum(~isnan(offline(:))) > 0
    plot(datetime(time_wave,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
    interpolated = fillmissing(tp,'linear');
    plot(datetime(time_wave(off_pts(:)), ...
        'ConvertFrom','datenum'),interpolated(off_pts),'k.', ...
        'LineWidth',lw,'DisplayName','Linear Interpolation')
end
%xlabel('Time')
ylabel({'[s]'},'FontSize',14)
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
legend('show')
grid on
%WIND SPEED
ax(3) = subplot(4,1,3);
plot(datetime(time_met,'ConvertFrom','datenum'), ...
    wind,'Color',[50,205,50]/256, ...
    'LineWidth',lw,'DisplayName',['Wind Speed at ' ...
    num2str(ht) ' m'])
hold on
offline = zeros(length(time_met),1);
offline(~isnan(wind)) = nan;
off_pts = find(offline == 0);
if sum(~isnan(offline(:))) > 0
    plot(datetime(time_met,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
    interpolated = fillmissing(wind,'linear');
    plot(datetime(time_met(off_pts(:)), ...
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
plot(datetime(time_met,'ConvertFrom','datenum'), ...
    inso/1000,'Color',[255,69,0]/256, ...
    'LineWidth',lw,'DisplayName','Shortwave Solar Irradiance')
hold on
offline = zeros(length(time_met),1);
offline(~isnan(inso)) = nan;
if sum(~isnan(offline(:))) > 0
    plot(datetime(time_met,'ConvertFrom','datenum'), ...
        offline,'ro','DisplayName','Missing Data')
end
xlim(xl)
%xticks(xt)
if max(inso/1000) > 2 || min(inso/1000) < 1
    ylim([-0.5 2])
end
xlabel('Time')
ylabel({'[kW/m^2]'},'FontSize',14)
set(gca,'FontSize',fs)
legend('show')
grid on

linkaxes(ax,'x')

end


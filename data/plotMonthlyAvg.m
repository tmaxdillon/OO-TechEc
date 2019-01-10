function [] = plotMonthlyAvg(dataStruct)

Kwave = getMonthlyK(dataStruct,'wave');
Kwind = getMonthlyK(dataStruct,'wind');
Kinso = getMonthlyK(dataStruct,'inso');

fs = 14; %font size
lw = 1.5; %line width

figure
set(gcf, 'Position', [100, 100, 1000, 650])
%WAVE
ax(1) = subplot(3,1,1);
plot(datetime(Kwave(:,1),'ConvertFrom','datenum'), ...
    Kwave(:,2)/1000,'Color',[100,149,237]/256, ...
    'LineWidth',lw,'DisplayName','Wave Power Density')
%xlabel('Time')
ylabel({'[kW/m]'},'FontSize',14)
ylim([0 inf])
xl = xlim;
xt = datetime(Kwave(:,1),'ConvertFrom','datenum');
xticks(xt)
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
title({[dataStruct.title ' Renewable Power Density (Monthly Avg)'],''}, ... 
    'FontSize',18)
legend('show')
grid on
%WIND SPEED
ax(2) = subplot(3,1,2);
plot(datetime(Kwind(:,1),'ConvertFrom','datenum'), ...
    Kwind(:,2)/1000,'Color',[50,205,50]/256, ...
    'LineWidth',lw,'DisplayName',['Wind Power Density at ' ...
    num2str(dataStruct.met.wind_ht) ' m'])
xlim(xl)
xticks(xt)
%xlabel('Time')
ylabel({'[kW/m^2]'},'FontSize',14)
ylim([0 inf])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
legend('show')
grid on
%IRRADIANCE
ax(3) = subplot(3,1,3);
plot(datetime(Kinso(:,1),'ConvertFrom','datenum'), ...
    Kinso(:,2)/1000,'Color',[255,69,0]/256, ...
    'LineWidth',lw,'DisplayName','Solar Power Density')
xlim(xl)
xticks(xt)
xtickangle(45)
xlabel('Time')
ylabel({'[kW/m^2]'},'FontSize',14)
ylim([0 inf])
set(gca,'FontSize',fs)
legend('show')
grid on

linkaxes(ax,'x')
function [] = visWindSim(output,data,atmo,batt,econ,load,turb)

%find indices/real values
% [~,R_ind] = min(abs(opt.R - R_val));
% R_real = opt.R(R_ind);
% [~,Smax_ind] = min(abs(opt.Smax - Smax_val));
% Smax_real = opt.R(Smax_ind);

figure
%STORAGE TIME SERIES
ax(1) = subplot(3,1,1);
plot(datetime(data.met.time,'ConvertFrom','datenum'), ...
    output.min.S(1:end-1)/1000,'Color',[255,69,0]/256, ... 
    'DisplayName','Battery Storage','LineWidth',2)
legend('show')
ylabel('[kWh]')
ylim([0 inf])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on
%POWER TIME SERIES
ax(2) = subplot(3,1,2);
plot(datetime(data.met.time,'ConvertFrom','datenum'), ...
    output.min.P/1000,'Color',[65,105,225]/256, ... 
    'DisplayName','Power Produced','LineWidth',2)
legend('show')
ylabel('[kW]')
set(gca,'XTickLabel',[]);
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on
%DUMPED POWER TIME SERIES
ax(3) = subplot(3,1,3);
plot(datetime(data.met.time,'ConvertFrom','datenum'), ...
    output.min.D/1000,'Color',[75,0,130]/256, ... 
    'DisplayName','Power Dumped','LineWidth',2)
legend('show')
ylabel('[kW]')
xlabel('Time')
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on

set(gcf, 'Position', [100, 100, 1400, 650])

linkaxes(ax,'x')
linkaxes(ax(2:3),'y')


end


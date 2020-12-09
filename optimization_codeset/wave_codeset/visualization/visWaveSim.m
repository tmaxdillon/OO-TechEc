function [] = visWaveSim(optStruct,i)

data = optStruct.data;
output = optStruct.output;
opt = optStruct.opt;

figure
set(gcf,'Units','inches')
set(gcf,'Position', [0, 0, 20, 4])
%STORAGE TIME SERIES
ax(1) = subplot(3,1,1);
plot(datetime(opt.wave.time,'ConvertFrom','datenum'), ...
    output.min.S(1:end-1)/1000,'Color',[255,69,0]/256, ... 
    'DisplayName','Battery Storage','LineWidth',2)
legend('show')
ylabel('[kWh]')
%ylim([min(output.min.S(1:end-1)/1000) inf]) %for convo with mike
ylim([0 inf])
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
if exist('i','var')
    title(['point ' num2str(i)])
end
grid on
%POWER TIME SERIES
ax(2) = subplot(3,1,2);
plot(datetime(opt.wave.time,'ConvertFrom','datenum'), ...
    output.min.P/1000,'Color',[65,105,225]/256, ... 
    'DisplayName','Power Produced','LineWidth',2)
legend('show')
ylabel('[kW]')
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on
%DUMPED POWER TIME SERIES
ax(3) = subplot(3,1,3);
plot(datetime(opt.wave.time,'ConvertFrom','datenum'), ...
    output.min.D/1000,'Color',[75,0,130]/256, ... 
    'DisplayName','Power Dumped','LineWidth',2)
legend('show')
ylabel('[kW]')
xlabel('Time')
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on

linkaxes(ax,'x')
linkaxes(ax(2:3),'y')

end


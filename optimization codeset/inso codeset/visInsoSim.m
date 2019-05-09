function [] = visInsoSim(optStruct)

data = optStruct.data;
output = optStruct.output;

%extend time values
if ~isequal(length(output.min.P),length(data.met.time))
    orig_l = length(data.met.time);
    vecMid = datevec(data.met.time(end));
    data.met.time = [data.met.time ; zeros(length(output.min.P) ...
        - length(data.met.time),1)];
    for t = orig_l+1:length(data.met.time)
        vec = vecMid;
        vec(4) = vecMid(4) + t - orig_l;
        data.met.time(t) = datenum(vec);
    end
end

figure
%STORAGE TIME SERIES
ax(1) = subplot(4,1,1);
plot(datetime(data.met.time,'ConvertFrom','datenum'), ...
    output.min.S(1:end-1)/1000,'Color',[255,69,0]/256, ... 
    'DisplayName','Battery Storage','LineWidth',2)
legend('show')
ylabel('[kWh]')
ylim([0 inf])
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on
%POWER TIME SERIES
ax(2) = subplot(4,1,2);
plot(datetime(data.met.time,'ConvertFrom','datenum'), ...
    output.min.P/1000,'Color',[65,105,225]/256, ... 
    'DisplayName','Power Produced','LineWidth',2)
legend('show')
ylabel('[kW]')
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on
%DUMPED POWER TIME SERIES
ax(3) = subplot(4,1,3);
plot(datetime(data.met.time,'ConvertFrom','datenum'), ...
    output.min.D/1000,'Color',[75,0,130]/256, ... 
    'DisplayName','Power Dumped','LineWidth',2)
legend('show')
ylabel('[kW]')
xlabel('Time')
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on
%EFFICIENCY TIME SERIES
ax(4) = subplot(4,1,4);
plot(datetime(data.met.time,'ConvertFrom','datenum'), ...
    output.min.eff_t,'Color',[255,20,147]/256, ... 
    'DisplayName','Efficiency','LineWidth',2)
legend('show')
ylabel('[~]')
xlabel('Time')
ylim([0 1.25*max(output.min.eff_t)])
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
grid on

set(gcf, 'Position', [100, 100, 1400, 650])

linkaxes(ax,'x')
linkaxes(ax(2:3),'y')
end


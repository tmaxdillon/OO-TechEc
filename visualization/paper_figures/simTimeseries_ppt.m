clc, close all, clear ax
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

load('wavecons')

l = 5;

data = wavecons(l,1).data;
output = wavecons(l,1).output;
opt = wavecons(l,1).opt;

opt.wave.time = opt.wave.time(1):1/24:opt.wave.time(end);
t = length(opt.wave.time);

start_date = datetime(opt.wave.time(5000),'ConvertFrom','datenum');
end_date = datetime(2017,7,1);
%[~,end_date_ind] = min(abs(opt.wave.time - end_date));

%plot settings
fs = 10;
lw = 1;
lw2 = 0.9;
yls = -.1;

timeseries = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [0, 0, 11, 2.2])
%STORAGE TIME SERIES
ax(1) = subplot(3,1,1);
plot(datetime(opt.wave.time,'ConvertFrom','datenum'), ...
    output.min.S(1:t)/1000,'Color',[255,69,0]/256, ... 
    'DisplayName','Battery Storage','LineWidth',lw2)
%legend('show')
ylabel({'Battery','Storage','[kWh]'})
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
ylabpos = get(ylh,'Position');
ylabpos(1) = yls;
set(ylh,'Position',ylabpos)
%ylim([min(output.min.S(1:end-1)/1000) inf]) %for convo with mike
ylim([0 inf])
xlim([start_date end_date])
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on
%POWER TIME SERIES
P_adj = movmean(output.min.P(1:t)/1000,1);
ax(2) = subplot(3,1,2);
plot(datetime(opt.wave.time,'ConvertFrom','datenum'), ...
    P_adj,'Color',[65,105,225]/256, ... 
    'DisplayName','Power Produced','LineWidth',lw2)
%legend('show')
ylabel({'Power','Produced','[kW]'})
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
ylabpos = get(ylh,'Position');
ylabpos(1) = yls;
set(ylh,'Position',ylabpos)
xlim([start_date end_date])
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on
%DUMPED POWER TIME SERIES
D_adj = movmean(output.min.D(1:t)/1000,1);
ax(3) = subplot(3,1,3);
plot(datetime(opt.wave.time,'ConvertFrom','datenum'), ...
    D_adj,'Color',[75,0,130]/256, ... 
    'DisplayName','Power Dumped','LineWidth',lw2)
%legend('show')
ylabel({'Power','Discarded','[kW]'})
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
ylabpos = get(ylh,'Position');
ylabpos(1) = yls;
set(ylh,'Position',ylabpos)
%xlabel('Time')
xlim([start_date end_date])
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on

linkaxes(ax,'x')
linkaxes(ax(2:3),'y')

% set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
% set(ax,'Color',[255 255 245]/256)
% print(timeseries,['~/Dropbox (MREL)/Research/General Exam/' ...
%     'pf/timeseries'],'-dpng','-r600')

set(gcf, 'Color','w','InvertHardCopy','off')
set(ax,'Color','w')
print(timeseries,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
    'Presentation/Figures/timeseries'],'-dpng','-r600')
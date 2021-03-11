function [] = visWaveSim(optStruct,i)

set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

data = optStruct.data;
output = optStruct.output;
opt = optStruct.opt;

fs = 11;
lw = .75;
yls = -.1;

%[output.min.S,opt.wave.time] = extendToLifetime(output.min.S(1:end-1)',data.wave.time,5);

bdf = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [0, 0, 9, .95])
%STORAGE TIME SERIES
plot(datetime(opt.wave.time,'ConvertFrom','datenum'), ...
    output.min.S(1:end-1)/1000,'Color',[255,69,0]/256, ... 
    'DisplayName','Battery Storage','LineWidth',2)
ylabel({'Battery','Storage','[kWh]'})
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
ylabpos = get(ylh,'Position');
ylabpos(1) = yls;
set(ylh,'Position',ylabpos)
xl = xlim;
ylim([23 27])
xlim([xl])
yln = yline(max(output.min.S)/1000,'--b','Rated Capacity', ...
    'LabelHorizontalAlignment','right','LabelVerticalAlignment', ...
    'middle','FontSize',fs,'LineWidth',lw);
%set(gca,'XTickLabel',{'2016','2017','2018','2019','2020','2021'});
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
if exist('i','var')
    title(['point ' num2str(i)])
end
grid on

set(gcf, 'Color',[256 256 245]/256,'InvertHardCopy','off')
set(gca,'Color',[256 256 245]/256)
print(bdf,'~/Dropbox (MREL)/Research/General Exam/pf/batdeg_2', ...
    '-dpng','-r600')

end


function [p] = visDeviceCost(type,xmax,n)

if isequal(type,'turbine')
    xf = 0:0.01:xmax; %kW
    xlab = 'Rated Power [kW]';
    turbineLibrary
    x = zeros(1,length(turbineLib));
    y = zeros(1,length(turbineLib));
    %unpack into arrays
    for i = 1:length(turbineLib)
        x(i) = turbineLib(i).kW;
        %y(i) = turbineLib(i).cost/turbineLib(i).kW;
        y(i) = turbineLib(i).cost;
    end
    %ylab = '[$1000/kW]';
    ylab = '[$1000]';
end
if isequal(type,'battery')
    xf = 0:0.01:xmax; %kWh
    xlab = 'Storage Capacity [kWh]';
    batteryLibrary
    x = zeros(1,length(batteryLib));
    y = zeros(1,length(batteryLib));
    %unpack into arrays
    for i = 1:length(batteryLib)
        x(i) = batteryLib(i).kWh;
        y(i) = batteryLib(i).cost/batteryLib(i).kWh;
        y(i) = batteryLib(i).cost;
    end
    %ylab = '[$/kWh]';
    ylab = '[$]';
end

yf = zeros(length(xf),length(n));
p = zeros(max(n)+1,length(n));
for j=1:length(n)
    for i = 1:length(xf)
        [~,yf(i,j)] = calcDeviceCost(type,xf(i),n(j));
    end
    p(1:n(j)+1,j) = calcDeviceCost(type,[],n(j)); %store polyvals
end

color = ['b','r'];

figure
for j=1:length(n)
    %     h(j) = plot(xf,yf(:,j)./(xf*1000)',color(j),'DisplayName',[num2str(n(j)) ...
    %         ' order polynomial fit'],'LineWidth',1.4); % $1000/x by x
    %boundedline(x,y,delta,'alpha','transparency',.1)
    h(j) = plot(xf,yf(:,j),color(j),'DisplayName', ... 
        'Trend: $266 $/kWh' ,'LineWidth',1.7); % $1000/x by x
    hold on
end
hold on
h(j+1) = scatter(x,y,100,'.','k','DisplayName','Lead-Acid AGM Batteries');
ylabel(ylab)
xlabel(xlab)
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', ...
    'HorizontalAlignment','center')
set(gca,'FontSize',14,'LineWidth',1.4)
legend(h,'Location','Southeast')
ylim([0 inf])
set(gca,'FontSize',22)
set(gca,'LineWidth',1.5)
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'))
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%d'))
grid on

set(gcf, 'Position', [100, 100, 800, 300])


end


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
        y(i) = turbineLib(i).cost/turbineLib(i).kW;
    end
    ylab = '[$1000/kW]';
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
    end
    ylab = '[$1000/kWh]';
end

yf = zeros(length(xf),length(n));
p = zeros(max(n)+1,length(n));
for j=1:length(n)
    for i = 1:length(xf)
        [~,yf(i,j)] = calcDeviceCost(type,xf(i),n(j));
    end
    p(1:n(j)+1,j) = calcDeviceCost(type,[],n(j)); %store polyvals
end

color = ['r','b'];

figure
for j=1:length(n)
    h(j) = plot(xf,yf(:,j)./(xf*1000)',color(j),'DisplayName',[num2str(j) ... 
        ' order polynomial fit'],'LineWidth',1.4);
    %boundedline(x,y,delta,'alpha','transparency',.1)
    hold on
end
hold on
scatter(x,y/1000,100,'.','k')
if type
ylabel(ylab)
xlabel(xlab)
set(gca,'FontSize',14,'LineWidth',1.4)
legend(h,'Location','Southeast')
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'))
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%d'))
grid on

set(gcf, 'Position', [100, 100, 800, 300])


end


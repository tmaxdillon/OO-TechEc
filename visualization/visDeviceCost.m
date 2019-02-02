function [p] = visDeviceCost(type,xmax,n)

if isequal(type,'turbine')
    x1 = 0:0.01:xmax; %kW
    xlab = 'Rated Power [kW]';
    turbineLibrary
    x = zeros(1,length(turbineLib));
    y = zeros(1,length(turbineLib));
    %unpack into arrays
    for i = 1:length(turbineLib)
        x(i) = turbineLib(i).kW;
        y(i) = turbineLib(i).cost;
    end
end
if isequal(type,'battery')
    x1 = 0:0.01:xmax; %kWh
    xlab = 'Storage Capacity [kWh]';
    batteryLibrary
    x = zeros(1,length(batteryLib));
    y = zeros(1,length(batteryLib));
    %unpack into arrays
    for i = 1:length(batteryLib)
        x(i) = batteryLib(i).kWh;
        y(i) = batteryLib(i).cost;
    end
end

y1 = zeros(size(x1));
for i = 1:length(x1)
    y1(i) = calcDeviceCost(x1(i),type,n);
end

[~,p] = calcDeviceCost(0,type,n); %store polyvals

figure
plot(x1,y1/1000,'r')
%boundedline(x,y,delta,'alpha','transparency',.1)
hold on
scatter(x,y/1000,100,'.','k')
ylabel('Cost in Thousands [$]')
xlabel(xlab)
set(gca,'FontSize',14,'LineWidth',1.4)
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'))
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%d'))
grid on

end


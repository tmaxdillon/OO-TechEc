function [] = visSensitivity(multStruct)

%x axis title
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    xlab = 'Percent Uptime';
    xt = fliplr(multStruct(1).opt.tuning_array);
elseif isequal(multStruct(1).opt.tuned_parameter,'load')
    xlab = 'Load [W]';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'bgd')
    xlab = 'Input Mesh Size: Smax Axis Extent [days of battery storage]';
    xt = min(multStruct(1).opt.tuning_array):3: ... 
        max(multStruct(1).opt.tuning_array);
end

cost = zeros(1,length(multStruct));
Scost = zeros(1,length(multStruct));
kWcost = zeros(1,length(multStruct));
OpEx = zeros(1,length(multStruct));
Smax = zeros(1,length(multStruct));
kW = zeros(1,length(multStruct));

%unpack multStruct
for i = 1:length(multStruct)
    cost(i) = multStruct(i).output.min.cost;
    Scost(i) = multStruct(i).output.min.Scost;
    kWcost(i) = multStruct(i).output.min.kWcost;
    OpEx(i) = multStruct(i).output.min.OpEx;
    Smax(i) = multStruct(i).output.min.Smax;
    kW(i) = multStruct(i).output.min.kW;
end

%cost
figure
ax(1) = subplot(3,1,1);
% plot(multStruct(1).opt.tuning_array,(Scost(:)+kWcost(:))./cost(:).*100, ...
%     'LineWidth',1.3,'DisplayName','Storage + Turbine')
% hold on
% plot(multStruct(1).opt.tuning_array,Scost(:)./cost(:).*100, ...
%     'LineWidth',1.3,'DisplayName', ...
%     'Storage Cost')
% hold on
% plot(multStruct(1).opt.tuning_array,kWcost(:)./cost(:).*100, ...
%     'LineWidth',1.3,'DisplayName', ...
%     'Turbine Cost')
area(multStruct(1).opt.tuning_array,[Scost;kWcost;OpEx]'./1000, ... 
    'DisplayName',['S','T','O'])
ylabel('cost in thousands')
ylim([0 inf])
xticks(xt)
legend('Storage','Turbine','OpEx (no shipping)','Location','NorthWest')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    set(gca,'xdir','reverse')
end
grid on
%radius
ax(2) = subplot(3,1,2);
plot(multStruct(1).opt.tuning_array,kW,'Color',[0,255,127]/256, ...
    'LineWidth',1.6,'DisplayName','Rated Power')
ylabel('[kW]')
ylim([0 inf])
xticks(xt)
legend('show','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    set(gca,'xdir','reverse')
end
grid on
%storage
ax(3) = subplot(3,1,3);
plot(multStruct(1).opt.tuning_array,Smax,'k','LineWidth',1.6,'DisplayName', ...
    'Storage Capacity')
ylabel('[kWh]')
ylim([0 inf])
xticks(xt)
xlabel(xlab)
legend('show','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    set(gca,'xdir','reverse')
end
grid on

linkaxes(ax,'x')

set(gcf, 'Position', [100, 100, 800, 400])
end


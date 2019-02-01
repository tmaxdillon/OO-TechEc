function [] = visDrawSens(multStruct)

cost = zeros(1,length(multStruct));
Scost = zeros(1,length(multStruct));
kWcost = zeros(1,length(multStruct));
R = zeros(1,length(multStruct));
Smax = zeros(1,length(multStruct));
ratedP = zeros(1,length(multStruct));

%unpack multStruct
for i = 1:length(multStruct)
    cost(i) = multStruct(i).output.min.cost;
    Scost(i) = multStruct(i).output.min.Scost;
    kWcost(i) = multStruct(i).output.min.kWcost;
    R(i) = multStruct(i).output.min.R;
    Smax(i) = multStruct(i).output.min.Smax;
    ratedP(i) = multStruct(i).output.min.ratedP;
end

xt = multStruct(1).opt.tuning_array;

%cost
figure
ax(1) = subplot(3,1,1);
plot(multStruct(1).opt.tuning_array,(Scost(:)+kWcost(:))./cost(:).*100, ... 
    'LineWidth',1.3,'DisplayName', ... 
    'Storage + Turbine Cost')
hold on
plot(multStruct(1).opt.tuning_array,Scost(:)./cost(:).*100, ... 
    'LineWidth',1.3,'DisplayName', ...
    'Storage Cost')
hold on
plot(multStruct(1).opt.tuning_array,kWcost(:)./cost(:).*100, ...
    'LineWidth',1.3,'DisplayName', ...
    'Turbine Cost')
ylabel('% of total cost')
xticks(xt)
legend('show','Location','NorthWest')
set(gca,'LineWidth',1.1,'Fontsize',14)
grid on
%rated power
ax(2) = subplot(3,1,2);
plot(multStruct(1).opt.tuning_array,ratedP,'Color',[0,255,127]/256, ... 
    'LineWidth',1.6,'DisplayName','Rated Power')
ylabel('[kW]')
xticks(xt)
legend('show','Location','NorthWest')
set(gca,'LineWidth',1.1,'Fontsize',14)
grid on
%storage
ax(3) = subplot(3,1,3);
plot(multStruct(1).opt.tuning_array,Smax,'k','LineWidth',1.6,'DisplayName', ... 
    'Storage Capacity')
ylabel('[kWh]')
xticks(xt)
xlabel('Load [W]')
legend('show','Location','NorthWest')
set(gca,'LineWidth',1.1,'Fontsize',14)
grid on

linkaxes(ax,'x')

set(gcf, 'Position', [100, 100, 800, 400])
end


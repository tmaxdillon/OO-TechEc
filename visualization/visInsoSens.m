function [] = visInsoSens(multStruct,xlab,xt)

cost = zeros(1,length(multStruct));
Scost = zeros(1,length(multStruct));
Mcost = zeros(1,length(multStruct));
maint = zeros(1,length(multStruct));
FScost = zeros(1,length(multStruct));
Icost = zeros(1,length(multStruct));
Ecost = zeros(1,length(multStruct));
Smax = zeros(1,length(multStruct));
kW = zeros(1,length(multStruct));
trips = zeros(1,length(multStruct));
repair = zeros(1,length(multStruct));
fuelcost = zeros(1,length(multStruct));
vesselcost = zeros(1,length(multStruct));

%unpack multStruct
for i = 1:length(multStruct)
    cost(i) = multStruct(i).output.min.cost;
    Scost(i) = multStruct(i).output.min.Scost;
    Mcost(i) = multStruct(i).output.min.Mcost;
    maint(i) = multStruct(i).output.min.maint;
    FScost(i) = multStruct(i).output.min.FScost;
    Icost(i) = multStruct(i).output.min.Icost;
    Ecost(i) = multStruct(i).output.min.Ecost;
    Smax(i) = multStruct(i).output.min.Smax;
    kW(i) = multStruct(i).output.min.kW;
    trips(i) = multStruct(i).output.min.trips;
    repair(i) = multStruct(i).output.min.repair;
    fuelcost(i) = multStruct(i).output.min.fuelcost;
    vesselcost(i) = multStruct(i).output.min.vesselcost;
end

%cost
figure
ax(1) = subplot(5,1,1:3);
a = area(multStruct(1).opt.tuning_array,[Scost;Mcost;FScost;Icost;Ecost; ... 
    maint;fuelcost;vesselcost;repair]'./1000);
%colormap differentiating OpEx from CapEx
CapCol = colormap(brewermap(5,'reds'));
OpCol = colormap(brewermap(4,'purples'));
a(1).FaceColor = CapCol(1,:);
a(2).FaceColor = CapCol(2,:);
a(3).FaceColor = CapCol(3,:);
a(4).FaceColor = CapCol(4,:);
a(5).FaceColor = CapCol(5,:);
a(6).FaceColor = OpCol(1,:);
a(7).FaceColor = OpCol(2,:);
a(8).FaceColor = OpCol(3,:);
a(9).FaceColor = OpCol(4,:);
ylabel('cost in thousands')
ylim([0 1.25*max(cost)/1000])
xticks(xt)
legend('CapEx: Storage','CapEx: Module','CapEx: Platform', ... 
    'CapEx: Installation','CapEx: Electrical','OpEx: Maintenance', ... 
    'OpEx: Fuel', ... 
    'OpEx: Vessel','OpEx: Repair','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    set(gca,'xdir','reverse')
end
grid on
%rated power
ax(2) = subplot(5,1,4);
plot(multStruct(1).opt.tuning_array,kW,'Color',[0,255,127]/256, ...
    'LineWidth',1.6,'DisplayName','Capacity')
ylabel('[kW]')
ylim([0 1.25*max(kW)])
xticks(xt)
legend('show','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    set(gca,'xdir','reverse')
end
grid on
%storage
ax(3) = subplot(5,1,5);
plot(multStruct(1).opt.tuning_array,Smax,'k','LineWidth',1.6,'DisplayName', ...
    'Storage Capacity')
ylabel('[kWh]')
ylim([0 1.25*max(Smax)])
xticks(xt)
xlabel(xlab)
legend('show','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    set(gca,'xdir','reverse')
end
grid on

linkaxes(ax,'x')

set(gcf, 'Position', [100, 100, 800, 600])

end


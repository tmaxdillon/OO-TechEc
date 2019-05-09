function [] = visInsoSens(multStruct,xlab,xt,xscale,ylab,yscale)

cost = zeros(1,length(multStruct));
Mcost = zeros(1,length(multStruct));
Scost = zeros(1,length(multStruct));
Ecost = zeros(1,length(multStruct));
Icost = zeros(1,length(multStruct));
FScost = zeros(1,length(multStruct));
maint = zeros(1,length(multStruct));
vesselcost = zeros(1,length(multStruct));
fuelcost = zeros(1,length(multStruct));
PVreplace = zeros(1,length(multStruct));
battreplace = zeros(1,length(multStruct));
battencl = zeros(1,length(multStruct));
wiring = zeros(1,length(multStruct));
Smax = zeros(1,length(multStruct));
kW = zeros(1,length(multStruct));

%unpack multStruct
for i = 1:length(multStruct)
    cost(i) = multStruct(i).output.min.cost;
    Mcost(i) = multStruct(i).output.min.Mcost;
    Scost(i) = multStruct(i).output.min.Scost;
    Ecost(i) = multStruct(i).output.min.Ecost;
    Icost(i) = multStruct(i).output.min.Icost;
    FScost(i) = multStruct(i).output.min.FScost;
    maint(i) = multStruct(i).output.min.maint;
    vesselcost(i) = multStruct(i).output.min.vesselcost;
    fuelcost(i) = multStruct(i).output.min.fuelcost;
    PVreplace(i) = multStruct(i).output.min.PVreplace;
    battreplace(i) = multStruct(i).output.min.battreplace;
    battencl(i) = multStruct(i).output.min.battencl;
    wiring(i) = multStruct(i).output.min.wiring;
    Smax(i) = multStruct(i).output.min.Smax;
    kW(i) = multStruct(i).output.min.kW;
end

%cost
figure
ax(1) = subplot(5,1,1:3);
if exist('yscale','var'), yscale = (1/1000)*yscale; else, yscale = 1/1000; end
if exist('xscale','var'), xscale = xscale; else, xscale = 1; end
a = area(multStruct(1).opt.tuning_array.*xscale, ... 
    [Mcost;Scost;Icost;FScost;Ecost;battencl;wiring; ... 
    maint;PVreplace;battreplace;fuelcost;vesselcost]'.*yscale);
%colormap differentiating OpEx from CapEx
CapN = 7;
OpN = 5;
CapCol = colormap(brewermap(CapN,'reds'));
OpCol = colormap(brewermap(OpN,'purples'));
for i = 1:CapN
    a(i).FaceColor = CapCol(i,:);
end
for i = 1:OpN
    a(CapN+i).FaceColor = OpCol(i,:);
end
if exist('ylab','var'), ylabel(ylab), else, ylabel('cost in thousands'), end
ylim([0 1.25*max(cost).*yscale])
xticks(xt)
legend('CapEx: Storage','CapEx: Module','CapEx: Platform', ... 
    'CapEx: Installation','CapEx: Electrical','CapEx: Battery Enclosure', ... 
    'CapEx: Wiring','OpEx: Maintenance','OpEx: PV Replacememnt', ... 
    'OpEx: Battery Replacements','OpEx: Fuel', ... 
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


function [] = visWindSens(multStruct,xlab,xt,xscale,ylab,yscale)

cost = zeros(1,length(multStruct));
kWcost = zeros(1,length(multStruct));
Icost = zeros(1,length(multStruct));
Scost = zeros(1,length(multStruct));
battencl = zeros(1,length(multStruct));
Pmtrl = zeros(1,length(multStruct));
Pinst = zeros(1,length(multStruct));
Panchor = zeros(1,length(multStruct));
Pline = zeros(1,length(multStruct));
vesselcost = zeros(1,length(multStruct));
turbrepair = zeros(1,length(multStruct));
battreplace = zeros(1,length(multStruct));
Smax = zeros(1,length(multStruct));
kW = zeros(1,length(multStruct));

%unpack multStruct
for i = 1:length(multStruct)
    cost(i) = multStruct(i).output.min.cost;
    kWcost(i) = multStruct(i).output.min.kWcost;
    Icost(i) = multStruct(i).output.min.Icost;    
    Scost(i) = multStruct(i).output.min.Scost;
    battencl(i) = multStruct(i).output.min.battencl;
    Pmtrl(i) = multStruct(i).output.min.Pmtrl;
    Pinst(i) = multStruct(i).output.min.Pinst;
    Panchor(i) = multStruct(i).output.min.Panchor;
    Pline(i) = multStruct(i).output.min.Pline;
    vesselcost(i) = multStruct(i).output.min.vesselcost;
    turbrepair(i) = multStruct(i).output.min.turbrepair;
    battreplace(i) = multStruct(i).output.min.battreplace;
    Smax(i) = multStruct(i).output.min.Smax;
    kW(i) = multStruct(i).output.min.kW;
end

%cost
figure
ax(1) = subplot(5,1,1:3);
if exist('yscale','var'), yscale = (1/1000)*yscale; else, yscale = 1/1000; end
if exist('xscale','var'), xscale = xscale; else, xscale = 1; end
a = area(multStruct(1).opt.tuning_array.*xscale, ... 
    [kWcost;Icost;Scost;battencl;Pmtrl;Pinst;Panchor;Pline; ... 
    vesselcost;turbrepair;battreplace]'.*yscale);
%colormap differentiating OpEx from CapEx
CapN = 8;
OpN = 3;
CapCol = colormap(brewermap(CapN,'reds'));
OpCol = colormap(brewermap(OpN,'purples'));
for i = 1:CapN
    a(i).FaceColor = CapCol(i,:);
end
for i = 1:OpN
    a(CapN+i).FaceColor = OpCol(i,:);
end
if exist('ylab','var'), ylabel(ylab), else, ylabel('cost in thousands'), end
ylim([0 1.25*max(cost)*yscale])
xticks(xt)
legend('CapEx: Turbine','CapEx: Turbine Installation','CapEx: Battery', ... 
    'CapEx: Battery Enclosure','CapEx: Platform Material', ...
    'CapEx: Platform Installation','CapEx: Anchor','CapEx: Line', ...
    'OpEx: Vessel','OpEx: Turbine Repair', ... 
    'OpEx: Battery Replacement','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    set(gca,'xdir','reverse')
end
grid on
%radius
ax(2) = subplot(5,1,4);
plot(multStruct(1).opt.tuning_array*xscale,kW,'Color',[0,255,127]/256, ...
    'LineWidth',1.6,'DisplayName','Rated Power')
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
plot(multStruct(1).opt.tuning_array*xscale,Smax,'k','LineWidth',1.6,'DisplayName', ...
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


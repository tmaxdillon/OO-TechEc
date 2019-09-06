function [] = visWaveSens(multStruct,xlab,xt,xscale,ylab,yscale)

cost = zeros(1,length(multStruct));
wecCapEx = zeros(1,length(multStruct));
wecOpEx = zeros(1,length(multStruct));
battCapEx = zeros(1,length(multStruct));
battOpEx = zeros(1,length(multStruct));
vesselcost = zeros(1,length(multStruct));
Smax = zeros(1,length(multStruct));
kW = zeros(1,length(multStruct));
CF = zeros(1,length(multStruct));

%unpack multStruct
for i = 1:length(multStruct)
    cost(i) = multStruct(i).output.min.cost;
    wecCapEx(i) = multStruct(i).output.min.kWcost + ...
        multStruct(i).output.min.Icost + ...
        multStruct(i).output.min.FScost;
    wecOpEx(i) = multStruct(i).output.min.maint + ...
        multStruct(i).output.min.wecrepair;
    battCapEx(i) = multStruct(i).output.min.Scost + ...
        multStruct(i).output.min.battencl + ...
        multStruct(i).output.min.platform;
    battOpEx(i) = multStruct(i).output.min.battreplace;
    vesselcost(i) = multStruct(i).output.min.vesselcost;
    Smax(i) = multStruct(i).output.min.Smax;
    kW(i) = multStruct(i).output.min.kW;
    CF(i) = multStruct(i).output.min.CF;
end

%cost
figure
ax(1) = subplot(6,1,1:3);
if exist('yscale','var'), yscale = (1/1000)*yscale; else, yscale = 1/1000; end
if exist('xscale','var'), xscale = xscale; else, xscale = 1; end
a = area(multStruct(1).opt.tuning_array.*xscale, ... 
    [wecCapEx;battCapEx;wecOpEx;battOpEx;vesselcost]'.*yscale);
%colormap differentiating OpEx from CapEx
CapN = 2;
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
legend('CapEx: WEC','CapEx: Battery','OpEx: WEC','OpEx: Battery', ... 
    'OpEx: Vessel','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp') || ...
        isequal(multStruct(1).opt.tuned_parameter,'wcp')
    set(gca,'xdir','reverse')
end
grid on
%radius
ax(2) = subplot(6,1,4);
plot(multStruct(1).opt.tuning_array*xscale,kW,'Color',[0,255,127]/256, ...
    'LineWidth',1.6,'DisplayName','Rated Power')
ylabel('[kW]')
ylim([0 1.25*max(kW)])
xticks(xt)
legend('show','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp') || ...
        isequal(multStruct(1).opt.tuned_parameter,'wcp')
    set(gca,'xdir','reverse')
end
grid on
%storage
ax(3) = subplot(6,1,5);
plot(multStruct(1).opt.tuning_array*xscale,Smax,'k','LineWidth',1.6,'DisplayName', ...
    'Storage Capacity')
ylabel('[kWh]')
ylim([0 1.25*max(Smax)])
xticks(xt)
legend('show','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp') || ...
        isequal(multStruct(1).opt.tuned_parameter,'wcp')
    set(gca,'xdir','reverse')
end
grid on
%capacity factor
ax(4) = subplot(6,1,6);
plot(multStruct(1).opt.tuning_array*xscale,CF,'r','LineWidth',1.6,'DisplayName', ...
    'Capacity Factor')
ylabel('[kWh]')
ylim([0 1])
xticks(xt)
xlabel(xlab)
legend('show','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp') || ...
        isequal(multStruct(1).opt.tuned_parameter,'wcp')
    set(gca,'xdir','reverse')
end
grid on

linkaxes(ax,'x')

set(gcf, 'Position', [100, 100, 800, 750])

end



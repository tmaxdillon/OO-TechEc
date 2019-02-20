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
elseif isequal(multStruct(1).opt.tuned_parameter,'mxn')
    xlab = '1D Mesh Resolution';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'zo')
    xlab = 'Surface Roughness';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'mtbf')
    xlab = 'Mean Time Between Failure';
    xt = multStruct(1).opt.tuning_array;
end

cost = zeros(1,length(multStruct));
Scost = zeros(1,length(multStruct));
kWcost = zeros(1,length(multStruct));
maint = zeros(1,length(multStruct));
FScost = zeros(1,length(multStruct));
Icost = zeros(1,length(multStruct));
shipping = zeros(1,length(multStruct));
Smax = zeros(1,length(multStruct));
kW = zeros(1,length(multStruct));

%unpack multStruct
for i = 1:length(multStruct)
    cost(i) = multStruct(i).output.min.cost;
    Scost(i) = multStruct(i).output.min.Scost;
    kWcost(i) = multStruct(i).output.min.kWcost;
    maint(i) = multStruct(i).output.min.maint;
    FScost(i) = multStruct(i).output.min.FScost;
    Icost(i) = multStruct(i).output.min.Icost;
    shipping(i) = multStruct(i).output.min.shipping;
    Smax(i) = multStruct(i).output.min.Smax;
    kW(i) = multStruct(i).output.min.kW;
end

%cost
figure
ax(1) = subplot(5,1,1:3);
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
a = area(multStruct(1).opt.tuning_array,[Scost;kWcost;FScost;Icost; ... 
    maint;shipping]'./1000,'DisplayName',['S','T','O']);
CapCol = colormap(brewermap(8,'reds'));
OpCol = colormap(brewermap(4,'purples'));
a(1).FaceColor = CapCol(5,:);
a(2).FaceColor = CapCol(6,:);
a(3).FaceColor = CapCol(7,:);
a(4).FaceColor = CapCol(8,:);
a(5).FaceColor = OpCol(3,:);
a(6).FaceColor = OpCol(4,:);
ylabel('cost in thousands')
ylim([0 1.25*max(cost)/1000])
xticks(xt)
legend('CapEx: Storage','CapEx: Turbine','CapEx: Platform','CapEx: Installation', ... 
    'OpEx: Maintenance','OpEx: Shipping','Location','NorthEast')
set(gca,'LineWidth',1.1,'Fontsize',14)
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    set(gca,'xdir','reverse')
end
grid on
%radius
ax(2) = subplot(5,1,4);
plot(multStruct(1).opt.tuning_array,kW,'Color',[0,255,127]/256, ...
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


function [multStruct] = visMultOpts(multStruct)

%unpack
opt = multStruct(1).opt; opt.fmin = false;
data = multStruct(1).data;
atmo = multStruct(1).atmo;
batt = multStruct(1).batt;
econ = multStruct(1).econ;
uc = multStruct(1).uc;
turb = multStruct(1).turb;

%curve-fit devices, find polyvals
p.t = calcDeviceCost('turbine',[],econ.turb_n);
[p.b,~,p.kWhmax] = calcDeviceCost('battery',[],econ.batt_n);

%preallocate
min_s = zeros(1,length(multStruct));
min_kW = zeros(1,length(multStruct));
min_z = zeros(1,length(multStruct));
init_s = zeros(1,length(multStruct));
init_kW = zeros(1,length(multStruct));
init_z = zeros(1,length(multStruct));

for i = 1:length(multStruct)
    min_s(i) = multStruct(i).output.min.Smax;
    min_kW(i) = multStruct(i).output.min.kW;
    min_z(i) = multStruct(i).output.min.cost;
    init_s(i) = multStruct(i).opt.Smax_init;
    init_kW(i) = multStruct(i).opt.kW_init;
    init_z(i) = multStruct(i).opt.init;
end

%compute vis surface
kW = linspace(0,1.1*max([min_kW(:) ; init_kW(:)]),100);
Smax = linspace(0,1.1*max([min_s(:) ; init_s(:)]),100);
if ~isfield(multStruct(1),'savedsurf')
    opt.surfacecreation = true;
    for i=1:100
        for j=1:100
            [surface.cost(i,j),surface.surv(i,j)] ...
                = simWind(kW(i),Smax(j),opt,data,atmo,batt,econ,uc,turb,p);
        end
    end
else 
    surface = multStruct(1).savedsurf;
end

%create grid
[Smaxgrid,kWgrid] = meshgrid(Smax,kW);
ms = 100;
lw = 1.1;
fs = 14;
z_adj = 20;

%remove failure configurations
alive = surface.cost;
alive(surface.surv == 0) = nan;

figure
s = surf(Smaxgrid,kWgrid,surface.cost,zeros(length(Smaxgrid),length(kWgrid),3));
s.EdgeColor = 'none';
hold on
s = surf(Smaxgrid,kWgrid,alive);
s.EdgeColor = 'none';
hold on
[~,con] = contour3(Smaxgrid,kWgrid,surface.cost,'LineColor','w');
hold on
col = colormap(brewermap(length(multStruct),'purples'));
for i = 1:length(multStruct)
    minval = scatter3(min_s(i),min_kW(i),min_z(i)+z_adj,...
        ms,'filled','MarkerEdgeColor',col(i,:),'MarkerFaceColor',col(i,:));
    hold on
    initval = scatter3(init_s(i),init_kW(i),init_z(i)+z_adj, ...
        ms,'MarkerEdgeColor',col(i,:));
end
xlabel('Storage Capacity [kWh]')
xlim([min(opt.Smax) inf])
ylabel('Rated Power [kW]')
ylim([min(opt.kW) inf])
c = colorbar;
c.Label.String = '[$] in thousands';
lb = min(min_z)/max(surface.cost(:));
AdvancedColormap('bg l w r',8000,[lb,lb+.05*(1-lb),lb+0.1*(1-lb),1])
hold on
l = legend([s initval minval con],'Input Mesh','Coarse Grid Minima', ...
    'Nelder-Mead Minima','Cost Contours','location','SouthWest');
l.Color = [.5 .5 .5];
title('Total Cost')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on
view(0,90)

multStruct(1).savedsurf = surface;

end


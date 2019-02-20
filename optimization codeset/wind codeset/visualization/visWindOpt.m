function [] = visWindOpt(optStruct)

opt = optStruct.opt;
output = optStruct.output;
data = optStruct.data;
atmo = optStruct.atmo;
turb = optStruct.turb;

%adjust to thousands
output.cost = output.cost/1000;
opt.init = opt.init/1000;
output.min.cost = output.min.cost/1000;

kW = (1/1000)*1/2*atmo.rho.*opt.R.^2.*pi.*turb.ura^3*turb.eta;
kW_init = (1/1000)*1/2*atmo.rho.*opt.R_init.^2.*pi.*turb.ura^3*turb.eta;

[Smaxgrid,kWgrid] = meshgrid(opt.Smax,kW);
ms = 100;
lw = 1.1;
fs = 14;
annodim1 = [.2 .5 .3 .3];
annodim2 = [.2 .3 .3 .3];
textadj.x = 5;
textadj.y = .2;

figure
%COST
a = 1; ax(a) = subplot(2,2,a);
% for i=1:size(output.cost,1)
%     for j=1:size(output.cost,2)
%         if output.surv(i,j) == 0
%             output.cost = opt.init + (opt.init - output.cost);
%         end
%     end
% end
%surf(Smaxgrid,Rgrid,output.cost);
scatter3(reshape(Smaxgrid,length(Smaxgrid)^2,1), ...
    reshape(kWgrid,length(kWgrid)^2,1),reshape(output.cost,length(output.cost)^2,1), ... 
    100,reshape(output.cost,length(output.cost)^2,1))
hold on
minval = scatter3(output.min.Smax,output.min.ratedP,output.min.cost,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
initval = scatter3(opt.Smax_init,kW_init,opt.init, ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rated Power [kW]')
xlim([min(opt.Smax) inf])
ylim([min(kW) inf])
c = colorbar;
c.Label.String = '[$] in thousands';
colormap(ax(a),brewermap([],'RdGy'))
hold on
annotation('textbox',annodim1,'String',['$ ' num2str(round(output.min.cost,2))], ...
    'FitBoxToText','on','color','m','BackgroundColor','w')
annotation('textbox',annodim2,'String',['$ ' ...
    num2str(round(opt.init,2))], ...
    'FitBoxToText','on','color','k','BackgroundColor','w')
legend([initval minval],'Grid Minima','Nelder-Mead Minima','location','NorthWest')
title('Total Cost')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on
%SCOST/KWCOST
a = 2; ax(a) = subplot(2,2,a);
costratio = output.Scost./output.kWcost;
costratio(output.surv == 0) = nan;
surf(Smaxgrid,kWgrid,costratio);
hold on
minval = scatter3(output.min.Smax,output.min.ratedP,output.min.Scost/output.min.kWcost,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
scatter3(opt.Smax_init,kW_init,output.Scost(opt.I_init(1),opt.I_init(2))/ ... 
    output.kWcost(opt.I_init(1),opt.I_init(2)), ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rated Power [kW]')
xlim([min(opt.Smax) inf])
ylim([min(kW) inf])
c = colorbar;
c.Label.String = '[~]';
colormap(ax(a),brewermap([],'Purples'))
caxis([0 inf])
hold on
% annotation('textbox',annodim1,'String',['$ ' num2str(output.min.cost)], ...
%     'FitBoxToText','on','color','m')
% annotation('textbox',annodim2,'String',['$ ' ...
%     num2str(output.cost(opt.I_init(1),opt.I_init(2)))], ...
%     'FitBoxToText','on','color','m')
legend(minval,[num2str(round(output.min.Scost/output.min.kWcost,3)) ' kW'], ...
    'location','NorthWest')
title('Storage Cost to kW Cost Ratio')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on
%PAVG
a = 3; ax(a) = subplot(2,2,a);
pavg = nanmean(output.P,3);
pavg(output.surv == 0) = nan;
surf(Smaxgrid,kWgrid,pavg/1000);
hold on
minval = scatter3(output.min.Smax,output.min.ratedP,nanmean(output.min.P)/1000,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
scatter3(opt.Smax_init,kW_init, ... 
    nanmean(output.P(opt.I_init(1),opt.I_init(2))/1000), ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rated Power [kW]')
xlim([min(opt.Smax) inf])
ylim([min(opt.R) inf])
c = colorbar;
c.Label.String = '[kW]';
colormap(ax(a),brewermap([],'Purples'))
caxis([0 inf])
legend(minval,[num2str(round(nanmean(output.min.P)/1000,3)) ' kW'], ...
    'location','NorthWest')
title('Average Power')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on
%DTOTAL
a = 4; ax(a) = subplot(2,2,a);
for i = 1:opt.m
    for j = 1:opt.n
        dtotal(i,j) = trapz(data.met.time,output.D(i,j,:));
    end
end
dtotal(output.surv == 0) = nan;
ytotal = ((data.met.time(end) - data.met.time(1))*24)/8760;
surf(Smaxgrid,kWgrid,(dtotal/1000)/ytotal);
hold on
minval = scatter3(output.min.Smax,output.min.ratedP, ... 
    trapz(data.met.time,output.min.D/1000)/ytotal, ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
scatter3(opt.Smax_init,kW_init,trapz(data.met.time, ... 
    output.D(opt.I_init(1),opt.I_init(2),:)/1000)/ytotal, ... 
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rated Power [kW]')
xlim([min(opt.Smax) inf])
ylim([min(kW) inf])
c = colorbar;
c.Label.String = '[kWh/year]';
colormap(ax(a),brewermap([],'Purples'))
caxis([0 inf])
legend(minval,[num2str(round(trapz(data.met.time,output.min.D/1000)/ytotal,2)) ...
    ' kWh/year'],'location','NorthWest')
title('Dumped Power')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on


set(gcf, 'Position', [100, 100, 800*1.2, 600*1.2])
axis(ax,'square')

% %SURVIVAL
% a = 5; ax(a) = subplot(3,2,a);
% surf(Smaxgrid,Rgrid,output.surv);
% view(0,90)
% xlabel('Storage Capacity [kWh]')
% ylabel('Rotor Radius [m]')
% xlim([min(opt.Smax) inf])
% ylim([min(opt.R) inf])
% c = colorbar;
% c.Label.String = 'Survival';
% colormap(ax(a),brewermap(2,'RdYlGn'))
% grid on
% %CAPACITY FACTOR
% a = 6; ax(a) = subplot(3,2,a);
% output.CF(output.surv == 0) = nan;
% surf(Smaxgrid,Rgrid,output.CF);
% view(0,90)
% xlabel('Storage Capacity [kWh]')
% ylabel('Rotor Radius [m]')
% xlim([min(opt.Smax) inf])
% ylim([min(opt.R) inf])
% c = colorbar;
% c.Label.String = 'Capacity Factor';
% colormap(ax(a),brewermap([],'YlGnBu'))

end


function [] = visWindOpt(opt,output,data,atmo,batt,econ,load,turb)

[Smaxgrid,Rgrid] = meshgrid(opt.Smax,opt.R);
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
output.cost(output.surv == 0) = nan;
%surf(Smaxgrid,Rgrid,output.cost);
scatter3(reshape(Smaxgrid,length(Smaxgrid)^2,1), ...
    reshape(Rgrid,length(Rgrid)^2,1),reshape(output.cost,length(output.cost)^2,1), ... 
    100,reshape(output.cost,length(output.cost)^2,1))
hold on
minval = scatter3(output.min.Smax,output.min.R,output.min.cost,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
initval = scatter3(opt.Smax_init,opt.R_init,output.cost(opt.I_init(1),opt.I_init(2)), ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rotor Radius [m]')
xlim([min(opt.Smax) inf])
ylim([min(opt.R) inf])
c = colorbar;
c.Label.String = '[$]';
colormap(ax(a),brewermap([],'Purples'))
caxis([0 inf])
hold on
annotation('textbox',annodim1,'String',['$ ' num2str(round(output.min.cost,2))], ...
    'FitBoxToText','on','color','m','BackgroundColor','w')
annotation('textbox',annodim2,'String',['$ ' ...
    num2str(round(output.cost(opt.I_init(1),opt.I_init(2)),2))], ...
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
surf(Smaxgrid,Rgrid,costratio);
hold on
minval = scatter3(output.min.Smax,output.min.R,output.min.Scost/output.min.kWcost,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
scatter3(opt.Smax_init,opt.R_init,output.Scost(opt.I_init(1),opt.I_init(2))/ ... 
    output.kWcost(opt.I_init(1),opt.I_init(2)), ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rotor Radius [m]')
xlim([min(opt.Smax) inf])
ylim([min(opt.R) inf])
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
surf(Smaxgrid,Rgrid,pavg/1000);
hold on
minval = scatter3(output.min.Smax,output.min.R,nanmean(output.min.P)/1000,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
scatter3(opt.Smax_init,opt.R_init, ... 
    nanmean(output.P(opt.I_init(1),opt.I_init(2))/1000), ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rotor Radius [m]')
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
surf(Smaxgrid,Rgrid,(dtotal/1000)/ytotal);
hold on
minval = scatter3(output.min.Smax,output.min.R, ... 
    trapz(data.met.time,output.min.D/1000)/ytotal, ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
scatter3(opt.Smax_init,opt.R_init,trapz(data.met.time, ... 
    output.D(opt.I_init(1),opt.I_init(2),:)/1000)/ytotal, ... 
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rotor Radius [m]')
xlim([min(opt.Smax) inf])
ylim([min(opt.R) inf])
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


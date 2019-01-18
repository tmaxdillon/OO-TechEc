function [] = visWindOpt(opt,output,data,atmo,batt,econ,load,turb)

[Smaxgrid,Rgrid] = meshgrid(opt.Smax,opt.R);
ms = 100;

figure
%COST
a = 1; ax(a) = subplot(2,2,a);
output.cost(output.surv == 0) = nan;
surf(Smaxgrid,Rgrid,output.cost);
hold on
scatter3(output.min.Smax,output.min.R,output.min.cost,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rotor Radius [m]')
xlim([min(opt.Smax) inf])
ylim([min(opt.R) inf])
c = colorbar;
c.Label.String = 'Cost [$]';
colormap(ax(a),brewermap([],'Purples'))
grid on
%SCOST/KWCOST
a = 2; ax(a) = subplot(2,2,a);
costratio = output.Scost./output.kWcost;
costratio(output.surv == 0) = nan;
surf(Smaxgrid,Rgrid,costratio);
hold on
scatter3(output.min.Smax,output.min.R,output.min.Scost/output.min.kWcost,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rotor Radius [m]')
xlim([min(opt.Smax) inf])
ylim([min(opt.R) inf])
c = colorbar;
c.Label.String = '^{Storage Costs}/_{Other Costs}';
colormap(ax(a),brewermap([],'Purples'))
%PAVG
a = 3; ax(a) = subplot(2,2,a);
pavg = nanmean(output.P,3);
pavg(output.surv == 0) = nan;
surf(Smaxgrid,Rgrid,pavg/1000);
hold on
scatter3(output.min.Smax,output.min.R,nanmean(output.min.P)/1000,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rotor Radius [m]')
xlim([min(opt.Smax) inf])
ylim([min(opt.R) inf])
c = colorbar;
c.Label.String = 'Average Power [kW]';
colormap(ax(a),brewermap([],'Purples'))
%DTOTAL
a = 4; ax(a) = subplot(2,2,a);
for i = 1:opt.m
    for j = 1:opt.n
        dtotal(i,j) = trapz(data.met.time,output.D(i,j,:));
    end
end
dtotal(output.surv == 0) = nan;
surf(Smaxgrid,Rgrid,dtotal);
hold on
scatter3(output.min.Smax,output.min.R,trapz(data.met.time,output.min.D), ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rotor Radius [m]')
xlim([min(opt.Smax) inf])
ylim([min(opt.R) inf])
c = colorbar;
c.Label.String = 'Dumped Power [kWh]';
colormap(ax(a),brewermap([],'Purples'))

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


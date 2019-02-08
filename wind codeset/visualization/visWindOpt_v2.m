function [] = visWindOpt_v2(optStruct)

opt = optStruct.opt;
output = optStruct.output;
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
z_adj = 1.5;
annodim1 = [.2 .5 .3 .3];
annodim2 = [.2 .3 .3 .3];
textadj.x = 5;
textadj.y = .2;

figure
%COST
% for i=1:size(output.cost,1)
%     for j=1:size(output.cost,2)
%         if output.surv(i,j) == 0
%             output.cost = opt.init + (opt.init - output.cost);
%         end
%     end
% end
alive = output.cost;
alive(output.surv == 0) = nan;
s = surf(Smaxgrid,kWgrid,output.cost,zeros(length(Smaxgrid),length(kWgrid),3));
%scatter3(reshape(Smaxgrid,length(Smaxgrid)^2,1), ...
%     reshape(kWgrid,length(kWgrid)^2,1),reshape(output.cost,length(output.cost)^2,1), ...
%     100,reshape(output.cost,length(output.cost)^2,1))
s.EdgeColor = 'none';
hold on
s = surf(Smaxgrid,kWgrid,alive);
s.EdgeColor = 'none';
hold on
[~,con] = contour3(Smaxgrid,kWgrid,output.cost,'LineColor','w');
hold on
minval = scatter3(output.min.Smax,output.min.ratedP,output.min.cost+z_adj,...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','m');
hold on
initval = scatter3(opt.Smax_init,kW_init,opt.init+z_adj, ...
    ms,'filled','MarkerEdgeColor','k', ...
    'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rated Power [kW]')
xlim([min(opt.Smax) inf])
ylim([min(kW) inf])
c = colorbar;
c.Label.String = '[$] in thousands';
lb = output.min.cost/max(output.cost(:));
AdvancedColormap('bg l w r',8000,[lb,lb+.05*(1-lb),lb+0.1*(1-lb),1])
hold on
% annotation('textbox',annodim1,'String',['$ ' num2str(round(output.min.cost,2))], ...
%     'FitBoxToText','on','color','m','BackgroundColor','w')
% annotation('textbox',annodim2,'String',['$ ' ...
%     num2str(round(opt.init,2))], ...
%     'FitBoxToText','on','color','k','BackgroundColor','w')
l = legend([s initval minval con],'Input Mesh','Coarse Grid Minima', ...
    'Nelder-Mead Minima','Cost Contours','location','SouthWest');
l.Color = [.5 .5 .5];
%l.TextColor = 'w';
title('Total Cost')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on

end


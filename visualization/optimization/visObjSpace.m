function [] = visObjSpace(optStruct)

opt = optStruct.opt;
output = optStruct.output;

%adjust cost to thousands
output.cost = output.cost/1000;
%opt.init = opt.init/1000;
opt.init = 0;
opt.Smax_init = 0;
opt.kW_init = 0;
output.min.cost = output.min.cost/1000;

%create grid
[Smaxgrid,kWgrid] = meshgrid(opt.Smax,opt.kW);
ms = 100;
lw = 1.1;
fs = 18;
z_adj = 100;

%remove failure configurations
alive = output.cost;
alive(output.surv == 0) = nan;

% if opt.nm.failurezoneslope
%     %remove survival configurations
%     dead = 2*opt.init+3*opt.init.*(1-(1/opt.kW_m).*kWgrid- ...
%         (1/opt.Smax_n).*Smaxgrid);
%     dead2=dead;
%     dead2(output.surv == 1) = nan;
%     for i=size(dead,1):-1:2
%         for j=size(dead,2):-1:2
%             if isnan(dead2(i,j)) && ~isnan(dead2(i-1,j)) && ~isnan(dead2(i,j-1))
%                 dead2(i,j) = dead(i,j);
%             end
%         end
%     end
%     deadcolor = repmat([64,224,208]/265,[length(Smaxgrid),1,length(kWgrid)]);
%     deadcolor = permute(deadcolor,[1,3,2]);
% end

figure
% if opt.nm.failurezoneslope
%     sdead = surf(Smaxgrid,kWgrid,dead2, ...
%         deadcolor);
%     sdead.EdgeColor = 'none';
%     hold on
% end
s = surf(Smaxgrid,kWgrid,output.cost,zeros(length(Smaxgrid), ... 
    length(kWgrid),3));
s.EdgeColor = 'none';
s.FaceColor = 'flat';
hold on
s = surf(Smaxgrid,kWgrid,alive);
s.EdgeColor = 'none';
s.FaceColor = 'flat';
hold on
% [~,con] = contour3(Smaxgrid,kWgrid,output.cost,'LineColor','w');
% hold on
% minval = scatter3(output.min.Smax,output.min.kW,output.min.cost+z_adj*3,...
%     ms,'filled','MarkerEdgeColor','k', ...
%     'MarkerFaceColor','m');
% hold on
% initval = scatter3(opt.Smax_init,opt.kW_init,opt.init+z_adj, ...
%     ms,'filled','MarkerEdgeColor','k', ...
%     'MarkerFaceColor','w');
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rated Power [kW]')
xlim([0 inf])
yticks([0 1 2 3 4])
ylim([0 inf])
xlim([0 inf])
ylim([0 inf])
c = colorbar;
c.Label.String = '[$] in thousands';
caxis([0 max(alive(:))]) %to produce cartoon
lb = (output.min.cost)/max(alive(:));
AdvancedColormap('bg l w r',8000,[1*lb,lb+.05*(1-lb),lb+0.1*(1-lb),1])
hold on
% l = legend([s initval minval con],'Input Mesh','Coarse Grid Minima', ...
%     'Nelder-Mead Minima','Cost Contours','location','NorthEast');
%l.Color = [.5 .5 .5];
%title('Total Cost')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on

end


%Thursday AM

load('mdd_output.mat')

% cost = zeros(4,3);
% diameter = zeros(4,3);
% depth = zeros(4,3);
% e_subsurface = zeros(4,3);
% e_tension = zeros(4,3);
% w_tension = zeros(4,3);

n = 1000;
z_adj = 1;
ms = 50;
fs = 16;
lw = 1.2;

[Xq,Yq] = meshgrid(linspace(0,max(diameter(:)),n), ...
    linspace(0,max(depth(:)),n));

Cq = interp2(diameter,depth,cost,Xq,Yq,'linear');
Eq = interp2(diameter,depth,e_tension,Xq,Yq,'linear');

%cost
figure
s = surf(Xq,Yq,Cq./1000);
s.EdgeColor = 'none';
view(0,90)
xlabel('WEC Diameter [m]')
ylabel('Water Depth [m]')
xlim([0 5])
ylim([0 inf])
c = colorbar;
c.Label.String = '[$k]';
colormap(brewermap(50,'reds'))
hold on
scatter3(diameter(:),depth(:),cost(:)./1000+z_adj,ms,'filled', ...
    'MarkerEdgeColor','k','MarkerFaceColor','k')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)





%Thursday AM

load('mdd_output.mat')

% cost = zeros(4,3);
% diameter = zeros(4,3);
% depth = zeros(4,3);
% e_subsurface = zeros(4,3);
% e_tension = zeros(4,3);
% w_tension = zeros(4,3);

% diameter(:,4) = 8;
% depth(:,4) = depth(:,1);

n = 1000;
z_adj = 5;
ms = 50;
fs = 16;
lw = 1.2;

addond = 3; %add on diameter range

[Xq,Yq] = meshgrid(linspace(0,max(diameter(:))+addond,n), ...
    linspace(0,max(depth(:)),n));

%Cq = interp2(diameter,depth,cost,Xq,Yq,'linear');
Cq = interp2(diameter,depth,cost,Xq,Yq,'spline');
% Eq = interp2(diameter,depth,e_tension,Xq,Yq,'linear');

%cost
figure
s = surf(Xq,Yq,Cq./1000);
s.EdgeColor = 'none';
hold on
view(0,90)
xlabel('WEC Diameter [m]')
ylabel('Water Depth [m]')
xlim([.9 (4 +.1 + addond)])
ylim([0 5600])
c = colorbar;
c.Label.String = '[$k]';
colormap(brewermap(8,'reds'))
%colormap(flipud(viridis(16)))
caxis([0 80])
%[~,con] = contour3(Xq,Yq,Cq./1000,'LineColor','w','LineWidth',.5);
hold on
scatter3(diameter(:),depth(:),cost(:)./1000+z_adj,ms,'filled', ...
    'MarkerEdgeColor','k','MarkerFaceColor','k')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)

set(gcf, 'Position', [100, 100, 400, 650])






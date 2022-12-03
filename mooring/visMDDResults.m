%Thursday AM

% cost = zeros(4,3);
% diameter = zeros(4,3);
% depth = zeros(4,3);
% e_subsurface = zeros(4,3);
% e_tension = zeros(4,3);
% w_tension = zeros(4,3);

% diameter(:,4) = 8;
% depth(:,4) = depth(:,1);

r = 2; %1: original, 2: inso/dgen, 3: wind, 4: wave

switch r
    case 1
        load('mdd_output.mat')
    case 2
        load('mdd_output_inso.mat')
    case 3
        load('mdd_output_wind.mat')
    case 4
        load('mdd_output_wave.mat')
end

n = 1000;
z_adj = 5;
ms = 50;
fs = 16;
lw = 1.2;

addond = 4; %add on diameter range
solar_multi = true; 
multi_factor = 4;
multi_di = 14;

if solar_multi && r == 2
    [Xq,Yq] = meshgrid(linspace(0,multi_di,n), ...
        linspace(0,max(depth(:)),n));
    depth(:,4) = depth(:,1);
    diameter(:,4) = multi_di.*ones(5,1);
    cost(:,4) = cost(:,3).*multi_factor;
else
s    [Xq,Yq] = meshgrid(linspace(0,max(diameter(:))+addond,n), ...
        linspace(0,max(depth(:)),n));
end

%Cq = interp2(diameter,depth,cost,Xq,Yq,'linear');
Cq = interp2(diameter,depth,cost,Xq,Yq,'linear');
% Eq = interp2(diameter,depth,e_tension,Xq,Yq,'linear');

%cost
figure
s = surf(Xq,Yq,Cq./1000);
s.EdgeColor = 'none';
hold on
view(0,90)
xlabel('Surface Element Diameter [m]')
ylabel('Water Depth [m]')
if solar_multi && r == 2
    xlim([.9 max(diameter(:))])
else
    xlim([.9 (max(diameter(:)) +.1 + addond)])
end
ylim([0 5600])
c = colorbar;
c.Label.String = '[$k]';
colormap(brewermap(10,'reds'))
%colormap(flipud(viridis(16)))
%caxis([0 80])
%[~,con] = contour3(Xq,Yq,Cq./1000,'LineColor','w','LineWidth',.5);
hold on
scatter3(diameter(:),depth(:),cost(:)./1000+z_adj,ms,'filled', ...
    'MarkerEdgeColor','k','MarkerFaceColor','k')
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)

set(gcf, 'Position', [100, 100, 400, 650])






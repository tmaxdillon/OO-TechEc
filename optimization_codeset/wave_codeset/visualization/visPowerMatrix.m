function [] = visPowerMatrix(data,opt,wave,atmo)

ymin = 0;
xmin = 0;
rho = 1020;
g = 9.81;

% set axes
y = ymin:.1:7; %wave height
x = xmin:.1:15; %peak period

% preallocate
power = zeros(ymin+length(y),xmin+length(x));
wavepower = zeros(ymin+length(y),xmin+length(x));
efficiency = zeros(ymin+length(y),xmin+length(x));

wave.method = 2;
opt = prepWave(data,opt,wave,atmo);

width = 2;

for i = 1:length(x) %Tp
    for j = 1:length(y) %Hs
        efficiency(j+ymin,i+xmin) = opt.wave.F(x(i),y(j),width);
        wavepower(j+ymin,i+xmin) = ...
            (1/(16*4*pi))*rho*g^2*y(j)^2*x(i)/1000; %[kW]
        power(j+ymin,i+xmin) = wave.eta_ct*width* ...
            efficiency(j+ymin,i+xmin)* ...
            wavepower(j+ymin,i+xmin); %[kW]
    end
end

%scale to rated power and revmove negative power
power(power<0) = 0;

% visualize
figure
pc = pcolor([1:xmin x],[1:ymin y],wavepower);
shading interp;
colormap(brewermap(50,'YlOrRd'))
set(pc, 'EdgeColor', 'none'); %remove edges to better visualize
cb = colorbar;
ylabel(cb,'[kW/m]','Fontsize',14)
axis equal
axis tight
title('Wave Energy Flux','Fontsize',20)
ylabel({'Significant', 'Wave Height [m]'},'Fontsize',20)
xlabel('Peak Period [s]','Fontsize',20)
set(gca,'Fontsize',14)

figure
pc = pcolor([1:xmin x],[1:ymin y],efficiency);
shading interp;
colormap(brewermap(50,'YlOrRd'))
set(pc, 'EdgeColor', 'none'); %remove edges to better visualize
cb = colorbar;
ylabel(cb,'Efficiency [~]','Fontsize',14)
axis equal
axis tight
title('Efficiency','Fontsize',20)
ylabel({'Significant', 'Wave Height [m]'},'Fontsize',20)
xlabel('Peak Period [s]','Fontsize',20)
set(gca,'Fontsize',14)

figure
pc = pcolor([1:xmin x],[1:ymin y],power);
shading interp;
colormap(brewermap(50,'YlOrRd'))
set(pc, 'EdgeColor', 'none'); %remove edges to better visualize
cb = colorbar;
ylabel(cb,'Power [kW]','Fontsize',14)
%axis equal
%axis tight
title('Power Matrix','Fontsize',20)
ylabel({'Significant', 'Wave Height [m]'},'Fontsize',20)
xlabel('Peak Period [s]','Fontsize',20)
set(gca,'Fontsize',14)

end


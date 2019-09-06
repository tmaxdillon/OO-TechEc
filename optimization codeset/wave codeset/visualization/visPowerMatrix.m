function [] = visPowerMatrix(Hsm,Tpm,rated,wave)

ymin = 0;
xmin = 0;
rho = 1020;
g = 9.81;

% set axes
y = ymin:.1:4*Hsm; %wave height
x = xmin:.1:1.3*Tpm; %peak period
N = 1000; %discretization for finding skewed gaussian

% preallocate
power = zeros(ymin+length(y),xmin+length(x));
wavepower = zeros(ymin+length(y),xmin+length(x));
efficiency = zeros(ymin+length(y),xmin+length(x));

% x = linspace(y(1),y(end),N);
% gaussian = @(x,b) (1/sqrt((2*pi))*exp(-x.^2/b))
% skewedgaussian = @(x,alpha,b) 2*gaussian(x,b).*normcdf(alpha*x)

%find skewed gaussian fit
c0 = [0.5 60];
fun = @(c)findSkewedSS(linspace(x(1),x(end),N),c,wave,Tpm);
options = optimset('MaxFunEvals',10000,'MaxIter',10000, ...
    'TolFun',.0001,'TolX',.0001);
tic
c = fminsearch(fun,c0,options);
[~,y_,Y,prob_max] = findSkewedSS(linspace(x(1),x(end),N),c,wave,Tpm);
figure, plot(y_,Y)
toc

%find width through resonance conditions
wavepower_r = (1/(16*4*pi))*rho*g^2*(wave.hs_rated*Hsm)^2 ...
    *(wave.tp_res*Tpm); %[W], wave power at resonance
hs_eff_r = exp(-1.*((wave.hs_rated*Hsm- ... 
    wave.hs_res*Hsm).^2)./wave.w); %Hs eff (resonance)
tp_eff_r = ...
    skewedGaussian(wave.tp_res*Tpm,c(1),c(2))/prob_max; %Tp eff (resonance)
width = 1000*rated/(wave.eta_ct*hs_eff_r*tp_eff_r*wavepower_r - ...
    1000*rated*wave.house); %[m]

for i = 1:length(x) %Tp
    for j = 1:length(y) %Hs
        hs_eff = exp(-1.*((y(j)-wave.hs_res*Hsm).^2)./wave.w); %Hs efficiency
        tp_eff = skewedGaussian(x(i),c(1),c(2))/prob_max; %Tp efficiency
        efficiency(j+ymin,i+xmin) = hs_eff*tp_eff;
        wavepower(j+ymin,i+xmin) = ...
            (1/(16*4*pi))*rho*g^2*y(j)^2*x(i)/1000; %[kW]
        power(j+ymin,i+xmin) = wave.eta_ct*width*efficiency(j+ymin,i+xmin)* ...
            wavepower(j+ymin,i+xmin) - rated*wave.house; %[kW]
        %cut out
        if wavepower(j+ymin,i+xmin)*width > wave.cutout*rated
            power(j+ymin,i+xmin) = 0;
        end
    end
end

%scale to rated power and revmove negative power
power(power<0) = 0;
power(power>rated) = rated; %[kW]

% visualize
figure
pc = pcolor([1:xmin x],[1:ymin y],wavepower);
shading interp;
colormap(brewermap(50,'purples'))
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
colormap(brewermap(50,'purples'))
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
colormap(brewermap(50,'purples'))
set(pc, 'EdgeColor', 'none'); %remove edges to better visualize
cb = colorbar;
ylabel(cb,'Power [kW]','Fontsize',14)
axis equal
axis tight
title('Power Matrix','Fontsize',20)
ylabel({'Significant', 'Wave Height [m]'},'Fontsize',20)
xlabel('Peak Period [s]','Fontsize',20)
set(gca,'Fontsize',14)

end


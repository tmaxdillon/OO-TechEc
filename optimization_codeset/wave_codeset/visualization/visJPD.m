function [] = visJPD(data)

%site properties
g = 9.81;   %gravity [m/s^2]
rho = 1020; %seawater density [kg/m^3]

%discretization for wave height and period
dH = 0.5; %significant wave height [m]
dT = 0.5; %peak period [s]

Hs = data.wave.significant_wave_height;
Tp = data.wave.peak_wave_period;

%set up bins for joint distribution - note: these are bin mid-points, not edges
H_bins = (min(Hs):dH:max(Hs))';
T_bins = (min(Tp):dT:max(Tp))';

%initialize retuern values
count = zeros(length(H_bins),length(T_bins));   %count of points
Pw_bins = zeros(size(count));   %wave power flux

%loop through each height and period bin
for i = 1:length(H_bins)
    for j = 1:length(T_bins)
        %find all points that fall within the bin defined by center point
        %and bin width to either side of center (in Hs and Tp directions)
        pts = find((H_bins(i)+dH/2)>Hs & Hs>(H_bins(i)-dH/2) ...
            & (T_bins(j)+dT/2)>Tp & Tp>(T_bins(j)-dT/2));
        
        %count how many points are in the bin
        count(i,j) = length(pts);
        
        %calculate the power in this bin
        Pw_bins(i,j) = (rho*g^2/64)*(T_bins(j)*(H_bins(i)^2)/pi)/1000;
    end
end

%calculate probability of occurrence - count for each bin divided by total
%number of measurements
p = count./sum(count(:));

% %find most commonly occurring bin
% [H_ind, T_ind] = find(p == max(max(p)));
% T_prob = T_bins(T_ind);
% H_prob = H_bins(H_ind);

% %calculate average power for site
% %hint - do a sum of sum to capture both dimensions of the wave matrix
% Pw_avg = sum(sum(Pw_bins.*p));

%plot results
figure
clf

%plot probability of occurrence for each bin
%subplot(2,1,1)
cmap = colormap('magma');
colormap(cmap(1:220,:))
pcolor(T_bins,H_bins,p)
ca = colorbar;
xlabel('T_p [s]','fontweight','b','fontsize',18)
ylabel('H_s [m]','fontweight','b','fontsize',18)
title('Probably of Occurence per Bin','fontsize',18)
ca.Label.String = 'Probability [~]';
ca.Label.FontWeight = 'b';
ylim([0 7])
xlim([-inf 20])

% %plot wave power for each bin
% subplot(2,1,2)
% cmap = colormap('magma');
% colormap(cmap(1:220,:))
% pcolor(T_bins,H_bins,Pw_bins/1000)
% ca = colorbar;
% xlabel('T_e [s]','fontweight','b','fontsize',18)
% ylabel('H_s [m]','fontweight','b','fontsize',18)
% title('Wave Power per Bin','fontsize',18)
% ca.Label.String = 'Wave Power (Energy Flux) [kW/m]';
% ca.Label.FontWeight = 'b';

set(gcf, 'Position', [100, 100, 500, 400])

end


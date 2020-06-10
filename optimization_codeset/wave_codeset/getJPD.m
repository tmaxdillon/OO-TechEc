function [jpd] = getJPD(data,Hs_bins,Tp_bins)

dH = Hs_bins(2)-Hs_bins(1);
dT = Tp_bins(2)-Tp_bins(1);

Hs = data.wave.significant_wave_height;
Tp = data.wave.peak_wave_period;

%initialize retuern values
count = zeros(length(Hs_bins),length(Tp_bins));   %count of points 

%loop through each height and period bin
for i = 1:length(Hs_bins)
    for j = 1:length(Tp_bins)
        %find all points that fall within the bin defined by center point
        %and bin width to either side of center (in Hs and Tp directions)
        pts = find((Hs_bins(i)+dH/2)>Hs & Hs>(Hs_bins(i)-dH/2) ...
            & (Tp_bins(j)+dT/2)>Tp & Tp>(Tp_bins(j)-dT/2));
        
        %count how many points are in the bin
        count(i,j) = length(pts);
    end
end

%calculate probability of occurrence - count for each bin divided by total
%number of measurements
jpd = count./sum(count(:));
end


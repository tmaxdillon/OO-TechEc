function [h,uo,HU] = createHU(h_max,d_h,uo_max,d_uo,h_o,type,zo)
%creates height by wind speed matrix for dynamic vertical extrapolation for
%wind simulation of oo tech ec model using log law

h = 2:d_h:h_max;
uo = 2:d_uo:uo_max;
HU = zeros(length(h),length(uo));

% %meshgrid
% H = meshgrid(h,uo)'; %height matrix
% U = meshgrid(uo,h); %speed matrix

for i = 1:length(h) 
    for j = 1:length(uo)
        HU(i,j) = adjustHeight(uo(j),h_o,h(i),type,zo);
    end
end

end


function [ss,y,Y,prob_max] = findSkewedSS(y,c,wave,Tpm)

% y - well resolved Tp array
% c - skewed normal distribution coefficients [skew, width]
% wave - struct with wec parameters
% Tpm - median Tp

Y = zeros(1,length(y)); %probability density array

for i = 1:length(y)
    Y(i) = skewedGaussian(y(i),c(1),c(2));
end

% %normalize
% Y = (Y-min(Y)); %subtract minimum
% Y = Y./max(Y); %divide by new maximum

%find resonant probability
[~,res_ind] = min(abs(y - Tpm*wave.tp_res));
res_prob = Y(res_ind);

%find median probability
[~,med_ind] = min(abs(y - Tpm));
med_prob = Y(med_ind);

% %find yint probability
% [~,yint_ind] = min(abs(y - y(1)));
% yint_prob = Y(yint_ind);

prob_max = max(Y);

ss = (res_prob - prob_max)^2 + (med_prob - wave.med_prob*prob_max)^2;

% ss = (res_prob - prob_max)^2 + (med_prob - wave.med_prob*prob_max)^2 + ...
%     (yint_prob - wave.yint_prob*prob_max)^2;

% disp(['c = ' num2str(c)])
% %disp(['yint_prob = ' num2str(yint_prob)])
% disp(['res_prob = ' num2str(res_prob)])
% disp(['median_prob = ' num2str(med_prob)])
% pause

end


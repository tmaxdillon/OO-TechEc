function [ss] = findWeibSS(y,c,wave,Tpm)

Y = zeros(1,length(y));

for i = 1:length(y)
    Y(i) = wblpdf(y(i),c(1),c(2));
end

Y = Y/max(Y);

%find peak of weibull distribution
[~,peak_ind] = max(Y);
peak_tp = y(peak_ind);

%find where median should be in weibull distribution
Y(1:peak_ind) = nan; %clear out left half of peak
[~,alpha_ind] = min(abs(Y - wave.tp_alpha));
alpha_tp = y(alpha_ind);

%sum of squares
ss = (peak_tp - Tpm*wave.tp_beta)^2 + (alpha_tp - Tpm)^2;

disp(['c = ' num2str(c)])
disp(['peak_tp = ' num2str(peak_tp)])
disp(['alpha_tp = ' num2str(alpha_tp)])
pause

end


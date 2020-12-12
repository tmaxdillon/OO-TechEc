delta = .01:.01:1; %depth of discharge
N = zeros(1,length(delta));

for i = 1:length(delta) %depth of discharge
    N(i) = 0.2/(3.66e-5*delta(i)*exp(0.717*delta(i)));
end

plot(delta,N)
set(gca, 'YScale', 'log')
ylim([1000 1000000])
grid on

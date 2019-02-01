%code inspired by: http://maggotroot.blogspot.com/2013/11/constrained-linear-
%least-squares-in.html
%and: https://www.mathworks.com/matlabcentral/answers/94272-how-do-i-constrain-
%a-fitted-curve-through-specific-points-like-the-origin-in-matlab


turbineLibrary

cost = zeros(1,length(turbine));
kW = zeros(1,length(turbine));

%unpack into arrays
for i = 1:length(turbine)
    cost(i) = turbine(i).cost/1000;
    kW(i) = turbine(i).kW;
end

x = kW(~isnan(cost))';
y = cost(~isnan(cost))';

n = 1;

V = [];
V(:,n+1) = ones(length(x),1,class(x));
for j = n:-1:1
    V(:,j) = x.*V(:,j+1);
end
C = V;
d = y;
[p,resnorm,residual,exitflag,output,lambda] = lsqnonneg(C,d);

x1 = min(kW):0.01:max(kW);
y1 = polyval(p,x1);

figure
plot(x1,y1,'r')
%boundedline(x,y,delta,'alpha','transparency',.1)
hold on
scatter(kW,cost,100,'.','k')
ylabel('Cost in Thousands [$]')
xlabel('Rated Power [kW]')
set(gca,'FontSize',14,'LineWidth',1.4)
set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'))
set(gca,'yticklabel',num2str(get(gca,'ytick')','%d'))
grid on


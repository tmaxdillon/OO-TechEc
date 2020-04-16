function [] = visScaleFactor(cost_in,cap_in,sf,xmax)

x = 0:.01:xmax; %capacity
y = zeros(size(x)); %cost
for i=1:length(x)
    y(i) = applyScaleFactor(cost_in,cap_in,x(i),sf);
end

figure
subplot(2,1,1)
plot(x,y,'r','LineWidth',1.5)
hold on
scatter(cap_in,cost_in,'k','filled')
xlabel('capacity')
ylabel('$')
ylim([0 max(y)*1.25])
set(gca,'FontSize',12)
grid on

subplot(2,1,2)
plot(x,y./x,'r','LineWidth',1.5)
hold on
scatter(cap_in,cost_in/cap_in,'k','filled')
xlabel('capacity')
ylabel('$/capacity')
ylim([0 max(y)*1.25])
set(gca,'FontSize',12)
grid on



end


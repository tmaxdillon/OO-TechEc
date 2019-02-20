function [] = verticalProfile(z,spd,h_0,k,zo)

U_p = zeros(size(z));
U_l = zeros(size(z));

for i = 1:length(z)
    U_p(i) = adjustHeight(spd,h_0,z(i),'power',k);
    for j = 1:length(zo)
        U_l(i,j) = adjustHeight(spd,h_0,z(i),'log',zo(j));
    end
end

figure
scatter(spd,h_0,75,'ko','filled','DisplayName','Observed')
hold on
col = colormap(brewermap(length(zo)*2,'blues'));
for j = 1:length(zo)
    plot(U_l(:,j),z,'Color',col(end+1-j,:),'LineWidth',1.8, ... 
        'DisplayName',['Logarithmic Law z_0 = ' num2str(zo(j))])
end
hold on
plot(U_p,z,'r','LineWidth',1.8,'DisplayName','1/7 Power Law')
ylabel('Height [m]')
xlabel('Wind Speed [m/s]')
xlim([0 inf])
grid on
legend('show','Location','Northwest')
set(gca,'FontSize',16)

end


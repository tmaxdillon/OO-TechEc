function [] = visCliff(opt,output)

% set polynomial coefficients
a = opt.cliff.c(1);
b = opt.cliff.c(2);
c = opt.cliff.c(3);

x = linspace(0,max(opt.cliff.Smax),1000);

%compute kW
y = a./(x.^b) + c;

% plot
figure
plot(x,y,'-k','LineWidth',2.5)
ylim([0,1.2*max(opt.cliff.kW)])
hold on
s = scatter(opt.cliff.Smax,opt.cliff.kW,150, ... 
    opt.cliff.cost/1000,'filled','MarkerEdgeColor','k');
s.MarkerFaceAlpha = 0.8;
c = colorbar;
colormap(brewermap(30,'YlOrRd'))
c.Label.String = 'Cost [$1000]';
hold on
scatter(output.min.Smax,output.min.kW,100, ...
    'm','filled','MarkerEdgeColor','k');
grid on
set(gca,'FontSize',14)
xlabel('[Smax]','Fontsize',14)
ylabel('[kW]','Fontsize',14)
legend(['Curve Fit SS: ' num2str(round(opt.cliff.ss,2))] ... 
    ,'Queries',['Minimum: ' num2str(round(output.min.cost/1000,2))])

end


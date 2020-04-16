function [] = visTdSens(multStruct)

opt = multStruct(1).opt;

if isequal(opt.tdsens_tp{1},'btm') && ...
        isequal(opt.tdsens_tp{2},'mbt')
    xlab = 'Minimum Battery Capacity Before Additional Maintenance Time';
    ylab = 'Hours Added per kWh Over Minimum';
    dy = multStruct(1).opt.tdsens_ta(2,2) - ...
        multStruct(1).opt.tdsens_ta(2,1);
    dt = multStruct(1).opt.tdsens_ta(1,2) - ...
        multStruct(1).opt.tdsens_ta(1,1);
    xt = multStruct(1).opt.tdsens_ta(2,:);
    yt = multStruct(1).opt.tdsens_ta(1,:);
end

cost = zeros(size(multStruct));
Smax = zeros(size(multStruct));
kW = zeros(size(multStruct));
at = zeros(size(multStruct));

%unpack multStruct
for i = 1:size(multStruct,1)
    for j = 1:size(multStruct,2)
        cost(i,j) = multStruct(i,j).output.min.cost;
        Smax(i,j) = multStruct(i,j).output.min.Smax;
        kW(i,j) = multStruct(i,j).output.min.kW;
        at(i,j) = multStruct(i,j).output.min.t_add_batt;
    end
end

%plot
figure
colormap(brewermap(100,'reds'));
ax(1) = subplot(2,2,1);
pcolor(xt,yt,cost/1000)
ylabel(ylab)
xlabel(xlab)
yticks(yt)
xticks(xt)
c = colorbar;
c.Label.String = 'Cost in Thousands';
set(gca,'FontSize',13)

ax(2) = subplot(2,2,2);
pcolor(xt,yt,Smax)
ylabel(ylab)
xlabel(xlab)
yticks(yt)
xticks(xt)
c = colorbar;
c.Label.String = 'Optimal Battery Capacity';
set(gca,'FontSize',13)

ax(3) = subplot(2,2,3);
pcolor(xt,yt,kW)
ylabel(ylab)
xlabel(xlab)
yticks(yt)
xticks(xt)
c = colorbar;
c.Label.String = 'Optimal Rated Power';
set(gca,'FontSize',13)

ax(4) = subplot(2,2,4);
pcolor(xt,yt,at)
ylabel(ylab)
xlabel(xlab)
yticks(yt)
xticks(xt)
c = colorbar;
c.Label.String = 'Added Time';
set(gca,'FontSize',13)

set(gcf, 'Position', [100, 100, 800, 800])

end


function [] = visObjSpace(optStruct)

opt = optStruct.opt;
output = optStruct.output;

%plot settings
Sm_max = 500; %[kWh]
Gr_max = 8; %[kW]

%adjust cost to thousands
output.cost = output.cost/1000;
output.min.cost = output.min.cost/1000;

%create grid
[Smaxgrid,kWgrid] = meshgrid(opt.Smax,opt.kW);
lw = 1.1;
fs = 18;

%remove failure configurations
a_sat = output.cost; %availability satisfied
a_sat(output.surv == 0) = nan;

%find minimum
[m,m_ind] = min(a_sat(:));

figure
s = surf(Smaxgrid,kWgrid,output.cost,1.*ones(length(Smaxgrid), ... 
    length(kWgrid),3)); %black
s.EdgeColor = 'none';
s.FaceColor = 'flat';
hold on
s = surf(Smaxgrid,kWgrid,a_sat);
s.EdgeColor = 'none';
s.FaceColor = 'flat';
hold on
scatter3(Smaxgrid(m_ind),kWgrid(m_ind),m*2,130,'w','filled', ...
    'LineWidth',1.5,'MarkerEdgeColor','k')
view(0,90)
xlabel('Storage Capacity [kWh]')
ylabel('Rated Power [kW]')
ylim([-inf Gr_max])
xlim([-inf Sm_max])
c = colorbar;
c.Label.String = '[$] in thousands';
caxis([0 max(a_sat(:))]) %to produce cartoon
lb = (output.min.cost)/max(a_sat(:));
% AdvancedColormap('bg l w r',8000,[1*lb,lb+.05*(1-lb),lb+0.1*(1-lb),1])
AdvancedColormap('kkgw glw lww r',1000, ...
        [lb,lb+.05*(1-lb),lb+0.15*(1-lb),1]);
hold on
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw)
grid on

end


close all
%set(0,'defaulttextinterpreter','none')
set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'helvetica')
set(0,'DefaultAxesFontName', 'helvetica')

%load data
load('argBasin')
load('cosEndurance_wa')
load('cosPioneer')
load('irmSea')
load('souOcean')
load('struct1m_opt')
load('struct2m_opt')
load('struct3m_opt')
load('struct4m_opt')
load('struct5m_opt')
load('struct6m_opt')

%constants
rho = 1020; %[kg/m^3]
g = 9.81;   %[m/s^2]
lw1 = 3;
lw2 = .8;
Ho = 3; %Hs to bold

%find iqr
Tp_trl_ab = prctile(argBasin.wave.peak_wave_period,10);
Tp_trh_ab = prctile(argBasin.wave.peak_wave_period,90);
Tp_trl_ce = prctile(cosEndurance_wa.wave.peak_wave_period,10)-.05;
Tp_trh_ce = prctile(cosEndurance_wa.wave.peak_wave_period,90);
Tp_trl_cp = prctile(cosPioneer.wave.peak_wave_period,10);
Tp_trh_cp = prctile(cosPioneer.wave.peak_wave_period,90);
Tp_trl_is = prctile(irmSea.wave.peak_wave_period,10);
Tp_trh_is = prctile(irmSea.wave.peak_wave_period,90);
Tp_trl_so = prctile(souOcean.wave.peak_wave_period,10);
Tp_trh_so = prctile(souOcean.wave.peak_wave_period,90);

%extract Tps and Hs
Tp_1 = unique(struct1m_opt.T);
Tp_2 = unique(struct2m_opt.T);
Tp_3 = unique(struct3m_opt.T);
Tp_4 = unique(struct4m_opt.T);
Tp_5 = unique(struct5m_opt.T);
Tp_6 = unique(struct6m_opt.T);
Hs_1 = unique(struct1m_opt.H);
Hs_2 = unique(struct2m_opt.H);
Hs_3 = unique(struct3m_opt.H);
Hs_4 = unique(struct4m_opt.H);
Hs_5 = unique(struct5m_opt.H);
Hs_6 = unique(struct6m_opt.H);

%find nearest H
[~,h_ind_1] = min(abs(Hs_1 - Ho));
[~,h_ind_2] = min(abs(Hs_2 - Ho));
[~,h_ind_3] = min(abs(Hs_3 - Ho));
[~,h_ind_4] = min(abs(Hs_4 - Ho));
[~,h_ind_5] = min(abs(Hs_5 - Ho));
[~,h_ind_6] = min(abs(Hs_6 - Ho));

%preallocate
cwr_1 = zeros(length(Tp_1),length(Hs_1));
cwr_2 = zeros(length(Tp_2),length(Hs_2));
cwr_3 = zeros(length(Tp_3),length(Hs_3));
cwr_4 = zeros(length(Tp_4),length(Hs_4));
cwr_5 = zeros(length(Tp_5),length(Hs_5));
cwr_6 = zeros(length(Tp_6),length(Hs_6));

%caculate capture width ratio
for i = 1:length(Hs_1)
    for j = 1:length(Tp_1) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_1(i)^2*Tp_1(j);
        cwr_1(i,j) = struct1m_opt.mat(i,j)/(J*struct1m_opt.B);
    end
end
for i = 1:length(Hs_2)
    for j = 1:length(Tp_2) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_2(i)^2*Tp_2(j);
        cwr_2(i,j) = struct2m_opt.mat(i,j)/(J*struct2m_opt.B);
    end
end
for i = 1:length(Hs_3)
    for j = 1:length(Tp_3) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_3(i)^2*Tp_3(j);
        cwr_3(i,j) = struct3m_opt.mat(i,j)/(J*struct3m_opt.B);
    end
end
for i = 1:length(Hs_4)
    for j = 1:length(Tp_4) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_4(i)^2*Tp_4(j);
        cwr_4(i,j) = struct4m_opt.mat(i,j)/(J*struct4m_opt.B);
    end
end
for i = 1:length(Hs_5)
    for j = 1:length(Tp_5) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_5(i)^2*Tp_5(j);
        cwr_5(i,j) = struct5m_opt.mat(i,j)/(J*struct5m_opt.B);
    end
end
for i = 1:length(Hs_6)
    for j = 1:length(Tp_6) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_6(i)^2*Tp_6(j);
        cwr_6(i,j) = struct6m_opt.mat(i,j)/(J*struct6m_opt.B);
    end
end

%set discretization
Tp_res = 1000;
%preallocate
cwr_1_int = zeros(length(Hs_1),Tp_res);
cwr_2_int = zeros(length(Hs_2),Tp_res);
cwr_3_int = zeros(length(Hs_3),Tp_res);
cwr_4_int = zeros(length(Hs_4),Tp_res);
cwr_5_int = zeros(length(Hs_5),Tp_res);
cwr_6_int = zeros(length(Hs_5),Tp_res);
%interpolate
for i = 1:length(Hs_1)
    cwr_1_int(i,:) = interp1(Tp_1,cwr_1(i,:), ...
        linspace(min(Tp_1),max(Tp_1),Tp_res),'spline');
end
for i = 1:length(Hs_2)
    cwr_2_int(i,:) = interp1(Tp_2,cwr_2(i,:), ...
        linspace(min(Tp_2),max(Tp_2),Tp_res),'spline');
end
for i = 1:length(Hs_3)
    cwr_3_int(i,:) = interp1(Tp_3,cwr_3(i,:), ...
        linspace(min(Tp_3),max(Tp_3),Tp_res),'spline');
end
for i = 1:length(Hs_4)
    cwr_4_int(i,:) = interp1(Tp_4,cwr_4(i,:), ...
        linspace(min(Tp_4),max(Tp_4),Tp_res),'spline');
end
for i = 1:length(Hs_5)
    cwr_5_int(i,:) = interp1(Tp_5,cwr_5(i,:), ...
        linspace(min(Tp_5),max(Tp_5),Tp_res),'spline');
end
for i = 1:length(Hs_6)
    cwr_6_int(i,:) = interp1(Tp_6,cwr_6(i,:), ...
        linspace(min(Tp_6),max(Tp_6),Tp_res),'spline');
end

%colors
col1m = brewermap(length(Hs_1)*2,'oranges');
col2m = brewermap(length(Hs_2)*2,'reds');
col3m = brewermap(length(Hs_3)*2,'greens');
col4m = brewermap(length(Hs_4)*2,'blues');
col5m = brewermap(length(Hs_5)*2,'purples');
col6m = brewermap(length(Hs_6)*2,'greys');

figure
ax(1) = subplot(2,1,1);
for i = 1:length(Hs_1)
    hold on
    if i == h_ind_1
        p1 = plot(linspace(min(Tp_1),max(Tp_1),Tp_res), ...
            cwr_1_int(i,:),'Color',col1m(end,:), ...
            'DisplayName','1 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_1),max(Tp_1),Tp_res), ...
            cwr_1_int(i,:),'Color',col1m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_2)
    hold on
    if i == h_ind_2
        p2 = plot(linspace(min(Tp_2),max(Tp_2),Tp_res), ...
            cwr_2_int(i,:),'Color',col2m(end,:), ...
            'DisplayName','2 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_2),max(Tp_2),Tp_res), ...
            cwr_2_int(i,:),'Color',col2m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_3)
    if i == h_ind_3
        p3 = plot(linspace(min(Tp_3),max(Tp_3),Tp_res), ...
            cwr_3_int(i,:),'Color',col3m(end,:), ...
            'DisplayName','3 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_4),max(Tp_4),Tp_res), ...
            cwr_3_int(i,:),'Color',col3m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_4)
    if i == h_ind_4
        p4 = plot(linspace(min(Tp_4),max(Tp_4),Tp_res), ...
            cwr_4_int(i,:),'Color',col4m(end,:), ...
            'DisplayName','4 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_4),max(Tp_4),Tp_res), ...
            cwr_4_int(i,:),'Color',col4m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_5)
    if i == h_ind_5
        p5 = plot(linspace(min(Tp_5),max(Tp_5),Tp_res), ...
            cwr_5_int(i,:),'Color',col5m(end,:), ...
            'DisplayName','5 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_5),max(Tp_5),Tp_res), ...
            cwr_5_int(i,:),'Color',col5m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_6)
    if i == h_ind_6
        p6 = plot(linspace(min(Tp_6),max(Tp_6),Tp_res), ...
            cwr_6_int(i,:),'Color',col6m(end,:), ...
            'DisplayName','6 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_6),max(Tp_6),Tp_res), ...
            cwr_6_int(i,:),'Color',col6m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
% xline(Tp_trh_ab,'-','Argentine Basin 90% Tp', ...
%     'DisplayName','10th & 90th prctile Tp');
% xline(Tp_trl_ab,'-','Argentine Basin 10% Tp');
% % xline(Tp_trh_ce,':','Coastal Endurance', ...
% %     'DisplayName','10th & 90th prctile Tp');
% % xline(Tp_trl_ce,':');
% xline(Tp_trh_cp,':','Coastal Pioneer 90% Tp', ...
%     'DisplayName','10th & 90th prctile Tp');
% xline(Tp_trl_cp,':','Coastal Pioneer 10% Tp');
% xline(Tp_trh_is,'--','Irminger Sea 90% Tp', ...
%     'DisplayName','10th & 90th prctile Tp');
% xline(Tp_trl_is,'--');
% % xline(Tp_trh_so,'--','Southern Ocean', ...
% %     'DisplayName','10th & 90th prctile Tp');
% % xline(Tp_trl_so,'--');
ylabel('CWR')
xlabel('Tp [s]')
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ... 
    'HorizontalAlignment','right')
%title('Capture Width Ratio')
xlim([0 max([Tp_1 ; Tp_2 ; Tp_3 ; Tp_4 ; Tp_5 ; Tp_6])])
legend([p1 p2 p3 p4 p5 p6],'location','east')
grid on
set(gca,'FontSize',13)

ax(2) = subplot(2,1,2);
for i = 1:length(Hs_1)
    hold on
    if i == h_ind_1
        p1 = plot(linspace(min(Tp_1),max(Tp_1),Tp_res), ...
            cwr_1_int(i,:)/struct1m_opt.B,'Color',col1m(end,:), ...
            'DisplayName','1 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_1),max(Tp_1),Tp_res), ...
            cwr_1_int(i,:)/struct1m_opt.B,'Color',col1m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_2)
    hold on
    if i == h_ind_2
        p2 = plot(linspace(min(Tp_2),max(Tp_2),Tp_res), ...
            cwr_2_int(i,:)/struct2m_opt.B,'Color',col2m(end,:), ...
            'DisplayName','2 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_2),max(Tp_2),Tp_res), ...
            cwr_2_int(i,:)/struct2m_opt.B,'Color',col2m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_3)
    if i == h_ind_3
        p3 = plot(linspace(min(Tp_3),max(Tp_3),Tp_res), ...
            cwr_3_int(i,:)/struct3m_opt.B,'Color',col3m(end,:), ...
            'DisplayName','3 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_4),max(Tp_4),Tp_res), ...
            cwr_3_int(i,:)/struct3m_opt.B,'Color',col3m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_4)
    if i == h_ind_4
        p4 = plot(linspace(min(Tp_4),max(Tp_4),Tp_res), ...
            cwr_4_int(i,:)/struct4m_opt.B,'Color',col4m(end,:), ...
            'DisplayName','4 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_4),max(Tp_4),Tp_res), ...
            cwr_4_int(i,:)/struct4m_opt.B,'Color',col4m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_5)
    if i == h_ind_5
        p5 = plot(linspace(min(Tp_5),max(Tp_5),Tp_res), ...
            cwr_5_int(i,:)/struct5m_opt.B,'Color',col5m(end,:), ...
            'DisplayName','5 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_5),max(Tp_5),Tp_res), ...
            cwr_5_int(i,:)/struct5m_opt.B,'Color',col5m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
for i = 1:length(Hs_6)
    if i == h_ind_6
        p6 = plot(linspace(min(Tp_6),max(Tp_6),Tp_res), ...
            cwr_6_int(i,:)/struct6m_opt.B,'Color',col6m(end,:), ...
            'DisplayName','6 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_6),max(Tp_6),Tp_res), ...
            cwr_6_int(i,:)/struct6m_opt.B,'Color',col6m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
% xline(Tp_trh_ab,'-','Argentine Basin 90% T_p', ...
%     'DisplayName','10th & 90th prctile T_p');
% xline(Tp_trl_ab,'-','Argentine Basin 10% T_p');
% xline(Tp_trh_ce,':','Coastal Endurance', ...
% %     'DisplayName','10th & 90th prctile Tp');
% % xline(Tp_trl_ce,':');
% xline(Tp_trh_cp,':','Coastal Pioneer 90% T_p', ...
%     'DisplayName','10th & 90th prctile T_p');
% xline(Tp_trl_cp,':','Coastal Pioneer 10% T_p');
% % xline(Tp_trh_is,'--','Irminger Sea 90% T_p', ...
% %     'DisplayName','10th & 90th prctile T_p');
% % xline(Tp_trl_is,'--','Irminger Sea 10% T_p');
% xline(Tp_trh_so,'--','Southern Ocean 90% T_p', ...
%     'DisplayName','10th & 90th prctile Tp');
% xline(Tp_trl_so,'--','Southern Ocean 10% T_p');
ylabel('$$\mathrm{\frac{CWR}{B}}$$')
xlabel('Tp [s]')
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ... 
    'HorizontalAlignment','right')
%title('Capture Width Ratio Normalized by WEC Width (B)')
xlim([0 max([Tp_1 ; Tp_2 ; Tp_3 ; Tp_4 ; Tp_5 ; Tp_6])])
legend([p1 p2 p3 p4 p5 p6],'location','east')
grid on
set(gcf, 'Position', [100, 100, 1000, 550])
set(gca,'FontSize',13)

% APPROXIMATION
% figure
% pa = plot(linspace(min(Tp_3),max(Tp_3),Tp_res), ...
%     cwr_3_int(i,:)/struct3m_opt.B,'Color',col3m(end-5,:), ...
%     'DisplayName','3 meter WEC, Hs = 3m','LineWidth',lw1);
% %ylabel('CWR/B')
% %xlabel('Tp [s]')
% %title('Capture Width Ratio Normalized by WEC Width (B)')
% xlim([0 max([Tp_1 ; Tp_2 ; Tp_3 ; Tp_4 ; Tp_5 ; Tp_6])])
% ylim([0 .2])
% legend(pa,'location','east')
% grid on
% set(gcf, 'Position', [100, 100, 1000, 275])
% set(gca,'FontSize',16)
% set(gca,'FontName','Calibri')
% set(gcf,'color','w')


set(gcf, 'Position', [100, 100, 1000, 650])


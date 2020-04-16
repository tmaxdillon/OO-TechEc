function [] = visWSCWR_line(struct2m,struct3m,struct4m,struct5m, ...
    argBasin,cosEndurance,souOcean,Ho)

%constants
rho = 1020; %[kg/m^3]
g = 9.81;   %[m/s^2]
lw1 = 2.2;
lw2 = 1.4;

%find iqr
Tp_trl_ab = prctile(argBasin.wave.peak_wave_period,10);
Tp_trh_ab = prctile(argBasin.wave.peak_wave_period,90);
Tp_trl_ce = prctile(cosEndurance.wave.peak_wave_period,10)-.05;
Tp_trh_ce = prctile(cosEndurance.wave.peak_wave_period,90);
Tp_trl_so = prctile(souOcean.wave.peak_wave_period,10);
Tp_trh_so = prctile(souOcean.wave.peak_wave_period,90);

%extract Tps and Hs
Tp_2 = unique(struct2m(1).T);
Tp_3 = unique(struct3m(1).T);
Tp_4 = unique(struct4m(1).T);
Tp_5 = unique(struct5m(1).T);
Hs_2 = unique(struct2m(1).H);
Hs_3 = unique(struct3m(1).H);
Hs_4 = unique(struct4m(1).H);
Hs_5 = unique(struct5m(1).H);

%find nearest H
[~,h_ind_2] = min(abs(Hs_2 - Ho));
[~,h_ind_3] = min(abs(Hs_3 - Ho));
[~,h_ind_4] = min(abs(Hs_4 - Ho));
[~,h_ind_5] = min(abs(Hs_5 - Ho));

%preallocate
cwr_2 = zeros(length(Tp_2),1);
cwr_3 = zeros(length(Tp_3),1);
cwr_4 = zeros(length(Tp_4),1);
cwr_5 = zeros(length(Tp_5),1);

%caculate capture width ratio
for i = 1:length(Hs_2)
    for j = 1:length(Tp_2) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_2(i)^2*Tp_2(j);
        cwr_2(i,j) = struct2m.mat(i,j)/(J*struct2m.B);
    end
end
for i = 1:length(Hs_3)
    for j = 1:length(Tp_3) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_3(i)^2*Tp_3(j);
        cwr_3(i,j) = struct3m.mat(i,j)/(J*struct3m.B);
    end
end
for i = 1:length(Hs_4)
    for j = 1:length(Tp_4) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_4(i)^2*Tp_4(j);
        cwr_4(i,j) = struct4m.mat(i,j)/(J*struct4m.B);
    end
end
for i = 1:length(Hs_5)
    for j = 1:length(Tp_5) %across all tp
        J = (1/(64*pi))*rho*g^2*Hs_5(i)^2*Tp_5(j);
        cwr_5(i,j) = struct5m.mat(i,j)/(J*struct5m.B);
    end
end

%set discretization
Tp_res = 1000;
%preallocate 
cwr_2_int = zeros(length(Hs_2),Tp_res);
cwr_3_int = zeros(length(Hs_3),Tp_res);
cwr_4_int = zeros(length(Hs_4),Tp_res);
cwr_5_int = zeros(length(Hs_5),Tp_res);
%interpolate
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

%colors
col2m = brewermap(length(Hs_2)*2,'reds');
col3m = brewermap(length(Hs_3)*2,'greens');
col4m = brewermap(length(Hs_4)*2,'blues');
col5m = brewermap(length(Hs_5)*2,'purples');

figure
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
        p5 = plot(linspace(min(Tp_4),max(Tp_4),Tp_res), ...
            cwr_5_int(i,:),'Color',col5m(end,:), ...
            'DisplayName','5 meter WEC, Hs = 3m','LineWidth',lw1);
    else
        plot(linspace(min(Tp_4),max(Tp_4),Tp_res), ...
            cwr_5_int(i,:),'Color',col5m(5+i,:), ...
            'LineWidth',lw2)
    end
end
hold on
xline(Tp_trh_ab,'-','Argentine Basin', ...
    'DisplayName','10th & 90th prctile Tp');
xline(Tp_trl_ab,'-');
xline(Tp_trh_ce,':','Coastal Endurance', ...
    'DisplayName','10th & 90th prctile Tp');
xline(Tp_trl_ce,':');
xline(Tp_trh_so,'--','Southern Ocean', ...
    'DisplayName','10th & 90th prctile Tp');
xline(Tp_trl_so,'--');
ylabel('CWR')
xlabel('Tp [s]')
xlim([0 max([Tp_2 ; Tp_3 ; Tp_4 ; Tp_5])])
legend([p2 p3 p4 p5],'location','east')
grid on
set(gcf, 'Position', [100, 100, 800, 350])
set(gca,'FontSize',13)



end


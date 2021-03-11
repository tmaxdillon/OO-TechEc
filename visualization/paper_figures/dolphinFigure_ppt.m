clc, close all, clear all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

%load data
load('struct1m_opt')
load('struct2m_opt')
load('struct3m_opt')
load('struct4m_opt')
load('struct5m_opt')
load('struct6m_opt')

%constants
rho = 1020; %[kg/m^3]
g = 9.81;   %[m/s^2]

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

%set discretization
Tp_res = 1000;
Tp_all = zeros(Tp_res,6);
Tp_all(:,1) = linspace(min(Tp_1),max(Tp_1),Tp_res);
Tp_all(:,2) = linspace(min(Tp_2),max(Tp_2),Tp_res);
Tp_all(:,3) = linspace(min(Tp_3),max(Tp_3),Tp_res);
Tp_all(:,4) = linspace(min(Tp_4),max(Tp_4),Tp_res);
Tp_all(:,5) = linspace(min(Tp_5),max(Tp_5),Tp_res);
Tp_all(:,6) = linspace(min(Tp_6),max(Tp_6),Tp_res);

%preallocate
cwr_int = zeros(2,Tp_res,6);

%spline interpolate cwr at max and min Hs onto finely resolved Tp
cwr_int(1,:,1) = interp1(Tp_1, ...
    struct1m_opt.mat(1,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_1(1)^2.*Tp_1.*struct1m_opt.B), ...
    linspace(min(Tp_1),max(Tp_1),Tp_res),'spline');
cwr_int(2,:,1) = interp1(Tp_1, ...
    struct1m_opt.mat(end,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_1(end)^2.*Tp_1.*struct1m_opt.B), ...
    linspace(min(Tp_1),max(Tp_1),Tp_res),'spline');
cwr_int(1,:,2) = interp1(Tp_2, ...
    struct2m_opt.mat(1,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_2(1)^2.*Tp_2.*struct2m_opt.B), ...
    linspace(min(Tp_2),max(Tp_2),Tp_res),'spline');
cwr_int(2,:,2) = interp1(Tp_2, ...
    struct2m_opt.mat(end,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_2(end)^2.*Tp_2.*struct2m_opt.B), ...
    linspace(min(Tp_2),max(Tp_2),Tp_res),'spline');
cwr_int(1,:,3) = interp1(Tp_3, ...
    struct3m_opt.mat(1,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_3(1)^2.*Tp_3.*struct3m_opt.B), ...
    linspace(min(Tp_3),max(Tp_3),Tp_res),'spline');
cwr_int(2,:,3) = interp1(Tp_3, ...
    struct3m_opt.mat(end,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_3(end)^2.*Tp_3.*struct3m_opt.B), ...
    linspace(min(Tp_3),max(Tp_3),Tp_res),'spline');
cwr_int(1,:,4) = interp1(Tp_4, ...
    struct4m_opt.mat(1,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_3(1)^2.*Tp_4.*struct4m_opt.B), ...
    linspace(min(Tp_4),max(Tp_4),Tp_res),'spline');
cwr_int(2,:,4) = interp1(Tp_4, ...
    struct4m_opt.mat(end,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_4(end)^2.*Tp_4.*struct4m_opt.B), ...
    linspace(min(Tp_4),max(Tp_4),Tp_res),'spline');
cwr_int(1,:,5) = interp1(Tp_5, ...
    struct5m_opt.mat(1,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_5(1)^2.*Tp_5.*struct5m_opt.B), ...
    linspace(min(Tp_5),max(Tp_5),Tp_res),'spline');
cwr_int(2,:,5) = interp1(Tp_5, ...
    struct5m_opt.mat(end,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_5(end)^2.*Tp_5.*struct5m_opt.B), ...
    linspace(min(Tp_5),max(Tp_5),Tp_res),'spline');
cwr_int(1,:,6) = interp1(Tp_6, ...
    struct6m_opt.mat(1,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_6(1)^2.*Tp_6.*struct6m_opt.B), ...
    linspace(min(Tp_6),max(Tp_6),Tp_res),'spline');
cwr_int(2,:,6) = interp1(Tp_6, ...
    struct6m_opt.mat(end,:)'./ ...
    ((1/(64*pi))*rho*g^2*Hs_6(end)^2.*Tp_6.*struct6m_opt.B), ...
    linspace(min(Tp_6),max(Tp_6),Tp_res),'spline');

%find inflection points
for i = 1:6
    [~,inflex_ind(i)] = min(abs(cwr_int(1,2:end-1,i) - ...
        cwr_int(2,2:end-1,i)));
end

%plot setup
lw1 = 0.3;
lw2 = .5;
lw3 = .5;
ms = 4;
fs = 14;

%colors
c = 7;
col1 = brewermap(10,'reds'); col(1,:) = col1(c,:);
col2 = brewermap(10,'oranges'); col(2,:) = col2(c,:);
col3 = brewermap(10,'greens'); col(3,:) = col3(c,:);
col4 = brewermap(10,'blues'); col(4,:) = col4(c,:);
col5 = brewermap(10,'purples'); col(5,:) = col5(c,:);
col6 = brewermap(10,'greys'); col(6,:) = col6(c,:);

wscwr = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 7, 2.5])
for i = size(cwr_int,3):-1:1
    a(i,:) = area(Tp_all(:,i)', ...
        [cwr_int(2,:,i);cwr_int(1,:,i)-cwr_int(2,:,i)]');
    hold on
    a(i,2).FaceColor = col(i,:);
    a(i,2).FaceAlpha = 0.2;
    a(i,1).FaceAlpha = 0;
    a(i,1).LineWidth = lw1;
    a(i,2).LineWidth = lw1;
    plot(Tp_all(inflex_ind(i),i),mean([cwr_int(1,inflex_ind(i),i) ...
        cwr_int(2,inflex_ind(i),i)]),'ko','MarkerSize',ms, ...
        'LineWidth',lw3)
end
a(1,1).EdgeColor = 'none';
ax = gca;
ax.YLabel.String = {'$\eta$ [$\sim$]'};
ax.YLabel.Interpreter = 'latex';
ax.XLabel.String = '$T_{p}$ [s]';
ax.XLabel.Interpreter = 'latex';
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
hYLabel.Position = [-.2, 0.5,0];
xlim([0 15])
ylim([0 .275])
xticks(1:1:15)
xticklabels({'','','','','5','','','','','10','','','','','15'})
yticks(0:.1:.3)
set(gca,'Units','Inches')
set(gca,'Position',[1.5,0.75,5,1.5])
%add arrow
ax = gca;
ax.Units = 'normalized';
x_arr = 3;
pos = get(gca,'Position');
X = pos(1) + [x_arr x_arr].*(pos(3)/ax.XLim(2));
[~,ind] = min(abs(Tp_all(:,2)-x_arr));
%Y = pos(2) + [cwr_int(1,ind,2) cwr_int(2,ind,2)].*(pos(4)/ax.YLim(2));
Y = pos(2) + [cwr_int(1,ind,2) cwr_int(2,ind,2)].*(pos(4)/ax.YLim(2));
arrow = annotation('arrow',X,Y);
arrow.HeadStyle = 'plain';	
arrow.HeadWidth = 5;	
arrow.HeadLength = 5;
%add text
x_tex = 2.1;
X_t = pos(1) + x_tex*(pos(3)/ax.XLim(2));
dim = [X_t mean(Y) .5 .05];
text = annotation('textbox',dim,'String','$H_{s}$','Interpreter','latex');
text.EdgeColor = 'none';
text.FontSize = 12;
grid on
set(gca,'FontSize',fs,'LineWidth',lw2)
legend([a(1,2) a(2,2) a(3,2) ...
    a(4,2) a(5,2) a(6,2)], ...
    'B = 1 m','B = 2 m','B = 3 m','B = 4 m', ...
    'B = 5 m','B = 6 m','FontSize',10,'Location','northeast','box','off')

set(gcf, 'Color',[256 256 245]/256,'InvertHardCopy','off')
set(ax,'Color',[256 256 245]/256)
print(wscwr,'~/Dropbox (MREL)/Research/General Exam/pf/dolphin_1', ...
    '-dpng','-r600')


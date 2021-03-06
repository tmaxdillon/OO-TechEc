clearvars -except array x0 t0 c0 o0
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

%var names
varname{1} = 'ssm_ab_lt';
varname{2} = 'ssm_ab_st';

if ~exist('array','var')
for i = 1:2
    load(varname{i})
    disp(['loading ' varname{i}])
    %merge
    array(1,:,i) = sdr;
    x0(1,i) = s0.batt.sdr;
    array(5,:,i) = bhc;
    x0(5,i) = s0.econ.batt.enclmult;
    array(9,:,i) = mbl;
    x0(9,i) = s0.batt.lc_max;
    array(13,:,i) = nbl;
    x0(13,i) = s0.batt.lc_nom;
    array(2,:,i) = dep;
    x0(2,i) = s0.data.depth;
    array(6,:,i) = utp;
    x0(6,i) = s0.uc.uptime;
    array(10,:,i) = lft;
    x0(10,i) = s0.uc.lifetime;
    array(14,:,i) = ild;
    x0(14,i) = s0.uc.draw;
    array(3,:,i) = cwm;
    x0(3,i) = 1;
    array(7,:,i) = whl;
    x0(7,i) = s0.wave.house;
    array(11,:,i) = wcm;
    if s0.econ.wave.scen == 2 %opt cost
        x0(11,i) = s0.econ.wave.costmult_opt;
    else
        x0(11,i) = s0.econ.wave.costmult_con;
    end
    array(15,:,i) = wiv;
    if s0.econ.wave.scen == 3 %opt durability
        x0(15,i) = s0.econ.wave.lowfail;
    else
        x0(15,i) = s0.econ.wave.highfail;
    end
    array(12,:,i) = tmt;
    if s0.c == 1 %short term
        x0(12,i) = s0.econ.vessel.t_ms;
    elseif s0.c == 2 %long term
        x0(12,i) = s0.econ.vessel.t_mosv;
    end
    array(8,:,i) = dtc;
    x0(8,i) = s0.data.dist;
    array(4,:,i) = spv;
    x0(4,i) = s0.econ.vessel.speccost;
    array(16,:,i) = osv;
    x0(16,i) = s0.econ.vessel.osvcost;
    t0(i) = s0.output.min.cost; %total cost of base case
    c0(i) = s0.output.min.CapEx; %capital cost of base case
    o0(i) = s0.output.min.OpEx; %operational cost of base case
end
end

n = 10; %sensitivity discretization

for i = 1:2 %across short term and long term
    for a = 1:size(array,1,i) %across all 16 arrays
        for r = 1:size(array,2,i) %across all 10 runs in an array
            CapEx(a,r,i) = array(a,r,i).output.min.CapEx;
            OpEx(a,r,i) = array(a,r,i).output.min.OpEx;
        end
        %tp{a} = array(a,1,i).opt.tuned_parameter; %tuned parameter
        ta(a,:,i) = array(a,1,i).opt.tuning_array; %tuned array
    end
end

%plot settings
lw = 2;
lw2 = 1;
ms = 22;
fs1 = 7.5;
fs2 = 7.5;
fs3 = 12;
alpha = 0.3;
red = [255, 105, 97]/256;
red2 = [255, 105, 97, alpha*256]/256;
blue = [70, 190, 234]/256;
blue2 = [70, 190, 234, alpha*256]/256;
orange = [255, 179, 71]/256;

% if s0.c == 1 && isequal(s0.loc,'argBasin')
%     ssm_ab_st = figure;
%     figstr = 'ssm_ab_st';
% elseif s0.c == 2 && isequal(s0.loc,'argBasin')
%     ssm_ab_lt = figure;
%     figstr = 'ssm_ab_lt';
% elseif s0.c == 1 && isequal(s0.loc,'souOcean')
%     ssm_so_st = figure;
%     figstr = 'ssm_so_st';
% elseif s0.c == 2 && isequal(s0.loc,'souOcean')
%     ssm_so_lt = figure;
%     figstr = 'ssm_so_lt';
% else
X_loc_c = figure;
figstr = 'X_loc_c';
% end
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 5.5])
for a = 1:size(array,1)
    ax(a) = subplot(4,4,a);
    total(1) = plot(ta(a,:,1),(CapEx(a,:,1)+OpEx(a,:,1))/t0(1), ...
        'Color','k','DisplayName','Total','LineWidth',lw);
    hold on
    total(2) = plot(ta(a,:,2),(CapEx(a,:,2)+OpEx(a,:,2))/t0(2), ...
        'Color','k','DisplayName','Total','LineWidth',lw);
    total(2).Color = [0,0,0,alpha];
    grid on
    gls = get(gca,'GridLineStyle');
    glc = get(gca,'GridColor');
    gla = get(gca,'GridAlpha');
    xl(1) = xline(x0(a,1),'Color',glc,'Alpha',gla,'LineStyle',gls);
    capex(1) = plot(ta(a,:,1),CapEx(a,:,1)/t0(1),'Color',red,  ...
        'DisplayName','CapEx','LineWidth',lw);
    opex(1) = plot(ta(a,:,1),OpEx(a,:,1)/t0(1),'Color',blue, ...
        'DisplayName','OpEx','LineWidth',lw);
    blt(1) = scatter(x0(a,1),1,ms,'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2,'DisplayName','Baseline');
    scatter(x0(a,1),c0(1)/t0(1),ms,'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2,'MarkerEdgeColor',red);
    scatter(x0(a,1),o0(1)/t0(1),ms,'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2,'MarkerEdgeColor',blue);
    hold on
    xl(2) = xline(x0(a,2),'Color',glc,'Alpha',gla,'LineStyle',gls);
    capex(2) = plot(ta(a,:,2),CapEx(a,:,2)/t0(2),'Color',red2,  ...
        'DisplayName','CapEx','LineWidth',lw);
    opex(2) = plot(ta(a,:,2),OpEx(a,:,2)/t0(2),'Color',blue2, ...
        'DisplayName','OpEx','LineWidth',lw);
    blt(2) = scatter(x0(a,2),1,ms,'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2,'DisplayName','Baseline');
    scatter(x0(a,2),c0(2)/t0(2),ms,'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2,'MarkerEdgeColor',red);
    scatter(x0(a,2),o0(2)/t0(2),ms,'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2,'MarkerEdgeColor',blue);
    xticks([ta(a,1),ta(a,n,1)]);
    xt = xticks;
    xlim([ta(a,1,1) ta(a,n,1)])
    max1 = max(max(CapEx(:,:,1) + OpEx(:,:,1)))/t0(1);
    max2 = max(max(CapEx(:,:,2) + OpEx(:,:,2)))/t0(2);
    ylim([0 max([max1 max2])])
    yticks([0 1])
    YTickString{1} = ['0k'];
    YTickString{2} = ['$$\begin{array}{c} \mathrm{Total} \\' ...
            '\mathrm{Cost} \\ \end{array}$$'];
        set(gca,'YTickLabel',YTickString,'TickLabelInterpreter','latex');
    set(gca,'FontSize',fs1)
    if a == 1
        t = title('Battery','FontWeight','normal','FontSize',fs3);
        t.Position(2) = t.Position(2)*1.1;
    end
    if a == 2
        t = title('Instrumentation','FontWeight','normal','FontSize',fs3);
        t.Position(2) = t.Position(2)*1.1;
    end
    if a == 3
        t = title('WEC','FontWeight','normal','FontSize',fs3);
        t.Position(2) = t.Position(2)*1.1;
    end
    if a == 4
        t = title('OpEx','FontWeight','normal','FontSize',fs3);
        t.Position(2) = t.Position(2)*1.1;
    end
    if isequal(array(a,1).opt.tuned_parameter,'sdr')
        xlabel(({'Self-','Discharge Rate'}),'FontSize',fs2)
        xticklabels({'1.5%','6.0%'})
    elseif isequal(array(a,1).opt.tuned_parameter,'bhc')
        xlabel({'Housing Cost','Multiplier'},'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'mbl')
        xlabel({'Maximum','Battery Life-Cycle [mo]'},'FontSize',fs2)
        xticklabels({'24','60'})
    elseif isequal(array(a,1).opt.tuned_parameter,'nbl')
        xlabel(({'Nominal','Battery Life-Cycle [mo]',''}),'FontSize',fs2)
        xticklabels({'9','36'})
    elseif isequal(array(a,1).opt.tuned_parameter,'dep')
        xlabel({'Depth [m]'},'FontSize',fs2)
        xticklabels({'200','5500'})
    elseif isequal(array(a,1).opt.tuned_parameter,'utp')
        xlabel({'Availability'},'FontSize',fs2)
        xticklabels({'80%','100%'})
    elseif isequal(array(a,1).opt.tuned_parameter,'lft')
        xlabel({'Lifetime [yr]'},'FontSize',fs2)
        xticklabels({'2','9'})
    elseif isequal(array(a,1).opt.tuned_parameter,'ild')
        xlabel(({'Power','Draw [W]'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'cwm')
        xlabel(({'Capture Width','Ratio Multiplier'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'whl')
        xlabel(({'WEC Hotel','Load'}),'FontSize',fs2)
        xticklabels({'0%','18%'})
    elseif isequal(array(a,1).opt.tuned_parameter,'wcm')
        xlabel(({'WEC Cost','Multiplier'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'wiv')
        xlabel(({'WEC Failures'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'tmt')
        xlabel(({'Maintenance','Time [h]'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'dtc')
        xlabel(({'Distance to','Coast [km]'}),'FontSize',fs2)
        xticklabels({'200','2000'})
    elseif isequal(array(a,1).opt.tuned_parameter,'spv')
        xlabel(({'Specialized','Vessel Cost [$k]'}),'FontSize',fs2)
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array(a,1).opt.tuned_parameter,'osv')
        xlabel(({'Offshore','Support Vessel Cost [$k]'}),'FontSize',fs2)
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    end
    xlab = get(ax(a),'XLabel');
    xlab.Position(2) = 0.6*xlab.Position(2);
    %fix x tick overlap
    xtl = xticklabels;
    xticklabels([])
    xtickpos = get(gca, 'xtick');
    for i = 1:2
        t(i) = text(xtickpos(i),0, xtl{i}, ...
            'FontSize',fs1,'HorizontalAlignment','center');
        set(t(i), 'Units','pixels');
        set(t(i), 'Position', get(t(i),'Position')-[0 8 0]);
    end
    set(gca,'LineWidth',0.9)
end

hL = legend([capex(1), opex(1), total(1), blt(1)],'CapEx','OpEx','Total Cost', ...
    'Baseline','location','southoutside','Orientation','horizontal');
newPosition = [0.41 .03 0.2 0];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'FontSize',fs1);

print(gcf,['../Research/OO-TechEc/paper_figures/' figstr],  ...
    '-dpng','-r600')

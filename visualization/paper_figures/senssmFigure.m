clearvars -except sdr bhc mbl nbl dep utp lft ild cwm whl wcm wiv tmt  ...
    dtc spv osv s0
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

%must load ssm output of interest manually

%merge
array(1,:) = sdr;
x0(1) = s0.batt.sdr;
array(5,:) = bhc;
x0(5) = s0.econ.batt.enclmult;
array(9,:) = mbl;
x0(9) = s0.batt.lc_max;
array(13,:) = nbl;
x0(13) = s0.batt.lc_nom;
array(2,:) = dep;
x0(2) = s0.data.depth;
array(6,:) = utp;
x0(6) = s0.uc.uptime;
array(10,:) = lft;
x0(10) = s0.uc.lifetime;
array(14,:) = ild;
x0(14) = s0.uc.draw;
array(3,:) = cwm;
x0(3) = 1;
array(7,:) = whl;
x0(7) = s0.wave.house;
array(11,:) = wcm;
if s0.econ.wave.scen == 2 %opt cost
    x0(11) = s0.econ.wave.costmult_opt;
else
    x0(11) = s0.econ.wave.costmult_con;
end
array(15,:) = wiv;
if s0.econ.wave.scen == 3 %opt durability
    x0(15) = s0.econ.wave.lowfail;
else
    x0(15) = s0.econ.wave.highfail;
end
array(12,:) = tmt;
if s0.c == 1 %short term
    x0(12) = s0.econ.vessel.t_ms;
elseif s0.c == 2 %long term
    x0(12) = s0.econ.vessel.t_mosv;
end
array(8,:) = dtc;
x0(8) = s0.data.dist;
array(4,:) = spv;
x0(4) = s0.econ.vessel.speccost;
array(16,:) = osv;
x0(16) = s0.econ.vessel.osvcost;

n = length(sdr(1).opt.tuning_array); %sensitivity discretization

for a = 1:size(array,1) %across all 16 arrays
    for r = 1:size(array,2) %across all 10 runs in an array
        CapEx(a,r) = array(a,r).output.min.CapEx;
        OpEx(a,r) = array(a,r).output.min.OpEx;
    end
    tp{a} = array(a,1).opt.tuned_parameter; %tuned parameter
    ta(a,:) = array(a,1).opt.tuning_array; %tuned array
end

t0 = s0.output.min.cost; %total cost of base case
c0 = s0.output.min.CapEx; %capital cost of base case
o0 = s0.output.min.OpEx; %operational cost of base case

%plot settings
lw = 2;
lw2 = 1;
ms = 22;
fs1 = 7.5;
fs2 = 7.5;
fs3 = 12;
red = [255, 105, 97]/256;
blue = [70, 190, 234]/256;
orange = [255, 179, 71]/256;

if s0.c == 1 && isequal(s0.loc,'argBasin')
    ssm_ab_st = figure;
    figstr = 'ssm_ab_st';
elseif s0.c == 2 && isequal(s0.loc,'argBasin')
    ssm_ab_lt = figure;
    figstr = 'ssm_ab_lt';
elseif s0.c == 1 && isequal(s0.loc,'souOcean')
    ssm_so_st = figure;
    figstr = 'ssm_so_st';
elseif s0.c == 2 && isequal(s0.loc,'souOcean')
    ssm_so_lt = figure;
    figstr = 'ssm_so_lt';
end
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 5.5])
for a = 1:size(array,1)
    ax(a) = subplot(4,4,a);
    total = plot(ta(a,:),(CapEx(a,:)+OpEx(a,:))/t0, ...
        'Color','k','DisplayName','Total','LineWidth',lw);
    hold on
    grid on
    gls = get(gca,'GridLineStyle');
    glc = get(gca,'GridColor');
    gla = get(gca,'GridAlpha');
    xl = xline(x0(a),'Color',glc,'Alpha',gla,'LineStyle',gls);
    capex = plot(ta(a,:),CapEx(a,:)/t0,'Color',red,  ...
        'DisplayName','CapEx','LineWidth',lw);
    opex = plot(ta(a,:),OpEx(a,:)/t0,'Color',blue, ...
        'DisplayName','OpEx','LineWidth',lw);  
    blt = scatter(x0(a),1,ms,'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2,'DisplayName','Baseline');
    scatter(x0(a),c0/t0,ms,'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2,'MarkerEdgeColor',red);
    scatter(x0(a),o0/t0,ms,'MarkerFaceColor',orange, ...
            'MarkerEdgeColor','k','LineWidth',lw2,'MarkerEdgeColor',blue);
    xticks([ta(a,1),ta(a,n)]);
    xt = xticks;
    xlim([ta(a,1) ta(a,n)])
    ylim([0 max(max(CapEx + OpEx))/t0])
    yticks([0 1])
    yticklabels({'$0k',['$' num2str(round(t0/1000),3) 'k']})
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

hL = legend([capex, opex, total, blt],'CapEx','OpEx','Total Cost', ...
    'Baseline','location','southoutside','Orientation','horizontal');
newPosition = [0.41 .03 0.2 0];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'FontSize',fs1);

print(gcf,['../Research/OO-TechEc/paper_figures/' figstr],  ...
    '-dpng','-r600')

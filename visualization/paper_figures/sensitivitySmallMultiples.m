clearvars -except sdr bhc mbl nbl dep utp lft ild cwm whl wcm wiv tmt  ...
    dtc spv osv s0 array
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

%merge
if ~exist('array','var')
    array(1,:) = sdr;
    array(5,:) = bhc;
    array(9,:) = mbl;
    array(13,:) = nbl;
    array(2,:) = dep;
    array(6,:) = utp;
    array(10,:) = lft;
    array(14,:) = ild;
    array(3,:) = cwm;
    array(7,:) = whl;
    array(11,:) = wcm;
    array(15,:) = wiv;
    array(4,:) = tmt;
    array(8,:) = dtc;
    array(12,:) = spv;
    array(16,:) = osv;
end

n = length(sdr(1).opt.tuning_array); %sensitivity discretization

for a = 1:size(array,1) %across all 16 arrays
    for r = 1:size(array,2) %across all 10 runs in an array
        CapEx(a,r) = array(a,r).output.min.CapEx;
        OpEx(a,r) = array(a,r).output.min.OpEx;
    end
    tp{a} = array(a,1).opt.tuned_parameter; %tuned parameter
    ta(a,:) = array(a,1).opt.tuning_array; %tuned array
end

tc = s0.output.min.cost; %total cost of base case

%plot settings
lw = 2;
lw2 = 1.2;
ms = 30;
fs1 = 8;
fs2 = 7;

senssm = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 5.5])
for a = 1:size(array,1)
    ax(a) = subplot(4,4,a);
    set(ax(a),'LineWidth',1.1)
    plot(ta(a,:),CapEx(a,:)/tc,'r', ...
        'DisplayName','CapEx','LineWidth',lw)
    hold on
    plot(ta(a,:),OpEx(a,:)/tc,'b', ...
        'DisplayName','OpEx','LineWidth',lw)
    hold on
    plot(ta(a,:),(CapEx(a,:)+OpEx(a,:))/tc, ...
        'Color','k','DisplayName','Total','LineWidth',lw*1)
    [~,xdot_ind] = min(abs((CapEx(a,:)+OpEx(a,:)-tc)));
    scatter(ta(a,xdot_ind),1,ms,'MarkerFaceColor',[1 .5 0], ...
        'MarkerEdgeColor','k','LineWidth',lw2)
    xticks([ta(a,1),ta(a,n)]);
    xt = xticks;
    xlim([ta(a,1) ta(a,n)])
    ylim([0 max(max(CapEx + OpEx))/tc])
    yticks([0 1])
    yticklabels({'$0k',['$' num2str(round(tc/1000),3) 'k']})
    set(gca,'FontSize',fs1)
    grid on
    if isequal(array(a,1).opt.tuned_parameter,'sdr')
        xlabel(({'Self-','Discharge Rate'}),'FontSize',fs2)
        xticklabels({'1.5%','6.0%'})
    elseif isequal(array(a,1).opt.tuned_parameter,'bhc')
        xlabel({'Housing Cost','Multiplier'},'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'mbl')
        xlabel({'Maximum Battery','Life-Cycle [mo]'},'FontSize',fs2)
        xticklabels({'24','60'})
    elseif isequal(array(a,1).opt.tuned_parameter,'nbl')
        xlabel(({'Nominal Battery','Life-Cycle [mo]',''}),'FontSize',fs2)
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
        xlabel(({'Load'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'cwm')
        xlabel(({'Capture Width','Multiplier'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'whl')
        xlabel(({'WEC Hotel','Load'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'wcm')
        xlabel(({'WEC Cost','Multiplier'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'wiv')
        xlabel(({'WEC Failures'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'tmt')
        xlabel(({'Maintenance','Time [h]'}),'FontSize',fs2)
    elseif isequal(array(a,1).opt.tuned_parameter,'dtc')
        xlabel(({'Distance to','Coast [m]'}),'FontSize',fs2)
        tx = round(9.7461e02.*xt,-1);
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array(a,1).opt.tuned_parameter,'spv')
        xlabel(({'Specialized','Vessel Cost [$k]'}),'FontSize',fs2)
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array(a,1).opt.tuned_parameter,'osv')
        xlabel(({'Offshore Support','Vessel Cost [$k]'}),'FontSize',fs2)
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    end
end
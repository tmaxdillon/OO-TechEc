clearvars -except array_ssm x0 t0 cost ta tp
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

path = '/Users/tmd1502/Dropbox (MREL)/MATLAB/OO-TechEc/output_data/';
loadcell{1} = 'ssm_ab_st.mat';
loadcell{3} = 'ssm_ce_st.mat';
loadcell{5} = 'ssm_cp_st.mat';
loadcell{7} = 'ssm_is_st.mat';
loadcell{9} = 'ssm_so_st.mat';
loadcell{2} = 'ssm_ab_lt.mat';
loadcell{4} = 'ssm_ce_lt.mat';
loadcell{6} = 'ssm_cp_lt.mat';
loadcell{8} = 'ssm_is_lt.mat';
loadcell{10} = 'ssm_so_lt.mat';

if ~exist('array_ssm','var')
    %preallocate
    x0 = zeros(16,10);
    t0 = zeros(1,10);
    cost = zeros(16,10,10);
    ta = zeros(16,10,10);
    %merge
    for i = 1:10
        tic
        load([path loadcell{i}])
        %battery
        array_ssm(1,:,i) = sdr;
        x0(1,i) = s0.batt.sdr;
        array_ssm(5,:,i) = bbt;
        x0(5,i) = s0.batt.T;
        array_ssm(9,:,i) = eol;
        x0(9,i) = s0.batt.EoL;
        array_ssm(13,:,i) = bcc;
        x0(13,i) = s0.batt.cost;
        %instrumentation
        array_ssm(2,:,i) = dep;
        x0(2,i) = s0.data.depth;
        array_ssm(6,:,i) = utp;
        x0(6,i) = s0.uc.uptime;        
        array_ssm(10,:,i) = ild;
        x0(10,i) = s0.uc.draw;
        array_ssm(14,:,i) = lft;
        x0(14,i) = s0.uc.lifetime;
        array_ssm(3,:,i) = bhc;
        %WEC
        x0(3,i) = s0.econ.batt.enclmult;
        array_ssm(7,:,i) = whl;
        x0(7,i) = s0.wave.house;
        array_ssm(11,:,i) = wcm;
        if s0.econ.wave.scen == 2 %opt cost
            x0(11,i) = s0.econ.wave.costmult_opt;
        else
            x0(11,i) = s0.econ.wave.costmult_con;
        end
        array_ssm(15,:,i) = wiv;
        if s0.econ.wave.scen == 3 %opt durability
            x0(15,i) = s0.econ.wave.lowfail;
        else
            x0(15,i) = s0.econ.wave.highfail;
        end
        %OPEX
        array_ssm(4,:,i) = spv;
        x0(4,i) = s0.econ.vessel.speccost;
        array_ssm(8,:,i) = tmt;
        if s0.c == 1 %short term
            x0(8,i) = s0.econ.vessel.t_ms;
        elseif s0.c == 2 %long term
            x0(8,i) = s0.econ.vessel.t_mosv;
        end
        array_ssm(12,:,i) = osv;        
        x0(12,i) = s0.econ.vessel.osvcost;        
        array_ssm(16,:,i) = dtc;
        x0(16,i) = s0.data.dist;
        t0(i) = s0.output.min.cost; %total cost of base case
        for a = 1:16 %across all 16 arrays
            for r = 1:10 %across all 10 runs in an array
                cost(a,r,i) = array_ssm(a,r,i).output.min.cost;
            end
            tp{a,i} = array_ssm(a,1,i).opt.tuned_parameter;
            ta(a,:,i) = array_ssm(a,1,i).opt.tuning_array;
        end
        disp(['Sensitivity ' num2str(i) ' loaded succesfully.'])
        toc
        clearvars -except array_ssm x0 t0 cost loadcell path ta tp
    end
end

n = 10; %sensitivity discretization

%plot settings
lw = 1.5;
lw2 = 0.8;
lw3 = 0.9;
ms = 20;
fs1 = 8; %axes
fs2 = 8; %xlabel
fs3 = 12; %column titles
fs4 = 10; %legend
alpha = 1;
alpha2 = 1;
alpha3 = 1;
red = [255, 105, 97]/256;
blue = [70, 190, 234]/256;
orange = [255, 179, 71]/256;
titles = {'Argentine Basin: Short-Term', ...
    'Argentine Basin: Long-Term', ...
    'Coastal Endurance: Short-Term', ...
    'Coastal Endurance: Long-Term', ...
    'Coastal Pioneer: Short-Term', ...
    'Coastal Pioneer: Long-Term', ...
    'Irminger Sea: Short-Term', ...
    'Irminger Sea: Long-Term', ...
    'Southern Ocean: Short-Term'...
    'Southern Ocean: Long-Term'};
ann = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(j)', ...
    '(k)','(l)','(m)','(n)','(o)','(p)'};


ssm_allscen = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 6])

%possible color schemes
% col = colormap(brewermap(10,'Dark2')); %colors (after figure set)
% colcorr = 1:1:10;
%col = flipud(colormap(brewermap(10,'Paired'))); %colors (after figure set)
%colcorr = [9 3 5 7 1 10 4 6 8 2];
% col(1:5,:) = flipud(colormap(brewermap(5,'blues')));
% col(6:10,:) = flipud(colormap(brewermap(5,'reds')));
%colcorr = 1:1:10;
allcols = colormap(brewermap(15,'RdYlGn'));
col = zeros(10,3);
col(6:10,:) = flipud(allcols(1:5,:));
col(1:5,:) = allcols(end-4:end,:);
colcorr = [1 6 2 7 3 8 4 9 5 10];

col(:,4) = alpha;
for a = 1:size(array_ssm,1)
    ax(a) = subplot(4,4,a);
    drawnow
    for i = 1:10
        %x0(8,l(i)) = x0(8,l(i))/1000;
        locs(i) = plot(ta(a,:,i),cost(a,:,i)/t0(i), ...
            'Color',col(colcorr(i),:),'DisplayName',titles{i}, ...
            'LineWidth',lw);
        hold on
        grid on
        set(gca,'GridAlpha',.3);
    end
    %     for i = 1:10
    [baselines_x,baselines_ind] = unique(x0(a,:));
    blt = scatter(baselines_x, ...
        t0(baselines_ind)./t0(baselines_ind),ms, ...
        'MarkerFaceColor',orange, ...
        'MarkerEdgeColor','k','LineWidth',lw2, ...
        'MarkerFaceAlpha',alpha2,'MarkerEdgeAlpha',alpha3, ...
        'DisplayName','Baseline');
    %     end
    %draw vertical gridlines
    gls = get(gca,'GridLineStyle');
    glc = get(gca,'GridColor');
    gla = get(gca,'GridAlpha');
    vlines = unique(x0(a,:));
    for j = 1:length(vlines)
        xline(vlines(j),'Color',glc,'Alpha',gla,'LineStyle',gls);
    end
    xticks([ta(a,1,i),ta(a,n,i)]);
    xt = xticks;
    xlim([ta(a,1,i) ta(a,n,i)])
    %don't show zero on y axis
    %     xt_yadj = 4.5;
    %     ylim([min(squeeze(min(cost(:,:,:),[],1:2))./t0(:)) ...
    %         max(squeeze(max(cost(:,:,:),[],1:2))./t0(:))])
    %     yticks([1])
    %     YTickString{1} = ['$$\begin{array}{c} \mathrm{Total} \\' ...
    %         '\mathrm{Cost} \\ \end{array}$$'];
    %show zero on y axis
%     xt_yadj = 8;
%     ylim([0 mean([max(squeeze(max(cost(:,:,:),[],1:2))./t0(:)) 1])])
%     yticks([0 1])
%     YTickString{1} = ['\$0k'];
%     YTickString{2} = ['$$\begin{array}{c} \mathrm{Total} \\' ...
%         '\mathrm{Cost} \\ \end{array}$$'];
      %percent tick labels
    xt_yadj = -4;
    ylim([.25 mean([max(squeeze(max(cost(:,:,:),[],1:2))./t0(:)) 1])])
    yticks([0 0.5 1])
    YTickString{1} = '0%';
    YTickString{2} = '50%';
    YTickString{3} = '100%';
    set(gca,'YTickLabel',YTickString);
    set(gca,'FontSize',fs1)
    %ylabels
    if a == 1 || a == 5 || a == 9 || a == 13
        ylabel_lshift = 0.3;
        hYLabel = ylabel('Cost');
        set(hYLabel,'rotation',0,'VerticalAlignment','middle', ...
        'HorizontalAlignment','center','Units','Normalized')
        ylabpos = get(hYLabel,'Position');
                ylabpos(1) = ylabpos(1) - ylabel_lshift;
        set(hYLabel,'Position',ylabpos,'FontSize',fs3)
    end
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
    if isequal(array_ssm(a,1).opt.tuned_parameter,'sdr')
        xlabel(({'Self-','Discharge Rate'}),'FontSize',fs2)
        xticklabels({'0%','15%'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'bhc')
        xlabel({'Battery','Housing Cost Multiplier'},'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'mbl')
        xlabel({'Maximum','Battery Lifetime [mo]'},'FontSize',fs2)
        xticklabels({'12','60'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'nbl')
        xlabel(({'Nominal','Battery Lifetime [mo]',''}), 'FontSize',fs2)
        xticklabels({'9','60'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'dep')
        xlabel({'Water','Depth [m]'},'FontSize',fs2)
        xticklabels({'120','5500'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'utp')
        xlabel({'Persistence','Requirement'},'FontSize',fs2)
        xticklabels({'80%','100%'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'lft')
        xlabel({'Lifetime [yr]'},'FontSize',fs2)
        xticklabels({'1','10'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'ild')
        xlabel(({'Power','Draw [W]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'cwm')
        xlabel(({'Capture','Width Ratio Multiplier'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'whl')
        xlabel(({'WEC Hotel','Load'}),'FontSize',fs2)
        xticklabels({'0%','18%'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'wcm')
        xlabel(({'WEC Cost','Multiplier'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'wiv')
        xlabel(({'WEC','Failures per Year'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'tmt')
        xlabel(({'Maintenance','Time [h]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'dtc')
        xlabel(({'Distance','to Coast [km]'}),'FontSize',fs2)
        xticklabels({'10','1400'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'spv')
        xlabel(({'Specialized','Vessel Cost [$k/d]'}),'FontSize',fs2)
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'osv')
        xlabel(({'Offshore','Support Vessel Cost [$k/d]'}),'FontSize',fs2)
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'bcc')
        xlabel(({'Battery','Cell Cost [$/kWh]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'bbt')
        xlabel(({'Battery','Temperature [C]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'eol')
        xlabel(({'Battery','End of Life'}),'FontSize',fs2)
        xticklabels({'5%','27.5%'})
    end
    %set x axis label to a consistent position
    set(ax(a).XLabel,'units','normalized')
    pos = get(ax(a).XLabel,'Position');
    pos(2) = -.125;
    set(ax(a).XLabel,'Position',pos,'VerticalAlignment','Top')
    xlab = get(ax(a),'XLabel');
    xlab.Position(2) = 0.6*xlab.Position(2);
    set(gca,'LineWidth',lw3)
    %     set(gca,'TickLength',[0.05 0.1])
end
set(gcf,'Color','w');
%make room at bottom for legend
for a = 1:size(array_ssm,1)
    set(ax(a),'Units','Inches')
    axesposition(a,:) = get(ax(a),'Position');
end
%addright = 0.75; %[in]
addbottom = .6; %[in]
lshift = 0.1;
set(gcf,'Position', [1, 1, 6.5, 6+addbottom])
for a = 1:size(array_ssm,1)
    axesposition(a,:) = get(ax(a),'Position');
    set(ax(a),'Position',[axesposition(a,1)-lshift ...
        axesposition(a,2)+addbottom axesposition(a,3) ...
        axesposition(a,4)])
end
%fix x tick label overlap and add annotation
for a = 1:size(array_ssm,1)
    axes(ax(a))
    xtl = ax(a).XTickLabel;
    xticklabels([])
    xtickpos = get(ax(a), 'xtick');
    for i = 1:2
        t(i) = text(xtickpos(i),0, xtl{i}, ...
            'FontSize',fs1,'HorizontalAlignment','center');
        set(t(i), 'Units','pixels');
        set(t(i), 'Position', get(t(i),'Position')-[0 xt_yadj 0]);
    end
    text(.975,.04,ann{a},'Units','Normalized', ...
        'VerticalAlignment','bottom','FontWeight','normal', ...
        'HorizontalAlignment','right','FontSize',fs1, ...
        'Color',[.25 .25 .25]);
end

hL = legend(locs,'location','eastoutside','Box','off', ...
    'Orientation','horizontal','NumColumns',2,'FontSize',fs4);
newPosition = [0.25 0.075 0.5 0];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'FontSize',fs1);


set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 245]/256)
print(ssm_allscen,'~/Dropbox (MREL)/Research/General Exam/pf/ssm',  ...
    '-dpng','-r600')



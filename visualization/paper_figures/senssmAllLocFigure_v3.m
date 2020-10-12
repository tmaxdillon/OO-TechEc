clearvars -except array x0 t0 cost ta tp
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

if ~exist('array','var')
    for i = 1:10
        tic
        load([path loadcell{i}])
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
        array(16,:,i) = dtc;
        x0(16,i) = s0.data.dist;
        array(4,:,i) = spv;
        x0(4,i) = s0.econ.vessel.speccost;
        array(8,:,i) = osv;
        x0(8,i) = s0.econ.vessel.osvcost;
        t0(i) = s0.output.min.cost; %total cost of base case
        for a = 1:16 %across all 16 arrays
            for r = 1:10 %across all 10 runs in an array
                cost(a,r,i) = array(a,r,i).output.min.cost;
            end
            tp{a,i} = array(a,1,i).opt.tuned_parameter;
            ta(a,:,i) = array(a,1,i).opt.tuning_array;
        end
        disp(['Sensitivity ' num2str(i) ' loaded succesfully.'])
        toc
        clearvars -except array x0 t0 cost loadcell path ta tp
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
for a = 1:size(array,1)
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
    xt_yadj = 8;
    ylim([0 max(squeeze(max(cost(:,:,:),[],1:2))./t0(:))])
    yticks([0 1])
    YTickString{1} = ['\$0k'];
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
        xlabel(({'Nominal','Battery Life-Cycle [mo]',''}), ...
            'FontSize',fs2)
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
        xlabel(({'Capture','Width Ratio Multiplier'}),'FontSize',fs2)
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
        xlabel(({'Specialized','Vessel Cost [$k/d]'}),'FontSize',fs2)
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array(a,1).opt.tuned_parameter,'osv')
        xlabel(({'Offshore','Support Vessel Cost [$k/d]'}), ...
            'FontSize',fs2)
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array(a,1).opt.tuned_parameter,'bcc')
        xlabel(({'Battery','Cell Cost [$/kWh]'}), ...
            'FontSize',fs2)
    end
    set(ax(a).XLabel,'units','normalized')
    pos = get(ax(a).XLabel,'Position');
    pos(2) = -.15;
    set(ax(a).XLabel,'Position',pos,'VerticalAlignment','Top')
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
        set(t(i), 'Position', get(t(i),'Position')-[0 xt_yadj 0]);
    end
    set(gca,'LineWidth',lw3)
%     set(gca,'TickLength',[0.05 0.1])
end
set(gcf,'Color','w');
%make room at bottom for legend
for a = 1:size(array,1)
    set(ax(a),'Units','Inches')
    axesposition(a,:) = get(ax(a),'Position');
end
%addright = 0.75; %[in]
addbottom = .6; %[in]
lshift = 0.1;
set(gcf,'Position', [1, 1, 6.5, 6+addbottom])
for a = 1:size(array,1)
    axesposition(a,:) = get(ax(a),'Position');
    set(ax(a),'Position',[axesposition(a,1)-lshift ...
        axesposition(a,2)+addbottom axesposition(a,3) ...
        axesposition(a,4)])
end
% hL = legend([locs, blt],'Argentine Basin\newline Short Term', ...
%     'Coastal Endurance\newline Short Term', ...
%     'Coastal Pioneer\newline Short Term', ...
%     'Irminger Sea\newline Short Term', ...
%     'Southern Ocean\newline Short Term', ...
%     'Argentine Basin\newline Long Term', ...
%     'Coastal Endurance\newline Long Term', ...
%     'Coastal Pioneer\newline Long Term', ...
%     'Irminger Sea\newline Long Term', ....
%     'Southern Ocean\newline Long Term', ...
%     'Baseline','location','eastoutside', ...
%     'Orientation','vertical','NumColumns',1);
% hL = legend(locs,'Argentine Basin: Short-Term', ...
%     'Argentine Basin: Long-Term', ...
%     'Coastal Pioneer: Short Term','Irminger Sea: Short Term', ...
%     'Southern Ocean: Short Term','Argentine Basin: Long Term', ...
%     'Coastal Endurance: Long Term','Coastal Pioneer: Long Term', ...
%     'Irminger Sea: Long Term','Southern Ocean: Long Term', ...
%     'location','eastoutside','Box','off', ...
%     'Orientation','horizontal','NumColumns',2,'FontSize',fs4);
hL = legend(locs,'location','eastoutside','Box','off', ...
    'Orientation','horizontal','NumColumns',2,'FontSize',fs4);
% hL = legend([locs, blt],{'Argentine Basin','Short Term'}, ...
%     {'Coastal Endurance','Short Term'}, ...
%     {'Coastal Pioneer','Short Term'},{'Irminger Sea','Short Term'}, ...
%     {'Southern Ocean','Short Term'},{'Argentine Basin','Long Term'}, ...
%     {'Coastal Endurance','Long Term'},{'Coastal Pioneer','Long Term'}, ...
%     {'Irminger Sea','Long Term'},{'Southern Ocean','Long Term'}, ...
%     'Baseline','location','eastoutside', ...
%     'Orientation','vertical','NumColumns',1);
newPosition = [0.25 0.075 0.5 0];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'FontSize',fs1);
print(gcf,'~/Dropbox (MREL)/Research/OO-TechEc/paper_figures/ssm_allscen',  ...
    '-dpng','-r600')


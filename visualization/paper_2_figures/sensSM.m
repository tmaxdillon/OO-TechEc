clearvars -except array_ssm x0 t0 cost ta tp pm
close all
clearvars -except pm
set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

%pm = 1;
printon = true;

path = '~/Dropbox (MREL)/MATLAB/OO-TechEc/output_data/oossm_out/';
if pm == 1
    loadcell{1} = 'wico_st_1.mat';
    loadcell{2} = 'wico_lt_1.mat';
    loadcell{3} = 'wico_st_2.mat';
    loadcell{4} = 'wico_lt_2.mat';
    loadcell{5} = 'wico_st_3.mat';
    loadcell{6} = 'wico_lt_3.mat';
elseif pm == 2
    loadcell{1} = 'inhu_lt_1.mat';
    loadcell{2} = 'inau_lt_1.mat';
    loadcell{3} = 'inhu_lt_2.mat';
    loadcell{4} = 'inau_lt_2.mat';
    loadcell{5} = 'inhu_lt_3.mat';
    loadcell{6} = 'inau_lt_3.mat';
elseif pm == 3
    loadcell{1} = 'wcon_st_1.mat';
    loadcell{2} = 'wcon_lt_1.mat';
    loadcell{3} = 'wcon_st_2.mat';
    loadcell{4} = 'wcon_lt_2.mat';
    loadcell{5} = 'wcon_st_3.mat';
    loadcell{6} = 'wcon_lt_3.mat';
elseif pm == 4
    loadcell{1} = 'dgen_st_1.mat';
    loadcell{2} = 'dgen_lt_1.mat';
    loadcell{3} = 'dgen_st_2.mat';
    loadcell{4} = 'dgen_lt_2.mat';
    loadcell{5} = 'dgen_st_3.mat';
    loadcell{6} = 'dgen_lt_3.mat';
end

if ~exist('array_ssm','var')
    %preallocate
    x0 = zeros(16,10);
    t0 = zeros(1,10);
    cost = zeros(16,10,10);
    ta = zeros(16,10,10);
    %merge
    for i = 1:6
        tic
        load([path loadcell{i}])
        if pm == 1
            array_ssm(1,:,i) = tiv;
            x0(1,i) = s0.econ.wind.highfail;
            array_ssm(2,:,i) = tcm;
            x0(2,i) = 2850/1000;
            array_ssm(3,:,i) = cis;
            x0(3,i) = s0.turb.uci;
            array_ssm(4,:,i) = rsp;
            x0(4,i)= s0.turb.ura;
        elseif pm == 2
            array_ssm(1,:,i) = psr;
            x0(1,i) = s0.atmo.soil;
            array_ssm(2,:,i) = pcm;
            x0(2,i) = 1040/1000;
            array_ssm(3,:,i) = pve;
            x0(3,i) = s0.inso.eff;
            array_ssm(4,:,i) = rai;
            x0(4,i)= s0.inso.rated;
        elseif pm == 3
            array_ssm(1,:,i) = wiv;
            if s0.econ.wave.scen == 3 %opt durability
                x0(1,i) = s0.econ.wave.lowfail;
            else
                x0(1,i) = s0.econ.wave.highfail;
            end
            array_ssm(2,:,i) = wcm;
            if s0.econ.wave.scen == 2 %opt cost
                x0(2,i) = s0.econ.wave.costmult_opt;
            else
                x0(2,i) = s0.econ.wave.costmult_con;
            end
            array_ssm(3,:,i) = whl;
            x0(3,i) = s0.wave.house;
            array_ssm(4,:,i) = rhs;
            x0(4,i) = s0.wave.Hs_ra;
        elseif pm == 4
%             array_ssm(2,:,i) = gcm;
%             x0(2,i) = 11214;
            array_ssm(1,:,i) = giv;
            x0(1,i) = s0.econ.dies.fail;
            array_ssm(2,:,i) = fca;
            x0(2,i) = s0.dies.fmax;
            array_ssm(3,:,i) = fsl;
            x0(3,i) = s0.dies.ftmax;
            array_ssm(4,:,i) = oci;
            x0(4,i)= s0.dies.oilint;
        end            
        array_ssm(5,:,i) = dtc;
        x0(5,i) = s0.data.dist/1000;
        array_ssm(6,:,i) = tmt;
        if s0.c == 1 %short term
            x0(6,i) = s0.econ.vessel.t_ms;
        elseif s0.c == 2 %long term
            x0(6,i) = s0.econ.vessel.t_mosv;
        end
        array_ssm(7,:,i) = osv;        
        x0(7,i) = s0.econ.vessel.osvcost;
        array_ssm(8,:,i) = spv;
        x0(8,i) = s0.econ.vessel.speccost;
        array_ssm(9,:,i) = lft;
        x0(9,i) = s0.uc.lifetime;
        array_ssm(10,:,i) = dep;
        x0(10,i) = s0.data.depth;
        array_ssm(11,:,i) = utp;
        x0(11,i) = s0.uc.uptime;        
        array_ssm(12,:,i) = ild;
        x0(12,i) = s0.uc.draw;
        array_ssm(13,:,i) = eol;
        x0(13,i) = s0.batt.EoL*100;
        array_ssm(14,:,i) = bcc;
        x0(14,i) = s0.batt.cost;
        array_ssm(15,:,i) = bhc;
        x0(15,i) = s0.econ.batt.enclmult;
        array_ssm(16,:,i) = sdr;
        x0(16,i) = s0.batt.sdr;                             
        t0(i) = s0.output.min.cost; %total cost of base case
        for a = 1:16 %across all 16 arrays
            for r = 1:10 %across all 10 runs in an array
                cost(a,r,i) = array_ssm(a,r,i).output.min.cost;                
            end
            tp{a,i} = array_ssm(a,1,i).opt.tuned_parameter;
            ta(a,:,i) = array_ssm(a,1,i).opt.tuning_array;
            if (pm == 1 && a == 2) || (pm == 2 && a == 2)
                ta(2,:,i) = ta(2,:,i)*x0(2,i);
            end
        end
        disp(['Sensitivity ' num2str(i) ' loaded succesfully.'])
        toc
        clearvars -except array_ssm x0 t0 cost loadcell path ta tp pm printon
    end
end

n = 10; %sensitivity discretization

%plot settings
lw = 1.7;
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
if pm ~= 2
    titles = {'Argentine Basin: Short-Term', ...
        'Argentine Basin: Long-Term', ...
        'Coastal Endurance: Short-Term', ...
        'Coastal Endurance: Long-Term', ...
        'Irminger Sea: Short-Term', ...
        'Irminger Sea: Long-Term'};
else
    titles = {'Argentine Basin: Human Clean', ...
        'Argentine Basin: Automated Clean', ...
        'Coastal Endurance: Human Clean', ...
        'Coastal Endurance: Automated Clean', ...
        'Irminger Sea: Human Clean', ...
        'Irminger Sea: Automated Clean'};
end
ann = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(j)', ...
    '(k)','(l)','(m)','(n)','(o)','(p)'};


ssm_allscen = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 5.9])

%possible color schemes
% col = colormap(brewermap(10,'Dark2')); %colors (after figure set)
% colcorr = 1:1:10;
%col = flipud(colormap(brewermap(10,'Paired'))); %colors (after figure set)
%colcorr = [9 3 5 7 1 10 4 6 8 2];
% col(1:5,:) = flipud(colormap(brewermap(5,'blues')));
% col(6:10,:) = flipud(colormap(brewermap(5,'reds')));
%colcorr = 1:1:10;
if pm == 1
    allcols = colormap(brewermap(16,'PiYg'));
elseif pm == 2
    allcols = colormap(brewermap(16,'RdBu'));
elseif pm == 3
    allcols = flipud(colormap(brewermap(16,'BrBg')));
elseif pm == 4
    allcols = colormap(brewermap(16,'RdGy'));   
end
col = zeros(6,3);
col(4:6,:) = allcols(4:6,:);
col(1:3,:) = allcols(end-4:end-2,:);
colcorr = [1 6 2 5 3 4];

col(:,4) = alpha;
for a = 1:size(array_ssm,1)
    ax(a) = subplot(4,4,a);
    drawnow
    for i = 1:6
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
%     if pm == 1 && a == 2
%         xticks([ta(a,1,i)*x0(2,i),ta(a,n,i)*x0(2,i)]);
%         xt = xticks;
%         xlim([ta(a,1,i)*x0(2,i) ta(a,n,i)*x0(2,i)])
%     else
        xticks([ta(a,1,i),ta(a,n,i)]);
        xt = xticks;
        xlim([ta(a,1,i) ta(a,n,i)])
%     end
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
    %ylim([.25 mean([max(squeeze(max(cost(:,:,:),[],1:2))./t0(:)) 1])])
    ylim([.25 1.75])
    yticks([0 0.5 1 1.5 2])
    YTickString{1} = '0%';
    YTickString{2} = '50%';
    YTickString{3} = '100%';
    YTickString{4} = '150%';
    YTickString{5} = '200%';
    set(gca,'YTickLabel',YTickString);
    set(gca,'FontSize',fs1)
    %ylabels
    if a == 1 || a == 5 || a == 9 || a == 13
        ylabel_lshift = 0.4;
        hYLabel = ylabel('Cost');
        set(hYLabel,'rotation',0,'VerticalAlignment','middle', ...
        'HorizontalAlignment','center','Units','Normalized')
        ylabpos = get(hYLabel,'Position');
                ylabpos(1) = ylabpos(1) - ylabel_lshift;
        set(hYLabel,'Position',ylabpos,'FontSize',fs3)
    end
%     if a == 1
%         t = title('Battery','FontWeight','normal','FontSize',fs3);
%         t.Position(2) = t.Position(2)*1.1;
%     end
%     if a == 2
%         t = title('Instrumentation','FontWeight','normal','FontSize',fs3);
%         t.Position(2) = t.Position(2)*1.1;
%     end
%     if a == 3
%         t = title('WEC','FontWeight','normal','FontSize',fs3);
%         t.Position(2) = t.Position(2)*1.1;
%     end
%     if a == 4
%         t = title('OpEx','FontWeight','normal','FontSize',fs3);
%         t.Position(2) = t.Position(2)*1.1;
%     end
    if isequal(array_ssm(a,1).opt.tuned_parameter,'sdr')
        xlabel(({'Self-','Discharge Rate'}),'FontSize',fs2)
        xticklabels({'0%','15%'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'bhc')
        xlabel({'Battery','Housing Cost Multiplier'},'FontSize',fs2)
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
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'whl')
        xlabel(({'WEC Hotel','Load'}),'FontSize',fs2)
        xticklabels({'0%','18%'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'wcm')
        xlabel(({'WEC Cost','Multiplier'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'wiv')
        xlabel(({'WEC','Failures per Year'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'rhs')
        xlabel(({'Rated','H_s [m]'}),'FontSize',fs2)
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
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'eol')
        xlabel(({'Battery','End of Life'}),'FontSize',fs2)
        xticklabels({'5%','27.5%'})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'tiv')
        xlabel(({'Turbine','Failures per Year'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'tcm')
        xlabel(({'Turbine','Cost [$k/kW]'}),'FontSize',fs2)
        xticklabels({num2str(xt(1),3),num2str(xt(2),3)})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'twf')
        xlabel(({'Turbine Weight Factor [kg/kW]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'cis')
        xlabel(({'Cut In','Speed [m/s]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'rsp')
        xlabel(({'Rated','Speed [m/s]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'cos')
        xlabel(({'Cut Out','Speed [m/s]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'tef')
        xlabel(({'Turbine Efficiency'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'szo')
        xlabel(({'Surface Roughness [mm]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'pvd')
        xlabel(({'Panel Degradation [%/year]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'pcm')
        xlabel(({'PV','System Cost'}),'FontSize',fs2)
        xticklabels({num2str(xt(1),3),num2str(xt(2),3)})
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'pwf')
        xlabel(({'Panel Weight Factor [kg/m^3]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'pve')
        xlabel(({'Panel','Efficiency'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'rai')
        xlabel(({'Rated','Irradiance'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'psr')
        xlabel(({'Soiling','Rate [%/year]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'giv')
        xlabel(({'Generator','Failures per Year'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'fco')
        xlabel(({'Fuel Cost [$/L]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'fca')
        xlabel(({'Fuel','Capacity [L]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'fsl')
        xlabel(({'Fuel','Shelf Life [mo]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'oci')
        xlabel(({'Oil','Change Interval [h]'}),'FontSize',fs2)
    elseif isequal(array_ssm(a,1).opt.tuned_parameter,'gcm')
        xlabel(({'Generator','Cost Multiplier'}),'FontSize',fs2)
        xticklabels({num2str(xt(1),3),num2str(xt(2),3)})
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
% %make room at bottom for legend
% for a = 1:size(array_ssm,1)
%     set(ax(a),'Units','Inches')
%     axesposition(a,:) = get(ax(a),'Position');
% end
% %addright = 0.75; %[in]
% addbottom = 0; %[in]
% lshift = 0.1;
% set(gcf,'Position', [1, 1, 6.5, 6+addbottom])
% for a = 1:size(array_ssm,1)
%     axesposition(a,:) = get(ax(a),'Position');
%     set(ax(a),'Position',[axesposition(a,1)-lshift ...
%         axesposition(a,2)+addbottom axesposition(a,3) ...
%         axesposition(a,4)])
% end
xoff = 1.1;
xlen = .95;
ylen = .95;
xmarg = .4;
ymarg = .35;
yoff = .9;
for a = 1:size(array_ssm,1)
    set(ax(a),'Units','Inches','Position', ...
        [xoff+(rem(a-1,4)*(xlen+xmarg)) ...
        yoff+floor((length(ax)-a)/4)*(ymarg+ylen) xlen ylen])
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
    text(.975,.01,ann{a},'Units','Normalized', ...
        'VerticalAlignment','bottom','FontWeight','normal', ...
        'HorizontalAlignment','right','FontSize',fs1, ...
        'Color',[.25 .25 .25]);
end

hL = legend(locs,'location','eastoutside','Box','off', ...
    'Orientation','horizontal','NumColumns',2,'FontSize',fs4);
newPosition = [0.325 0.05 0.5 0];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'FontSize',fs1);

if printon
    print(ssm_allscen,['~/Dropbox (MREL)/Research/OO-TechEc/' ...
        'wave-comparison/paper_figures/' ...
        'ssm_' num2str(pm)],'-dpng','-r600')
end



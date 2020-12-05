close all
clearvars -except array x0 t0 cost ta tp
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

path = '~/Dropbox (MREL)/MATLAB/OO-TechEc/output_data/10_17/';
loadcell{1} = 'ssm_ab_st.mat';
loadcell{2} = 'ssm_ce_st.mat';
loadcell{3} = 'ssm_cp_st.mat';
loadcell{4} = 'ssm_is_st.mat';
loadcell{5} = 'ssm_so_st.mat';
loadcell{6} = 'ssm_ab_lt.mat';
loadcell{7} = 'ssm_ce_lt.mat';
loadcell{8} = 'ssm_cp_lt.mat';
loadcell{9} = 'ssm_is_lt.mat';
loadcell{10} = 'ssm_so_lt.mat';

if ~exist('array','var')
    for i = 1:10
        tic
        load([path loadcell{i}])
        %merge
        array(1,:,i) = dtc;
        x0(1,i) = s0.data.dist;
        array(16,:,i) = sdr;
        x0(16,i) = s0.batt.sdr;
        array(15,:,i) = bcc;
        x0(15,i) = s0.batt.cost;
        array(8,:,i) = bhc;
        x0(8,i) = s0.econ.batt.enclmult;
        array(14,:,i) = mbl;
        x0(14,i) = s0.batt.lc_max;
        array(13,:,i) = nbl;
        x0(13,i) = s0.batt.lc_nom;
        array(12,:,i) = dep;
        x0(12,i) = s0.data.depth;
        array(11,:,i) = utp;
        x0(11,i) = s0.uc.uptime;
        array(10,:,i) = lft;
        x0(10,i) = s0.uc.lifetime;
        array(9,:,i) = ild;
        x0(9,i) = s0.uc.draw;
%         array(3,:,i) = cwm;
%         x0(3,i) = 1;
        array(7,:,i) = whl;
        x0(7,i) = s0.wave.house;
        array(6,:,i) = wcm;
        if s0.econ.wave.scen == 2 %opt cost
            x0(6,i) = s0.econ.wave.costmult_opt;
        else
            x0(6,i) = s0.econ.wave.costmult_con;
        end
        array(5,:,i) = wiv;
        if s0.econ.wave.scen == 3 %opt durability
            x0(5,i) = s0.econ.wave.lowfail;
        else
            x0(5,i) = s0.econ.wave.highfail;
        end
        array(3,:,i) = tmt;
        if s0.c == 1 %short term
            x0(3,i) = s0.econ.vessel.t_ms;
        elseif s0.c == 2 %long term
            x0(3,i) = s0.econ.vessel.t_mosv;
        end
        array(4,:,i) = spv;
        x0(4,i) = s0.econ.vessel.speccost;
        array(2,:,i) = osv;
        x0(2,i) = s0.econ.vessel.osvcost;
        t0(i) = s0.output.min.cost; %total cost of base case
        for a = 1:16
            ta(a,:,i) = array(a,1,i).opt.tuning_array;
        end
        disp(['Sensitivity ' num2str(i) ' loaded succesfully.'])
        toc
        clearvars -except array x0 t0 cost loadcell path ta tp
    end
    ta(1,:,:) = ta(1,:,:)./1000;
    ta(2,:,:) = ta(2,:,:)./1000;
    ta(4,:,:) = ta(4,:,:)./1000;
end

units = fliplr({' % month^{-1}',' $k Wh^{-1}',' months',' months', ...
    ' meters',' %',' year',' watts',' multiples',' %',' multiples', ...
    ' failure',' $k day^{-1}',' hours',' $k day^{-1}',' kilometers'});

rval = fliplr([1, -1, 1, 1, -1, 2, 0, 0, 2, 2, 1, 0, 0, 1, 1, -1]);
%rval = 3*ones(1,16);

for i = 1:16
    dx{i} = [num2str(round(abs(ta(i,1,1)-ta(i,2,1)),rval(i))) units{i}];
end

%load into cost and mean slope arrays
for a = 1:16
    for i = 1:10
        for n = 1:10
            cost(a,n,i) = array(a,n,i).output.min.cost;
        end
        ms(a,i) = mean(abs(diff(cost(a,:,i)/t0(i)))); %mean slope
        %ms(a,i) = mean(abs(diff(cost(a,:,i)))); %mean slope
    end
end
%ms = ms./max(ms(:)); %normalize
%ms = round(ms/1000);
%[x_ms,y_ms] = meshgrid(1:11,1:17);

%annotations
tS = num2str(round(ms(:).*100,0,'decimal'),'%0.f'); %strings
tS = strtrim(cellstr(tS)); %remove any space padding
%tS = cellfun(@(c)['$' c 'k'],tS,'uni',false);
tS = cellfun(@(c)[c '%'],tS,'uni',false);
[x_t,y_t] = meshgrid((1:10)+0.5,(1:16)+0.5);

%add row to ms
[r_ms,c_ms] = size(ms);
ms = [ms ; zeros(1,c_ms)];
ms = [ms zeros(r_ms+1,1)];

%colors
nc = 1000;
cmap = brewermap(nc,'reds');
cmap = cmap(round(nc*0.1):round(nc*0.6),:);

%plot settings
fs1 = 8.5;
fs2 = 10;
fs3 = 12;
xticks = 1.5:1:10.5;
yticks = 1.5:1:16.5;
ytl = {'Self-Discharge Rate','Battery Cell Cost', ...
    'Maximum Battery Lifetime','Nominal Battery Lifetime', ...
    'Water Depth','Persistence Requirement','Lifetime','Power Draw', ...
    'Battery Housing Cost','WEC Hotel Load','WEC Cost Multiplier', ...
    'WEC Failures','Specialized Vessel Cost','Maintenance Time', ...
    'Offshore Support Vessel Cost','Distance to Coast'};
xtl = {'Argentine Basin: Short-Term', ...
    'Coastal Endurance: Short-Term', ...
    'Coastal Pioneer: Short-Term', ...
    'Irminger Sea: Short-Term', ...
    'Southern Ocean: Short-Term'...
    'Argentine Basin: Long-Term', ...
    'Coastal Endurance: Long-Term', ...    
    'Coastal Pioneer: Long-Term', ...    
    'Irminger Sea: Long-Term', ...    
    'Southern Ocean: Long-Term'};
xtrot = 45;

senstable = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 6])
pc = pcolor(ms);
% colormap(cmap);
AdvancedColormap('wa')
%colorbar
ylim([1 17])
xlim([1 11])
hStrings = text(x_t(:),y_t(:),tS(:), ...
    'HorizontalAlignment','center'); %plot strings
set(hStrings,'Color','black')
set(hStrings,'FontSize',fs1)
set(gca,'XAxisLocation','top','XTick',xticks,'YTick',yticks, ...
    'XTickLabels',xtl,'YTickLabels',fliplr(ytl),'XTickLabelRotation',xtrot)
%plot delta values
ytickpos = get(gca,'ytick');
t = text(zeros(1,16)',ytickpos',dx,'FontSize',fs2, ... 
    'HorizontalAlignment','left','Interpreter','tex');
for i = 1:length(t)
    set(t(i),'Units','normalized');
    set(t(i),'Position', get(t(i),'Position')+[1.13 0 0]);
end
posdel1 = get(t(end),'Position');
posdel2 = get(t(end-1),'Position');
t = text(posdel1(1)+0.01,posdel1(2)+abs(posdel1(2)-posdel2(2)), ...
    '\underline{Unit Step}','interpreter','latex','Units','normalized', ...
    'HorizontalAlignment','left','FontSize',fs3);

xoff = 1.85; %[in]
yoff = 0.35; %[in]
xdist = 3.5; %[in]
ydist = 4; %[in]
set(gca,'Units','Inches','Position',[xoff yoff xdist ydist])

print(gcf,['~/Dropbox (MREL)/Research/OO-TechEc/paper_figures/' ...
    'senstable_pr'],'-dpng','-r600')



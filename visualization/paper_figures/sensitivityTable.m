close all
clearvars -except array_st x0 t0 cost ta tp
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

path = '~/Dropbox (MREL)/MATLAB/OO-TechEc/output_data/';
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

if ~exist('array_st','var')
    for i = 1:10
        tic
        load([path loadcell{i}])
        %merge
        array_st(16,:,i) = sdr;
        x0(16,i) = s0.batt.sdr;
        array_st(15,:,i) = bbt;
        x0(15,i) = s0.batt.T;
        array_st(14,:,i) = eol;
        x0(14,i) = s0.batt.EoL;
        array_st(13,:,i) = bcc;
        x0(13,i) = s0.batt.cost;
        array_st(12,:,i) = dep;
        x0(12,i) = s0.data.depth;
        array_st(11,:,i) = utp;
        x0(11,i) = s0.uc.uptime;
        array_st(10,:,i) = ild;
        x0(10,i) = s0.uc.draw;
        array_st(9,:,i) = lft;
        x0(9,i) = s0.uc.lifetime;
        array_st(8,:,i) = bhc;
        x0(8,i) = s0.econ.batt.enclmult;
        array_st(7,:,i) = whl;
        x0(7,i) = s0.wave.house;
        array_st(6,:,i) = wcm;
        if s0.econ.wave.scen == 2 %opt cost
            x0(6,i) = s0.econ.wave.costmult_opt;
        else
            x0(6,i) = s0.econ.wave.costmult_con;
        end
        array_st(5,:,i) = wiv;
        if s0.econ.wave.scen == 3 %opt durability
            x0(5,i) = s0.econ.wave.lowfail;
        else
            x0(5,i) = s0.econ.wave.highfail;
        end
        array_st(4,:,i) = spv;
        x0(4,i) = s0.econ.vessel.speccost;
        array_st(3,:,i) = tmt;
        if s0.c == 1 %short term
            x0(3,i) = s0.econ.vessel.t_ms;
        elseif s0.c == 2 %long term
            x0(3,i) = s0.econ.vessel.t_mosv;
        end
        array_st(2,:,i) = osv;
        x0(2,i) = s0.econ.vessel.osvcost;
        array_st(1,:,i) = dtc;
        x0(1,i) = s0.data.dist;
        t0(i) = s0.output.min.cost; %total cost of base case
        for a = 1:16
            ta(a,:,i) = array_st(a,1,i).opt.tuning_array;
        end
        disp(['Sensitivity ' num2str(i) ' loaded succesfully.'])
        toc
        clearvars -except array_st x0 t0 cost loadcell path ta tp
    end
    ta(1,:,:) = ta(1,:,:)./1000;
    ta(2,:,:) = ta(2,:,:)./1000;
    ta(4,:,:) = ta(4,:,:)./1000;
end

units = fliplr({' % month^{-1}',' %','^{\circ} C',' $k Wh^{-1}', ...
    ' meters',' %',' watts',' year',' multiples',' %',' multiples', ...
    ' failures year^{-1}',' $k day^{-1}',' hours',' $k day^{-1}', ...
    ' kilometers'});

%round values
rval = fliplr([1, 1, 1, -1, -1, 2, 0, 0, 2, 2, 1, 2, 0, 1, 1, -1]);
%rval = 3*ones(1,16);

for i = 1:16
    dx{i} = [num2str(round(abs(ta(i,1,1)-ta(i,2,1)),rval(i))) units{i}];
end

%load into cost and mean slope arrays
for a = 1:16
    for i = 1:10
        for n = 1:10
            cost(a,n,i) = array_st(a,n,i).output.min.cost;
        end
        ms(a,i) = mean(abs(diff(cost(a,:,i)/t0(i)))); %mean slope
        %ms(a,i) = mean(abs(diff(cost(a,:,i)))); %mean slope
    end
end
%ms = ms./max(ms(:)); %normalize
%ms = round(ms/1000);
%[x_ms,y_ms] = meshgrid(1:11,1:17);

%set middle colum width
mcw = .075;

%annotations
tS = num2str(round(ms(:).*100,0,'decimal'),'%0.f'); %strings
tS = strtrim(cellstr(tS)); %remove any space padding
%tS = cellfun(@(c)['$' c 'k'],tS,'uni',false);
tS = cellfun(@(c)[c '%'],tS,'uni',false);
[x_t,y_t] = meshgrid((1:10)+1,(1:16)+1);
x_t(:,6:end) = x_t(:,6:end) + mcw;

%add row, column and center column to mean slope matrix
[r_ms,c_ms] = size(ms);
ms = [ms ; zeros(1,c_ms)];
ms = [ms zeros(r_ms+1,1)];
ms = [ms(:,1:5) NaN(r_ms+1,1) ms(:,6:end)];
[x_t_ms,y_t_ms] = meshgrid((1:12)+0.5,(1:17)+0.5);
x_t_ms(:,7:end) = x_t_ms(:,7:end) - (1 - mcw);

%colors
nc = 1000;
cmap = brewermap(nc,'reds');
cmap = cmap(round(nc*0.1):round(nc*0.6),:);

%plot settings
fs1 = 8.5;
fs2 = 10;
fs3 = 12;
xticks = 2:1:12;
xticks(6:end) = xticks(6:end) - (1 - mcw);
yticks = 2:1:17;
% [CW,RW] = meshgrid(xticks,yticks);
ytl = {'Self-Discharge Rate','Battery Temperature', ...
    'Battery End of Life','Battery Cell Cost', ...
    'Water Depth','Persistence Requirement','Power Draw','Lifetime', ...
    'Battery Housing Cost','WEC Hotel Load','WEC Cost Multiplier', ...
    'WEC Failures','Specialized Vessel Cost','Maintenance Time', ...
    'Offshore Support Vessel Cost','Distance to Coast'};
xtl = {'Argentine Basin: Short-Term', ...
    'Coastal Endurance: Short-Term', ...
    'Coastal Pioneer: Short-Term', ...
    'Irminger Sea: Short-Term', ...
    'Southern Ocean: Short-Term', ...
    '', ...
    'Argentine Basin: Long-Term', ...
    'Coastal Endurance: Long-Term', ...    
    'Coastal Pioneer: Long-Term', ...    
    'Irminger Sea: Long-Term', ...    
    'Southern Ocean: Long-Term'};
xtrot = 45;

senstable = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 6.5, 6])
%pc = pcolor(CW,RW,ms(1:end-1,1:end-1));
pc = pcolor(x_t_ms,y_t_ms,ms);
% colormap(cmap);
AdvancedColormap('wa')
%colorbar
% ylim([1 17])
% xlim([1 11])
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
    set(t(i),'Position', get(t(i),'Position')+[1.13+(mcw) 0 0]);
end
posdel1 = get(t(end),'Position');
posdel2 = get(t(end-1),'Position');
t = text(posdel1(1)+0.04,posdel1(2)+abs(posdel1(2)-posdel2(2)), ...
    '\underline{Unit Step}','interpreter','latex','Units','normalized', ...
    'HorizontalAlignment','left','FontSize',fs3);

xoff = 1.9; %[in]
yoff = 0.35; %[in]
xdist = 3.25; %[in]
ydist = 4; %[in]
set(gca,'Units','Inches','Position',[xoff yoff xdist ydist])

print(gcf,['~/Dropbox (MREL)/Research/OO-TechEc/paper_figures/' ...
    'senstable_pr'],'-dpng','-r600')



function [] = visSensSM_trio(s1,s2,s3,s0)

%merge
array(1,:) = s1;
array(2,:) = s2;
array(3,:) = s3;

n = length(s1(1).opt.tuning_array);

%set
lw = 2;

for a = 1:size(array,1)
    for r = 1:size(array,2)
        CapEx(a,r) = array(a,r).output.min.CapEx;
        OpEx(a,r) = array(a,r).output.min.OpEx;
    end
    tp{a} = array(a,1).opt.tuned_parameter;
    ta(a,:) = array(a,1).opt.tuning_array;
end

tc = s0.output.min.cost;

%purple: [.5 0 .5]

figure
for a = 1:size(array,1)
    ax(a) = subplot(3,1,a);
    plot(ta(a,:),CapEx(a,:)/tc,'r', ...
        'DisplayName','CapEx','LineWidth',lw)
    hold on
    plot(ta(a,:),OpEx(a,:)/tc,'b', ...
        'DisplayName','OpEx','LineWidth',lw)
    hold on
    plot(ta(a,:),(CapEx(a,:)+OpEx(a,:))/tc, ...
        'Color','k','DisplayName','Total','LineWidth',lw*1)
%     if ta(a,n) > 2 %not a multiplier
%         xticks([ta(a,1),round(ta(a,(4/10)*n)), ...
%             round(ta(a,(7/10)*n)),ta(a,n)]);
%     else
    %xticks([ta(a,1),ta(a,(4/10)*n),ta(a,(7/10)*n),ta(a,n)]);
    if a > 1
        title({'',''})
    end
    xticks([ta(a,1),ta(a,n)]);
    xt = xticks;
%     end
    xlim([ta(a,1) ta(a,n)])
    ylim([0 max(max(CapEx + OpEx))/tc*1.3])
    yticks([0 1])
    yticklabels({'$0k',['$' num2str(round(tc/1000),3) 'k']})
    grid on
    if isequal(array(a,1).opt.tuned_parameter,'mzm')
        %title({'Marinization','Multiplier',''})
        xticklabels({'0.5\sigma_m',['\sigma_m = ' num2str(ta(a,4))], ...
            '1.5\sigma_m','2\sigma_m'})
    elseif isequal(array(a,1).opt.tuned_parameter,'sbm')
        %title({'Spar Buoyancy','Multiplier',''})
        xticklabels({'0.5b_m',['b_m = ' num2str(ta(a,4))], ...
            '1.5b_m','2b_m'})
    elseif isequal(array(a,1).opt.tuned_parameter,'tiv')
        %title({'Unexpected','Turbine Failures',''})
        xticklabels({'0.5\lambda_{turb}',['\lambda_{turb} = ' ...
            num2str(ta(a,4))],'1.5\lambda_{turb}','2\lambda_{turb}'})
    elseif isequal(array(a,1).opt.tuned_parameter,'twf')
        %title({'Turbine','Weight Factor',''})
        xticklabels({'0.5wf_{turb}',['wf_{turb} = ' ...
            num2str(ta(a,4))],'1.5wf_{turb}','2wf_{turb}'})
    elseif isequal(array(a,1).opt.tuned_parameter,'ild')
        %title(({'Instrumentation','Load',''}))
%         xticklabels({'0.5L',['L = ' ...
%             num2str(ta(a,4))],'1.5L','2L'})
    elseif isequal(array(a,1).opt.tuned_parameter,'osv')
        %title(({'Offshore Support','Vessel Cost',''}))
        %         xticklabels({'0.5\alpha_{osv}',['\alpha_{osv} = ' ...
        %             num2str(ta(a,4))],'1.5\alpha_{osv}','2\alpha_{osv}'})
        tx = xt./1000;
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array(a,1).opt.tuned_parameter,'nbl')
        %title(({'Nominal Battery','Life-Cycle',''}))
        %         xticklabels({'0.5L_{batt}',['L_{batt} = ' ...
        %             num2str(ta(a,4))],'1.5L_{batt}','2L_{batt}'})
        xticklabels({'9','36'})
        %set(gca,'xdir','reverse')
    elseif isequal(array(a,1).opt.tuned_parameter,'sdr')
        %title(({'Battery Self-','Discharge-Rate',''}))
%         xticklabels({'0.5\Gamma',['\Gamma = ' ...
%             num2str(ta(a,4))],'1.5\Gamma','2\Gamma'})
        %xticklabels({'1.5','3.0','4.5','6.0'})
        xticklabels({'1.5%','6.0%'})
    elseif isequal(array(a,1).opt.tuned_parameter,'utp')
        %title(({'Percent','Availability',''}))
        xticklabels({'80%','100%'}) 
    elseif isequal(array(a,1).opt.tuned_parameter,'dep')
        tx = round(4589.*xt,-1);
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    elseif isequal(array(a,1).opt.tuned_parameter,'dtc')
        tx = round(9.7461e02.*xt,-1);
        xticklabels({num2str(tx(1)),num2str(tx(2))})
    end
end

set(gcf, 'Position', [0, 0, 200, 550])
set(ax,'FontSize',14)
set(ax,'LineWidth',1.1)
set(gcf,'color','w')
% hL = legend('show','location','southoutside','Orientation','horizontal');
% newPosition = [0.41 .03 0.2 0.01];
% newUnits = 'normalized';
% set(hL,'Position', newPosition,'Units', newUnits,'FontSize',16);

end

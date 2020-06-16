function [] = visSensSM_trio(s1,s2,s3,s0)

%merge
array(1,:) = s1;
array(2,:) = s2;
array(3,:) = s3;

%set
lw = 1.8;

for a = 1:size(array,1)
    for r = 1:size(array,2)
        CapEx(a,r) = array(a,r).output.min.CapEx;
        OpEx(a,r) = array(a,r).output.min.OpEx;
    end
    tp{a} = array(a,1).opt.tuned_parameter;
    ta(a,:) = array(a,1).opt.tuning_array;
end

tc = s0.output.min.cost;

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
        'Color',[.5 0 .5],'DisplayName','Total','LineWidth',lw)
    xticks([ta(a,1),ta(a,4),ta(a,7),ta(a,10)]);
    xlim([ta(a,1) ta(a,10)])
    ylim([0 max(max(CapEx + OpEx))/tc*1.1])
    yticks([0 1])
    yticklabels({'$0k',['$' num2str(round(tc/1000),3) 'k']})
    grid on
    if isequal(array(a,1).opt.tuned_parameter,'mzm')
        title({'Marinization','Multiplier',''})
        xticklabels({'0.5\sigma_m',['\sigma_m = ' num2str(ta(a,4))], ...
            '1.5\sigma_m','2\sigma_m'})
    elseif isequal(array(a,1).opt.tuned_parameter,'sbm')
        title({'Spar Buoyancy','Multiplier',''})
        xticklabels({'0.5b_m',['b_m = ' num2str(ta(a,4))], ...
            '1.5b_m','2b_m'})
    elseif isequal(array(a,1).opt.tuned_parameter,'tiv')
        title({'Unexpected','Turbine Failures',''})
        xticklabels({'0.5\lambda_{turb}',['\lambda_{turb} = ' ...
            num2str(ta(a,4))],'1.5\lambda_{turb}','2\lambda_{turb}'})
    elseif isequal(array(a,1).opt.tuned_parameter,'twf')
        title({'Turbine','Weight Factor',''})
        xticklabels({'0.5wf_{turb}',['wf_{turb} = ' ...
            num2str(ta(a,4))],'1.5wf_{turb}','2wf_{turb}'})
    elseif isequal(array(a,1).opt.tuned_parameter,'ild')
        title(({'Instrumentation','Load',''}))
        xticklabels({'0.5L',['L = ' ...
            num2str(ta(a,4))],'1.5L','2L'})
    elseif isequal(array(a,1).opt.tuned_parameter,'osv')
        title(({'Offshore Support','Vessel Cost',''}))
        xticklabels({'0.5\alpha_{osv}',['\alpha_{osv} = ' ...
            num2str(ta(a,4))],'1.5\alpha_{osv}','2\alpha_{osv}'})
    elseif isequal(array(a,1).opt.tuned_parameter,'nbl')
        title(({'Nominal Battery','Life-Cycle',''}))
        xticklabels({'0.5L_{batt}',['L_{batt} = ' ...
            num2str(ta(a,4))],'1.5L_{batt}','2L_{batt}'})
        set(gca,'xdir','reverse')
    elseif isequal(array(a,1).opt.tuned_parameter,'sdr')
        title(({'Battery Self-','Discharge-Rate',''}))
        xticklabels({'0.5\Gamma',['\Gamma = ' ...
            num2str(ta(a,4))],'1.5\Gamma','2\Gamma'})
    elseif isequal(array(a,1).opt.tuned_parameter,'utp')
        title(({'Percent','Availability',''}))
        xticklabels({'80%','87%','93%','100%'}) 
    end
end

set(gcf, 'Position', [100, 100, 300, 700])
hL = legend('show','location','southoutside','Orientation','horizontal');
newPosition = [0.41 .03 0.2 0.01];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'FontSize',16);

end

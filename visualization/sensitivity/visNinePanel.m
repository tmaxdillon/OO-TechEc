function [] = visNinePanel(s1,s2,s3,s4,s5,s6,s7,s8,s9)

%merge
panel(1,:) = s1;
panel(2,:) = s2;
panel(3,:) = s3;
panel(4,:) = s4;
panel(5,:) = s5;
panel(6,:) = s6;
panel(7,:) = s7;
panel(8,:) = s8;
panel(9,:) = s9;

%set 
lw = 1.8;

for p = 1:size(panel,1)
    for r = 1:size(panel,2)
        CapEx(p,r) = panel(p,r).output.min.CapEx;
        OpEx(p,r) = panel(p,r).output.min.OpEx;
    end
    tp{p} = panel(p,1).opt.tuned_parameter;
    ta(p,:) = panel(p,1).opt.tuning_array;
end

%type-specific settings
if panel(1,1).pm == 1 %wind
    if panel(1,1).c == 1
        o = [6 9 3 5 1 8 2 7 4];
    else
        o = [6 9 3 4 5 1 2 8 7];
    end
    tc = (CapEx(1,4) + OpEx(1,4));
end

figure
for p = 1:size(panel,1)
    ax(o(p)) = subplot(3,3,o(p));
%     a = area(ta(p,:),[OpEx(p,:);CapEx(p,:)]');
%     a(1).FaceColor = 'red';
%     a(2).FaceColor = 'blue';
    plot(ta(p,:),CapEx(p,:)/tc,'r', ...
        'DisplayName','CapEx','LineWidth',lw)
    hold on
    plot(ta(p,:),OpEx(p,:)/tc,'b', ...
        'DisplayName','OpEx','LineWidth',lw)
     hold on
    plot(ta(p,:),(CapEx(p,:)+OpEx(p,:))/tc, ...
        'Color',[.5 0 .5],'DisplayName','Total','LineWidth',lw)
    xticks([ta(p,1),ta(p,4),ta(p,7),ta(p,10)]);
    xlim([ta(p,1) ta(p,10)])
    ylim([0 max(max(CapEx + OpEx))/tc*1.1])
    yticks([0 1])
    yticklabels({'$0k',['$' num2str(round(tc/1000),3) 'k']})
    grid on
    if isequal(panel(p,1).opt.tuned_parameter,'mzm')
        title({'Marinization','Multiplier',''})
        xticklabels({'0.5\sigma_m',['\sigma_m = ' num2str(ta(p,4))], ...
            '1.5\sigma_m','2\sigma_m'})
    elseif isequal(panel(p,1).opt.tuned_parameter,'sbm')
        title({'Spar Buoyancy','Multiplier',''})
        xticklabels({'0.5b_m',['b_m = ' num2str(ta(p,4))], ...
            '1.5b_m','2b_m'})
    elseif isequal(panel(p,1).opt.tuned_parameter,'tiv')
        title({'Unexpected','Turbine Failures',''})
        xticklabels({'0.5\lambda_{turb}',['\lambda_{turb} = ' ...
            num2str(ta(p,4))],'1.5\lambda_{turb}','2\lambda_{turb}'})
    elseif isequal(panel(p,1).opt.tuned_parameter,'twf')
        title({'Turbine','Weight Factor',''})
        xticklabels({'0.5wf_{turb}',['wf_{turb} = ' ...
            num2str(ta(p,4))],'1.5wf_{turb}','2wf_{turb}'})
    elseif isequal(panel(p,1).opt.tuned_parameter,'ild')
        title(({'Instrumentation','Load',''}))
        xticklabels({'0.5L',['L = ' ...
            num2str(ta(p,4))],'1.5L','2L'})
    elseif isequal(panel(p,1).opt.tuned_parameter,'osv')
        title(({'Offshore Support','Vessel Cost',''}))
        xticklabels({'0.5\alpha_{osv}',['\alpha_{osv} = ' ...
            num2str(ta(p,4))],'1.5\alpha_{osv}','2\alpha_{osv}'})
    elseif isequal(panel(p,1).opt.tuned_parameter,'nbl')
        title(({'Nominal Battery','Life-Cycle',''}))
        xticklabels({'0.5L_{batt}',['L_{batt} = ' ...
            num2str(ta(p,4))],'1.5L_{batt}','2L_{batt}'})
        set(gca,'xdir','reverse')
    elseif isequal(panel(p,1).opt.tuned_parameter,'sdr')
        title(({'Battery Self-','Discharge-Rate',''}))
        xticklabels({'0.5\Gamma',['\Gamma = ' ...
            num2str(ta(p,4))],'1.5\Gamma','2\Gamma'})
    elseif isequal(panel(p,1).opt.tuned_parameter,'utp')
        title(({'Percent','Availability',''}))
        xticklabels({'80%','87%','93%','100%'}) 
    end
end

set(gcf, 'Position', [100, 100, 800, 700])
hL = legend('show','location','southoutside','Orientation','horizontal');
newPosition = [0.41 .03 0.2 0.01];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'FontSize',16);

end


function [] = visOoSsmOut(par,reso,S)

addpath(genpath('~/Dropbox (MREL)/MATLAB/Helper'))

if isequal(reso,'wiod')
    tr = 'Wind (Opt. Durability)';
elseif isequal(reso,'wico')
    tr = 'Wind (Conservative)';
elseif isequal(reso,'inau')
    tr = 'Solar (Automated Clean)';
elseif isequal(reso,'inhu')
    tr = 'Solar (Human Clean)';
elseif isequal(reso,'wcon')
    tr = 'Wave (Conservative)';
elseif isequal(reso,'woco')
    tr = 'Wave (Opt. Cost)';
elseif isequal(reso,'wodu')
    tr = 'Wave (Opt. Durability)';
elseif isequal(reso,'dgen')
    tr = 'Diesel';
end

%set parameter specific settings
    %wind
if isequal(par,'tiv')
    xl = 'Turbine Interventions';
elseif isequal(par,'tcm')
    xl = 'Turbine Cost Multiplier';
elseif isequal(par,'twf')
    xl = 'Turbine Weight Factor [kg/kW]';
elseif isequal(par,'cis')   
    xl = 'Cut In Speed [m/s]';
elseif isequal(par,'rsp')
    xl = 'Rated Speed [m/s]';
elseif isequal(par,'cos')
    xl = 'Cut Out Speed [m/s]';
elseif isequal(par,'tef')
    xl = 'Turbine Efficiency';
elseif isequal(par,'szo')
    xl = 'Surface Roughness [mm]';
    %inso
elseif isequal(par,'pvd')
    xl = 'Panel Degradation [%/year]';
elseif isequal(par,'pcm')
    xl = 'PV System Cost Multiplier';
elseif isequal(par,'pwf')
    xl = 'Panel Weight Factor [kg/m^3]';
elseif isequal(par,'pve')
    xl = 'PV Efficiency';
    %wave
elseif isequal(par,'wiv')
    xl = 'WEC Interventions';
elseif isequal(par,'wcm')
    xl = 'WEC Cost Multiplier';
elseif isequal(par,'whl')
    xl = 'WEC Hotel Load [% of Gr]';
elseif isequal(par,'ect')
    xl = 'Electrical Efficiency';
    %dies
elseif isequal(par,'giv')
    xl = 'Generator Interventions';
elseif isequal(par,'fco')
    xl = 'Fuel Cost [$/L]';
elseif isequal(par,'fca')
    xl = 'Fuel Capacity [L]';
elseif isequal(par,'fsl')
    xl = 'Fuel Shelf Life [mo]';
elseif isequal(par,'oci')
    xl = 'Oil Change Interval [hours]';
elseif isequal(par,'gcm')
    xl = 'Generator Cost Multiplier';
    %all
elseif isequal(par,'lft')
    xl = 'Lifetime [years]';
elseif isequal(par,'dtc')
    xl = 'Distance To Coast [km]';
elseif isequal(par,'osv')
    xl = 'Offshore Support Vessel Cost [$/day]';
elseif isequal(par,'spv')
    xl = 'Specialized Vessel Cost [$/day]';
elseif isequal(par,'tmt')
    xl = 'Time on Site for Maintenance [h]';
elseif isequal(par,'eol')
    xl = 'Battery End of Life [%]';
elseif isequal(par,'dep')
    xl = 'Water Depth [m]';
elseif isequal(par,'bcc')
    xl = 'Battery Cell Cost [$/kWh]';
elseif isequal(par,'bhc')
    xl = 'Battery Housing Cost Multiplier';
elseif isequal(par,'utp')
    xl = 'Uptime Percent [%]';
elseif isequal(par,'ild')
    xl = 'Instrumentation Load [W]';
elseif isequal(par,'sdr')
    xl = 'Self Discharge Rate [%/month]';
elseif isequal(par,'pmm')
    xl = 'Barge Material Multiplier';
end

%unpack data structure
for uc = 1:2
    for l = 1:3
        for i = 1:10
            C(l,uc,i) = S(l,uc).(par)(i).output.min.cost;
        end
        co(l,uc) = S(l,uc).s0.output.min.cost;
    end
end
ta = S(l,uc).(par)(i).opt.tuning_array;

%plot settings
loc = {'argBasin','cosEndurance','irmSea'};

% for a = 1:size(array,1)
%     for r = 1:size(array,2)
%         CapEx(a,r) = array(a,r).output.min.CapEx;
%         OpEx(a,r) = array(a,r).output.min.OpEx;
%     end
%     tp{a} = array(a,1).par;
%     ta(a,:) = array(a,1).opt.tuning_array;
% end
% 
% tc = s0.output.min.cost;

%purple: [.5 0 .5]

figure
set(gcf,'color','w')
ax(1) = subplot(1,2,1);
for l = 1:3
    plot(ta,squeeze(C(l,1,:))/co(l,1),'DisplayName',loc{l})
    hold on
end
xlabel(xl)
ylabel('Cost [%]')
ylim([.25 1.5])
set(ax(1),'FontSize',14)
set(ax(1),'LineWidth',1.1)
legend('show','location','southoutside')
title({tr,'short-term'})
grid on
ax(2) = subplot(1,2,2);
for l = 1:3
    plot(ta,squeeze(C(l,2,:))/co(l,2),'DisplayName',loc{l})
    hold on
end
xlabel(xl)
ylabel('Cost [%]')
ylim([.25 1.5])
set(ax(2),'FontSize',14)
set(ax(2),'LineWidth',1.1)
legend('show','location','southoutside')
title({tr,'long-term'})
grid on
% hL = legend('show','location','southoutside','Orientation','horizontal');
% newPosition = [0.41 .03 0.2 0.01];
% newUnits = 'normalized';
% set(hL,'Position', newPosition,'Units', newUnits,'FontSize',16);

end

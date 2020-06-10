function [] = visPowerCurve(turb)

rho = 1.225;

u = linspace(0,25,5000);

P = zeros(length(u),1);

for i=1:length(u)
    if u(i) < turb.uci
        P(i) = 0;
    elseif u(i) < turb.ura
        P(i) = (1/2)*turb.eta*rho*u(i)^3;
    elseif u(i) < turb.uco
        P(i) = (1/2)*turb.eta*rho*turb.ura^3;
    end
end

figure
plot(u,P,'Color',[0 204 0]/256,'LineWidth',2.5)
xlabel('Wind Speed [m/s]')
ylabel({'Available','Power [W/m^2]'})
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', ...
    'HorizontalAlignment','center')
set(gca,'FontSize',22)
set(gca,'LineWidth',1.5)
ylim([0 1.15*max(P)])
grid on

set(gcf, 'Position', [850, 100, 1000, 300])

end


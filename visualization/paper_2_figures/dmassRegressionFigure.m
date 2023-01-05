set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

clearvars -except xf yf xlab ylab legendname alphavar x y n p xlimmax
if ~exist('xf','var')
    type = 'dieselmass';
    n = 1;
    xmax = 22; %[kw]
    if isequal(type,'turbine')
        xf = 0:0.01:xmax; %kW
        xlab = 'Rated Power [kW]';
        legendname = 'Turbines';
        alphavar = '\alpha_{wind}';
        turbineLibrary
        x = zeros(1,length(turbineLib));
        y = zeros(1,length(turbineLib));
        %unpack into arrays
        for i = 1:length(turbineLib)
            x(i) = turbineLib(i).kW;
            %y(i) = turbineLib(i).cost/turbineLib(i).kW;
            y(i) = turbineLib(i).cost;
        end
        %ylab = '[$1000/kW]';
        ylab = {'Market','Cost','[$1000s]'};
    elseif isequal(type,'agm') || isequal(type,'lfp')
        xf = 0:0.01:xmax; %kWh
        xlab = 'Storage Capacity [kWh]';
        if isequal(type,'agm')
            batteryLibrary_agm
        else
            batteryLibrary_lfp
        end
        x = zeros(1,length(batteryLib));
        y = zeros(1,length(batteryLib));
        %unpack into arrays
        for i = 1:length(batteryLib)
            x(i) = batteryLib(i).kWh;
            y(i) = batteryLib(i).cost/batteryLib(i).kWh;
            y(i) = batteryLib(i).cost;
        end
        %ylab = '[$/kWh]';
        ylab = '[$]';
    elseif isequal(type,'dieselcost')
        xf = 0:0.01:xmax; %kW
        xlab = 'Rated Power [kW]';
        xlimmax = 22;
        legendname = 'Generators';
        alphavar = '\alpha_{dgen}';
        dieselLibrary
        x = zeros(1,length(diesLib));
        y = zeros(1,length(diesLib));
        %unpack into arrays
        for i = 1:length(diesLib)
            x(i) = diesLib(i).kW;
            y(i) = diesLib(i).cost;
        end
        ylab = '[$]';
    elseif isequal(type,'dieselmass')
        xf = 0:0.01:xmax; %kW
        xlab = 'Rated Power [kW]';
        xlimmax = 22;
        legendname = 'Generators';
        alphavar = 'Mass';
        dieselLibrary
        dieselLibrary
        x = zeros(1,length(diesLib));
        y = zeros(1,length(diesLib));
        %unpack into arrays
        for i = 1:length(diesLib)
            x(i) = diesLib(i).kW;
            y(i) = diesLib(i).m;
        end
        ylab = '[kg]';
    elseif isequal(type,'dieselsize')
        xf = 0:0.01:xmax; %kW
        xlab = 'Rated Power [kW]';
        xlimmax = 22;
        legendname = 'Generators';
        alphavar = 'Volume';
        dieselLibrary
        x = zeros(1,length(diesLib));
        y = zeros(1,length(diesLib));
        %unpack into arrays
        for i = 1:length(diesLib)
            x(i) = diesLib(i).kW;
            y(i) = diesLib(i).d.^3;
        end
        ylab = '[m^3]';
    elseif isequal(type,'dieselburn')
        xf = 0:0.01:xmax; %kW
        xlab = 'Rated Power [kW]';
        dieselLibrary
        x = zeros(1,length(diesLib));
        y = zeros(1,length(diesLib));
        %unpack into arrays
        for i = 1:length(diesLib)
            x(i) = diesLib(i).kW;
            y(i) = diesLib(i).c;
        end
        ylab = '[l/h]';
    end
    
    yf = zeros(length(xf),length(n));
    p = zeros(max(n)+1,length(n));
    for j=1:length(n)
        for i = 1:length(xf)
            [~,yf(i,j)] = calcDeviceVal(type,xf(i),n(j));
        end
        p(1:n(j)+1,j) = calcDeviceVal(type,[],n(j)); %store polyvals
    end
end

%color = ['b','r'];

reg = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [1, 1, 3, 1.5])
blue = [70, 190, 234]/256;
ms = 50;
lw = 1.7;
lw2 = 1.3;
fs = 9;
xshrink = .9;
rshift = .125;
for j=1:length(n)
    %     h(j) = plot(xf,yf(:,j)./(xf*1000)',color(j),'DisplayName',[num2str(n(j)) ...
    %         ' order polynomial fit'],'LineWidth',1.4); % $1000/x by x
    %boundedline(x,y,delta,'alpha','transparency',.1)
    h(j) = plot(xf,yf(:,j),'Color',blue,'DisplayName', ...
        ['Trend'], ...
        'LineWidth',lw); % $1000/x by x
    hold on
end
hold on
h(j+1) = scatter(x,y,ms,'.','k','DisplayName',legendname);
ylabel(ylab)
xlabel(xlab)
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
ylabpos = get(ylh,'Position');
ylabpos(1) = -.225;
set(ylh,'Position',ylabpos)
ylim([0 inf])
xlim([0 xlimmax])
set(gca,'FontSize',fs)
set(gca,'LineWidth',lw2)
%adjust axis
axpos(:) = get(gca,'Position');
axpos(1) = axpos(1)+rshift;
axpos(3) = xshrink*axpos(3);
set(gca,'Position',axpos)
% set(gca,'xticklabel',num2str(get(gca,'xtick')','%.1f'))
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%d'))
leg = legend(h);
set(leg,'Position',[.65 .35 .01 .01])
grid on

print(reg,['~/Dropbox (MREL)/Research/OO-TechEc/wave-comparison/' ...
    'paper_figures/dmassreg'],'-dpng','-r600')
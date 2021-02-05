function [] = visWSCWR_surf(struct,data)

%constants
rho = 1020; %[kg/m^3]
g = 9.81;   %[m/s^2]
%lw = 1.8;   %line width

%extract Hs and Tp
Hs = unique(struct(1).H);
DH = Hs(2) - Hs(1);
Tp = unique(struct(1).T);
DT = Tp(2) - Tp(1);
%Hs_avg = round(mean(Hs));
%Hs_avg_ind = find(Hs == Hs_avg);

%preallocate
CWR = zeros(length(Hs),length(Tp));
ODC = zeros(length(Hs),length(Tp));
CWR_comp = zeros(length(Hs),length(Tp),length(struct));
%CWR_interp = zeros(length(Hs),1000);

%compute CWP
if length(struct) > 1 %multiple damping coefficients
    for i = 1:length(Hs)
        for j = 1:length(Tp)
            J = (1/(64*pi))*rho*g^2*Hs(i)^2*Tp(j);
            for d = 1:length(struct)
                CWR_comp(i,j,d) = 100*struct(d).mat(i,j)/(J*struct(d).B);
            end
            [CWR(i,j),ODC(i,j)] = max(CWR_comp(i,j,:)); %find optimal dc
            B = struct.B;
            P(i,j) = CWR(i,j)*J*B*(1/100);
        end
    end
else %one damping coefficient
    for i = 1:length(Hs)
        for j = 1:length(Tp)
            J = (1/(64*pi))*rho*g^2*Hs(i)^2*Tp(j);
            CWR(i,j) = struct.mat(i,j)/(J*struct.B);
            P(i,j) = struct.mat(i,j)/1000;
        end
    end
end

%colors
%col = brewermap(length(Hs)*2,'Reds');
%colbuff = 10;
%col(colbuff+Hs_avg_ind,:) = [0 0 0];

%find jpd and clear values
jpd = getJPD(data,Hs,Tp);
CWP_trim = CWR;
CWP_trim(jpd <= prctile(jpd(:),00)) = nan;

%annotations
CWP_a = CWR(1:end-1,1:end-1);
tS = num2str(round(CWP_a(:),2,'decimal'),'%0.2f'); %create cwr strings
tS = strtrim(cellstr(tS)); %remove any space padding
CWP_a_t = CWP_trim(1:end-1,1:end-1);
tS_trim = num2str(round(CWP_a_t(:),2,'decimal'),'%0.2f');
tS_trim = strtrim(cellstr(tS_trim));
ODC_a = ODC(1:end-1,1:end-1);
tS_odc = num2str(round(ODC_a(:),2,'decimal'),'%0.2f'); %create cwr strings
tS_odc = strtrim(cellstr(tS_odc));
P_a = P(1:end-1,1:end-1);
tP = num2str(round(P_a(:),2,'decimal'),'%0.2f'); %create cwr strings
tP = strtrim(cellstr(tP)); %remove any space padding

figure
for i = 1:2
    if i == 1
        sf = CWR;
        ann = tS;
        ttl = 'Capture Width Ratio at All Sea States';
    else
        sf = CWP_trim;
        ann = tS_trim;
        ttl = 'Capture Width Ratio at Occurring Sea States';
    end
    
    %%interpolated surface
    %Hs_res = linspace(min(Hs),max(Hs),1000);
    %Tp_res = linspace(min(Tp),max(Tp),1000);
    %[Tpg,Hsg] = meshgrid(Tp_res,Hs_res);
    %CWP_surf = griddata(Tp,Hs,sf,Tpg,Hsg,'cubic');
    
    ax(i) = subplot(2,1,i);
    s = pcolor(Tp,Hs,sf);
    hold on
    [x,y] = meshgrid(Tp(1:end-1)+DT/2,Hs(1:end-1)+DH/2); % x and y coordinates for  strings
    hStrings = text(x(:),y(:),ann(:), ...
        'HorizontalAlignment','center'); %plot strings
    set(hStrings,'Color','white')
    set(hStrings,'FontSize',12)
    %ct = contour(Tp,Hs,sf,'Color','white');
    s.EdgeColor = 'none';
    %colormap(brewermap(20,'spectral'))
    cmap = colormap(ax(i),'bone');
    colormap(ax(i),cmap(1:220,:))
    c = colorbar;
    c.Label.String = 'CWR';
    ylabel('Hs [m]')
    xlabel('Tp [s]')
    title(ttl)
    zlim([0 1.1*max(CWR(:))])
    caxis([0 1.1*max(CWR(:))])
    set(gca,'FontSize',13)
end

set(gcf, 'Position', [100, 100, 600, 800])
linkaxes(ax,'xy')

% figure
% s = pcolor(Tp,Hs,P);
% hold on
% [x,y] = meshgrid(Tp(1:end-1)+DT/2,Hs(1:end-1)+DH/2); % x and y coordinates for  strings
% hStrings = text(x(:),y(:),tP(:), ...
%     'HorizontalAlignment','center'); %plot strings
% set(hStrings,'Color','black')
% set(hStrings,'FontSize',8)
% %ct = contour(Tp,Hs,sf,'Color','white');
% s.EdgeColor = 'none';
% %colormap(brewermap(20,'spectral'))
% cmap = colormap('magma');
% colormap(ax(i),cmap(30:end,:))
% c = colorbar;
% c.Label.String = 'Power [kW]';
% ylabel('Hs [m]')
% xlabel('Tp [s]')
% title(ttl)
% zlim([0 1.1*max(CWP(:))])
% caxis([0 1.1*max(CWP(:))])

if length(struct) > 1 %multiple damping coefficients
    figure
    s2 = pcolor(Tp,Hs,ODC);
    hold on
    [x,y] = meshgrid(Tp(1:end-1)+DT/2,Hs(1:end-1)+DH/2); % x and y coordinates for  strings
    hStrings = text(x(:),y(:),tS_odc(:), ...
        'HorizontalAlignment','center'); %plot strings
    set(hStrings,'Color','black')
    set(hStrings,'FontSize',8)
    %ct = contour(Tp,Hs,sf,'Color','white');
    s2.EdgeColor = 'none';
    %colormap(brewermap(20,'spectral'))
    colormap(brewermap(5,'reds'));
    c = colorbar;
    c.Label.String = 'Optimal Damping Coefficient';
    ylabel('Hs [m]')
    xlabel('Tp [s]')
    set(gca,'FontSize',13)
end


% %interpolate
% for i = 1:length(Hs)
%     CWR_interp(i,:) = interp1(Tp,CWR(i,:), ...
%         linspace(min(Tp),max(Tp),1000),'spline');
% end

% figure
% subplot(2,1,1)
% for i = 1:length(Hs)
%     if i == Hs_avg_ind
%         lw = lw*2;
%     end
%     plot(Tp,CWR(i,:),'Color',col(colbuff+i,:),'DisplayName', ...
%         ['Hs = ' num2str(Hs(i))],'LineWidth',lw);
%     if i == Hs_avg_ind
%         lw = lw/2;
%     end
%     ylabel('CWR')
%     xlabel('Tp')
%     hold on
%     grid on
% end
% legend('show','location','northeast')
% title('raw')
% subplot(2,1,2)
% for i = 1:length(Hs)
%     if i == Hs_avg_ind
%         lw = lw*2;
%     end
%     plot(linspace(min(Tp),max(Tp),1000),CWR_interp(i,:), ...
%         'Color',col(colbuff+i,:),'DisplayName', ...
%         ['Hs = ' num2str(Hs(i))],'LineWidth',lw);
%     if i == Hs_avg_ind
%         lw = lw/2;
%     end
%     ylabel('CWR')
%     xlabel('Tp')
%     hold on
%     grid on
% end
% title('interpolated')
% legend('show','location','northeast')
% set(gcf, 'Position', [100, 100, 700, 850])

end


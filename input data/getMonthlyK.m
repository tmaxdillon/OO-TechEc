function [K_avg] = getMonthlyK(dataStruct,type)

%%%%%%%%%%% SET VALUES %%%%%%%%%%%%%%

pts = 1:length(dataStruct.met.time);

time = dataStruct.met.time(pts);
wind = dataStruct.met.wind_spd(pts);
inso = dataStruct.met.shortwave_irradiance(pts);
if ~isfield(dataStruct, 'wave')
    hs = zeros(length(time),1);
    tp = zeros(length(time),1);
else
    hs = dataStruct.wave.significant_wave_height(pts);
    tp = dataStruct.wave.peak_wave_period(pts);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isequal(type,'wave')
    dvall = datevec(time);
    dvymu = unique(dvall(:,1:2),'rows');
    K_avg = zeros(length(dvymu),2);
    K_avg(:,1) = datenum(num2str(dvymu(:,1:2)));
    rho = 1020; %[kg/m^3]
    g = 9.81; %[m/s^2]
    K = (1/(16*4*pi))*rho*g^2.*hs(:).^2 ...
        .*tp(:);
    for i = 1:length(dvymu)
        pts = find(dvall(:,1) == dvymu(i,1) & ...
            dvall(:,2) == dvymu(i,2));
        K_avg(i,2) = nanmean(K(pts));
    end
end

if isequal(type,'wind')
    dvall = datevec(time);
    dvymu = unique(dvall(:,1:2),'rows');
    K_avg = zeros(length(dvymu),2);
    K_avg(:,1) = datenum(num2str(dvymu(:,1:2)));
    rho = 1; %[kg/m^3]
    K = (1/2)*rho.*wind.^3;
    for i = 1:length(dvymu)
        pts = find(dvall(:,1) == dvymu(i,1) & ...
            dvall(:,2) == dvymu(i,2));
        K_avg(i,2) = nanmean(K(pts));
    end
end

if isequal(type,'inso')
    dvall = datevec(dataStruct.met.time);
    dvymu = unique(dvall(:,1:2),'rows');
    K_avg = zeros(length(dvymu),2);
    K_avg(:,1) = datenum(num2str(dvymu(:,1:2)));
    K = inso;
    for i = 1:length(dvymu)
        pts = find(dvall(:,1) == dvymu(i,1) & ...
            dvall(:,2) == dvymu(i,2));
        K_avg(i,2) = nanmean(K(pts));
    end
end
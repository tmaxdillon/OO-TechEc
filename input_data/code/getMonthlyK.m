function [K_avg] = getMonthlyK(dataStruct,type)

%%%%%%%%%%% SET VALUES %%%%%%%%%%%%%%

met_pts = 1:length(dataStruct.met.time);
wave_pts = 1:length(dataStruct.wave.time);
met_time = dataStruct.met.time(met_pts);
wave_time = dataStruct.wave.time(wave_pts);
wind = dataStruct.met.wind_spd(met_pts);
inso = dataStruct.met.shortwave_irradiance(met_pts);
hs = dataStruct.wave.significant_wave_height(wave_pts);
tp = dataStruct.wave.peak_wave_period(wave_pts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isequal(type,'wave')
    dvall = datevec(wave_time);
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
    dvall = datevec(met_time);
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
function [K_ts] = getPowerDensity(dataStruct,type)

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
    K_ts(:,1) = wave_time;
    rho = 1020; %[kg/m^3]
    g = 9.81; %[m/s^2]
    K_ts(:,2) = (1/(16*4*pi))*rho*g^2.*hs(:).^2.*tp(:);
end

if isequal(type,'wind')
    K_ts(:,1) = met_time;
    rho = 1.225; %[kg/m^3]
    K_ts(:,2) = (1/2)*rho.*wind.^3;
end

if isequal(type,'inso')
    K_ts(:,1) = met_time;
    K_ts(:,2) = inso;
end
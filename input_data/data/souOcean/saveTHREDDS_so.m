%created by Trent Dillon on Monday June 17 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% CONSTANTS

souOcean.title = 'Southern Ocean';
souOcean.lat = -54.40717;
souOcean.lon = -89.20604;
souOcean.depth = 4589; %[m]
souOcean.dist = dist_from_coast(souOcean.lat, ...
    souOcean.lon,'great_circle'); %[m]

%% WAVE: set up filenames

%recovered host, dcl statistics
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T045459464Z-GS01SUMO-SBD12-05-WAVSSA000-recovered_host-wavss_a_dcl_statistics_recovered/';
deppath(1,:) = 'deployment0001_GS01SUMO-SBD12-05-WAVSSA000-recovered_host-wavss_a_dcl_statistics_recovered_20150721T012303.052000-20151227T102305.686000.nc';
deppath(2,:) = 'deployment0002_GS01SUMO-SBD12-05-WAVSSA000-recovered_host-wavss_a_dcl_statistics_recovered_20151214T210737.792000-20161212T070740.217000.nc';
deppath(3,:) = 'deployment0003_GS01SUMO-SBD12-05-WAVSSA000-recovered_host-wavss_a_dcl_statistics_recovered_20161125T020749.472000-20181209T162316.234000.nc';
deppath(4,:) = 'deployment0004_GS01SUMO-SBD12-05-WAVSSA000-recovered_host-wavss_a_dcl_statistics_recovered_20181204T172301.964000-20200120T092312.860000.nc';

wave_filenames = cell(1,size(deppath,1));
for i = 1:length(wave_filenames)
    wave_filenames{i} = [threddspath deppath(i,:)];
end

clear i deppath threddspath

vars = {'time' 'deployment' 'significant_wave_height' 'peak_wave_period'};

%% WAVE: read vars into data structure

%base time
Y = 1900;
M = 1;
D = 1;
H = 0;
MI = 0;
S = 0;

for v = 1:length(vars)
    souOcean.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        souOcean.wave.(vars{v}) = [souOcean.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        souOcean.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + souOcean.wave.(vars{v}));
    end
%     %collapse lat/lon
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(cosPioneer.wave.(vars{v}) - cosPioneer.wave.(vars{v})(1))
%             cosPioneer.wave.(vars{v}) = cosPioneer.wave.(vars{v})(1);
%         end
%     end
end

temp_wave = datevec(souOcean.wave.time);

clear Y M D H MI S v i wave_filenames vars temp opendap

%% WAVE: additional structure adjustments

%remove outliers by setting to mean
souOcean.wave.peak_wave_period_orig = souOcean.wave.peak_wave_period;
souOcean.wave.peak_wave_period(souOcean.wave.peak_wave_period > 22) = ...
    mean(souOcean.wave.peak_wave_period);

%% MET: set up filenames

%telemetered, metbk hourly
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T052222627Z-GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0001_GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20151124T070237.970000-20151222T182906.239000.nc';
deppath(2,:) = 'deployment0002_GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20151214T205021.824000-20161128T065659.929000.nc';
deppath(3,:) = 'deployment0003_GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20161125T014201.966000-20180709T192951.873000.nc';

met_filenames = cell(1,size(deppath,1));
for i = 1:length(met_filenames)
    met_filenames{i} = [threddspath deppath(i,:)];
end

clear i deppath threddspath

vars = {'time' 'deployment' 'met_wind10m' 'shortwave_irradiance'};

%% MET: read vars into data structure

%base time
Y = 1900;
M = 1;
D = 1;
H = 0;
MI = 0;
S = 0;

for v = 1:length(vars)
    souOcean.met.(vars{v}) = [];
    for i = 1:length(met_filenames)
        temp = ncread([opendap met_filenames{i}],vars{v});
        souOcean.met.(vars{v}) = [souOcean.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        souOcean.met.(vars{v}) = datenum(Y,M,D,H,MI,S + souOcean.met.(vars{v}));
    end
    %collapse lat/lon
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(cosPioneer.met.(vars{v}) - cosPioneer.met.(vars{v})(1))
%             cosPioneer.met.(vars{v}) = cosPioneer.met.(vars{v})(1);
%         end
%     end
end

temp_met = datevec(souOcean.met.time);

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

souOcean.met.time_orig = souOcean.met.time;
souOcean.met.shortwave_irradiance_orig = souOcean.met.shortwave_irradiance;
souOcean.met.wind_spd_orig = souOcean.met.met_wind10m;
souOcean.met.wind_ht_orig = 10;

%adjust time window and interpolate over outages
[~,souOcean.met.tstart] = min(abs(souOcean.met.time_orig - ...
    datenum('15-Dec-2015 10:02:37.97')));
[~,souOcean.met.tend] = min(abs(souOcean.met.time_orig - ...
    datenum('07-Jul-2018 03:29:33')));
%time
souOcean.met.time = ...
    souOcean.met.time_orig(souOcean.met.tstart:souOcean.met.tend);
%irradiance
souOcean.met.shortwave_irradiance = ...
    souOcean.met.shortwave_irradiance_orig(souOcean.met.tstart: ...
    souOcean.met.tend);
souOcean.met.shortwave_irradiance(souOcean.met.shortwave_irradiance < 0) = 0;
%wind
souOcean.met.wind_spd = ...
    fillmissing(souOcean.met.wind_spd_orig(souOcean.met.tstart: ...
    souOcean.met.tend),'linear');

%adjust height
souOcean.met.wind_ht = 4;
souOcean.met.zo = 0.2;
souOcean.met.type = 'log';
for i = 1:length(souOcean.met.wind_spd)
    souOcean.met.wind_spd(i) = adjustHeight(souOcean.met.wind_spd(i), ... 
        souOcean.met.wind_ht_orig,souOcean.met.wind_ht,souOcean.met.type,... 
        souOcean.met.zo);
end

clear i

%% EXAMINE

figure
plot(souOcean.wave.peak_wave_period)
figure
plot(souOcean.wave.significant_wave_height)
figure
plot(souOcean.wave.time)

figure
plot(souOcean.met.wind_spd)
figure
plot(souOcean.met.shortwave_irradiance)
figure
plot(souOcean.met.time)










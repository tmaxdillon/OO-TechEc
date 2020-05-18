%created by Trent Dillon on Monday June 17 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% CONSTANTS

irmSea.title = 'Irminger Sea';
irmSea.lat = 59.93370;
irmSea.lon = -39.47378;
irmSea.depth = 2685; %[m]
irmSea.dist = dist_from_coast(irmSea.lat, ...
    irmSea.lon,'great_circle'); %[m]

%% WAVE: set up filenames

%recovered host, dcl statistics
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T051120125Z-GI01SUMO-SBD12-05-WAVSSA000-recovered_host-wavss_a_dcl_statistics_recovered/';
deppath(1,:) = 'deployment0001_GI01SUMO-SBD12-05-WAVSSA000-recovered_host-wavss_a_dcl_statistics_recovered_20140910T202306.751000-20150325T182312.809000.nc';

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
    irmSea.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        irmSea.wave.(vars{v}) = [irmSea.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        irmSea.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + irmSea.wave.(vars{v}));
    end
%     %collapse lat/lon
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(cosPioneer.wave.(vars{v}) - cosPioneer.wave.(vars{v})(1))
%             cosPioneer.wave.(vars{v}) = cosPioneer.wave.(vars{v})(1);
%         end
%     end
end

temp_wave = datevec(irmSea.wave.time);

clear Y M D H MI S v i wave_filenames vars temp opendap

%% WAVE: additional structure adjustments

%none apply for this location

%% MET: set up filenames

%telemetered, metbk hourly
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T044511502Z-GI01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0005_GI01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20180608T175109.234000-20190628T152920.840000.nc';

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
    irmSea.met.(vars{v}) = [];
    for i = 1:length(met_filenames)
        temp = ncread([opendap met_filenames{i}],vars{v});
        irmSea.met.(vars{v}) = [irmSea.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        irmSea.met.(vars{v}) = datenum(Y,M,D,H,MI,S + irmSea.met.(vars{v}));
    end
    %collapse lat/lon
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(cosPioneer.met.(vars{v}) - cosPioneer.met.(vars{v})(1))
%             cosPioneer.met.(vars{v}) = cosPioneer.met.(vars{v})(1);
%         end
%     end
end

temp_met = datevec(irmSea.met.time);

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

irmSea.met.time_orig = irmSea.met.time;
irmSea.met.shortwave_irradiance_orig = irmSea.met.shortwave_irradiance;
irmSea.met.wind_spd_orig = irmSea.met.met_wind10m;
irmSea.met.wind_ht_orig = 10;

%adjust time window and interpolate over outages
[~,irmSea.met.tstart] = min(abs(irmSea.met.time_orig - ...
    datenum('08-Jun-2018 17:51:9')));
[~,irmSea.met.tend] = min(abs(irmSea.met.time_orig - ...
    datenum('20-Jun-2019 13:29:14')));
%time
irmSea.met.time = ...
    irmSea.met.time_orig(irmSea.met.tstart:irmSea.met.tend);
%irradiance
irmSea.met.shortwave_irradiance = ...
    irmSea.met.shortwave_irradiance_orig(irmSea.met.tstart: ...
    irmSea.met.tend);
%wind
irmSea.met.wind_spd = ...
    fillmissing(irmSea.met.wind_spd_orig(irmSea.met.tstart: ...
    irmSea.met.tend),'linear');

%adjust height
irmSea.met.wind_ht = 4;
irmSea.met.zo = 0.2;
irmSea.met.type = 'log';
for i = 1:length(irmSea.met.wind_spd)
    irmSea.met.wind_spd(i) = adjustHeight(irmSea.met.wind_spd(i), ... 
        irmSea.met.wind_ht_orig,irmSea.met.wind_ht,irmSea.met.type,... 
        irmSea.met.zo);
end

clear i

%% EXAMINE

figure
plot(irmSea.wave.peak_wave_period)
figure
plot(irmSea.wave.significant_wave_height)
figure
plot(irmSea.wave.time)

figure
plot(irmSea.met.wind_spd)
figure
plot(irmSea.met.shortwave_irradiance)
figure
plot(irmSea.met.time)










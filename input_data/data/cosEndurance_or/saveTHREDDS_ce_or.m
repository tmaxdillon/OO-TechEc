%created by Trent Dillon on Tuesday July 30 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% CONSTANTS

cosEndurance_or.title = 'Coastal Endurance, Oregon';
cosEndurance_or.lat = 44.38177;
cosEndurance_or.lon = -124.94973;
cosEndurance_or.depth = 575; %[m]
cosEndurance_or.dist = dist_from_coast(cosEndurance_or.lat, ...
    cosEndurance_or.lon,'great_circle'); %[m]

%% WAVE: set up filenames

%telemetered, dcl statistics
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200513T212813730Z-CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics/';
deppath(1,:) = 'deployment0001_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20150407T232300.957000-20160509T112309.426000.nc';
deppath(2,:) = 'deployment0002_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20160516T062302.976000-20161001T142304.052000.nc';
deppath(3,:) = 'deployment0003_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20161001T022310.917000-20170421T122309.017000.nc';
deppath(4,:) = 'deployment0004_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20170421T032302.867000-20171013T142304.218000.nc';
deppath(5,:) = 'deployment0005_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20171012T002259.532000-20180403T182301.189000.nc';
deppath(6,:) = 'deployment0006_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20180403T202259.176000-20180927T175304.220000.nc';
deppath(7,:) = 'deployment0007_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20180927T172301.437000-20190420T195307.041000.nc';
deppath(8,:) = 'deployment0008_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20190420T202303.692000-20191021T182303.742000.nc';
deppath(9,:) = 'deployment0009_CE04OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20191021T182300.786000-20200513T162304.322000.nc';

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
    cosEndurance_or.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        cosEndurance_or.wave.(vars{v}) = [cosEndurance_or.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosEndurance_or.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + cosEndurance_or.wave.(vars{v}));
    end
%     %collapse lat/lon - if included in opendap
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(cosEndurance_or.wave.(vars{v}) - cosEndurance_or.wave.(vars{v})(1))
%             cosEndurance_or.wave.(vars{v}) = cosEndurance_or.wave.(vars{v})(1);
%         end
%     end
end

temp_wave = datevec(cosEndurance_or.wave.time);

clear Y M D H MI S v i wave_filenames vars temp opendap

%% WAVE: additional structure adjustments

cosEndurance_or.wave.time_orig = cosEndurance_or.wave.time;
cosEndurance_or.wave.peak_wave_period_orig = cosEndurance_or.wave.peak_wave_period;
cosEndurance_or.wave.significant_wave_height_orig = cosEndurance_or.wave.significant_wave_height;

%adjust time window
[~,cosEndurance_or.wave.tstart] = min(abs(cosEndurance_or.wave.time - ...
    datenum('07-Apr-2015 23:23:0.967')));
[~,cosEndurance_or.wave.tend] = min(abs(cosEndurance_or.wave.time - ...
    datenum('03-Aug-2018 18:23:1.6')));

%adjust time span
cosEndurance_or.wave.time = ...
    cosEndurance_or.wave.time_orig(cosEndurance_or.wave.tstart:cosEndurance_or.wave.tend);
cosEndurance_or.wave.peak_wave_period = ...
    cosEndurance_or.wave.peak_wave_period(cosEndurance_or.wave.tstart:cosEndurance_or.wave.tend);
cosEndurance_or.wave.significant_wave_height = ...
    cosEndurance_or.wave.significant_wave_height(cosEndurance_or.wave.tstart:cosEndurance_or.wave.tend);

%% MET: set up filenames

%telemetered, metbk hourly
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T024851845Z-CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0001_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20150407T233006.002000-20151223T195828.092000.nc';
deppath(2,:) = 'deployment0002_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20160516T054050.293000-20161001T152914.044000.nc';
deppath(3,:) = 'deployment0003_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20161001T015240.859000-20170421T122944.593000.nc';
deppath(4,:) = 'deployment0004_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20170421T025518.003000-20171013T143029.823000.nc';
deppath(5,:) = 'deployment0005_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20171012T001120.099000-20171114T124834.712000.nc';
deppath(6,:) = 'deployment0006_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20180403T185639.427000-20180927T180431.417000.nc';
deppath(7,:) = 'deployment0007_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20180927T175244.573000-20190420T202932.393000.nc';
deppath(8,:) = 'deployment0008_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20190420T204352.071000-20191021T182918.377000.nc';
deppath(9,:) = 'deployment0009_CE04OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20191021T181040.196000-20200513T182953.087000.nc';

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
    cosEndurance_or.met.(vars{v}) = [];
    for i = 1:length(met_filenames)
        temp = ncread([opendap met_filenames{i}],vars{v});
        cosEndurance_or.met.(vars{v}) = [cosEndurance_or.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosEndurance_or.met.(vars{v}) = datenum(Y,M,D,H,MI,S + cosEndurance_or.met.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(cosEndurance_or.met.(vars{v}) - cosEndurance_or.met.(vars{v})(1))
            cosEndurance_or.met.(vars{v}) = cosEndurance_or.met.(vars{v})(1);
        end
    end
end

temp_met = datevec(cosEndurance_or.met.time);

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

cosEndurance_or.met.time_orig = cosEndurance_or.met.time;
cosEndurance_or.met.shortwave_irradiance_orig = cosEndurance_or.met.shortwave_irradiance;
cosEndurance_or.met.wind_spd_orig = cosEndurance_or.met.met_wind10m;
cosEndurance_or.met.wind_ht_orig = 10;
cosEndurance_or.title = 'Coastal Endurance';

%adjust time window and interpolate over outages
[~,cosEndurance_or.met.tstart] = min(abs(cosEndurance_or.met.time_orig - ...
    datenum('03-Apr-2018 18:56:39.4')));
[~,cosEndurance_or.met.tend] = min(abs(cosEndurance_or.met.time_orig - ...
    datenum('13-May-2020 18:29:53.09')));
%time
cosEndurance_or.met.time = ...
    cosEndurance_or.met.time_orig(cosEndurance_or.met.tstart:cosEndurance_or.met.tend);
%irradiance
cosEndurance_or.met.shortwave_irradiance = ...
    cosEndurance_or.met.shortwave_irradiance_orig(cosEndurance_or.met.tstart: ...
    cosEndurance_or.met.tend);
%wind
cosEndurance_or.met.wind_spd = ...
    fillmissing(cosEndurance_or.met.wind_spd_orig(cosEndurance_or.met.tstart: ...
    cosEndurance_or.met.tend),'linear');

%adjust height
cosEndurance_or.met.wind_ht = 4;
cosEndurance_or.met.zo = 0.2;
cosEndurance_or.met.type = 'log';
for i = 1:length(cosEndurance_or.met.wind_spd)
    cosEndurance_or.met.wind_spd(i) = adjustHeight(cosEndurance_or.met.wind_spd(i), ... 
        cosEndurance_or.met.wind_ht_orig,cosEndurance_or.met.wind_ht,cosEndurance_or.met.type,... 
        cosEndurance_or.met.zo);
end

clear i

%% EXAMINE

figure
plot(cosEndurance_or.wave.peak_wave_period)
figure
plot(cosEndurance_or.wave.significant_wave_height)
figure
plot(cosEndurance_or.wave.time)

figure
plot(cosEndurance_or.met.wind_spd)
figure
plot(cosEndurance_or.met.shortwave_irradiance)
figure
plot(cosEndurance_or.met.time)












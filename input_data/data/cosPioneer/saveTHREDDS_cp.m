%created by Trent Dillon on Monday June 17 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% CONSTANTS

cosPioneer.title = 'Coastal Pioneer';
cosPioneer.lat = 40.13338;
cosPioneer.lon = -70.77830;
cosPioneer.depth = 134; %[m]
cosPioneer.dist = dist_from_coast(cosPioneer.lat, ...
    cosPioneer.lon,'great_circle'); %[m]

%% WAVE: set up filenames

%telemeterd, dcl statistics
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T035651374Z-CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics/';
deppath(1,:) = 'deployment0005_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20160516T182300.405000-20161013T192302.575000.nc';
deppath(2,:) = 'deployment0006_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20161013T190747.536000-20170609T140750.935000.nc';
deppath(3,:) = 'deployment0007_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20170609T150747.252000-20171101T170749.344000.nc';
deppath(4,:) = 'deployment0008_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20171101T000746.391000-20180326T140748.972000.nc';
deppath(5,:) = 'deployment0009_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20180324T220747.185000-20180423T130750.663000.nc';

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
    cosPioneer.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        cosPioneer.wave.(vars{v}) = [cosPioneer.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosPioneer.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + cosPioneer.wave.(vars{v}));
    end
%     %collapse lat/lon
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(cosPioneer.wave.(vars{v}) - cosPioneer.wave.(vars{v})(1))
%             cosPioneer.wave.(vars{v}) = cosPioneer.wave.(vars{v})(1);
%         end
%     end
end

temp_wave = datevec(cosPioneer.wave.time);

clear Y M D H MI S v i wave_filenames vars temp opendap

%% WAVE: additional structure adjustments

%none apply for this location

%% MET: set up filenames

%telemetered, metbk hourly
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T041210240Z-CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0006_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20161013T190639.786000-20170609T152930.258000.nc';
deppath(2,:) = 'deployment0007_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20170609T145459.388000-20171101T182932.342000.nc';
deppath(3,:) = 'deployment0008_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20171101T003103.066000-20180326T153044.350000.nc';
deppath(4,:) = 'deployment0009_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20180324T220305.285000-20180423T122949.101000.nc';

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
    cosPioneer.met.(vars{v}) = [];
    for i = 1:length(met_filenames)
        temp = ncread([opendap met_filenames{i}],vars{v});
        cosPioneer.met.(vars{v}) = [cosPioneer.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosPioneer.met.(vars{v}) = datenum(Y,M,D,H,MI,S + cosPioneer.met.(vars{v}));
    end
    %collapse lat/lon
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(cosPioneer.met.(vars{v}) - cosPioneer.met.(vars{v})(1))
%             cosPioneer.met.(vars{v}) = cosPioneer.met.(vars{v})(1);
%         end
%     end
end

temp_met = datevec(cosPioneer.met.time);

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

cosPioneer.met.time_orig = cosPioneer.met.time;
cosPioneer.met.shortwave_irradiance_orig = cosPioneer.met.shortwave_irradiance;
cosPioneer.met.wind_spd_orig = cosPioneer.met.met_wind10m;
cosPioneer.met.wind_ht_orig = 10;

%adjust time window and interpolate over outages
[~,cosPioneer.met.tstart] = min(abs(cosPioneer.met.time_orig - ...
    datenum('13-Oct-2016 19:06:40')));
[~,cosPioneer.met.tend] = min(abs(cosPioneer.met.time_orig - ...
    datenum('12-Apr-2018 23:29:24.05')));
%time
cosPioneer.met.time = ...
    cosPioneer.met.time_orig(cosPioneer.met.tstart:cosPioneer.met.tend);
%irradiance
cosPioneer.met.shortwave_irradiance = ...
    cosPioneer.met.shortwave_irradiance_orig(cosPioneer.met.tstart: ...
    cosPioneer.met.tend);
%wind
cosPioneer.met.wind_spd = ...
    fillmissing(cosPioneer.met.wind_spd_orig(cosPioneer.met.tstart: ...
    cosPioneer.met.tend),'linear');

%adjust height
cosPioneer.met.wind_ht = 4;
cosPioneer.met.zo = 0.2;
cosPioneer.met.type = 'log';
for i = 1:length(cosPioneer.met.wind_spd)
    cosPioneer.met.wind_spd(i) = adjustHeight(cosPioneer.met.wind_spd(i), ... 
        cosPioneer.met.wind_ht_orig,cosPioneer.met.wind_ht,cosPioneer.met.type,... 
        cosPioneer.met.zo);
end

clear i

%% EXAMINE

figure
plot(cosPioneer.wave.peak_wave_period)
figure
plot(cosPioneer.wave.significant_wave_height)
figure
plot(cosPioneer.wave.time)

figure
plot(cosPioneer.met.wind_spd)
figure
plot(cosPioneer.met.shortwave_irradiance)
figure
plot(cosPioneer.met.time)










%created by Trent Dillon on Tuesday July 30 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% CONSTANTS

cosEndurance_wa.title = 'Coastal Endurance, Washington';
cosEndurance_wa.lat = 46.84905;
cosEndurance_wa.lon = -124.97750;
cosEndurance_wa.depth = 542; %[m]
cosEndurance_wa.dist = dist_from_coast(cosEndurance_wa.lat, ...
    cosEndurance_wa.lon,'great_circle'); %[m]

%% WAVE: set up filenames

%telemetered, dcl statistics
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T032022252Z-CE09OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics/';
deppath(1,:) = 'deployment0003_CE09OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20160512T192301.441000-20160922T142305.887000.nc';
deppath(2,:) = 'deployment0004_CE09OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20160920T022257.525000-20170414T142307.457000.nc';
deppath(3,:) = 'deployment0005_CE09OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20170412T020746.216000-20171006T220747.118000.nc';
deppath(4,:) = 'deployment0006_CE09OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20171005T002258.480000-20180330T162302.565000.nc';
deppath(5,:) = 'deployment0007_CE09OSSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20180326T032304.716000-20180427T175804.041000.nc';

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
    cosEndurance_wa.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        cosEndurance_wa.wave.(vars{v}) = [cosEndurance_wa.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosEndurance_wa.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + cosEndurance_wa.wave.(vars{v}));
    end
%     %collapse lat/lon - if included in opendap
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(cosEndurance_or.wave.(vars{v}) - cosEndurance_or.wave.(vars{v})(1))
%             cosEndurance_or.wave.(vars{v}) = cosEndurance_or.wave.(vars{v})(1);
%         end
%     end
end

temp_wave = datevec(cosEndurance_wa.wave.time);

clear Y M D H MI S v i wave_filenames vars temp opendap

%% WAVE: additional structure adjustments

%none apply for this location

%% MET: set up filenames

%telemetered, metbk hourly
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T034050334Z-CE09OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0007_CE09OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20180429T150323.550000-20180919T135631.839000.nc';
deppath(2,:) = 'deployment0008_CE09OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20180919T010302.043000-20190424T222921.115000.nc';
deppath(3,:) = 'deployment0009_CE09OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20190424T230324.332000-20191013T122955.128000.nc';
deppath(4,:) = 'deployment0010_CE09OSSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20191011T233308.105000-20200513T182930.383000.nc';

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
    cosEndurance_wa.met.(vars{v}) = [];
    for i = 1:length(met_filenames)
        temp = ncread([opendap met_filenames{i}],vars{v});
        cosEndurance_wa.met.(vars{v}) = [cosEndurance_wa.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosEndurance_wa.met.(vars{v}) = datenum(Y,M,D,H,MI,S + cosEndurance_wa.met.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(cosEndurance_wa.met.(vars{v}) - cosEndurance_wa.met.(vars{v})(1))
            cosEndurance_wa.met.(vars{v}) = cosEndurance_wa.met.(vars{v})(1);
        end
    end
end

temp_met = datevec(cosEndurance_wa.met.time);

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

cosEndurance_wa.met.time_orig = cosEndurance_wa.met.time;
cosEndurance_wa.met.shortwave_irradiance_orig = cosEndurance_wa.met.shortwave_irradiance;
cosEndurance_wa.met.wind_spd_orig = cosEndurance_wa.met.met_wind10m;
cosEndurance_wa.met.wind_ht_orig = 10;

%adjust time window and interpolate over outages
[~,cosEndurance_wa.met.tstart] = min(abs(cosEndurance_wa.met.time_orig - ...
    datenum('31-Oct-2018 23:29:23.99')));
[~,cosEndurance_wa.met.tend] = min(abs(cosEndurance_wa.met.time_orig - ...
    datenum('13-May-2020 18:29:30.38')));
%time
cosEndurance_wa.met.time = ...
    cosEndurance_wa.met.time_orig(cosEndurance_wa.met.tstart:cosEndurance_wa.met.tend);
%irradiance
cosEndurance_wa.met.shortwave_irradiance = ...
    cosEndurance_wa.met.shortwave_irradiance_orig(cosEndurance_wa.met.tstart: ...
    cosEndurance_wa.met.tend);
%wind
cosEndurance_wa.met.wind_spd = ...
    fillmissing(cosEndurance_wa.met.wind_spd_orig(cosEndurance_wa.met.tstart: ...
    cosEndurance_wa.met.tend),'linear');

%adjust height
cosEndurance_wa.met.wind_ht = 4;
cosEndurance_wa.met.zo = 0.2;
cosEndurance_wa.met.type = 'log';
for i = 1:length(cosEndurance_wa.met.wind_spd)
    cosEndurance_wa.met.wind_spd(i) = adjustHeight(cosEndurance_wa.met.wind_spd(i), ... 
        cosEndurance_wa.met.wind_ht_orig,cosEndurance_wa.met.wind_ht,cosEndurance_wa.met.type,... 
        cosEndurance_wa.met.zo);
end

clear i

%% EXAMINE

figure
plot(cosEndurance_wa.wave.peak_wave_period)
figure
plot(cosEndurance_wa.wave.significant_wave_height)
figure
plot(cosEndurance_wa.wave.time)

figure
plot(cosEndurance_wa.met.wind_spd)
figure
plot(cosEndurance_wa.met.shortwave_irradiance)
figure
plot(cosEndurance_wa.met.time)












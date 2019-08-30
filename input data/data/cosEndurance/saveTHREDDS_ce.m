%created by Trent Dillon on Tuesday July 30 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% MET: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20190730T213931967Z-CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0001_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20150402T211559.890000-20150825T183025.060000.nc';
deppath(2,:) = 'deployment0002_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20151007T214021.365000-20160516T183017.576000.nc';
deppath(3,:) = 'deployment0003_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20160517T221755.792000-20160928T153033.657000.nc';
deppath(4,:) = 'deployment0004_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20160926T221835.539000-20170422T103018.272000.nc';
deppath(5,:) = 'deployment0005_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20170420T180148.775000-20171014T143029.696000.nc';
deppath(6,:) = 'deployment0006_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20171011T031424.766000-20180404T123024.211000.nc';
deppath(7,:) = 'deployment0007_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20180403T014701.558000-20180925T145630.543000.nc';
deppath(8,:) = 'deployment0008_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20180922T233451.565000-20190421T003000.942000.nc';
deppath(9,:) = 'deployment0009_CE02SHSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20190420T003053.723000-20190730T183100.444000.nc';

met_filenames = cell(1,size(deppath,1));
for i = 1:length(met_filenames)
    met_filenames{i} = [threddspath deppath(i,:)];
end

clear i deppath threddspath

vars = {'time' 'deployment' 'met_wind10m' 'shortwave_irradiance' 'lat' 'lon'};

%% MET: read vars into data structure

%base time
Y = 1900;
M = 1;
D = 1;
H = 0;
MI = 0;
S = 0;

for v = 1:length(vars)
    cosEndurance.met.(vars{v}) = [];
    for i = 1:length(met_filenames)
        temp = ncread([opendap met_filenames{i}],vars{v});
        cosEndurance.met.(vars{v}) = [cosEndurance.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosEndurance.met.(vars{v}) = datenum(Y,M,D,H,MI,S + cosEndurance.met.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(cosEndurance.met.(vars{v}) - cosEndurance.met.(vars{v})(1))
            cosEndurance.met.(vars{v}) = cosEndurance.met.(vars{v})(1);
        end
    end
end

cosEndurance.met.time_orig = cosEndurance.met.time;
cosEndurance.met.shortwave_irradiance_orig = cosEndurance.met.shortwave_irradiance;
cosEndurance.met.wind_spd_orig = cosEndurance.met.met_wind10m;
cosEndurance.met.wind_ht_orig = 10;
cosEndurance.title = 'Coastal Endurance';

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

%adjust time window and interpolate over outages
[~,cosEndurance.met.tstart] = min(abs(cosEndurance.met.time_orig - ...
    datenum('14-Feb-2018 09:08:25')));
[~,cosEndurance.met.tend] = min(abs(cosEndurance.met.time_orig - ...
    datenum('30-Jul-2019 18:31:00')));
%time
cosEndurance.met.time = ...
    cosEndurance.met.time_orig(cosEndurance.met.tstart:cosEndurance.met.tend);
%irradiance
cosEndurance.met.shortwave_irradiance = ...
    cosEndurance.met.shortwave_irradiance_orig(cosEndurance.met.tstart: ...
    cosEndurance.met.tend);
%wind
cosEndurance.met.wind_spd = ...
    fillmissing(cosEndurance.met.wind_spd_orig(cosEndurance.met.tstart: ...
    cosEndurance.met.tend),'linear');

%adjust height
cosEndurance.met.wind_ht = 4;
cosEndurance.met.zo = 0.2;
cosEndurance.met.type = 'log';
for i = 1:length(cosEndurance.met.wind_spd)
    cosEndurance.met.wind_spd(i) = adjustHeight(cosEndurance.met.wind_spd(i), ... 
        cosEndurance.met.wind_ht_orig,cosEndurance.met.wind_ht,cosEndurance.met.type,... 
        cosEndurance.met.zo);
end

clear i

%% WAVE: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20190730T220357290Z-CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics/';
deppath(1,:) = 'deployment0001_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20150402T212258.607000-20150922T072302.208000.nc';
deppath(2,:) = 'deployment0002_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20151007T212302.886000-20160516T172309.959000.nc';
deppath(3,:) = 'deployment0003_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20160517T222303.873000-20160928T142303.725000.nc';
deppath(4,:) = 'deployment0004_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20160926T222312.882000-20170105T202311.098000.nc';
deppath(5,:) = 'deployment0005_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20170420T182302.158000-20171014T142304.058000.nc';
deppath(6,:) = 'deployment0006_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20171011T032259.573000-20180404T122308.596000.nc';
deppath(7,:) = 'deployment0007_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20180403T022258.090000-20180925T125302.291000.nc';
deppath(8,:) = 'deployment0008_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20180922T232257.583000-20190421T002303.260000.nc';
deppath(9,:) = 'deployment0009_CE02SHSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20190420T002303.177000-20190730T182302.606000.nc';

wave_filenames = cell(1,size(deppath,1));
for i = 1:length(wave_filenames)
    wave_filenames{i} = [threddspath deppath(i,:)];
end

clear i deppath threddspath

vars = {'time' 'deployment' 'significant_wave_height' 'peak_wave_period' 'lat' 'lon'};

%% WAVE: read vars into data structure

%base time
Y = 1900;
M = 1;
D = 1;
H = 0;
MI = 0;
S = 0;

for v = 1:length(vars)
    cosEndurance.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        cosEndurance.wave.(vars{v}) = [cosEndurance.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosEndurance.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + cosEndurance.wave.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(cosEndurance.wave.(vars{v}) - cosEndurance.wave.(vars{v})(1))
            cosEndurance.wave.(vars{v}) = cosEndurance.wave.(vars{v})(1);
        end
    end
end

cosEndurance.wave.time_orig = cosEndurance.wave.time;
cosEndurance.wave.peak_wave_period_orig = cosEndurance.wave.peak_wave_period;
cosEndurance.wave.significant_wave_height_orig = cosEndurance.wave.significant_wave_height;
cosEndurance.title = 'Coastal Endurance';

clear Y M D H MI S v i wave_filenames vars temp opendap

%% WAVE: additional structure adjustments

%adjust time window
[~,cosEndurance.wave.tstart] = min(abs(cosEndurance.wave.time - ...
    datenum('20-Apr-2017 18:23:02')));
[~,cosEndurance.wave.tend] = min(abs(cosEndurance.wave.time - ...
    datenum('30-Jul-2019 18:23:02')));

%adjust time span
cosEndurance.wave.time = ...
    cosEndurance.wave.time_orig(cosEndurance.wave.tstart:cosEndurance.wave.tend);
cosEndurance.wave.peak_wave_period = ...
    cosEndurance.wave.peak_wave_period(cosEndurance.wave.tstart:cosEndurance.wave.tend);
cosEndurance.wave.significant_wave_height = ...
    cosEndurance.wave.significant_wave_height(cosEndurance.wave.tstart:cosEndurance.wave.tend);

%% dist and port

%souOcean.port =
%souOcean.portlat =
%souOcean.portlon =
cosEndurance.dist = dist_from_coast(cosEndurance.met.lat, cosEndurance.met.lon, ...
    'great_circle'); %[m] need to do this differently









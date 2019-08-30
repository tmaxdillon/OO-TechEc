%created by Trent Dillon on Tuesday July 30 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% MET: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20190730T193150918Z-GI01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0001_GI01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20140910T192041.465000-20150702T163000.008000.nc';
deppath(2,:) = 'deployment0002_GI01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20150815T195214.032000-20160127T083019.947000.nc';
deppath(3,:) = 'deployment0003_GI01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20160710T181403.350000-20170814T043048.738000.nc';
deppath(4,:) = 'deployment0004_GI01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20170805T184721.211000-20171012T093058.936000.nc';
deppath(5,:) = 'deployment0005_GI01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20180608T175109.234000-20190730T153103.154000.nc';

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
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(irmSea.met.(vars{v}) - irmSea.met.(vars{v})(1))
            irmSea.met.(vars{v}) = irmSea.met.(vars{v})(1);
        end
    end
end

irmSea.met.time_orig = irmSea.met.time;
irmSea.met.shortwave_irradiance_orig = irmSea.met.shortwave_irradiance;
irmSea.met.wind_spd_orig = irmSea.met.met_wind10m;
irmSea.met.wind_ht_orig = 10;
irmSea.title = 'Irminger Sea';

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

%adjust time window and interpolate over outages
[~,irmSea.met.tstart] = min(abs(irmSea.met.time_orig - ...
    datenum('07-May-2015 18:04:20')));
[~,irmSea.met.tend] = min(abs(irmSea.met.time_orig - ...
    datenum('02-Apr-2016 20:23:05')));
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

%% WAVE: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20190730T202933718Z-GI01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics/';
deppath(1,:) = 'deployment0001_GI01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20140910T192304.694000-20150706T170742.344000.nc';
deppath(2,:) = 'deployment0002_GI01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20150815T200742.050000-20160609T120748.862000.nc';
deppath(3,:) = 'deployment0003_GI01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20160710T180746.024000-20170814T033250.638000.nc';
deppath(4,:) = 'deployment0004_GI01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20170805T190747.411000-20171012T080748.323000.nc';
deppath(5,:) = 'deployment0005_GI01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20180608T172302.577000-20190730T172304.426000.nc';

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
    irmSea.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        irmSea.wave.(vars{v}) = [irmSea.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        irmSea.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + irmSea.wave.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(irmSea.wave.(vars{v}) - irmSea.wave.(vars{v})(1))
            irmSea.wave.(vars{v}) = irmSea.wave.(vars{v})(1);
        end
    end
end

irmSea.wave.time_orig = irmSea.wave.time;
irmSea.wave.peak_wave_period_orig = irmSea.wave.peak_wave_period;
irmSea.wave.significant_wave_height_orig = irmSea.wave.significant_wave_height;
irmSea.title = 'Irminger Sea';

clear Y M D H MI S v i wave_filenames vars temp opendap

%% WAVE: additional structure adjustments

%adjust time window
[~,irmSea.wave.tstart] = min(abs(irmSea.wave.time - ...
    datenum('07-May-2015 18:04:20')));
[~,irmSea.wave.tend] = min(abs(irmSea.wave.time - ...
    datenum('03-Apr-2016 20:23:05')));

%adjust time span
irmSea.wave.time = ...
    irmSea.wave.time_orig(irmSea.wave.tstart:irmSea.wave.tend);
irmSea.wave.peak_wave_period = ...
    irmSea.wave.peak_wave_period(irmSea.wave.tstart:irmSea.wave.tend);
irmSea.wave.significant_wave_height = ...
    irmSea.wave.significant_wave_height(irmSea.wave.tstart:irmSea.wave.tend);

%% dist and port

%souOcean.port =
%souOcean.portlat =
%souOcean.portlon =
irmSea.dist = dist_from_coast(irmSea.met.lat, irmSea.met.lon, ...
    'great_circle'); %need to do this differently









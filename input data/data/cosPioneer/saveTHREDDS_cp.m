%created by Trent Dillon on Monday June 17 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% MET: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20190618T014106266Z-CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0001_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20131121T184518.610000-20140210T065814.943000.nc';
deppath(2,:) = 'deployment0002_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20141213T191752.649000-20141215T203001.252000.nc';
deppath(3,:) = 'deployment0003_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20150507T180420.503000-20151023T193046.056000.nc';
deppath(4,:) = 'deployment0004_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20151023T191935.883000-20160403T213036.471000.nc';
deppath(5,:) = 'deployment0005_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20160513T142040.010000-20160609T093014.599000.nc';
deppath(6,:) = 'deployment0006_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20161013T190639.786000-20170609T153031.152000.nc';
deppath(7,:) = 'deployment0007_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20170609T145459.388000-20171101T183014.484000.nc';
deppath(8,:) = 'deployment0008_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20171101T003103.066000-20180326T153025.589000.nc';
deppath(9,:) = 'deployment0009_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20180324T220305.285000-20180423T183836.265000.nc';
deppath(10,:) = 'deployment0010_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20181030T021812.609000-20190407T183057.336000.nc';
deppath(11,:) = 'deployment0011_CP01CNSM-SBD11-06-METBKA000-telemetered-metbk_hourly_20190406T150543.898000-20190617T233024.400000.nc';

met_filenames_cp = cell(1,4);
for i = 1:length(met_filenames_cp)
    met_filenames_cp{i} = [threddspath deppath(i,:)];
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
    cosPioneer.met.(vars{v}) = [];
    for i = 1:length(met_filenames_cp)
        temp = ncread([opendap met_filenames_cp{i}],vars{v});
        cosPioneer.met.(vars{v}) = [cosPioneer.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosPioneer.met.(vars{v}) = datenum(Y,M,D,H,MI,S + cosPioneer.met.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(cosPioneer.met.(vars{v}) - cosPioneer.met.(vars{v})(1))
            cosPioneer.met.(vars{v}) = cosPioneer.met.(vars{v})(1);
        end
    end
end

cosPioneer.met.time_orig = cosPioneer.met.time;
cosPioneer.met.shortwave_irradiance_orig = cosPioneer.met.shortwave_irradiance;
cosPioneer.met.wind_spd_orig = cosPioneer.met.met_wind10m;
cosPioneer.met.wind_ht_orig = 10;
cosPioneer.title = 'Coastal Pioneer';

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

%adjust time window and interpolate over outages
[~,cosPioneer.met.tstart] = min(abs(cosPioneer.met.time_orig - ...
    datenum('07-May-2015 18:04:20')));
[~,cosPioneer.met.tend] = min(abs(cosPioneer.met.time_orig - ...
    datenum('02-Apr-2016 20:23:05')));
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

%% WAVE: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20190618T014348405Z-CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics/';
deppath(1,:) = 'deployment0001_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20131121T193131.934000-20140217T113129.043000.nc';
deppath(2,:) = 'deployment0002_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20141213T192259.680000-20141215T202258.072000.nc';
deppath(3,:) = 'deployment0003_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20150507T182259.016000-20151023T192303.559000.nc';
deppath(4,:) = 'deployment0004_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20151023T192301.727000-20160403T202305.051000.nc';
deppath(5,:) = 'deployment0005_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20160513T142258.024000-20161013T192302.575000.nc';
deppath(6,:) = 'deployment0006_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20161013T190747.536000-20170609T140750.935000.nc';
deppath(7,:) = 'deployment0007_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20170609T150747.252000-20171101T170749.344000.nc';
deppath(8,:) = 'deployment0008_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20171101T000746.391000-20180326T140748.972000.nc';
deppath(9,:) = 'deployment0009_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20180324T220747.185000-20180423T180745.782000.nc';
deppath(10,:) = 'deployment0010_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20181030T022303.668000-20190407T172304.630000.nc';
deppath(11,:) = 'deployment0011_CP01CNSM-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20190406T152302.434000-20190617T232253.382000.nc';

wave_filenames_cp = cell(1,4);
for i = 1:length(wave_filenames_cp)
    wave_filenames_cp{i} = [threddspath deppath(i,:)];
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
    cosPioneer.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames_cp)
        temp = ncread([opendap wave_filenames_cp{i}],vars{v});
        cosPioneer.wave.(vars{v}) = [cosPioneer.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        cosPioneer.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + cosPioneer.wave.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(cosPioneer.wave.(vars{v}) - cosPioneer.wave.(vars{v})(1))
            cosPioneer.wave.(vars{v}) = cosPioneer.wave.(vars{v})(1);
        end
    end
end

cosPioneer.wave.time_orig = cosPioneer.wave.time;
cosPioneer.wave.peak_wave_period_orig = cosPioneer.wave.peak_wave_period;
cosPioneer.wave.significant_wave_height_orig = cosPioneer.wave.significant_wave_height;
cosPioneer.title = 'Coastal Pioneer';

clear Y M D H MI S v i wave_filenames_cp vars temp opendap

%% WAVE: additional structure adjustments

%adjust time window
[~,cosPioneer.wave.tstart] = min(abs(cosPioneer.wave.time - ...
    datenum('07-May-2015 18:04:20')));
[~,cosPioneer.wave.tend] = min(abs(cosPioneer.wave.time - ...
    datenum('03-Apr-2016 20:23:05')));

%adjust time span
cosPioneer.wave.time = ...
    cosPioneer.wave.time_orig(cosPioneer.wave.tstart:cosPioneer.wave.tend);
cosPioneer.wave.peak_wave_period = ...
    cosPioneer.wave.peak_wave_period(cosPioneer.wave.tstart:cosPioneer.wave.tend);
cosPioneer.wave.significant_wave_height = ...
    cosPioneer.wave.significant_wave_height(cosPioneer.wave.tstart:cosPioneer.wave.tend);

%% dist and port

%souOcean.port =
%souOcean.portlat =
%souOcean.portlon =
cosPioneer.dist = dist_from_coast(cosPioneer.met.lat, cosPioneer.met.lon, ...
    'great_circle'); %need to do this differently









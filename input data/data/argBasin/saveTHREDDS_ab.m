%created by Trent Dillon on Monday January 7th 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure
% - the argBasin dataset was the first dataset downloaded. Therefore, this
% code is irregular in comparison to other saveTHREDDS.m files that are
% more systematic. This dataset was often wrangled from the command window.

clear all, close all, clc
%% CONSTANTS

argBasin.title = 'Argentine Basin';
argBasin.lat = -42.97805;
argBasin.lon = -42.49567;
argBasin.depth = 5198; %[m]
argBasin.dist = dist_from_coast(argBasin.lat,argBasin.lon, ...
    'great_circle'); %[m]

%% WAVE: set up filenames

%telemetered, dcl statistics
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200512T185217218Z-GA01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics/';
deppath(1,:) = 'deployment0001_GA01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20150315T222303.347000-20151126T092303.865000.nc';
deppath(2,:) = 'deployment0002_GA01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20151114T210746.415000-20161108T080748.550000.nc';
deppath(3,:) = 'deployment0003_GA01SUMO-SBD12-05-WAVSSA000-telemetered-wavss_a_dcl_statistics_20161027T020748.291000-20180114T100751.930000.nc';

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
    argBasin.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        argBasin.wave.(vars{v}) = [argBasin.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        argBasin.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + argBasin.wave.(vars{v}));
    end
%     %collapse lat/lon - if included in opendap
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(argBasin.wave.(vars{v}) - argBasin.wave.(vars{v})(1))
%             argBasin.wave.(vars{v}) = argBasin.wave.(vars{v})(1);
%         end
%     end
end

temp_wave = datevec(argBasin.wave.time);

clear Y M D H MI S v i wave_filenames vars temp opendap

%% WAVE: additional structure adjustments

%none apply for this location

%% MET: set up filenames

%telemetered, metbk hourly
opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20200515T030601246Z-GA01SUMO-SBD12-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0002_GA01SUMO-SBD12-06-METBKA000-telemetered-metbk_hourly_20151114T213657.470000-20161108T093002.253000.nc';
deppath(2,:) = 'deployment0003_GA01SUMO-SBD12-06-METBKA000-telemetered-metbk_hourly_20161027T021717.360000-20180113T233033.896000.nc';

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
    argBasin.met.(vars{v}) = [];
    for i = 1:length(met_filenames)
        temp = ncread([opendap met_filenames{i}],vars{v});
        argBasin.met.(vars{v}) = [argBasin.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        argBasin.met.(vars{v}) = datenum(Y,M,D,H,MI,S + argBasin.met.(vars{v}));
    end
%     %collapse lat/lon - if included in opendap
%     if isequal(vars{v},'lat') || isequal(vars{v},'lon')
%         if any(argBasin.met.(vars{v}) - argBasin.met.(vars{v})(1))
%             argBasin.met.(vars{v}) = argBasin.met.(vars{v})(1);
%         end
%     end
end

temp_met = datevec(argBasin.met.time);

clear Y M D H MI S v i met_filenames vars temp opendap

%% MET: additional structure adjustments

argBasin.met.time_orig = argBasin.met.time;
argBasin.met.shortwave_irradiance_orig = argBasin.met.shortwave_irradiance;
argBasin.met.wind_spd_orig = argBasin.met.met_wind10m;
argBasin.met.wind_ht_orig = 10;

%adjust time window and interpolate over outages
[~,argBasin.met.tstart] = min(abs(argBasin.met.time_orig - ...
    datenum('14-Nov-2015 21:36:57.47')));
[~,argBasin.met.tend] = min(abs(argBasin.met.time_orig - ...
    datenum('24-Mar-2017 22:29:27.9650')));
%time
argBasin.met.time = ...
    argBasin.met.time_orig(argBasin.met.tstart:argBasin.met.tend);
%irradiance
argBasin.met.shortwave_irradiance = ...
    argBasin.met.shortwave_irradiance_orig(argBasin.met.tstart: ...
    argBasin.met.tend);
%wind
argBasin.met.wind_spd = ...
    fillmissing(argBasin.met.wind_spd_orig(argBasin.met.tstart: ...
    argBasin.met.tend),'linear');

%adjust height
argBasin.met.wind_ht = 4;
argBasin.met.zo = 0.2;
argBasin.met.type = 'log';
for i = 1:length(argBasin.met.wind_spd)
    argBasin.met.wind_spd(i) = adjustHeight(argBasin.met.wind_spd(i), ... 
        argBasin.met.wind_ht_orig,argBasin.met.wind_ht,argBasin.met.type,... 
        argBasin.met.zo);
end

clear i

%% EXAMINE

figure
plot(argBasin.wave.peak_wave_period)
figure
plot(argBasin.wave.significant_wave_height)
figure
plot(argBasin.wave.time)

figure
plot(argBasin.met.wind_spd)
figure
plot(argBasin.met.shortwave_irradiance)
figure
plot(argBasin.met.time)







%created by Trent Dillon on Monday Thursday June 13 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars, close all, clc
%% MET: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
threddspath = '/thredds/dodsC/ooi/tmaxd@uw.edu/20190613T213228850Z-GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly/';
deppath(1,:) = 'deployment0001_GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20150405T210713.050000-20151222T183027.310000.nc';
deppath(2,:) = 'deployment0002_GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20151214T205021.824000-20161128T065659.929000.nc';
deppath(3,:) = 'deployment0003_GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20161125T014201.966000-20181209T163012.563000.nc';
deppath(4,:) = 'deployment0004_GS01SUMO-SBD11-06-METBKA000-telemetered-metbk_hourly_20181204T174137.654000-20190613T173011.323000.nc';

met_filenames_so = cell(1,4);
for i = 1:length(met_filenames_so)
    met_filenames_so{i} = [threddspath deppath(i,:)];
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
    souOcean.met.(vars{v}) = [];
    for i = 1:length(met_filenames_so)
        temp = ncread([opendap met_filenames_so{i}],vars{v});
        souOcean.met.(vars{v}) = [souOcean.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        souOcean.met.(vars{v}) = datenum(Y,M,D,H,MI,S + souOcean.met.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(souOcean.met.(vars{v}) - souOcean.met.(vars{v})(1))
            souOcean.met.(vars{v}) = souOcean.met.(vars{v})(1);
        end
    end
end

souOcean.met.time_orig = souOcean.met.time;
souOcean.met.shortwave_irradiance_orig = souOcean.met.shortwave_irradiance;
souOcean.met.wind_spd_orig = souOcean.met.met_wind10m;

clear Y M D H MI S v i met_filenames vars temp opendap

%% additional structure features

%title and port
souOcean.title = 'South Ocean';
%souOcean.port =
%souOcean.portlat =
%souOcean.portlon =
souOcean.dist = dist_from_coast(souOcean.met.lat, souOcean.met.lon, ...
    'great_circle'); %need to do this differently

%adjust time window and interpolate over outages
[~,souOcean.met.tstart] = min(abs(souOcean.met.time - ...
    datenum('25-Nov-2016 15:42:01')));
[~,souOcean.met.tend] = min(abs(souOcean.met.time - ...
    datenum('12-Oct-2018 20:30:12')));
%time
souOcean.met.time = ...
    souOcean.met.time_orig(souOcean.met.tstart:souOcean.met.tend);
%irradiance
souOcean.met.shortwave_irradiance = ...
    souOcean.met.shortwave_irradiance_orig(souOcean.met.tstart: ...
    souOcean.met.tend);
%wind
souOcean.met.wind_spd = ...
    fillmissing(souOcean.met.wind_spd_orig(souOcean.met.tstart: ...
    souOcean.met.tend), ...
    'linear');

%adjust height
souOcean.met.wind_ht = 4;
souOcean.met.wind_ht_orig = 10;
souOcean.met.zo = 0.2;
souOcean.met.type = 'log';
for i = 1:length(souOcean.met.wind_spd)
    souOcean.met.wind_spd(i) = adjustHeight(souOcean.met.wind_spd(i), ... 
        souOcean.met.wind_ht_orig,souOcean.met.wind_ht,souOcean.met.type,... 
        souOcean.met.zo);
end

clear i














%created by Trent Dillon on Monday January 7th 2019 to load THREDDS data
%from OOI website: https://ooinet.oceanobservatories.org/

%NOTE: variable names are manually adjusted post-creation of data structure

clearvars -except argBasin, close all, clc
%% WAVE: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
load('wave_filenames.mat')

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
    argBasin.wave.(vars{v}) = [];
    for i = 1:length(wave_filenames)
        temp = ncread([opendap wave_filenames{i}],vars{v});
        argBasin.wave.(vars{v}) = [argBasin.wave.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        argBasin.wave.(vars{v}) = datenum(Y,M,D,H,MI,S + argBasin.wave.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(argBasin.wave.(vars{v}) - argBasin.wave.(vars{v})(1))
            argBasin.wave.(vars{v}) = argBasin.wave.(vars{v})(1);
        end
    end
end


clear Y M D H MI S v i wave_filenames vars temp opendap

%% MET: set up filenames

opendap = 'https://opendap.oceanobservatories.org';
load('met_filenames.mat')

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
    argBasin.met.(vars{v}) = [];
    for i = 1:length(met_filenames)
        temp = ncread([opendap met_filenames{i}],vars{v});
        argBasin.met.(vars{v}) = [argBasin.met.(vars{v}) ; temp];
    end
    %adjust time
    if isequal(vars{v},'time')
        argBasin.met.(vars{v}) = datenum(Y,M,D,H,MI,S + argBasin.met.(vars{v}));
    end
    %collapse lat/lon
    if isequal(vars{v},'lat') || isequal(vars{v},'lon')
        if any(argBasin.met.(vars{v}) - argBasin.met.(vars{v})(1))
            argBasin.met.(vars{v}) = argBasin.met.(vars{v})(1);
        end
    end
end


clear Y M D H MI S v i met_filenames vars temp opendap






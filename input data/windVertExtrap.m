clear all; close all; clc

%% extrapolate wind to new height

%load data
location = 'argBasin';
data = load(location,location);
data = data.(location);
clear location
%set originals
data.met.wind_spd_orig = data.met.wind_spd;
data.met.wind_ht_orig = 10;

%settings
data.met.wind_ht = 4;
data.met.zo = 0.2;
data.met.type = 'log';

for i = 1:length(data.met.wind_spd_orig)
    data.met.wind_spd(i,1) = adjustHeight(data.met.wind_spd_orig(i), ...
        data.met.wind_ht_orig,data.met.wind_ht,data.met.type,data.met.zo);
end

clear i



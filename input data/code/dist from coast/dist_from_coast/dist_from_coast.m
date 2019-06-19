%dist_from_coast.m - determine minimum distance to a coastal point
%Purpose: determine minimum distance to a coastal point
%   threhsold
%
% Syntax:  [dists_min,lats_closest,lons_closest] = dist_from_coast(lats_in,lons_in,dist_method,dist_maxthresh)
%
% Inputs:
%   lats_in [deg N [-90,90]] - vector of latitude values
%   lons_in [deg E (-180,180]] - vector of corresponding longitude values
%   dist_method [] - 'fast' (default) for latitude-weighted mean distance (vectorized);
%       'great_circle' for exact calculation (non-vectorized)
%   dist_maxthresh [m] - (optional) only return distances below this threshold;
%       if ignored, uses entire Earth. This greatly speeds up calculation
%       if you don't care about large distances
%
% Outputs:
%   dists_min [m] - vector of minimum distances to nearest coastal point
%   lats_closest [deg N [-90,90] - vector of latitudes of closest point
%   lons_closest [deg E (-180,180]] - vector of longitudes of closest point
%
% Example: (see dist_from_coast_example.m)
%   lats_in = 30;    %[deg N]
%   lons_in = 140;   %[deg E] 
%   dist_method = 'fast';   %'fast' or 'great_circle'
%   dist_maxthresh = 1000*1000; %[m] check within 1000 km
%   [dists_min,lats_closest,lons_closest] = dist_from_coast(lats_in,lons_in,dist_method,dist_maxthresh);
%
% Other m-files required: vdist (available on MATLAB file exchange)
% Subfunctions: none
% MAT-files required: coast.mat (included in MATLAB)

% Author: Dan Chavas
% CEE Dept, Princeton University
% email: drchavas@gmail.com
% Website: http://www.princeton.edu/~dchavas/
% 22 Aug 2014; Last revision:

% Revision history:

%------------- BEGIN CODE --------------

function [dists_min,lats_closest,lons_closest] = dist_from_coast(lats_in,lons_in,dist_method,dist_maxthresh)

switch nargin
    case 2
        dist_method = 'fast';        
        dist_maxthresh = 200000*1000; %default is allow for entire earth
    case 3
        dist_maxthresh = 200000*1000; %default is allow for entire earth
end

%% Constants
km_per_deg=111.325; %[km/deg] at equator

%% Load coastal data
coast = load('coast.mat');  %included with matlab
Npts_coastlat = length(coast.lat);
Npts_coastlon = length(coast.long);
Mpts_latsin = length(lats_in);
Mpts_lonsin = length(lons_in);
assert(Mpts_latsin == Mpts_lonsin,'Must have same number of lat and lon pts')

%% Adjust longitude range if needed
lons_in(lons_in>180) = lons_in(lons_in>180) - 360;    %convert to deg E (-180,180]

%% Extract coastal subset sufficiently close to data
%%Latitude
lat_in_min = min(min(lats_in));
lat_in_max = max(max(lats_in));

dlat_maxthresh = (dist_maxthresh/1000)/km_per_deg;  %[deg]
lat_coast_subset_min = lat_in_min - dlat_maxthresh;
lat_coast_subset_max = lat_in_max + dlat_maxthresh;

%%Longitude
lon_in_min = min(min(lons_in));
lon_in_max = max(max(lons_in));

lat_temp = max(abs([lat_in_min lat_in_max]));   %use highest latitude to ensure you go far enough in lat/lon space
dlon_maxthresh_min = (dist_maxthresh/1000)/(km_per_deg*cosd(lat_temp));  %[deg]
lon_coast_subset_min = lon_in_min - dlon_maxthresh_min;
dlon_maxthresh_max = (dist_maxthresh/1000)/(km_per_deg*cosd(lat_temp));  %[deg]
lon_coast_subset_max = lon_in_max + dlon_maxthresh_max;

%%Check if crosses international dateline
if(abs(dlon_maxthresh_max - dlon_maxthresh_min) > 300)  %crossing likely exists, subset lat only
    
    ii_coast_subset = coast.lat >= lat_coast_subset_min & coast.lat <= lat_coast_subset_max;
    
else    %no crossing, subset lat and lon
    
    ii_coast_subset = coast.lat >= lat_coast_subset_min & coast.lat <= lat_coast_subset_max & ...
        coast.long >= lon_coast_subset_min & coast.long <= lon_coast_subset_max;
    
end

coast_all_lat = coast.lat;
coast_all_lon = coast.long;
coast.lat = coast.lat(ii_coast_subset);
coast.long = coast.long(ii_coast_subset);
Npts_coastlat = length(coast.lat);
Npts_coastlon = length(coast.long);

%% TESTING: coastal subset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
figure(1001)
plot(coast_all_lon,coast_all_lat)
hold on
plot(coast.long,coast.lat,'g')
'hi'
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Initialize arrays
dists_min = NaN(size(lons_in));
if(nargout>1)
    lats_closest = NaN(size(lons_in));
    lons_closest = NaN(size(lons_in));
end

if(~isempty(coast.long)) %no coastal data!

    %% Choose method for calculating distances
    switch dist_method

        %% Quick method: mean distance, dlon weighted by cos(lat); vectorized
        case 'fast' 

            %%Make input lats and lons be ROW vectors
            if(size(lats_in,1)>1)
                lats_in = lats_in';
            end
            if(size(lons_in,1)>1)
                lons_in = lons_in';
            end

            %%Make matrices of data: both input and coastal
            lats_in_mat = repmat(lats_in,Npts_coastlat,1);
            lons_in_mat = repmat(lons_in,Npts_coastlon,1);

            lats_coast_mat = repmat(coast.lat,1,Mpts_latsin);
            lons_coast_mat = repmat(coast.long,1,Mpts_lonsin);

            dlat_temp = lats_in_mat - lats_coast_mat;
            latmean_temp = (lats_in_mat+lats_coast_mat)/2;
            dlon_temp = cosd(abs(latmean_temp)).*(lons_in_mat - lons_coast_mat); %weighted by cosine of mean latitude

            [dists_min,i_closest] = min(sqrt(dlat_temp.^2 + dlon_temp.^2),[],1);
            dists_min = dists_min*km_per_deg*1000;   %[m]

            %%If desired, return lat/lon of closest coastal point
            if(nargout>1)
                lats_closest = coast.lat(i_closest);
                lons_closest = coast.long(i_closest);
            end


        %% Fancy method: great circle distance (vdist) -- O(.1 s) per call); not vectorized
        case 'great_circle'  

            %%Loop over points
            for ii=1:length(lons_in)

                lon_in = lons_in(ii);
                lat_in = lats_in(ii);


                        [dist_min_temp,i_closest] = min(vdist(lat_in*ones(size(coast.lat)),lon_in*ones(size(coast.long)),coast.lat,coast.long));

                        %%If desired, return lat/lon of closest coastal point
                        if(nargout>1)
                            lat_closest_temp = coast.lat(i_closest);
                            lats_closest(ii) = lat_closest_temp(1);
                            lon_closest_temp = coast.long(i_closest);
                            lons_closest(ii) = lon_closest_temp(1);
                        end

                dists_min(ii) = dist_min_temp;

            end

        otherwise
            assert(1==2,'Only allowed distance methods are "fast" and "great_circle"')
    end

    %% Set any points farther than input threshold distance to NaN
    dists_min(dists_min>dist_maxthresh)=NaN;
    
end

%------------- END OF CODE --------------
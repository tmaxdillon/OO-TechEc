%dist_from_coast_example.m - test example of dist_from_coast.m

%------------- BEGIN CODE --------------

clear
clc
close all

%profile on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Point of interest
lats_in = -80:10:80;    %[deg N]
lons_in = 2*lats_in;   %[deg E]

%%Choose your distance method
dist_method = 'great_circle';   %'fast' or 'great_circle'

%%OPTIONAL: subset coastal data to reasonably close by, if desired
dist_maxthresh = 200000*1000;   %[m]; only return distances less than this

%%Make a plot?
make_plot = 1;  %1: makes a plot; ow: no plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('mfiles/')

tic

%%Return lat/lon of closest points too
[dists_min,lats_closest,lons_closest] = dist_from_coast(lats_in,lons_in,dist_method,dist_maxthresh);

%%Do NOT return lat/lon of closest points
% [dists_min] = dist_from_coast(lats_in,lons_in,dist_method,dist_maxthresh));
% lats_closest = NaN*lats_in;
% lons_closest = NaN*lons_in;

toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TESTING: Plot coast, point %%%%
if(make_plot)
    hh = figure(1001);
    clf(hh)
    set(hh,'Units','centimeters');
    hpos = [0 0 20 20];
    set(hh,'Position',hpos);
    set(hh,'PaperUnits','centimeters');
    set(hh,'PaperPosition',hpos);
    set(hh,'PaperSize',hpos(3:4));
    set(gca,'position',[0.08    0.08    0.88    0.87]);

    coast = load('coast.mat');  %included with matlab
    lons_in(lons_in>180) = lons_in(lons_in>180) - 360;    %convert to deg E (-180,180]

    plot(coast.long,coast.lat)
    hold on
    plot(lons_in,lats_in,'ro','MarkerFaceColor','r','MarkerSize',15)
    plot(lons_closest,lats_closest,'go','MarkerFaceColor','g','MarkerSize',15)
    text(lons_in,lats_in,cellstr(num2str(round(dists_min/1000)')))
    title('Testing dist\_from\_coast; distances in [km]')

    plot_filename = sprintf('dist_from_coast_example_%s.jpg',dist_method)
    saveas(gcf,plot_filename,'jpg')
    %}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%profile viewer

%------------- END OF CODE --------------
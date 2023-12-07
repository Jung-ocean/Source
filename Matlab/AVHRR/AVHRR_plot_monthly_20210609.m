%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot AVHRR monthly mean temperature using .nc file
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear; clc
%% Setting
% Target year and month
%target_year = 2001;
%target_month = 1;

tys = num2str(target_year); % tys means target year string
tms = num2char(target_month,2); % tys means target month string

%casename = 'NWP';

% Contour and Colorbar properties
clim = [0 30];
contour_interval = [clim(1):2:clim(2)];
colormap_style = 'parula';
colorbarname = '^oC';

% .nc file name
filepath = 'D:\Data\Satellite\AVHRR\monthly\';
filename = ['avhrr_monthly', tys, '_', tms, '.nc'];
file = [filepath, filename];

%% Read and compile data
% Read data from .mat file
nc = netcdf(file);
temp = nc{'temp'}(:);
Lon = nc{'long'}(:); Lon1 = Lon(1,:);
Lat = nc{'lat'}(:); Lat1 = Lat(:,1);
close(nc);

% Set the map and data limit
[lon_lim, lat_lim] = domain_J(casename);
lon_ind = find(Lon1 > lon_lim(1) & Lon1 < lon_lim(2));
lat_ind = find(Lat1 > lat_lim(1) & Lat1 < lat_lim(2));

Lon_selected = Lon(lat_ind, lon_ind);
Lat_selected = Lat(lat_ind, lon_ind);
temp_selected = temp(lat_ind, lon_ind);

%% Plot
figure
map_J(casename)

m_pcolor(Lon_selected, Lat_selected, temp_selected); colormap(colormap_style); shading interp;
[cs, h] = m_contour(Lon_selected, Lat_selected, temp_selected, contour_interval, 'k');
clabel(cs,h, 'FontSize', 12, 'FontWeight', 'bold')
c = colorbar; c.Title.String = colorbarname;
c.FontSize = 15;
caxis(clim);

title(['AVHRR ', tys, tms], 'fontsize', 25);
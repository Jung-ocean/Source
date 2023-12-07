%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot AVHRR daily mean temperature using .nc file
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
tds = num2char(target_day,2);

%casename = 'DA';

% Contour and Colorbar properties
contour_interval = [10:2:30];
clim = [10 30];
colormap_style = 'jet';
colorbarname = 'Temperature (deg C)';

% .nc file name
filepath = '.\';
filename = ['avhrr-only-v2.', tys, tms, tds, '.nc'];
file = [filepath, filename];

%% Read and compile data
% Read data from .mat file
nc = netcdf(file);
temp = nc{'sst'}(:);
temp(temp == nc{'sst'}.FillValue_(:)) = NaN;
temp = temp.*nc{'sst'}.scale_factor(:) + nc{'sst'}.add_offset(:);
Lon = nc{'lon'}(:);
Lat = nc{'lat'}(:);
close(nc);

[Lon2, Lat2] = meshgrid(Lon, Lat);

% Set the map and data limit
[lon_lim, lat_lim] = domain_J(casename);
lon_ind = find(Lon > lon_lim(1) & Lon < lon_lim(2));
lat_ind = find(Lat > lat_lim(1) & Lat < lat_lim(2));

Lon_selected = Lon2(lat_ind, lon_ind);
Lat_selected = Lat2(lat_ind, lon_ind);
temp_selected = temp(lat_ind, lon_ind);

%% Plot
figure;
map_J(casename)

m_pcolor(Lon_selected, Lat_selected, temp_selected); colormap(colormap_style); shading flat;
[cs, h] = m_contour(Lon_selected, Lat_selected, temp_selected, contour_interval, 'w');
clabel(cs, h);
c = colorbar; c.FontSize = 15;
c.Label.String = colorbarname; c.Label.FontSize = 15;
caxis(clim);

title(['AVHRR ', tys, tms, tds], 'fontsize', 25);
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

ystr = num2str(target_year); % tys means target year string
mstr = num2char(target_month,2); % tys means target month string

%casename = 'NWP';

% Contour and Colorbar properties
clim = [0 30];
contour_interval = [clim(1):2:clim(2)];
colormap_style = 'parula';
colorbarname = '^oC';

% .nc file name
fpath_all = 'D:\Data\Satellite\AVHRR\daily\';

fpath = [fpath_all, ystr, mstr, '\'];
files = dir([fpath, '*.nc']);

temp_sum = zeros;
for fi = 1:length(files)
    filename = files(fi).name;
    file = [fpath, filename];
    nc = netcdf(file);
    lon = nc{'lon'}(:);
    lat = nc{'lat'}(:);
    [lon_lim, lat_lim] = domain_J(casename);
    lon_ind = find(lon > lon_lim(1) & lon < lon_lim(2));
    lat_ind = find(lat > lat_lim(1) & lat < lat_lim(2));
    [lon, lat] = meshgrid(lon, lat);
    temp = nc{'sst'}(:);
    temp(temp == -999) = NaN;
    temp = temp.*nc{'sst'}.scale_factor(:) + nc{'sst'}.add_offset(:);
    close(nc)
    
    temp_sum = temp_sum + temp;
end
temp_mean = temp_sum./length(files);

Lon_selected = lon(lat_ind, lon_ind);
Lat_selected = lat(lat_ind, lon_ind);
temp_selected = temp_mean(lat_ind, lon_ind);

%% Plot
figure
map_J(casename)

m_pcolor(Lon_selected, Lat_selected, temp_selected); colormap(colormap_style); shading interp;
[cs, h] = m_contour(Lon_selected, Lat_selected, temp_selected, contour_interval, 'k');
clabel(cs,h, 'FontSize', 12, 'FontWeight', 'bold')
c = colorbar; c.Title.String = colorbarname;
c.FontSize = 15;
caxis(clim);

title(['AVHRR ', ystr, mstr], 'fontsize', 25);
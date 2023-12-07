%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot OSTIA monthly mean temperature using .mat file
%       You need to run OSTIA_save_monthly.m before running
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear; clc
%% Setting
% Target year and month
%target_year = 2013;
%target_month = 5;

FS = 15;

ystr = num2str(yyyy); % tys means target year string
mstr = num2char(mm,2); % tys means target month string

% Contour and Colorbar properties
clim = [0 30];
contour_interval = [clim(1):cinterval:clim(2)];
colormap_style = 'parula';
%colorbarname = 'Temperature (deg C)';
colorbarname = '^oC';

% Map limit
[lon_lim, lat_lim] = domain_J(casename);
lim = [lon_lim lat_lim];

% .mat file name
target_filename = ['OSTIA_monthly_global_2011_2020.nc'];

%% Read and compile data
% Read data from .mat file
nc = netcdf(target_filename);
time = nc{'time'}(:);

timevec = datevec(time/60/60/24 + datenum(1981,1,1));
index = find(timevec(:,1) == yyyy & timevec(:,2) == mm);

Lon = nc{'lon'}(:);
Lat = nc{'lat'}(:);
temp_Kelvin = nc{'analysed_sst'}(index,:,:);
temp_add_offset = nc{'analysed_sst'}.add_offset(:);
temp_scale_factor = nc{'analysed_sst'}.scale_factor(:);
FillValue_ = nc{'analysed_sst'}.FillValue_(:);
close(nc)

temp_Kelvin(temp_Kelvin == FillValue_) = NaN;
temp_Kelvin = temp_Kelvin.*temp_scale_factor + temp_add_offset;
temp_Celsius = temp_Kelvin - 273.15;
temp = temp_Celsius;
% mask(mask ~= -1) = NaN;
% mask(~isnan(mask)) = 1;
% temp = temp_Celsius.*mask;

% Set the map and data limit
lon_ind = find(Lon > lon_lim(1) & Lon < lon_lim(2));
lat_ind = find(Lat > lat_lim(1) & Lat < lat_lim(2));

if lon_lim(2) > 180
    lon_ind2 = find(Lon > -180 & Lon < lon_lim(2) - 360);
    lon_ind = [lon_ind; lon_ind2];
end

Lon_selected = Lon(lon_ind);
Lon_selected(Lon_selected < 0) = Lon_selected(Lon_selected < 0) + 360;

Lat_selected = Lat(lat_ind);
temp_selected = temp(lat_ind, lon_ind);

%% Plot
figure; hold on;
map_J(casename)
m_pcolor(Lon_selected, Lat_selected, temp_selected); colormap(colormap_style); shading flat;
[cs, h] = m_contour(Lon_selected, Lat_selected, temp_selected, contour_interval, 'k');
h.LineWidth = 1;
clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200);
c = colorbar; c.FontSize = FS;
c.Title.String = colorbarname; c.Title.FontSize = FS;
caxis(clim);


setposition(domain_case)
m_gshhs_i('patch', [.7 .7 .7])

%title(['OSTIA ', tys, tms], 'fontsize', 25);
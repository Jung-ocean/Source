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

tys = num2str(target_year); % tys means target year string
tms = num2char(target_month,2); % tys means target month string

% Contour and Colorbar properties
contour_interval = [0:cinterval:30];
clim = [contour_interval(1) contour_interval(end)];
colormap_style = 'parula';
%colorbarname = 'Temperature (deg C)';
colorbarname = '^oC';

% Map limit
[lon_lim, lat_lim] = domain_J(casename);
lim = [lon_lim lat_lim];

% .mat file name
target_filename = ['OSTIA_monthly_', tys, tms, '.mat'];

%% Read and compile data
% Read data from .mat file
load(target_filename);
temp = temp_mean;

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
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

tys = num2str(target_year); % tys means target year string
tms = num2char(target_month,2); % tys means target month string

% Contour and Colorbar properties
%contour_interval = [0:2:35];
clim = [0 2];
colormap_style = 'jet';
colorbarname = 'err (deg C)';
fc = [.95 .95 .95 ];

% Map limit
[lon_lim, lat_lim] = domain_J(casename);
lim = [lon_lim lat_lim];
interval_line = 6;

% .mat file name
target_filename = ['OSTIA_err_monthly_', tys, tms, '.mat'];

%% Read and compile data
% Read data from .mat file
load(target_filename);
err = err_mean;

% Set the map and data limit
lon_ind = find(Lon > lon_lim(1) & Lon < lon_lim(2));
lat_ind = find(Lat > lat_lim(1) & Lat < lat_lim(2));

Lon_selected = Lon(lon_ind);
Lat_selected = Lat(lat_ind);
err_selected = err(lat_ind, lon_ind);

%% Plot
figure; hold on;
set(gca,'ydir','nor');
m_proj('miller','lon',[lim(1) lim(2)],'lat',[lim(3) lim(4)]);
m_gshhs_i('color','k')
m_pcolor(Lon_selected, Lat_selected, err_selected); colormap(colormap_style); shading flat;
%[cs, h] = m_contour(Lon_selected, Lat_selected, temp_selected, contour_interval, 'w');
%clabel(cs, h);
m_gshhs_i('patch',fc )
c = colorbar; c.FontSize = 15;
c.Label.String = colorbarname; c.Label.FontSize = 15;
caxis(clim);
m_grid('XTick',lim(1):interval_line:lim(2),'YTick',lim(3):interval_line:lim(4),'linewi',2,'linest','none','tickdir','out','fontsize',20, 'fontweight','bold','FontName', 'Times');

title(['OSTIA err ', tys, tms], 'fontsize', 25);
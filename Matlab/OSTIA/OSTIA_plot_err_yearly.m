%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot OSTIA monthly mean temperature using .mat file
%       You need to run OSTIA_save_monthly.m before running
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all
%% Setting
% Target year and month
target_year = 2016;
casename = 'DA';

tys = num2str(target_year); % tys means target year string

% Contour and Colorbar properties
%contour_interval = [0:2:35];
clim = [0.2 1];
colormap_style = 'jet';
colorbarname = 'err (deg C)';
fc = [.95 .95 .95 ];

% Map limit
[lon_lim, lat_lim] = domain_J(casename);
lim = [lon_lim lat_lim];
interval_line = 6;

for mi = 1:12
    tms = num2char(mi,2);
    
    % .mat file name
    target_filename = ['OSTIA_err_monthly_', tys, tms, '.mat'];
    
    %% Read and compile data
    % Read data from .mat file
    load(target_filename);
    err = err_mean;
    
    % Set the map and data limit
    lon_ind = find(Lon > lon_lim(1) - 5 & Lon < lon_lim(2) + 5);
    lat_ind = find(Lat > lat_lim(1) - 5 & Lat < lat_lim(2) + 5);
    
    Lon_selected = Lon(lon_ind);
    Lat_selected = Lat(lat_ind);
    err_selected = err(lat_ind, lon_ind);
    
    err_all(mi,:,:) = err_selected;
    
end
err_yearly = squeeze(nanmean(err_all));

%% Plot
figure; hold on;
set(gca,'ydir','nor');
m_proj('miller','lon',[lim(1) lim(2)],'lat',[lim(3) lim(4)]);
m_gshhs_i('color','k')
m_pcolor(Lon_selected, Lat_selected, err_yearly); colormap(colormap_style); shading flat;
%[cs, h] = m_contour(Lon_selected, Lat_selected, temp_selected, contour_interval, 'w');
%clabel(cs, h);
m_gshhs_i('patch',fc )
c = colorbar; c.FontSize = 15;
c.Label.String = colorbarname; c.Label.FontSize = 15;
caxis(clim);
m_grid('XTick',lim(1):interval_line:lim(2),'YTick',lim(3):interval_line:lim(4),'linewi',2,'linest','none','tickdir','out','fontsize',20, 'fontweight','bold','FontName', 'Times');

title(['OSTIA err ', tys], 'fontsize', 25);

save OSTIA_err.mat Lon_selected Lat_selected err_yearly
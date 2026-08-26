%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

model = 'Oregon_1km';
expname = 'WCOFS';

vari_str = 'temp';
location = 'OR_shelf';

yyyy = 2024;
datenum_start = datenum(yyyy,1,1);
datenum_end = datenum(yyyy,12,31);

switch location
    case 'OR_shelf'
        title_str = replace(location, '_', ' ');
        lat_target = 44.6351;
        lon_target = -124.3035;
        file_obs = '/data/jungjih/Observations/OOI_buoy/OOI_CE02SHSM/ooi-ce02shsm-sbd11-06-metbka001_a569_448e_3929.nc';
        time_obs = ncread(file_obs, 'time');
        timenum_obs = time_obs/60/60/24 + datenum(1970,1,1);
        vari_obs = ncread(file_obs, 'sea_surface_temperature');
        
        timenum_daily = datenum_start:datenum_end;
        vari_model = NaN(length(timenum_daily),1);
        for ti = 1:length(timenum_daily)
            timenum_tmp = timenum_daily(ti);
            index = find(timenum_obs >= timenum_tmp & timenum_obs < timenum_tmp+1);
            vari_model(ti) = mean(vari_obs(index));
        end
        time_obs = timenum_daily;
        timenum_obs = time_obs;
        vari_obs = vari_model;
end

ismap = 0;
if ismap == 1
    % Map
    g = grd('Oregon_1km');
    figure;
    set(gcf, 'Position', [1 200 500 800])
    plot_map('Oregon', 'mercator', 'l');
    [cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');
    cl = clabelm(cs, h);
    set(cl, 'BackgroundColor', 'none');
    plotm(lat_target, lon_target, 'xr', 'MarkerSize', 12, 'LineWidth', 4);
    print(['map_cmp_SST_OOI_buoy'], '-dpng')
end

% ROMS
g = grd(model);
filepath = ['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Outputs/Output_', expname, '/'];

F = scatteredInterpolant(g.lon_rho(:), g.lat_rho(:), 0.*g.lat_rho(:));

vari_model = NaN(length(timenum_daily),1);
for ti = 1:length(timenum_daily)
    timenum_tmp = timenum_daily(ti);

    vari = load_models_2d_daily(model, expname, 'temp', g.N, timenum_tmp);
    F.Values = vari(:);
    vari_model(ti) = F(lon_target, lat_target);
end

% Figure
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
pm = plot(timenum_daily, vari_model, '-k', 'LineWidth', 2);
po = plot(timenum_daily, vari_obs, '--r');
xlim([datenum(yyyy,1,1)-1 datenum(yyyy,12,31)+1]);
ylim([8 20])
xticks(datenum(yyyy,1:12,1))
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
ylabel('^oC');
set(gca, 'FontSize', 15)

title('Sea surface temperature')

l = legend([pm, po], 'ROMS', ['OOI buoy (', title_str, ')']);
l.Location = 'NorthWest';

print('cmp_SST_OOI_buoy', '-dpng')
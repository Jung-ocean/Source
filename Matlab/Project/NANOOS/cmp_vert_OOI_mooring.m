%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';

yyyy = 2024;
ystr = num2str(yyyy);

gn = grd('NANOOS');
gw = grd('WCOFS');

% regions_target = {'OR_inshore', 'OR_shelf', 'OR_offshore', 'WA_inshore', 'WA_shelf', 'WA_offshore'};
% regions_target = {'OR_offshore', 'OR_shelf', 'OR_inshore'};
regions_target = {'OR_shelf'}

switch vari_str
    case 'temp'
        scale = 1;
        offset = 0;
        colormap = 'jet';
        climit = [0 18];
        interval = 1;
        [color, contour_interval] = get_color(colormap, climit, interval);
        unit = '^oC';
        title_vari = 'Temperature';
        vari_model = vari_str;
    case 'salt'
        scale = 1;
        offset = 0;
        colormap = 'jet';
        climit = [29 34.5];
        interval = .25;
        [color, contour_interval] = get_color(colormap, climit, interval);
        unit = 'psu';
        title_vari = 'Salinity';
        vari_model = vari_str;
    case 'pden'
        scale = 1;
        offset = -1000;
        colormap = 'jet';
        climit = [23 27];
        interval = .1;
        [color, contour_interval] = get_color(colormap, climit, interval);
        unit = '\sigma_\theta';
        title_vari = 'Potential density';
        vari_model = vari_str;
    case {'uvel', 'vvel'}
        scale = 100;
        offset = 0;
        colormap = 'redblue';
        climit = [-50 50];
        interval = 10;
        [color, contour_interval] = get_color(colormap, climit, interval);
        unit = 'cm/s';
        if strcmp(vari_str, 'uvel')
            title_vari = 'Zonal velocity';
            vari_model = 'u';
        else
            title_vari = 'Meridional velocity';
            vari_model = 'v';
        end
end
clearvars colormap

for ri = 1:length(regions_target)

region = regions_target{ri};

title_str = [title_vari, ' at ', replace(region, '_', ' '), ' (', ystr, ')'];

load_OOI_mooring_info
rindex = find(strcmp(regions, region));
lat_obs = lats(rindex);
lon_obs = lons(rindex);
depth_obs = -depths(rindex);
timenum_ref = datenum(1970,1,1);

if strcmp(vari_str, 'pden')
    load(['temp_', region, '_daily.mat']);
    temp_obs = vari;
    depth_temp = depth;
    load(['salt_', region, '_daily.mat']);
    salt_obs = vari;
    depth_salt = depth;

    index_temp = find(ismember(depth_temp, depth_salt));
    index_salt = find(ismember(depth_salt, depth_temp));

    depth_temp = depth_temp(index_temp);
    temp_obs = temp_obs(index_temp,:);

    depth_salt = depth_salt(index_salt);
    salt_obs = salt_obs(index_salt,:);
    
    depth = depth_salt;
    
    p = gsw_p_from_z(depth,lat_obs);
    [SA, in_ocean] = gsw_SA_from_SP(salt_obs,p,lon_obs,lat_obs);
    CT = gsw_CT_from_t(SA,temp_obs,p);
    pden = gsw_rho(SA,CT,0);
    
    tindex = find(timenum >= datenum(yyyy,1,1) & timenum < datenum(yyyy+1,1,1));
    timenum_obs = timenum(tindex);
    vari_obs = pden(:,tindex);
else
    load([vari_str, '_', region, '_daily.mat']);
    tindex = find(timenum >= datenum(yyyy,1,1) & timenum < datenum(yyyy+1,1,1));
    timenum_obs = timenum(tindex);
    vari_obs = vari(:,tindex);
end

vari_NANOOS = [];
vari_WCOFS = [];
for ti = 1:length(timenum_obs)
    timenum_target = timenum_obs(ti);
    vari_NANOOS(:,ti) = load_models_profile_daily('NANOOS', gn, vari_model, timenum_target, lat_obs, lon_obs, depth);
    vari_WCOFS(:,ti) = load_models_profile_daily('WCOFS', gw, vari_model, timenum_target, lat_obs, lon_obs, depth);
end

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1800 500])
t = tiledlayout(1,3);
title(t, {title_str, ''}, 'FontSize', 20);

ax1 = nexttile(1); hold on; grid on;
% plot_contourf(ax1, timenum_obs, depth, vari_obs.*scale+offset, color, climit, contour_interval);
pcolor(ax1, timenum_obs, depth, vari_obs.*scale+offset); shading flat
colormap(color);
caxis(climit)
xlim([timenum_obs(1)-1 timenum_obs(end)+1]);
ylim([min(depth)-2 0])
xticks(datenum(yyyy,[1 4 7 10],1))
datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
ylabel('Depth (m)')
set(gca, 'FontSize', 12);
title('OOI mooring')

ax2 = nexttile(2); hold on; grid on;
plot_contourf(ax2, timenum_obs, depth, vari_NANOOS.*scale+offset, color, climit, contour_interval);
xlim([timenum_obs(1)-1 timenum_obs(end)+1]);
ylim([min(depth)-2 0])
xticks(datenum(yyyy,[1 4 7 10],1))
datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
yticklabels('')
set(gca, 'FontSize', 12);
title('NANOOS')

ax3 = nexttile(3); hold on; grid on;
plot_contourf(ax3, timenum_obs, depth, vari_WCOFS.*scale+offset, color, climit, contour_interval);
xlim([timenum_obs(1)-1 timenum_obs(end)+1]);
ylim([min(depth)-2 0])
xticks(datenum(yyyy,[1 4 7 10],1))
datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
yticklabels('')
set(gca, 'FontSize', 12);
title('WCOFS')

t.Padding = 'compact';
t.TileSpacing = 'compact';

c = colorbar;
c.Title.String = unit;
c.Layout.Tile = 'east';

pause(3)

print(['cmp_', vari_str, '_OOI_mooring_', region, '_', ystr], '-dpng')

end
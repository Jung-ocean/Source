clear; clc; close all

N = 45;
colors = {'k', 'r', 'b'};

datenum_start = datenum(2018,7,1)+.5;
datenum_end = datenum(2023,12,1);
dt = 15;
timenum_all = datenum_start:dt:datenum_end;

datenum_ref = datenum(1968,5,23);

g = grd('BSf');
theta_s = g.theta_s;
theta_b = g.theta_b;
hc = g.hc;

grid_org = '../grid/grid_1D_DP.nc';
lon = ncread(grid_org, 'lon_rho');
lon = mean(lon(:));
lat = ncread(grid_org, 'lat_rho');
lat = mean(lat(:));
depth = ncread(grid_org, 'h');
depth = mean(depth(:));

temp_HYCOM = NaN(40, length(timenum_all));
salt_HYCOM = NaN(40, length(timenum_all));
temp_diff_3D = NaN(40, length(timenum_all));
salt_diff_3D = NaN(40, length(timenum_all));
temp_diff_1D = NaN(40, length(timenum_all));
salt_diff_1D = NaN(40, length(timenum_all));
for ti = 1:length(timenum_all)
    timenum_tmp = timenum_all(ti);

    profile_hycom = load_HYCOM_profile(lon, lat, floor(timenum_tmp));
    if isstruct(profile_hycom)
        z_hycom = profile_hycom.depth;
        salt_HYCOM(:,ti) = profile_hycom.salt;
        temp_HYCOM(:,ti) = profile_hycom.pt0;

        % ROMS 3D
        profile = load_models_profile('BSf', g, floor(timenum_tmp), lon, lat);
        z_r_3d = profile.depth;
        temp_3d = profile.temp;
        salt_3d = profile.salt;
        
        temp_interp = interp1(z_r_3d, temp_3d, z_hycom);
        temp_diff_3D(:,ti) = temp_interp - temp_HYCOM(:,ti);
        salt_interp = interp1(z_r_3d, salt_3d, z_hycom);
        salt_diff_3D(:,ti) = salt_interp - salt_HYCOM(:,ti);

        % ROMS 1D
        Nstr = num2str(N);
        filepath = ['../output_all/output_N', Nstr, '/'];
        filename = 'avg.nc';
        file = [filepath, filename];
        ot = ncread(file, 'ocean_time');
        timenum = datenum_ref + ot/60/60/24;
        tindex = find(timenum == timenum_tmp);
        
        z_r = squeeze(zlevs(depth,0,theta_s,theta_b,hc,N,'r',2));
        temp = ncread(file, 'temp', [1 1 1 tindex], [Inf Inf Inf 1]);
        temp = squeeze(mean(mean(temp,1),2));
        salt = ncread(file, 'salt', [1 1 1 tindex], [Inf Inf Inf 1]);
        salt = squeeze(mean(mean(salt,1),2));

        temp_interp = interp1(z_r, temp, z_hycom);
        temp_diff_1D(:,ti) = temp_interp - temp_HYCOM(:,ti);
        salt_interp = interp1(z_r, salt, z_hycom);
        salt_diff_1D(:,ti) = salt_interp - salt_HYCOM(:,ti);
    end
end % ti

xlimit = [datenum_start-1 datenum_end+1];
ylimit = [-1000 10];
FS = 15;

f1 = figure;
set(gcf, 'Position', [1 200 1300 800]);
t = tiledlayout(3,2);
t.Padding = 'compact';
t.TileSpacing = 'tight';

% temp HYCOM
ax1 = nexttile(1);
climit = [-2 12];
interval = 1;
[color, contour_interval] = get_color('jet', climit, interval);
pcolor(timenum_all, z_hycom, temp_HYCOM);
caxis(climit)
colormap(ax1, color)
c = colorbar(ax1);
c.Title.String = '^oC';
c.Ticks = contour_interval;
shading flat
xlim(xlimit);
ylim(ylimit);
xticks(datenum(2018:2024,1,1));
ylabel('Depth (m)')
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
title('Temp (HYCOM)', 'FontSize', FS);

% salt HYCOM
ax2 = nexttile(2);
climit = [32 35];
interval = .3;
[color, contour_interval] = get_color('jet', climit, interval);
pcolor(timenum_all, z_hycom, salt_HYCOM);
caxis(climit)
colormap(ax2, color)
c = colorbar;
c.Title.String = 'psu';
c.Ticks = contour_interval;
shading flat
xlim(xlimit);
ylim(ylimit);
xticks(datenum(2018:2024,1,1));
ylabel('Depth (m)')
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
title('Salt (HYCOM)', 'FontSize', FS);

% temp diff (3d)
ax3 = nexttile(3);
climit = [-3 3];
interval = .5;
[color, contour_interval] = get_color('redblue', climit, interval);
pcolor(timenum_all, z_hycom, temp_diff_3D);
caxis(climit)
colormap(ax3, color)
c = colorbar;
c.Title.String = '^oC';
c.Ticks = contour_interval;
shading flat
xlim(xlimit);
ylim(ylimit);
xticks(datenum(2018:2024,1,1));
ylabel('Depth (m)')
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
title('Temp (ROMS 3D - HYCOM)', 'FontSize', FS);

% salt diff (3d)
ax4 = nexttile(4);
climit = [-.5 .5];
interval = .1;
[color, contour_interval] = get_color('redblue', climit, interval);
pcolor(timenum_all, z_hycom, salt_diff_3D);
caxis(climit)
colormap(ax4, color)
c = colorbar;
c.Title.String = 'psu';
c.Ticks = contour_interval;
shading flat
xlim(xlimit);
ylim(ylimit);
xticks([datenum(2018:2024,1,1)]);
ylabel('Depth (m)')
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
title('Salt (ROMS 3D - HYCOM)', 'FontSize', FS);

% temp diff (1d)
ax5 = nexttile(5);
climit = [-3 3];
interval = .5;
[color, contour_interval] = get_color('redblue', climit, interval);
pcolor(timenum_all, z_hycom, temp_diff_1D);
caxis(climit)
colormap(ax5, color)
c = colorbar;
c.Title.String = '^oC';
c.Ticks = contour_interval;
shading flat
xlim(xlimit);
ylim(ylimit);
xticks(datenum(2018:2024,1,1));
ylabel('Depth (m)')
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
title('Temp (ROMS 1D - HYCOM)', 'FontSize', FS);

% salt diff (1d)
ax6 = nexttile(6);
climit = [-.5 .5];
interval = .1;
[color, contour_interval] = get_color('redblue', climit, interval);
pcolor(timenum_all, z_hycom, salt_diff_1D);
caxis(climit)
colormap(ax6, color)
c = colorbar;
c.Title.String = 'psu';
c.Ticks = contour_interval;
shading flat
xlim(xlimit);
ylim(ylimit);
xticks([datenum(2018:2024,1,1)]);
ylabel('Depth (m)')
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
title('Salt (ROMS 1D - HYCOM)', 'FontSize', FS);

print('temp_and_salt', '-dpng')
clear; clc

station = '46050';
lon_target = -124.535;
lat_target = 44.679;

ismap = 1;
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
    print(['map_cmp_vwind'], '-dpng')
end

yyyy = 2024;

% Observation (NDBC)
[timenum_obs, vari] = load_NDBC('46050', 'wind', yyyy);
vwind_obs = vari.vwind;

% CFSv2
filepath = '/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Setups/Forcing/';
filename = 'Vwind_2024.nc';
file = [filepath, filename];
wind_time = ncread(file, 'wind_time');
timenum = datenum(2024,1,1) + wind_time;
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');
vwind = ncread(file, 'Vwind');

F = scatteredInterpolant(lon(:), lat(:), 0.*lat(:));

vwind_interp = [];
for ti = 1:length(wind_time)
    vwind_tmp = vwind(:,:,ti);
    F.Values = vwind_tmp(:);
    vwind_interp(ti) = F(lon_target, lat_target);
end

% Figure
figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pm = plot(timenum, vwind_interp, '-k', 'LineWidth', 2);
po = plot(timenum_obs, vwind_obs, '--r');
xlim([datenum(yyyy,1,1)-1 datenum(yyyy,12,31)+1]);
ylim([-30 30])
xticks(datenum(yyyy,1:2:12,1))
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
ylabel('m/s');
set(gca, 'FontSize', 15)

title('Meridional wind')

l = legend([pm, po], 'CFSv2', 'NDBC (46050)');
l.Location = 'Southwest';
l.NumColumns = 2;

print('cmp_vwind', '-dpng')
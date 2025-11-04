clear; clc

g = grd('NANOOS');

timenum_start = datenum(2025,9,23);
timenum_end = datenum(2025,10,13);

filepath = '/data/jungjih/RTDAOW2/Prm/BC/';

time_ref = datenum(2005,1,1);
ind_south = 110;
ind_west = 270;
ind_north = 70;

figure; hold on;
set(gcf, 'Position', [1 200 500 800])
plot_map('US_west', 'mercator', 'l')
plotm(g.lat_rho(ind_south,1)+.1, g.lon_rho(ind_south,1), 'xb', 'MarkerSize', 25, 'LineWidth', 3);
plotm(g.lat_rho(1,ind_west), g.lon_rho(1,ind_west)+0.1, 'xg', 'MarkerSize', 25, 'LineWidth', 3);
plotm(g.lat_rho(ind_north,end)-.1, g.lon_rho(ind_north,1), 'xr', 'MarkerSize', 25, 'LineWidth', 3);
print(['location_bndy_point'], '-dpng');

ot = [];
zeta_south = [];
zeta_west = [];
zeta_north = [];
for ti = timenum_start:timenum_end
    timenum = ti;
    timenum2 = timenum+8;
    tstr = datestr(timenum, 'dd-mmm-yyyy');
    tstr2 = datestr(timenum2, 'dd-mmm-yyyy');

    filename = ['orw2km_bc_hycom', tstr, '_', tstr2, '.nc'];
    file = [filepath, filename];

    ot_tmp = ncread(file, 'ocean_time');
    zeta_south_tmp = ncread(file, 'zeta_south', [ind_south, 1], [1, Inf]);
    zeta_west_tmp = ncread(file, 'zeta_south', [ind_west, 1], [1, Inf]);
    zeta_north_tmp = ncread(file, 'zeta_north', [ind_south, 1], [1, Inf]);

    if ti == timenum_start
        ot = [ot; ot_tmp];
        zeta_south = [zeta_south; zeta_south_tmp'];
        zeta_west = [zeta_west; zeta_west_tmp'];
        zeta_north = [zeta_north; zeta_north_tmp'];
    else
        index = find(~ismember(ot, ot_tmp));

        ot = [ot(index); ot_tmp];
        zeta_south = [zeta_south(index); zeta_south_tmp'];
        zeta_west = [zeta_west(index); zeta_west_tmp'];
        zeta_north = [zeta_north(index); zeta_north_tmp'];
    end

    disp([tstr, ' - ', tstr2, '...'])
end
ot_datenum = ot + time_ref;

figure; hold on; grid on
set(gcf, 'Position', [1 200 1300 800])
t = tiledlayout(3,1);

nexttile(1); hold on; grid on;
plot(ot_datenum, zeta_north, '.-r')
ylim([-2 2])
xticks(timenum_start:14:timenum_end)
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
xticklabels('')
ylabel('SSH (m)');
set(gca, 'FontSize', 15)
title('Northern boundary')

nexttile(2); hold on; grid on;
plot(ot_datenum, zeta_west, '.-g')
ylim([-2 2])
xticks(timenum_start:14:timenum_end)
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
xticklabels('')
ylabel('SSH (m)');
set(gca, 'FontSize', 15)
title('Western boundary')

nexttile(3); hold on; grid on;
plot(ot_datenum, zeta_south, '.-b')
ylim([-2 2])
xticks(timenum_start:14:timenum_end)
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
ylabel('SSH (m)');
set(gca, 'FontSize', 15)
title('Southern boundary')
asdf
print('zeta_bndy', '-dpng')
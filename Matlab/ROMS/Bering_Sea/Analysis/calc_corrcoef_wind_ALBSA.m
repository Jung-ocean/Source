clear; clc; %close all

lon_target = -177;
lat_target = 63.5;
ismap = 0;

if ismap == 1
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('Gulf_of_Anadyr', 'mercator', 'l')
    plotm(lat_target, lon_target, 'xr', 'LineWidth', 5, 'MarkerSize', 30)
    print('point_corrcoef', '-dpng')
end

% wgs84 = wgs84Ellipsoid("km");
% angle = 90 - azimuth(62.4042, -180.9088, 64.2745, -173.0732, wgs84);
angle = 45;

yyyy_all = 2019:2022;
mm_all = 4:7;

filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/';

figure;
set(gcf, 'Position', [1 200 600 900])
t = tiledlayout(4,1);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    wtime = [];
    wind_NE = [];
    wind_NW = [];
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        filename = ['BSf_ERA5_', ystr, '_', mstr, '_ni2_a_frc.nc'];
        file = [filepath, filename];
        lon = ncread(file, 'lon');
        lat = ncread(file, 'lat');
        
        dist = sqrt((lon - lon_target).^2 + (lat - lat_target).^2);
        distind = find(dist == min(dist(:)));
        [lonind, latind] = ind2sub(size(lon), distind);

        windtime_tmp = ncread(file, 'sfrc_time');
        windtimenum = datenum(windtime_tmp + datenum(1968,5,23));
        windtimenum_daily = unique(floor(windtimenum));
        uwind = squeeze(ncread(file, 'Uwind', [lonind latind 1], [1 1 Inf]));
        vwind = squeeze(ncread(file, 'Vwind', [lonind latind 1], [1 1 Inf]));

        uwind_daily = [];
        vwind_daily = [];
        for wi = 1:length(windtimenum_daily)
            index = find( floor(windtimenum) == windtimenum_daily(wi) );
            uwind_daily(wi) = mean(uwind(index));
            vwind_daily(wi) = mean(vwind(index));
        end
        
        wind_NE_tmp = uwind_daily.*cosd(-angle) - vwind_daily.*sind(-angle);
        wind_NW_tmp = uwind_daily.*sind(-angle) + vwind_daily.*cosd(-angle);

        wtime = [wtime; windtimenum_daily];
        wind_NE = [wind_NE; wind_NE_tmp'];
        wind_NW = [wind_NW; wind_NW_tmp'];
    end
    ALBSA = load_ALBSA(wtime, 'daily');

    [R, P] = corrcoef(wind_NE, ALBSA);
    
    nexttile(yi); hold on; grid on;
    p1 = plot(wtime, wind_NE, '-k', 'LineWidth', 2);
    ylim([-20 20])
    ylabel('NE wind (m/s)')
    yyaxis right
    set(gca, 'Ycolor', 'r')
    p2 = plot(wtime, ALBSA, '-r', 'LineWidth', 2);
    ylim([-700 700]);
    ylabel('ALBSA');
    xticks(datenum(yyyy,1:12,1));
    xlim([wtime(1)-1 wtime(end)+1])
    datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
    if yi == length(yyyy_all)
        xlabel('Date')
    else
        xticklabels('')
    end
    set(gca, 'FontSize', 12)
    xtickangle(0)
    title([ystr, ' (R = ', num2str(R(1,2), '%.2f'), ', p-value = ', num2str(P(1,2), '%.2f'), ')'], 'FontSize', 15)
end

print(['corrcoef_wind_ALBSA'], '-dpng')
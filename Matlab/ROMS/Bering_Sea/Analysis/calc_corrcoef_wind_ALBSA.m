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
mm_start = 4;
dd_start = 15;
mm_end = 7;
dd_end = 28;

labels = {'(a)', '(b)', '(c)', '(d)'};

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
    
    ALBSA = movmean(ALBSA,7, 'Endpoints', 'fill');
    wind_NE = movmean(wind_NE,7, 'Endpoints', 'fill');

    datenum_start = datenum(yyyy,mm_start, dd_start);
    datenum_end = datenum(yyyy,mm_end, dd_end);
    tindex = find(wtime > datenum_start-1 & wtime < datenum_end+1);

%     [R, P] = corrcoef(wind_NE(tindex), ALBSA(tindex));
    [R, P, P_ess, ESS] = calc_ess_and_pvalue(wind_NE(tindex),ALBSA(tindex));
    [P_ess, ESS]

    nexttile(yi); hold on; grid on;
    p1 = plot(wtime(tindex), wind_NE(tindex), '-k', 'LineWidth', 2);
    ylim([-10 10])
    ylabel('NE wind (m/s)')
    yyaxis right
    set(gca, 'Ycolor', 'r')
    p2 = plot(wtime(tindex), ALBSA(tindex), '-r', 'LineWidth', 2);
    ylim([-400 400]);
    ylabel('ALBSA (m)');
    xticks(datenum(yyyy,1:12,1));
    xlim([datenum_start-1 datenum_end+1])
    datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
    if yi == length(yyyy_all)
        xlabel('Date')
    else
        xticklabels('')
    end
    set(gca, 'FontSize', 12)
    xtickangle(0)
    title([labels{yi}, ' ', ystr, ' (R = ', num2str(R, '%.2f'), ', p-value = ', num2str(P_ess, '%.2f'), ')'], 'FontSize', 15)
end
asdf
print(['corrcoef_wind_ALBSA'], '-dpng')
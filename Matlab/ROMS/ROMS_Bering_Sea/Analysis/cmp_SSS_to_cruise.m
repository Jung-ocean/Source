%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare SSS to cruise data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
g = grd('BSf');
startdate = datenum(2018,7,1);
filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

f1_mm_ind = 8;
f3_mm_ind = 7;

files = {
    '/data/jungjih/Observations/Nomura_etal_2021/data_Nomura_etal_2021_2018.mat'
    '/data/jungjih/Observations/NIPR_ARD/A20191216-015/data_NIPR_ARD_2017.mat'
    '/data/jungjih/Observations/NIPR_ARD/A20240705-007/data_NIPR_ARD_2023.mat'
    };

filenames_obs = {
    'Nomura_etal_2021_2018'
    'NIPR_ARD_2017'
    'NIPR_ARD_2023'
    };

titles = {
    'T/S Oshoro-maru'
    'T/S Oshoro-maru'
    'T/S Oshoro-maru'
    };
if f1_mm_ind == 8
    titles{1} = 'R/V Multanovsky';
end

climit = [29 34];
interval = 0.25;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';

polygon = [;
    -185   60
    -170   60
    -170   66.3040
    -185   66.3040
    -185   60
    ];

h1 = figure; hold on; grid on;
t = tiledlayout(2,2);
set(gcf, 'Position', [1 200 800 800])
nexttile(1)
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
nexttile(2)
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
nexttile(3)
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
nexttile(4)
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

ms = 70;

for fi = 1:length(files)

    file_obs = files{fi};
    data = load(file_obs);

    lat = data.lat;
    lon = data.lon;
    salt = data.SSS;
    timenum_all = data.timenum;
    timevec = datevec(timenum_all);

    if fi == 1
        index = find(timevec(:,2) == f1_mm_ind);
        lat = lat(index);
        lon = lon(index);
        salt = salt(index);
        timenum_all = timenum_all(index);
    end
    if fi == 3
        index = find(timevec(:,2) == f3_mm_ind);
        lat = lat(index);
        lon = lon(index);
        salt = salt(index);
        timenum_all = timenum_all(index);
    end

    nexttile(1)
    pc = scatterm(lat, lon, ms, salt, 'Filled', 'MarkerEdgeColor', 'k');
    [in, on] = inpolygon(lon, lat, polygon(:,1), polygon(:,2));
    if fi == 3 && f3_mm_ind == 7
        in(1) = 0;
    end
    %     tc = textm(lat(1:7:end), lon(1:7:end)+1, datestr(timenum_all(1:7:end), 'dd'), 'FontWeight', 'bold', 'FontSize', 8);
    colormap(color)
    caxis(climit);

    title(titles{fi});
    title(t, {[datestr(min(timenum_all(in)), 'mmm dd, yyyy'), ' - ',  datestr(max(timenum_all(in)), 'mmm dd, yyyy')], ''})

    ot = zeros;
    SST_model = zeros;
    SSS_model = zeros;
    for ti = 1:length(timenum_all)
        timenum = floor(timenum_all(ti));
        filenum = timenum - startdate + 1;
        fstr = num2str(filenum, '%04i');
        filename = [exp, '_avg_', fstr, '.nc'];
        file = [filepath, filename];
        if exist(file)
            SST = ncread(file, 'temp', [1, 1, g.N, 1], [Inf, Inf, 1, Inf])';
            SSS = ncread(file, 'salt', [1, 1, g.N, 1], [Inf, Inf, 1, Inf])';
            ot(ti) = ncread(file, 'ocean_time')/60/60/24 + datenum(1968,5,23);

            lat_mean = lat(ti);
            lon_mean = lon(ti);

            SST_model(ti) = interp2(g.lon_rho, g.lat_rho, SST, lon_mean, lat_mean);
            SSS_model(ti) = interp2(g.lon_rho, g.lat_rho, SSS, lon_mean, lat_mean);
        else
            ot(ti) = NaN;
            SST_model(ti) = NaN;
            SSS_model(ti) = NaN;
        end
    end

    % SSS plot
    nexttile(2);
    pm = scatterm(lat, lon, ms, SSS_model, 'Filled', 'MarkerEdgeColor', 'k');
    colormap(color)
    caxis(climit);
    title('ROMS (daily)')

    filename_obs = filenames_obs{fi};
    %SMAP
    data_SMAP = load(['./SMAP/SSS_SMAP_', filename_obs, '.mat']);
    lat_SMAP = data_SMAP.lat_SMAP;
    lon_SMAP = data_SMAP.lon_SMAP;
    SSS_SMAP = data_SMAP.SSS_SMAP;
    if exist('index')
        lat_SMAP = lat_SMAP(index);
        lon_SMAP = lon_SMAP(index);
        SSS_SMAP = SSS_SMAP(index);
    end

    nexttile(3);
    psmap = scatterm(lat_SMAP, lon_SMAP, ms, SSS_SMAP, 'Filled', 'MarkerEdgeColor', 'k');
    colormap(color)
    caxis(climit);
    title('SMAP (daily 8-day running)')

    %SMOS
    data_SMOS = load(['./SMOS/SSS_SMOS_', filename_obs, '.mat']);
    lat_SMOS = data_SMOS.lat_SMOS;
    lon_SMOS = data_SMOS.lon_SMOS;
    SSS_SMOS = data_SMOS.SSS_SMOS;
    if exist('index')
        lat_SMOS = lat_SMOS(index);
        lon_SMOS = lon_SMOS(index);
        SSS_SMOS = SSS_SMOS(index);
    end

    nexttile(4);
    psmos = scatterm(lat_SMOS, lon_SMOS, ms, SSS_SMOS, 'Filled', 'MarkerEdgeColor', 'k');
    colormap(color)
    caxis(climit);
    title('SMOS (4-day or the closest date)')

    c = colorbar;
    c.Title.String = unit;
    c.Layout.Tile = 'east';

    t.Padding = 'compact';
    t.TileSpacing = 'compact';

    if fi == 1 && exist('index')
        print(['cmp_SSS_to_cruise_', filename_obs, '_', num2str(f1_mm_ind)], '-dpng')
    elseif fi == 3 && exist('index')
        print(['cmp_SSS_to_cruise_', filename_obs, '_', num2str(f3_mm_ind)], '-dpng')
    else
        print(['cmp_SSS_to_cruise_', filename_obs], '-dpng')
    end

    delete(pc)
    %     delete(tc)
    delete(pm)
    delete(psmap)
    delete(psmos)
    delete(c)
    clearvars index
end

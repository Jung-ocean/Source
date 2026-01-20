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

ismonthly = 0;
if ismonthly == 1
    filename_last = '_monthly';
else
    filename_last = '';
end

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
[color, contour_interval] = get_color('jet', climit, interval);
unit = 'psu';

polygon = [;
    -185   60
    -170   60
    -170   66.3040
    -185   66.3040
    -185   60
    ];

climit2 = [-2 2];
interval2 = 0.5;
[color2, contour_interval2] = get_color('redblue', climit2, interval2);

h1 = figure; hold on; grid on;
t = tiledlayout(2,2);
t.Padding = 'compact';
t.TileSpacing = 'compact';
set(gcf, 'Position', [1 200 900 800])
nexttile(1)
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
nexttile(2)
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
nexttile(3)
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
nexttile(4)
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

ms = 70;

for fi = 1:length(files)

    file_obs = files{fi};
    filename_obs = filenames_obs{fi};
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

    ax1 = nexttile(1);
    pc = scatterm(lat, lon, ms, salt, 'Filled', 'MarkerEdgeColor', 'k');
    [in, on] = inpolygon(lon, lat, polygon(:,1), polygon(:,2));
    if fi == 3 && f3_mm_ind == 7
        in(1) = 0;
    end
    %     tc = textm(lat(1:7:end), lon(1:7:end)+1, datestr(timenum_all(1:7:end), 'dd'), 'FontWeight', 'bold', 'FontSize', 8);
    colormap(ax1, color)
    caxis(climit);
    c1 = colorbar;
    c1.Title.String = unit;

    title(['in-situ (', titles{fi}, ')']);
    title(t, {[datestr(min(timenum_all(in)), 'mmm dd, yyyy'), ' - ',  datestr(max(timenum_all(in)), 'mmm dd, yyyy')], ''})

    plabel('FontSize', 12);
    mlabel('off');

    %SMAP
    ax2 = nexttile(2);
    if ismonthly == 1
        data_SMAP = load(['./SMAP/SSS_SMAP_', filename_obs, '_monthly.mat']);
        title('SMAP (monthly) - in-situ')
    else
        data_SMAP = load(['./SMAP/SSS_SMAP_', filename_obs, '.mat']);
        title('SMAP (daily 8-day running) - in-situ')
    end
    plabel('off');
    mlabel('off');

    lat_SMAP = data_SMAP.lat_SMAP;
    lon_SMAP = data_SMAP.lon_SMAP;
    SSS_SMAP = data_SMAP.SSS_SMAP;
    if exist('index')
        lat_SMAP = lat_SMAP(index);
        lon_SMAP = lon_SMAP(index);
        SSS_SMAP = SSS_SMAP(index);
    end

    psmap = scatterm(lat_SMAP, lon_SMAP, ms, SSS_SMAP-salt, 'Filled', 'MarkerEdgeColor', 'k');
    colormap(ax2, color2)
    caxis(climit2);
    c2 = colorbar;
    c2.Title.String = unit;

%     if f1_mm_ind == 8 && fi == 1
%         ind_rmse = find(lat > 62.5 & lon < -173 & isnan(SSS_SMAP) == 0);
%         RMSE_SMAP = sqrt( mean( (SSS_SMAP(ind_rmse)-salt(ind_rmse)).^2 ) );
%         trmse(2) = textm(65.7, -184.7, {'RMSE', 'near the GA', [num2str(RMSE_SMAP, '%.2f'), ' psu']}, 'FontSize', 12);
%     end

    %SMOS
    ax3 = nexttile(3);
    if ismonthly == 1
        data_SMOS = load(['./SMOS/SSS_SMOS_', filename_obs, '_monthly.mat']);
        title('SMOS (monthly) - in-situ')
    else
        data_SMOS = load(['./SMOS/SSS_SMOS_', filename_obs, '.mat']);
        title('SMOS CEC (4-day or closest) - in-situ')
    end
    plabel('FontSize', 12);
    mlabel('FontSize', 12);

    lat_SMOS = data_SMOS.lat_SMOS;
    lon_SMOS = data_SMOS.lon_SMOS;
    SSS_SMOS = data_SMOS.SSS_SMOS;
    if exist('index')
        lat_SMOS = lat_SMOS(index);
        lon_SMOS = lon_SMOS(index);
        SSS_SMOS = SSS_SMOS(index);
    end

    psmos = scatterm(lat_SMOS, lon_SMOS, ms, SSS_SMOS-salt, 'Filled', 'MarkerEdgeColor', 'k');
    colormap(ax3, color2)
    caxis(climit2);
    
%     if f1_mm_ind == 8 && fi == 1
%         ind_rmse = find(lat > 62.5 & lon < -173 & isnan(SSS_SMOS) == 0);
%         RMSE_SMOS = sqrt( mean( (SSS_SMOS(ind_rmse)-salt(ind_rmse)).^2 ) );
%         trmse(3) = textm(65.7, -184.7, {'RMSE', 'near the GA', [num2str(RMSE_SMOS, '%.2f'), ' psu']}, 'FontSize', 12);
%     end

    %SMOS_BEC
    ax4 = nexttile(4);
    if ismonthly == 1
        data_SMOS_BEC = load(['./SMOS_BEC/SSS_SMOS_BEC_', filename_obs, '_monthly.mat']);
        title('SMOS BEC (monthly) - in-situ')
    else
        data_SMOS_BEC = load(['./SMOS_BEC/SSS_SMOS_BEC_', filename_obs, '.mat']);
        title('SMOS BEC (daily 9-day running) - in-situ')
    end
    plabel('off');
    mlabel('FontSize', 12);

    lat_SMOS_BEC = data_SMOS_BEC.lat_SMOS_BEC;
    lon_SMOS_BEC = data_SMOS_BEC.lon_SMOS_BEC;
    SSS_SMOS_BEC = data_SMOS_BEC.SSS_SMOS_BEC;
    if exist('index')
        lat_SMOS_BEC = lat_SMOS_BEC(index);
        lon_SMOS_BEC = lon_SMOS_BEC(index);
        SSS_SMOS_BEC = SSS_SMOS_BEC(index);
    end

    psmos_bec = scatterm(lat_SMOS_BEC, lon_SMOS_BEC, ms, SSS_SMOS_BEC-salt, 'Filled', 'MarkerEdgeColor', 'k');
    colormap(ax4, color2)
    caxis(climit2);
    
%     if f1_mm_ind == 8 && fi == 1
%         ind_rmse = find(lat > 62.5 & lon < -173 & isnan(SSS_SMOS_BEC) == 0);
%         RMSE_SMOS_BEC = sqrt( mean( (SSS_SMOS_BEC(ind_rmse)-salt(ind_rmse)).^2 ) );
%         trmse(4) = textm(65.7, -184.7, {'RMSE', 'near the GA', [num2str(RMSE_SMOS_BEC, '%.2f'), ' psu']}, 'FontSize', 12);
%     end

    if fi == 1 && exist('index')
        print(['cmp_SSS_to_cruise_', filename_obs, '_', num2str(f1_mm_ind), filename_last], '-dpng')
    elseif fi == 3 && exist('index')
        print(['cmp_SSS_to_cruise_', filename_obs, '_', num2str(f3_mm_ind), filename_last], '-dpng')
    else
        print(['cmp_SSS_to_cruise_', filename_obs, filename_last], '-dpng')
    end
asdf
    delete(pc)
    %     delete(tc)
    delete(pm)
    delete(psmap)
    delete(psmos)
    clearvars index
    if f1_mm_ind == 8 && fi == 1
        delete(trmse)
    end
    
end

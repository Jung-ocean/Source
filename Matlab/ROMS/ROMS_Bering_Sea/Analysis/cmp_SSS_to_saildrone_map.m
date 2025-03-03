%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare SSS to saildrone data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
g = grd('BSf');
startdate = datenum(2018,7,1);
filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

filepath_obs = '/data/jungjih/Observations/Saildrone/PMEL_ERDDAP/data/';
filename_obs_all = dir([filepath_obs, '/*.nc']);

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

for fi = [14 15 17]%1:length(filename_obs_all)
    filename_obs = filename_obs_all(fi).name;
    file_obs = [filepath_obs, filename_obs];
    
    lat = ncread(file_obs, 'latitude');
    lon = ncread(file_obs, 'longitude');
    time = ncread(file_obs, 'time');
    time_units = ncreadatt(file_obs, 'time', 'units');
    id = ncreadatt(file_obs, '/', 'drone_id');
    if strcmp(time_units(1:7), 'seconds')
        timenum_ref = datenum(time_units(15:end), 'yyyy-mm-ddTHH:MM:SSZ');
        timenum_all = time/60/60/24 + timenum_ref;
    else
        pause
    end
    timenum_daily = unique(floor(timenum_all));
    yyyy = str2num(datestr(timenum_daily, 'yyyy'));

    try
        temp_sbe37 = ncread(file_obs, 'TEMP_SBE37_MEAN');
        ind_Tsbe37 = 1;
    catch
        ind_Tsbe37 = 0;
    end

    try
        temp_rbr = ncread(file_obs, 'TEMP_CTD_RBR_MEAN');
        ind_Trbr = 1;
    catch
        ind_Trbr = 0;
    end
    
    try
        salt = ncread(file_obs, 'SAL_SBE37_MEAN');
        ind_S = 1;
    catch
        ind_S = 0;
    end
    
    if sum(ismember(2019:2022, yyyy)) > 0 & ind_S == 1

        nexttile(1)
        pc = scatterm(lat, lon, ms, salt, 'Filled', 'MarkerEdgeColor', 'none');
        [in, on] = inpolygon(lon, lat, polygon(:,1), polygon(:,2));
        if fi == 14
            index = find(timenum_all == 737675);
            tc(1) = textm(lat(index)+0.5, lon(index)-2, datestr(timenum_all(index), 'mmm dd'), 'FontWeight', 'bold', 'FontSize', 8);
            index = find(timenum_all == 737594);
            tc(2) = textm(lat(index)+0.5, lon(index)-2, datestr(timenum_all(index), 'mmm dd'), 'FontWeight', 'bold', 'FontSize', 8);
            index = find(timenum_all == 737583);
            tc(3) = textm(lat(index)+0.5, lon(index)-2, datestr(timenum_all(index), 'mmm dd'), 'FontWeight', 'bold', 'FontSize', 8);
        elseif fi == 15
            index = find(timenum_all == 738002);
            tc(1) = textm(lat(index)+0.5, lon(index)-2, datestr(timenum_all(index), 'mmm dd'), 'FontWeight', 'bold', 'FontSize', 8);
        elseif fi == 17
            index = find(timenum_all == 737996);
            tc(1) = textm(lat(index)+0.5, lon(index)-2, datestr(timenum_all(index), 'mmm dd'), 'FontWeight', 'bold', 'FontSize', 8);
            index = find(timenum_all == datenum(2020,8,8,1,0,0));
            tc(2) = textm(lat(index)+0.5, lon(index)-2, datestr(timenum_all(index), 'mmm dd'), 'FontWeight', 'bold', 'FontSize', 8);
        end
        colormap(color)
        caxis(climit);

        title(['Saildrone ID ', id, ' (', datestr(diff(timenum_all(1:2)), 'HH:MM'), ')']);
        title(t, {[datestr(min(timenum_all(in)), 'mmm dd, yyyy'), ' - ',  datestr(max(timenum_all(in)), 'mmm dd, yyyy')], ''})

        ot = zeros;
        SST_model = zeros;
        SSS_model = zeros;
        lat_mean = zeros;
        lon_mean = zeros;
        for ti = 1:length(timenum_daily)
            timenum = timenum_daily(ti);
            filenum = timenum - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = [exp, '_avg_', fstr, '.nc'];
            file = [filepath, filename];
            SST = ncread(file, 'temp', [1, 1, g.N, 1], [Inf, Inf, 1, Inf])';
            SSS = ncread(file, 'salt', [1, 1, g.N, 1], [Inf, Inf, 1, Inf])';
            ot(ti) = ncread(file, 'ocean_time')/60/60/24 + datenum(1968,5,23);
        
            index = find(timenum_all >= timenum & timenum_all < timenum+1);
            lat_mean(ti) = mean(lat(index), 'omitnan');
            lon_mean(ti) = mean(lon(index), 'omitnan');
            
            SST_model(ti) = interp2(g.lon_rho, g.lat_rho, SST, lon_mean(ti), lat_mean(ti));
            SSS_model(ti) = interp2(g.lon_rho, g.lat_rho, SSS, lon_mean(ti), lat_mean(ti));
        end
      
        % SSS plot
        nexttile(2);
        pm = scatterm(lat_mean, lon_mean, ms, SSS_model, 'Filled', 'MarkerEdgeColor', 'k');
        colormap(color)
        caxis(climit);
        title('ROMS (daily)')
        %SMAP
        data_SMAP = load(['./SMAP/SSS_SMAP_', filename_obs, '.mat']);
        lat_SMAP = data_SMAP.lat_SMAP;
        lon_SMAP = data_SMAP.lon_SMAP;
        SSS_SMAP = data_SMAP.SSS_SMAP;
       
    nexttile(3);
    psmap = scatterm(lat_SMAP, lon_SMAP, ms, SSS_SMAP, 'Filled', 'MarkerEdgeColor', 'k');
    colormap(color)
    caxis(climit);
    title('SMAP (daily 8-day running)')

%         4 days or the closest date available

        %SMOS
        data_SMOS = load(['./SMOS/SSS_SMOS_', filename_obs, '.mat']);
        lat_SMOS = data_SMOS.lat_SMOS;
        lon_SMOS = data_SMOS.lon_SMOS;
        SSS_SMOS = data_SMOS.SSS_SMOS;
       
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

        print(['cmp_SSS_to_saildrone_', id, '_', datestr(min(timenum_all), 'yyyymmdd'), '_', datestr(max(timenum_all), 'yyyymmdd')], '-dpng')

        delete(pc)
        delete(tc)
        delete(pm)
        delete(psmap)
        delete(psmos)
        delete(c)
    end
end
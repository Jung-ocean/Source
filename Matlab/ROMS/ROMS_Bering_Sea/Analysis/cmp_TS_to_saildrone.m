%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot Saildron data using data from ERDDAP 
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

h1 = figure; hold on; grid on;
t = tiledlayout(2,2);
set(gcf, 'Position', [1 200 1600 500])
nexttile(1, [2 1])
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
colormap parula

for fi = 1:length(filename_obs_all)
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

        nexttile(1, [2 1])
        p = scatterm(lat, lon, 10, timenum_all);
        caxis([min(timenum_all) max(timenum_all)]);
        c = colorbar;
        datetick(c, 'y', 'yyyy-mm-dd', 'keeplimits');

        title(['Saildrone ID ', id, ' (', datestr(min(timenum_all), 'mmm dd, yyyy'), ' - ', datestr(max(timenum_all), 'mmm dd, yyyy'), ') ']);

        ot = zeros;
        SST_model = zeros;
        SSS_model = zeros;
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
            lat_mean = mean(lat(index), 'omitnan');
            lon_mean = mean(lon(index), 'omitnan');
            
            SST_model(ti) = interp2(g.lon_rho, g.lat_rho, SST, lon_mean, lat_mean);
            SSS_model(ti) = interp2(g.lon_rho, g.lat_rho, SSS, lon_mean, lat_mean);
        end

        % SST plot
        nexttile(2); cla; hold on; grid on;
        if ind_Tsbe37 == 1
            pSST_sbe37 = plot(timenum_all, temp_sbe37, '.', 'Color', [0.4667 0.6745 0.1882]);
        end
        if ind_Trbr == 1
            pSST_rbr = plot(timenum_all, temp_rbr, '.', 'Color', [0.9294 0.6941 0.1255]);
        end
        pSST_model = plot(ot, SST_model, '-k', 'LineWidth', 2);
        datetick('x', 'mmm yyyy', 'keeplimits')
        ylabel('^oC');
        ylim([0 15])

        if ind_Tsbe37 == 1 & ind_Trbr == 1
            l = legend([pSST_sbe37 pSST_rbr pSST_model], 'Saildrone (SBE 37)', 'Saildrone (RBR)', 'ROMS');
        elseif ind_Tsbe37 == 1 & ind_Trbr ~= 1
            l = legend([pSST_sbe37 pSST_model], 'Saildrone (SBE 37)', 'ROMS');
        else
            l = legend([pSST_rbr pSST_model], 'Saildrone (RBR)', 'ROMS');
        end
        l.FontSize = 12;
        l.Location = 'SouthOutside';
        l.NumColumns = 3;
        title(['SST, Saildrone (', datestr(timenum_all(2) - timenum_all(2), 'mm'), ' min) vs ROMS (daily)'])

        % SSS plot
        nexttile(4); cla; hold on; grid on;
        pSSS_sail = plot(timenum_all, salt, '.', 'Color', [0.4667 0.6745 0.1882]);
        pSSS_model = plot(ot, SSS_model, '-k', 'LineWidth', 2);
        %SMAP
        load(['./SMAP/SSS_SMAP_', filename_obs, '.mat']);
        pSSS_SMAP = plot(timenum_SMAP, SSS_SMAP, '.r', 'MarkerSize', 12);
        %SMOS
        load(['./SMOS/SSS_SMOS_', filename_obs, '.mat']);
        pSSS_SMOS = plot(timenum_SMOS, SSS_SMOS, '.b', 'MarkerSize', 12);

        datetick('x', 'mmm yyyy', 'keeplimits')
        ylabel('psu');
        ylim([25 34])
        
        l = legend([pSSS_sail pSSS_model pSSS_SMAP pSSS_SMOS], 'Saildrone (SBE 37)', 'ROMS', 'SMAP', 'SMOS');
        l.FontSize = 12;
        l.Location = 'SouthOutside';
        l.NumColumns = 4;
        title(['SSS, Saildrone (', datestr(timenum_all(2) - timenum_all(2), 'mm'), ' min) vs ROMS (daily) vs SMAP (daily 8d running) vs SMOS (4 day)'])

        print(['cmp_TS_to_saildrone_', id, '_', datestr(min(timenum_all), 'yyyymmdd'), '_', datestr(max(timenum_all), 'yyyymmdd')], '-dpng')

        delete(p)
    end
end
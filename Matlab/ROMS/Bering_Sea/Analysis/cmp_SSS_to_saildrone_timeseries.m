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

h1 = figure; hold on; grid on;
t = tiledlayout(1,2);
set(gcf, 'Position', [1 200 1600 500])
nexttile(1)
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
colormap parula

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
      
        % SSS plot
        nexttile(2); cla; hold on; grid on;
        pSSS_sail = plot(timenum_all, salt, '.', 'Color', [0.4667 0.6745 0.1882]);
        pSSS_model = plot(ot, SSS_model, '-k', 'LineWidth', 2);
        %SMAP
        load(['./SMAP/SSS_SMAP_', filename_obs, '.mat']);
        pSSS_SMAP = plot(timenum_SMAP, SSS_SMAP, '-r', 'LineWidth', 2);
        %SMOS
        load(['./SMOS/SSS_SMOS_', filename_obs, '.mat']);
        index = find(isnan(SSS_SMOS) == 0);
        pSSS_SMOS = plot(timenum_SMOS(index), SSS_SMOS(index), '.-b', 'LineWidth', 2, 'MarkerSize', 12);

        xlim([timenum_all(1)-1 timenum_all(end)+1]);
        datetick('x', 'mmm yyyy', 'keeplimits')
        ylabel('psu');
        ylim([20 34])
        
        l = legend([pSSS_sail pSSS_model pSSS_SMAP pSSS_SMOS], 'Saildrone (SBE 37)', 'ROMS', 'SMAP', 'SMOS');
        l.FontSize = 12;
        l.Location = 'SouthOutside';
        l.NumColumns = 4;
        title(['SSS, Saildrone (', datestr(timenum_all(2) - timenum_all(2), 'mm'), ' min) vs ROMS (daily) vs SMAP (daily 8d running) vs SMOS (4 day)'])

        if strcmp(id, '1033') == 1 & yyyy(1) == 2021
            timenum1 = datenum(2021,9,22);
            timenum2 = datenum(2021,10,9);
            xlim([timenum1-1 timenum2+1]);
            ylim([31 33.5])
            xticks([timenum1 timenum2])
            datetick('x', 'mmm dd, yyyy', 'keeplimits', 'keepticks')
            nexttile(1);
            index = find(timenum_all > timenum1 & timenum_all < timenum2);
            p2 = plotm(lat(index), lon(index), '.r');
        elseif strcmp(id, '1034') == 1 & yyyy(1) == 2019
            timenum1 = datenum(2019,9,25);
            timenum2 = datenum(2019,10,1);
            xlim([timenum1-1 timenum2+1]);
            ylim([31 33.5])
            xticks([timenum1 timenum2])
            datetick('x', 'mmm dd, yyyy', 'keeplimits', 'keepticks')
            nexttile(1);
            index = find(timenum_all > timenum1 & timenum_all < timenum2);
            p2 = plotm(lat(index), lon(index), '.r');
        elseif strcmp(id, '1034') == 1 & yyyy(1) == 2021
            timenum1 = datenum(2021,10,1);
            timenum2 = datenum(2021,10,9);
            xlim([timenum1-1 timenum2+1]);
            ylim([31 33.5])
            xticks([timenum1 timenum2])
            datetick('x', 'mmm dd, yyyy', 'keeplimits', 'keepticks')
            nexttile(1);
            index = find(timenum_all > timenum1 & timenum_all < timenum2);
            p2 = plotm(lat(index), lon(index), '.r');
        elseif strcmp(id, '1036') == 1 & yyyy(1) == 2019
            timenum1 = datenum(2019,9,24);
            timenum2 = datenum(2019,9,30);
            xlim([timenum1-1 timenum2+1]);
            ylim([31 33.5])
            xticks([timenum1 timenum2])
            datetick('x', 'mmm dd, yyyy', 'keeplimits', 'keepticks')
            nexttile(1);
            index = find(timenum_all > timenum1 & timenum_all < timenum2);
            p2 = plotm(lat(index), lon(index), '.r');
        elseif strcmp(id, '1041') == 1 & yyyy(1) == 2019
            timenum1 = datenum(2019,6,5);
            timenum2 = datenum(2019,6,21);
            xlim([timenum1-1 timenum2+1]);
            ylim([31 33.5])
            xticks([timenum1:5:timenum2])
            datetick('x', 'mmm dd', 'keeplimits', 'keepticks')
            plot([737587 737587], [0 40], '-k')
            plot([737589 737589], [0 40], '-k')
            text((timenum1 + 737587)/2, 33.4, '1', 'FontSize', 15)
            text((737587 + 737589)/2, 33.4, '2', 'FontSize', 15)
            text((737589 + timenum2)/2, 33.4, '3', 'FontSize', 15)
            l = legend([pSSS_sail pSSS_model pSSS_SMAP pSSS_SMOS], 'Saildrone (SBE 37)', 'ROMS', 'SMAP', 'SMOS');
            nexttile(1);
            index = find(timenum_all > timenum1 & timenum_all < timenum2);
            p2 = plotm(lat(index), lon(index), '.r');
            tm(1) = textm(61.5, -174.5, '1', 'FontSize', 15);
            tm(2) = textm(59, -180, '2', 'FontSize', 15);
            tm(3) = textm(63, -176, '3', 'FontSize', 15);
        elseif strcmp(id, '1043') == 1 & yyyy(1) == 2020
            timenum1 = datenum(2020,7,23);
            timenum2 = datenum(2020,8,4);
            xlim([timenum1-1 timenum2+1]);
            ylim([31 33.5])
            xticks([timenum1:5:timenum2])
            datetick('x', 'mmm dd', 'keeplimits', 'keepticks')
            plot([738002 738002], [0 40], '-k')
            plot([738003 738003], [0 40], '-k')
            text((timenum1 + 738002)/2, 33.4, '1', 'FontSize', 15)
            text((738002 + 738003)/2, 33.4, '2', 'FontSize', 15)
            text((738003 + timenum2)/2, 33.4, '3', 'FontSize', 15)
            l = legend([pSSS_sail pSSS_model pSSS_SMAP pSSS_SMOS], 'Saildrone (SBE 37)', 'ROMS', 'SMAP', 'SMOS');
            nexttile(1);
            index = find(timenum_all > timenum1 & timenum_all < timenum2);
            p2 = plotm(lat(index), lon(index), '.r');
            tm(1) = textm(60, -171.5, '1', 'FontSize', 15);
            tm(2) = textm(61.8, -173.5, '2', 'FontSize', 15);
            tm(3) = textm(60, -176, '3', 'FontSize', 15);
        elseif strcmp(id, '1049') == 1 & yyyy(1) == 2020
            timenum1 = datenum(2020,7,10);
            timenum2 = datenum(2020,8,14);
            xlim([timenum1-1 timenum2+1]);
            ylim([31 33.5])
            xticks([timenum1:5:timenum2])
            datetick('x', 'mmm dd', 'keeplimits', 'keepticks')
            plot([737996 737996], [0 40], '-k')
            plot([737997 737997], [0 40], '-k')
            plot([738005 738005], [0 40], '-k')
            plot([738006 738006], [0 40], '-k')
            plot([738011 738011], [0 40], '-k')
            plot([738013 738013], [0 40], '-k')
            text((timenum1 + 737996)/2-.5, 33.4, '1', 'FontSize', 15)
            text((737996 + 737997)/2-.5, 33.4, '2', 'FontSize', 15)
            text((737997 + 738005)/2-.5, 33.4, '3', 'FontSize', 15)
            text((738005 + 738006)/2-.5, 33.4, '4', 'FontSize', 15)
            text((738006 + 738011)/2-.5, 33.4, '5', 'FontSize', 15)
            text((738011 + 738013)/2-.5, 33.4, '6', 'FontSize', 15)
            text((738013 + timenum2)/2-.5, 33.4, '7', 'FontSize', 15)
            l = legend([pSSS_sail pSSS_model pSSS_SMAP pSSS_SMOS], 'Saildrone (SBE 37)', 'ROMS', 'SMAP', 'SMOS');
            nexttile(1);
            index = find(timenum_all > timenum1 & timenum_all < timenum2);
            p2 = plotm(lat(index), lon(index), '.r');
            tm(1) = textm(61.5, -174, '1', 'FontSize', 15);
            tm(2) = textm(62.7, -176.5, '2', 'FontSize', 15);
            tm(3) = textm(60.5, -176.7, '3', 'FontSize', 15);
            tm(4) = textm(58, -176.8, '4', 'FontSize', 15);
            tm(5) = textm(60, -177.7, '5', 'FontSize', 15);
            tm(6) = textm(61.5, -179, '6', 'FontSize', 15);
            tm(7) = textm(59.5, -180, '7', 'FontSize', 15);
        elseif strcmp(id, '1067') == 1 & yyyy(1) == 2021
            timenum1 = datenum(2021,9,22);
            timenum2 = datenum(2021,10,9);
            xlim([timenum1-1 timenum2+1]);
            ylim([31 33.5])
            xticks([timenum1 timenum2])
            datetick('x', 'mmm dd, yyyy', 'keeplimits', 'keepticks')
            nexttile(1);
            index = find(timenum_all > timenum1 & timenum_all < timenum2);
            p2 = plotm(lat(index), lon(index), '.r');
        end

        print(['cmp_SSS_to_saildrone_', id, '_', datestr(min(timenum_all), 'yyyymmdd'), '_', datestr(max(timenum_all), 'yyyymmdd')], '-dpng')

        delete(p)
        if exist('p2')
            delete(p2)
            clearvars p2
        end
        if exist('tm')
            delete(tm)
            clearvars tm
        end
    end
end
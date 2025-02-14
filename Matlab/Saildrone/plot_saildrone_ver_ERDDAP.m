%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot Saildron data using data from ERDDAP 
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

filepath = '/data/jungjih/Observations/Saildrone/PMEL_ERDDAP/data/';
filename_all = dir([filepath, '/*.nc']);

g = grd('BSf');
h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
colormap parula

for fi = 1:length(filename_all)
    filename = filename_all(fi).name;
    file = [filepath, filename];
    
    lat = ncread(file, 'latitude');
    lon = ncread(file, 'longitude');
    time = ncread(file, 'time');
    time_units = ncreadatt(file, 'time', 'units');
    id = ncreadatt(file, '/', 'drone_id');
    
    try
        temp_sbe37 = ncread(file, 'TEMP_SBE37_MEAN');
        ind_Tsbe37 = 1;
    catch
        ind_Tsbe37 = 0;
    end

    try
        temp_rbr = ncread(file, 'TEMP_CTD_RBR_MEAN');
        ind_Trbr = 1;
    catch
        ind_Trbr = 0;
    end
    
    try
        salt_sbe37 = ncread(file, 'SAL_SBE37_MEAN');
        ind_Ssbe37 = 1;
    catch
        ind_Ssbe37 = 0;
    end

    try
        salt_rbr = ncread(file, 'SAL_CTD_RBR_MEAN');
        ind_Srbr = 1;
    catch
        ind_Srbr = 0;
    end

    if strcmp(time_units(1:7), 'seconds')
        timenum_ref = datenum(time_units(15:end), 'yyyy-mm-ddTHH:MM:SSZ');
        timenum = time/60/60/24 + timenum_ref;
    else
        pause
    end

    p = scatterm(lat, lon, 10, timenum);
    caxis([min(timenum) max(timenum)]);
    c = colorbar;
    datetick(c, 'y', 'yyyy-mm-dd', 'keeplimits');

    title(['Saildrone ID ', id, ' (', datestr(min(timenum), 'mmm dd, yyyy'), ' - ', datestr(max(timenum), 'mmm dd, yyyy'), ') ' ...
        'Tsbe37 (', num2str(ind_Tsbe37), '), Trbr (', num2str(ind_Trbr), '), ' ...
        'Ssbe37 (', num2str(ind_Ssbe37), '), Srbr (', num2str(ind_Srbr), ')']);
    
    print(['location_and_time_saildrone_', id, '_', datestr(min(timenum), 'yyyymmdd'), '_', datestr(max(timenum), 'yyyymmdd')], '-dpng')

    delete(p)
end
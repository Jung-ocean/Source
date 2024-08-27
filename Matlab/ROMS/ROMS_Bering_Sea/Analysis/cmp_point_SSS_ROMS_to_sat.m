%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SSS to satellite SSS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy_all = 2019:2022;
mm_all = 4:5;
depth_shelf = 200; % m
layer = 45;
num_sat = 5;

len_data = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    len_data = len_data + sum(eomday(yyyy, mm_all));
end

switch vari_str
    case 'salt'
        ylimit_shelf = [30.5 34.5];
        ylimit_basin = [32.2 34.0];
        climit = [31.5 33.5];
        unit = 'g/kg';
    case 'temp'
        climit = [0 20];
        unit = '^oC';
end

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/'];

% Load grid information
g = grd('BSf');
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;
startdate = datenum(2018,7,1);

figure;
pcolor(g.lon_rho,g.lat_rho,h.*mask); shading interp
caxis([5 1000]);
[point_lon, point_lat] = ginput;
close all

dist = sqrt((g.lon_rho - point_lon).^2 + abs(g.lat_rho - point_lat).^2);
[latind, lonind] = find(dist == min(dist(:)));

figure;
plot_map('Bering', 'mercator', 'l')
hold on;
contourm(g.lat_rho, g.lon_rho, h, [50 200], 'k');
plotm(point_lat, point_lon, '.r', 'MarkerSize', 15)
print('map_SSS', '-dpng')

ti = 1;
vari_con = NaN(1, len_data);
vari_sat_all = NaN(num_sat, len_data);
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Satellite SSS
    % RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/8day_running/', ystr, '/'];
    filepath_RSS_40 = filepath_RSS_70;
    % CEC SMOS v9.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/4day/'];
    % OISSS L4 v2.0 (https://podaac.jpl.nasa.gov/dataset/OISSS_L4_multimission_7day_v2)
    filepath_OISSS = ['/data/sdurski/Observations/Satellite_SSS/OISSS_v2/'];
    % CMEMS Multi Observation Global Ocean SSS (https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_S_SURFACE_MYNRT_015_013/description)
    filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/daily/', ystr, '/'];
    filepaths_sat = {filepath_RSS_70, filepath_RSS_40, filepath_CEC, filepath_OISSS, filepath_CMEMS};

    lons_sat = {'lon', 'lon', 'lon', 'longitude', 'lon'};
    lons_360ind = [360, 360, 180, 180, 360];
    lats_sat = {'lat', 'lat', 'lat', 'latitude', 'lat'};
    varis_sat = {'sss_smap', 'sss_smap_40km', 'SSS', 'sss', 'sos'};
    titles_sat = {'RSS SMAP L3 SSS v5.3 (70 km)', 'RSS SMAP L3 SSS v5.3 (40 km)', 'CEC SMOS L3 SSS v9.0', 'ESR OISSS L4 v2.0', 'CMEMS Multi Observation L4 SSS'};

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');

            yyyymmdd = [ystr, mstr, dstr];

            filenum = datenum(yyyy,mm,dd) - startdate + 1;
            fstr = num2str(filenum, '%04i');
            file_control = [filepath_control, 'Dsm2_spng_avg_', fstr, '.nc'];

            if exist(file_control) ~= 0
                vari_con(ti) = ncread(file_control,vari_str,[lonind latind layer 1],[1 1 1 1]);
            else
                vari_con(ti) = NaN;
            end

            YTD = datenum(yyyy,mm,dd) - datenum(yyyy,1,1) + 1;
            % Satellite
            for si = 1:num_sat

                filepath_sat = filepaths_sat{si};
                filepattern1_sat = fullfile(filepath_sat, (['*', ystr, '_', num2str(YTD, '%03i'), '*.nc']));
                filepattern2_sat = fullfile(filepath_sat, (['*', ystr, mstr, dstr, '*.nc']));
                filepattern3_sat = fullfile(filepath_sat, (['*', ystr, '-', mstr, '-', dstr, '*.nc']));

                filename_sat = dir(filepattern1_sat);
                if isempty(filename_sat)
                    filename_sat = dir(filepattern2_sat);
                end
                if isempty(filename_sat)
                    filename_sat = dir(filepattern3_sat);
                end

                if isempty(filename_sat)
                    vari_sat_all(si,ti) = NaN;
                else
                    file_sat = [filepath_sat, filename_sat.name];
                    lon_sat = double(ncread(file_sat,lons_sat{si}));
                    lat_sat = double(ncread(file_sat,lats_sat{si}));
                    vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');
                    if si == 3 || si == 4
                        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
                        vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
                    end
                    lon_sat = lon_sat - lons_360ind(si);

                    vari_sat_all(si,ti) = interp2(lon_sat, lat_sat, vari_sat, point_lon, point_lat);
                end

            end % si
            
            disp([ystr, mstr, dstr, '...'])
            timenum(ti) = datenum(yyyy,mm,dd);
            ti = ti+1;
        end % di
    end % mi
end % yi

tt = timetable(datetime(datestr(timenum)), vari_con', 'VariableNames', {'ROMS'});
for si = 1:num_sat
    tt = addvars(tt, vari_sat_all(si,:)', 'NewVariableNames', titles_sat{si});
end
monthly = retime(tt, 'monthly', 'mean');
yearly = retime(tt, 'yearly', 'mean');

figure; hold on; grid on
plot(timenum, vari_con, 'o')
datetick('x', 'mmm, yyyy')
for si = 1:4%num_sat
    plot(timenum, vari_sat_all(si,:), 'o')
end

figure; hold on; grid on
for i = [1 2 4 5]
    plot(yearly.Time, yearly{:,i}, '-o');
end

figure; hold on; grid on
for i = [1 2 3 4 5]
    plot(monthly{:,i}, '-o');
end
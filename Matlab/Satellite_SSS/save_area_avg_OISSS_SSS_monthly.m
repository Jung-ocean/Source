%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged SMOS SSS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'midshelf';
area_frac_cutoff = 0.99;

vari_str = 'salt';
yyyy_all = 2011:2022;
mm_all = 1:12;

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
[mask, area] = mask_and_area(region, g);

SSS = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);


    % Satellite SSS
    % OISSS L4 v2.0 (https://podaac.jpl.nasa.gov/dataset/OISSS_L4_multimission_7day_v2)
    filepath_OISSS = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/monthly/'];

    lons_sat = 'longitude';
    lons_360ind = [180];
    lats_sat = 'latitude';
    varis_sat = 'sss';
    titles_sat = 'ESR OISSS L4 v2.0';

    % Satellite
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');
        timenum = [timenum; datenum(yyyy,mm,15)];

        filepath_sat = filepath_OISSS;
        filepattern_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
        filename_sat = dir(filepattern_sat);

        if isempty(filename_sat)
            SSS = [SSS; NaN];
            continue
        end

        file_sat = [filepath_sat, filename_sat.name];
        lon_sat = double(ncread(file_sat,lons_sat));
        lat_sat = double(ncread(file_sat,lats_sat));
        vari_sat = double(squeeze(ncread(file_sat,varis_sat))');

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
        
        lon_sat = lon_sat - lons_360ind;

        index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
        index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

        vari_sat_part = vari_sat(index_lat,index_lon);

        [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

        vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat_part, lon,lat);
        mask_sat = ~isnan(vari_sat_interp);
        mask_sat_model = (mask_sat./mask_sat).*mask;
        area_sat = area.*mask_sat_model;

        area_frac = sum(area_sat(:), 'omitnan')./sum(area(:), 'omitnan');
        if area_frac < area_frac_cutoff
            SSS = [SSS; NaN];
        else
            SSS_tmp = sum(vari_sat_interp(:).*area_sat(:), 'omitnan')./sum(area_sat(:), 'omitnan');
            SSS = [SSS; SSS_tmp];
        end

        disp([ystr, mstr])
    end % mi
end % yi

figure; hold on; grid on
plot(timenum, SSS, '-o');
xticks(datenum(yyyy_all,1,15));
datetick('x', 'yyyy', 'keepticks')

save(['SSS_OISSS_', region, '.mat'], 'timenum', 'SSS', 'area_frac_cutoff')
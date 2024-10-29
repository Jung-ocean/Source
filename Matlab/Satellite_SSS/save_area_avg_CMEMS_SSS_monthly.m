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
yyyy_all = 2015:2022;
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
    % CMEMS Multi Observation Global Ocean SSS (https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_S_SURFACE_MYNRT_015_013/description)
    filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/monthly/', ystr, '/'];

    lons_sat = 'lon';
    lons_360ind = [360];
    lats_sat = 'lat';
    varis_sat = 'sos';
    titles_sat = 'CMEMS Multi Observation L4 SSS';

    % Satellite
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');
        timenum = [timenum; datenum(yyyy,mm,15)];

        filepath_sat = filepath_CMEMS;
        filepattern_sat = fullfile(filepath_sat, (['*monthly_', ystr, mstr, '*.nc']));
        filename_sat = dir(filepattern_sat);

        if isempty(filename_sat)
            SSS = [SSS; NaN];
            continue
        end

        file_sat = [filepath_sat, filename_sat.name];
        lon_sat = double(ncread(file_sat,lons_sat));
        lat_sat = double(ncread(file_sat,lats_sat));
        vari_sat = double(squeeze(ncread(file_sat,varis_sat))');

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

save(['SSS_CMEMS_', region, '.mat'], 'timenum', 'SSS', 'area_frac_cutoff')
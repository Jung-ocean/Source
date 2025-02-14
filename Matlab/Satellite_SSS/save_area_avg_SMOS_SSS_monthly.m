%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged SMOS SSS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Smidshelf';
area_frac_cutoff = 0.95;
% area_frac_cutoff = 0.1;

vari_str = 'salt';
yyyy_all = 2010:2023;
mm_all = 1:12;

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;

if strcmp(region, 'Gulf_of_Anadyr_common')
    load mask_common.mat
    dx = 1./g.pm; dy = 1./g.pn;
    mask = mask_common./mask_common;
    area = dx.*dy.*mask;
else
    [mask, area] = mask_and_area(region, g);
end

SSS = [];
err = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Satellite SSS
    % CEC SMOS v9.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/monthly/'];

    lons_sat = 'lon';
    lons_360ind = [180];
    lats_sat = 'lat';
    varis_sat = 'SSS';
    titles_sat = 'CEC SMOS L3 SSS v9.0';

    % Satellite
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');
        timenum = [timenum; datenum(yyyy,mm,15)];

        filepath_sat = filepath_CEC;
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
        err_sat = double(squeeze(ncread(file_sat,'eSSS'))');

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
        err_sat = [err_sat(:,index1) err_sat(:,index2)];
        
        lon_sat = lon_sat - lons_360ind;

        index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
        index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

        vari_sat_part = vari_sat(index_lat,index_lon);
        err_sat_part = err_sat(index_lat,index_lon);

        [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

        vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat_part, lon,lat);
        mask_sat = ~isnan(vari_sat_interp);
        mask_sat_model = (mask_sat./mask_sat).*mask;
        area_sat = area.*mask_sat_model;

        err_sat_interp = griddata(lon_sat2, lat_sat2, err_sat_part, lon, lat);

        area_frac = sum(area_sat(:), 'omitnan')./sum(area(:), 'omitnan');
        if area_frac < area_frac_cutoff
            SSS = [SSS; NaN];
            err = [err; NaN];
        else
            SSS_tmp = sum(vari_sat_interp(:).*area_sat(:), 'omitnan')./sum(area_sat(:), 'omitnan');
            SSS = [SSS; SSS_tmp];

            err_tmp = sum(err_sat_interp(:).*area_sat(:), 'omitnan')./sum(area_sat(:), 'omitnan');
            err = [err; err_tmp];
        end

        disp([ystr, mstr])
    end % mi
end % yi

figure; hold on; grid on
plot(timenum, SSS, '-o');
xticks(datenum(yyyy_all,1,15));
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

if length(mm_all) == 1
    output_filename = ['SSS_SMOS_', region, '_', num2str(mm_all, '%02i'), '.mat'];
else
    output_filename = ['SSS_SMOS_', region, '.mat'];
end
save(output_filename, 'timenum', 'SSS', 'err', 'area_frac_cutoff')
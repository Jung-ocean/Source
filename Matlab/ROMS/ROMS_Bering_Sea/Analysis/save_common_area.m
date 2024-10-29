%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save common area between SMAP and SMOS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2015:2023;
mm = 7;

g = grd('BSf');

% Gulf of Anadyr
polygon = [;
    -180.9180   62.3790
    -172.9734   64.3531
    -178.7092   66.7637
    -184.1599   64.8934
    -180.9180   62.3790
    ];

[in, on] = inpolygon(g.lon_rho, g.lat_rho, polygon(:,1), polygon(:,2));
mask = double(in);

mask_common = ones(size(g.mask_rho));
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    mstr = num2str(mm, '%02i');

    % SMAP
    filepath_SMAP = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/monthly/', ystr, '/'];
    filename_SMAP = ['RSS_smap_SSS_L3_monthly_', ystr, '_', mstr, '_FNL_v05.3.nc'];
    file_SMAP = [filepath_SMAP, filename_SMAP];

    lon_sat = double(ncread(file_SMAP,'lon'));
    lat_sat = double(ncread(file_SMAP,'lat'));
    vari_sat = double(ncread(file_SMAP,'sss_smap'))';

    lon_sat = lon_sat - 360;
    [lon_sat2, lat_sat2] = meshgrid(lon_sat, lat_sat);

    vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat, g.lon_rho, g.lat_rho);
    mask_sat = double(~isnan(vari_sat_interp));
    mask_common = mask_common.*mask_sat.*mask;

    % SMOS
    filepath_SMOS = '/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/monthly/';
    filename_SMOS = ['SMOS_L3_DEBIAS_LOCEAN_AD_', ystr, mstr, '_EASE_09d_25km_v09.nc'];
    file_SMOS = [filepath_SMOS, filename_SMOS];

    lon_sat = double(ncread(file_SMOS,'lon'));
    lat_sat = double(ncread(file_SMOS,'lat'));
    vari_sat = double(ncread(file_SMOS,'SSS'))';

    index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
    vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
    lon_sat = lon_sat - 180;
    [lon_sat2, lat_sat2] = meshgrid(lon_sat, lat_sat);

    vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat, g.lon_rho, g.lat_rho);
    mask_sat = double(~isnan(vari_sat_interp));
    mask_common = mask_common.*mask_sat.*mask;
end
save mask_common.mat mask_common
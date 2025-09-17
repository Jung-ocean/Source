function [lat, lon, vari] = load_SSS_sat_2d_monthly(sat, yyyy, mm)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');

lons_sat = {'lon', 'lon'};
lons_360ind = [360, 180];
lats_sat = {'lat', 'lat'};
varis_sat = {'sss_smap', 'SSS'};

if strcmp(sat, 'SMAP')
    si = 1;

    filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/RSS/v6.0/monthly/', ystr, '/'];
    filename_sat = ['RSS_smap_SSS_L3_monthly_', ystr, '_', mstr, '_FNL_v06.0.nc'];
    file_sat = [filepath_sat, filename_sat];

    if exist(file_sat)

        lon_sat = double(ncread(file_sat,lons_sat{si}));
        lat_sat = double(ncread(file_sat,lats_sat{si}));
        vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

        lon_sat = lon_sat - lons_360ind(si);

        lat = lat_sat;
        lon = lon_sat;
        vari = vari_sat;
    else
        lat = NaN;
        lon = NaN;
        vari = NaN;
    end

    disp(['loading SMAP v6.0 monthly SSS ', ystr, mstr]);

elseif strcmp(sat, 'SMOS')
    si = 2;

    filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CEC/v10/monthly/'];
    filename_sat = ['SMOS_L3_DEBIAS_LOCEAN_AD_', ystr, mstr, '_EASE_09d_25km_v10.nc'];
    file_sat = [filepath_sat, filename_sat];
    
    if exist(file_sat)

        lon_sat = double(ncread(file_sat,lons_sat{si}));
        lat_sat = double(ncread(file_sat,lats_sat{si}));
        vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(index1,:); vari_sat(index2,:)];

        lon_sat = lon_sat - lons_360ind(si);

        lat = lat_sat;
        lon = lon_sat;
        vari = vari_sat;
    else
        lat = NaN;
        lon = NaN;
        vari = NaN;
    end

    disp(['loading SMOS v10 monthly SSS ', ystr, mstr]);
end

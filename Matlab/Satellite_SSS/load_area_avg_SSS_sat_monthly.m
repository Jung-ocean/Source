function [SSS, err] = load_area_avg_SSS_sat_monthly(sat, yyyy, mm, g, mask, area, area_frac_cutoff)

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
        err_sat = double(squeeze(ncread(file_sat,'sss_smap_unc')));

        lon_sat = lon_sat - lons_360ind(si);
    else
        lat_sat = NaN;
        lon_sat = NaN;
        vari_sat = NaN;
        err_sat = NaN;
        SSS = NaN;
        err = NaN;
        disp(['file does not exist ', file_sat])
        return
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
        err_sat = double(squeeze(ncread(file_sat,'eSSS')));

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(index1,:); vari_sat(index2,:)];

        lon_sat = lon_sat - lons_360ind(si);
    else
        lat_sat = NaN;
        lon_sat = NaN;
        vari_sat = NaN;
        SSS = NaN;
        err = NaN;
        disp(['file does not exist ', file_sat])
        return
    end
    disp(['loading SMOS v10 monthly SSS ', ystr, mstr]);
end

[lat_sat2, lon_sat2] = meshgrid(lat_sat, lon_sat);
F = griddedInterpolant(lat_sat2', lon_sat2', vari_sat');
vari_sat_interp = F(g.lat_rho, g.lon_rho);
mask_sat = ~isnan(vari_sat_interp);
mask_sat_model = (mask_sat./mask_sat).*mask;
area_sat = area.*mask_sat_model;

Ferr = griddedInterpolant(lat_sat2', lon_sat2', err_sat');
err_sat_interp = Ferr(g.lat_rho, g.lon_rho);

area_frac = sum(area_sat(:), 'omitnan')./sum(area(:), 'omitnan');
if area_frac < area_frac_cutoff
    SSS = NaN;
    err = NaN;
    disp('available data area is smaller than target area')
else
    SSS_tmp = sum(vari_sat_interp(:).*area_sat(:), 'omitnan')./sum(area_sat(:), 'omitnan');
    SSS = SSS_tmp;

    err_tmp = sum(err_sat_interp(:).*area_sat(:), 'omitnan')./sum(area_sat(:), 'omitnan');
    err = err_tmp;
end
function [timenum_all, vari_all] = load_SSS_sat(sat, datenum_start, datenum_end, lat_target, lon_target)

lons_sat = {'lon', 'lon'};
lons_360ind = [360, 180];
lats_sat = {'lat', 'lat'};
varis_sat = {'sss_smap', 'SSS'};

timenum_all = [];
vari_all = [];

if strcmp(sat, 'SMAP')
    si = 1;

    for di = datenum_start:datenum_end
        datenum_target = di;
        ystr = datestr(datenum_target, 'yyyy');
        yyyy = str2num(ystr);
        filenum = datenum_target - datenum(yyyy,1,1) + 1;
        fstr = num2str(filenum, '%03i');

        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/8day_running/', ystr, '/'];
        filename_sat = ['RSS_smap_SSS_L3_8day_running_', ystr, '_', fstr, '_FNL_v06.0.nc'];

        file_sat = [filepath_sat, filename_sat];
        if exist(file_sat)

            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

            lon_sat = lon_sat - lons_360ind(si);

            vari_tmp = interp2(lat_sat, lon_sat, vari_sat, lat_target, lon_target);

            timenum_all = [timenum_all; datenum_target];
            vari_all = [vari_all; vari_tmp];
        else
            timenum_all = [timenum_all; datenum_target];
            vari_all = [vari_all; NaN];
        end
    end

elseif strcmp(sat, 'SMOS')
    si = 2;

    for di = datenum_start:datenum_end
        datenum_target = di;
        yyyymmdd = datestr(datenum_target, 'yyyymmdd');

        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/4day/'];
        filename_sat = ['SMOS_L3_DEBIAS_LOCEAN_AD_', yyyymmdd, '_EASE_09d_25km_v09.nc'];

        file_sat = [filepath_sat, filename_sat];
        if exist(file_sat)

            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

            index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
            vari_sat = [vari_sat(index1,:); vari_sat(index2,:)];

            lon_sat = lon_sat - lons_360ind(si);

            vari_tmp = interp2(lat_sat, lon_sat, vari_sat, lat_target, lon_target);

            timenum_all = [timenum_all; datenum_target];
            vari_all = [vari_all; vari_tmp];
        else
            timenum_all = [timenum_all; datenum_target];
            vari_all = [vari_all; NaN];
        end
    end
end
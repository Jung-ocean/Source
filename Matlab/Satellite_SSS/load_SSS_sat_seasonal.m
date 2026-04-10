function [lat, lon, vari] = load_SSS_sat_seasonal(sat, version, yyyy, season)

ystr = num2str(yyyy);

lons_sat = {'lon', 'lon', 'lon', 'lon', 'lon', 'longitude'};
lons_360ind = [360, 180, 360, 360, 360, 180];
lats_sat = {'lat', 'lat', 'lat', 'lat', 'lat', 'latitude'};
varis_sat = {'sss_smap', 'SSS', 'sos', 'sss', 'SSS', 'sss'};

switch sat
    case 'SMAP'
        si = 1;

        vstr = num2str(version, '%2.1f');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/RSS/v', vstr, '/seasonal/'];
        filename_sat = ['mean_', ystr, '_', season, '.nc'];
        file_sat = [filepath_sat, filename_sat];

        if exist(file_sat)
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

            lon_sat = lon_sat - lons_360ind(si);

            lat = lat_sat;
            lon = lon_sat;
            vari = vari_sat;
            disp(['Loading SMAP v', vstr, ' seasonal SSS ', ystr, ' ', season]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data in ', ystr, ' ', season]);
        end

    case 'SMOS'
        si = 2;

        vstr1 = num2str(version);
        vstr2 = num2str(version, '%02i');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CEC/v', vstr1, '/seasonal/'];
        filename_sat = ['mean_', ystr, '_', season, '.nc'];
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
            disp(['Loading SMOS v', vstr2, ' seasonal SSS ', ystr, ' ', season]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data in ', ystr, ' ', season]);
        end

    case 'CMEMS'
        si = 3;

        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CMEMS/monthly/', ystr, '/'];
        filepattern = ['*', ystr, mstr, '15T1200Z*'];
        fileinfo = dir([filepath_sat, filepattern]);
        filename_sat = fileinfo.name;
        file_sat = [filepath_sat, filename_sat];

        if exist(file_sat)
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

            lon_sat = lon_sat - lons_360ind(si);

            lat = lat_sat;
            lon = lon_sat;
            vari = vari_sat;
            disp(['Loading CMEMS L4 monthly SSS ', ystr, mstr]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data in ', ystr, mstr]);
        end

    case 'SMOS_BEC'
        si = 4;

        vstr1 = num2str(version);
        vstr2 = num2str(version, '%2.1f');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/BEC/Arctic/v', vstr1, '/seasonal/'];
        filename_sat = ['mean_', ystr, '_', season, '.nc'];
        file_sat = [filepath_sat, filename_sat];

        if exist(file_sat)
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

            lon_sat(lon_sat > 0) = lon_sat(lon_sat > 0) - lons_360ind(si);

            lat = lat_sat;
            lon = lon_sat;
            vari = vari_sat;
            disp(['Loading SMOS_BEC v', vstr2, ' seasonal SSS ', ystr, ' ', season]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data in ', ystr, ' ', season]);
        end

    case 'SMOS_Arctic'
        si = 5;

        vstr1 = num2str(version);
        vstr2 = num2str(version, '%02i');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CEC/Arctic/v', vstr1, '/monthly/'];
        filename_sat = ['SMOS_L3_DEBIAS_LOCEAN_AD_', ystr, mstr, '_EASE_Arctic_09d_v', vstr2, '.nc'];
        file_sat = [filepath_sat, filename_sat];

        if exist(file_sat)
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

            lon_sat(lon_sat > 0) = lon_sat(lon_sat > 0) - lons_360ind(si);

            lat = lat_sat;
            lon = lon_sat;
            vari = vari_sat;
            disp(['Loading SMOS_Arctic v', vstr2, ' monthly SSS ', ystr, mstr]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data in ', ystr, mstr]);
        end

    case 'OISSS'
        si = 6;

        vstr = num2str(version, '%2.1f');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/OISSS/v', vstr, '/seasonal/'];
        filename_sat = ['mean_', ystr, '_', season, '.nc'];
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
            disp(['Loading OISSS v', vstr, ' seasonal SSS ', ystr, ' ', season]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data in ', ystr, ' ', season]);
        end

end

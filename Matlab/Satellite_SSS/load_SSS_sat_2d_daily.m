function [lat, lon, vari] = load_SSS_sat_2d_daily(sat, version, timenum)

yyyymmdd = datestr(timenum, 'yyyymmdd');
ystr = datestr(timenum, 'yyyy');
yyyy = str2num(ystr);
mstr = datestr(timenum, 'mm');
mm = str2num(mstr);

lons_sat = {'lon', 'lon', 'lon', 'lon'};
lons_360ind = [360, 180, 360, 360];
lats_sat = {'lat', 'lat', 'lat', 'lat'};
varis_sat = {'sss_smap', 'SSS', 'sos', 'sss'};

switch sat
    case 'SMAP'
        si = 1;
        
        YTD = timenum - datenum(yyyy,1,1) + 1;
        YTDstr = num2str(YTD, '%03i');
        vstr = num2str(version, '%2.1f');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/RSS/v', vstr, '/8day_running/', ystr, '/'];
        filename_sat = ['RSS_smap_SSS_L3_8day_running_', ystr, '_', YTDstr, '_FNL_v0', vstr, '.nc'];
        file_sat = [filepath_sat, filename_sat];

        if exist(file_sat)
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

            lon_sat = lon_sat - lons_360ind(si);

            lat = lat_sat;
            lon = lon_sat;
            vari = vari_sat;
            disp(['loading SMAP v', vstr, ' daily SSS ', yyyymmdd]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data on ', yyyymmdd]);
        end

    case 'SMOS'
        si = 2;

        vstr1 = num2str(version);
        vstr2 = num2str(version, '%02i');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CEC/v', vstr1, '/9day/'];
        filename_sat = ['SMOS_L3_DEBIAS_LOCEAN_AD_', yyyymmdd, '_EASE_09d_25km_v', vstr2, '.nc'];
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
            disp(['loading SMOS v', vstr2, ' daily SSS ', yyyymmdd]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data on ', yyyymmdd]);
        end

    case 'CMEMS'
        si = 3;

        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CMEMS/daily/', ystr, '/'];
        filepattern = ['*', yyyymmdd, 'T1200Z*'];
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
            disp(['loading CMEMS L4 daily SSS ', yyyymmdd]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data on ', yyyymmdd]);
        end

    case 'SMOS_BEC'
        si = 4;

        vstr1 = num2str(version);
        vstr2 = num2str(version, '%2.1f');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/BEC/Arctic/v', vstr1, '/9day/', ystr, '/'];
        filename_sat = ['BEC_SSS___SMOS__ARC_L3__B_', yyyymmdd, 'T120000_25km__9d_REP_v', vstr2, '.nc'];
        file_sat = [filepath_sat, filename_sat];

        if exist(file_sat)
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si})));

            lon_sat(lon_sat > 0) = lon_sat(lon_sat > 0) - lons_360ind(si);

            lat = lat_sat;
            lon = lon_sat;
            vari = vari_sat;
            disp(['loading SMOS_BEC v', vstr2, ' daily SSS ', yyyymmdd]);
        else
            lat = NaN;
            lon = NaN;
            vari = NaN;
            disp(['No data on ', yyyymmdd]);
        end
end

function [lat, lon, trend] = load_SSS_sat_trend(sat, version, season)

if nargin < 3
    season = [];
end

lons_sat = {'lon', 'lon', 'lon', 'lon', 'lon', 'longitude'};
lons_360ind = [360, 180, 360, 360, 360, 180];
lats_sat = {'lat', 'lat', 'lat', 'lat', 'lat', 'latitude'};
varis_sat = {'sss_smap', 'SSS', 'sos', 'sss', 'SSS', 'sss'};

switch sat
    case 'SMAP'
        si = 1;

        vstr = num2str(version, '%2.1f');
        if isempty(season)
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/RSS/v', vstr, '/mean_std_2019_2023/'];
        else
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/RSS/v', vstr, '/mean_std_2019_2023_', season, '/'];
        end
        filename_trend = ['trend.nc'];
        file_trend = [filepath_sat, filename_trend];

        if exist(file_trend)
            lon_sat = double(ncread(file_trend,lons_sat{si}));
            lat_sat = double(ncread(file_trend,lats_sat{si}));
            trend = double(squeeze(ncread(file_trend,varis_sat{si})));

            lon_sat = lon_sat - lons_360ind(si);
            lat = lat_sat;
            lon = lon_sat;
            
            disp(['Loading SMAP v', vstr, ' SSS trend']);
        else
            lat = NaN;
            lon = NaN;
            trend = NaN;
            
            disp(['No data']);
        end

    case 'SMOS'
        si = 2;

        vstr1 = num2str(version);
        vstr2 = num2str(version, '%02i');
        if isempty(season)
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CEC/v', vstr1, '/mean_std_2019_2023/'];
        else
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CEC/v', vstr1, '/mean_std_2019_2023_', season, '/'];
        end
        filename_trend = ['trend.nc'];
        file_trend = [filepath_sat, filename_trend];

        if exist(file_trend)
            lon_sat = double(ncread(file_trend,lons_sat{si}));
            lat_sat = double(ncread(file_trend,lats_sat{si}));
            trend = double(squeeze(ncread(file_trend,varis_sat{si})));

            index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
            trend = [trend(index1,:); trend(index2,:)];

            lon_sat = lon_sat - lons_360ind(si);
            lat = lat_sat;
            lon = lon_sat;

            disp(['Loading SMOS v', vstr2, ' SSS trend']);
        else
            lat = NaN;
            lon = NaN;
            trend = NaN;
            
            disp(['No data in ', ystr, mstr]);
        end

    case 'CMEMS'
        si = 3;

        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CMEMS/monthly/', ystr, '/'];
        filepattern = ['*', ystr, mstr, '15T1200Z*'];
        fileinfo = dir([filepath_sat, filepattern]);
        filename_trend = fileinfo.name;
        file_trend = [filepath_sat, filename_trend];

        if exist(file_trend)
            lon_sat = double(ncread(file_trend,lons_sat{si}));
            lat_sat = double(ncread(file_trend,lats_sat{si}));
            trend = double(squeeze(ncread(file_trend,varis_sat{si})));

            lon_sat = lon_sat - lons_360ind(si);
            lat = lat_sat;
            lon = lon_sat;

            disp(['Loading CMEMS L4 monthly SSS ', ystr, mstr]);
        else
            lat = NaN;
            lon = NaN;
            trend = NaN;

            disp(['No data in ', ystr, mstr]);
        end

    case 'SMOS_BEC'
        si = 4;

        vstr1 = num2str(version);
        vstr2 = num2str(version, '%2.1f');
        if isempty(season)
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/BEC/Arctic/v4/mean_std_2018_2022/'];
        else
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/BEC/Arctic/v4/mean_std_2018_2022_', season, '/'];
        end
        filename_trend = ['trend.nc'];
        file_trend = [filepath_sat, filename_trend];

        if exist(file_trend)
            lon_sat = double(ncread(file_trend,lons_sat{si}));
            lat_sat = double(ncread(file_trend,lats_sat{si}));
            trend = double(squeeze(ncread(file_trend,varis_sat{si})));

            lon_sat(lon_sat > 0) = lon_sat(lon_sat > 0) - lons_360ind(si);
            lat = lat_sat;
            lon = lon_sat;
            
            disp(['Loading SMOS_BEC v', vstr2, ' SSS trend']);
        else
            lat = NaN;
            lon = NaN;
            trend = NaN;

            disp(['No data in ', ystr, mstr]);
        end
 
    case 'SMOS_Arctic'
        si = 5;

        vstr1 = num2str(version);
        vstr2 = num2str(version, '%02i');
        filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/CEC/Arctic/v', vstr1, '/monthly/'];
        filename_trend = ['SMOS_L3_DEBIAS_LOCEAN_AD_', ystr, mstr, '_EASE_Arctic_09d_v', vstr2, '.nc'];
        file_trend = [filepath_sat, filename_trend];

        if exist(file_trend)
            lon_sat = double(ncread(file_trend,lons_sat{si}));
            lat_sat = double(ncread(file_trend,lats_sat{si}));
            trend = double(squeeze(ncread(file_trend,varis_sat{si})));

            lon_sat(lon_sat > 0) = lon_sat(lon_sat > 0) - lons_360ind(si);

            lat = lat_sat;
            lon = lon_sat;
            vari = trend;
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
        if isempty(season)
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/OISSS/v', vstr, '/mean_std_2019_2023/'];
        else
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/OISSS/v', vstr, '/mean_std_2019_2023_', season, '/'];
        end
        filename_trend = ['trend.nc'];
        file_trend = [filepath_sat, filename_trend];

        if exist(file_trend)
            lon_sat = double(ncread(file_trend,lons_sat{si}));
            lat_sat = double(ncread(file_trend,lats_sat{si}));
            trend = double(squeeze(ncread(file_trend,varis_sat{si})));

            index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
            trend = [trend(index1,:); trend(index2,:)];

            lon_sat = lon_sat - lons_360ind(si);
            lat = lat_sat;
            lon = lon_sat;

            disp(['Loading OISSS v', vstr, ' SSS trend']);
        else
            lat = NaN;
            lon = NaN;
            trend = NaN;
            
            disp(['No data in ', ystr, mstr]);
        end

end

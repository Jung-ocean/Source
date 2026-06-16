function [lon_sat, lat_sat, SST_sat] = load_OSTIA_river_point(lon_target, lat_target, timenum_target)

SST_sat = NaN(size(timenum_target));
for ti = 1:length(timenum_target)
    timenum = timenum_target(ti);
    ystr = datestr(timenum, 'yyyy');
    mstr = datestr(timenum, 'mm');
    yyyymmdd = datestr(timenum, 'yyyymmdd');

    filepath = ['/data/jungjih/Observations/Satellite_SST/OSTIA/daily/', ystr, '/', mstr, '/'];
    fileinfo = dir([filepath, yyyymmdd, '*.nc']);
    file = [filepath, fileinfo.name];

    lon = ncread(file, 'lon');
    lat = ncread(file, 'lat');

    if ti == 1
        mask = ncread(file,'mask');

        lon(lon>0) = lon(lon>0)-360;
        [lat2, lon2] = meshgrid(lat,lon);
        index = find(mask == 1);
        lon_sea = lon2(index);
        lat_sea = lat2(index);
        dist = sqrt((lon_sea - lon_target).^2 + (lat_sea - lat_target).^2);
        index = find(dist == min(dist));

        lonind = find(lon == lon_sea(index));
        latind = find(lat == lat_sea(index));
    end
    SST_K = ncread(file, 'analysed_sst', [lonind latind 1], [1 1 1]);
    SST_C = SST_K - 273.15; % K to C
    
    lon_sat = lon(lonind);
    lat_sat = lat(latind);
    SST_sat(ti) = SST_C;

    disp(['Loading OSTIA SST at ', ...
        num2str(lon_sat), ' (target = ', num2str(lon_target), '), and ', ...
        num2str(lat_sat), ' (target = ', num2str(lat_target), ')', ...
        ' on ', yyyymmdd])
end

end
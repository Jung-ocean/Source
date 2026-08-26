function [lon_sat, lat_sat, SST_sat] = load_ODYSSEA_daily(timenum)

    timevec = datevec(timenum);
    yyyy = timevec(:,1);
    mm = timevec(:,2);
    dd = timevec(:,3);

    ystr = num2str(yyyy);
    mstr = num2str(mm, '%02i');
    dstr = num2str(dd, '%02i');
    
    filepath = ['/data/jungjih/Observations/Satellite_SST/ODYSSEA/daily/', ystr, '/', mstr, '/'];
    files = dir([filepath, ystr, mstr, dstr, '*']);
    if length(files) == 1
        filename = files(1).name;
    else
        error('More than one files are found')
    end
    file = [filepath, filename];

    lon_sat = double(ncread(file, 'lon'));
    lat_sat = double(ncread(file, 'lat'));
    SST_sat = ncread(file, 'sea_surface_temperature')-273.15; % K to C
    quality_level = ncread(file, 'quality_level');

    lon1 = find(lon_sat > 0);
    lon2 = find(lon_sat < 0);
    lon_sat = [lon_sat(lon1)-360; lon_sat(lon2)];
    SST_sat = [SST_sat(lon1,:); SST_sat(lon2,:)];
    quality_level = [quality_level(lon1,:); quality_level(lon2,:)];

end
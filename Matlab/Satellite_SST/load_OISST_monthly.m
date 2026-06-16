function [lon_sat, lat_sat, SST_sat] = load_OISST_monthly(yyyy,mm)

    ystr = num2str(yyyy);
    mstr = num2str(mm, '%02i');
    
    filepath = ['/data/jungjih/Observations/Satellite_SST/OISST/monthly/'];
    filename = ['OISST_monthly_', ystr, mstr, '.nc'];
    file = [filepath, filename];

    lon_sat = double(ncread(file, 'lon'))-360;
    lat_sat = double(ncread(file, 'lat'));
    SST_sat = ncread(file, 'sst');

end
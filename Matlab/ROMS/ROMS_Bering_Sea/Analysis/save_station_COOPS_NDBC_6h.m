clear; clc; close all

filepath = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2019/Dsm4_phi3m1/';
startdate = datenum(2018,7,1);
filenum_start = datenum(2019,7,1) - startdate;
filenum_end = datenum(2019,11,1) - startdate;
filenum_all = filenum_start:filenum_end;

g = grd('BSf');

stations = {
    'CO-OPS, Sand Point'   % 1
    'CO-OPS, King Cove'    % 2
    'CO-OPS, Adak Island'  % 3
    'CO-OPS, Atka'         % 4
    'CO-OPS, Nikolski'     % 5
    'CO-OPS, Unalaska'     % 6
    'CO-OPS, Village Cove' % 7
    'CO-OPS, Unalakleet'   % 8
    'CO-OPS, Nome'         % 9
    'NDBC, Central Bering Sea'   % 10
    'NDBC, Southwest Bering Sea' % 11
    'NDBC, Western Aleutians'    % 12
    'NDBC, Central Aleutians'    % 13
    'NDBC, Southeast Bering Sea' % 14
    'NDBC, Shumagin Islands'     % 15
    'NDBC, Nome'                 % 16
    };
ids = {
    '9459450' % 1
    '9459881' % 2
    '9461380' % 3
    '9461710' % 4
    '9462450' % 5
    '9462620' % 6
    '9464212' % 7
    '9468333' % 8
    '9468756' % 9
    '46035'   % 10
    '46070'   % 11
    '46071'   % 12
    '46072'   % 13
    '46073'   % 14
    '46075'   % 15
    '46265'   % 16
    };
locations = [
199.496 55.332  % 1
197.6741 55.060 % 2
183.382 51.861  % 3
185.827 52.222  % 4
191.129 52.941  % 5
193.460 53.879  % 6
189.715 57.125  % 7
199.197 63.871  % 8
194.535 64.495  % 9
182.532 57.034  % 10
175.261 55.050  % 11
179.764 51.040  % 12
187.855 51.645  % 13
187.988 55.008  % 14
199.206 53.969  % 15
194.521 64.474  % 16
];

timenum_target = [];
temp_target = NaN(length(stations), 4*(filenum_end-filenum_start+1));
speed_target = NaN(length(stations), 4*(filenum_end-filenum_start+1));
zeta_target = NaN(length(stations), 4*(filenum_end-filenum_start+1));
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); 
    fstr = num2str(filenum, '%04i');
    filename = ['SumFal_2019_Dsm4_phi3m1_qck_', fstr, '.nc'];
    file = [filepath, filename];

    lon = ncread(file, 'lon_rho') + 360;
    lat = ncread(file, 'lat_rho');
    ot = ncread(file, 'ocean_time');
    timenum = ot/60/60/24 + datenum(1968,5,23);
    timenum_target = [timenum_target; timenum];

    temp = ncread(file, 'temp_sur');
    u = ncread(file, 'u_sur_eastward');
    v = ncread(file, 'v_sur_northward');
    speed = sqrt(u.*u + v.*v);
    zeta = ncread(file, 'zeta');

    wgs84 = wgs84Ellipsoid("km");

    for li = 1:length(stations)
        lon_sta = locations(li,1);
        lat_sta = locations(li,2);

        dist = distance(lat_sta,lon_sta,lat,lon,wgs84);
        [j, i] = find(dist == min(min(dist)));
        
        if li == 1
            i = i-2;
        elseif li == 2
            i = i-2;
        elseif li == 3
            j = j+1;
        elseif li == 5
            i = i+1;
        elseif li == 6
            i = i+4;
        elseif li == 8
            j = j-1;
        elseif li == 9
            i = i-1;
        end

        if fi == 1
            station_target{li} = stations{li};
            id_target{li} = ids{li};
            distance_from_station(li) = dist(j,i);
            lon_target(li) = lon(j,i);
            lat_target(li) = lat(j,i);
        end
        
        temp_target(li, (4*fi-3:4*fi)) = squeeze(temp(j,i,:));
        if isnan(sum(temp(j,i,:))) == 1
            figure; hold on;
            pcolor(g.mask_rho)
            plot(j,i, '.r')
            pause
        end
        speed_target(li, (4*fi-3:4*fi)) = squeeze(speed(j,i,:));
        zeta_target(li, (4*fi-3:4*fi)) = squeeze(zeta(j,i,:));
    end
    disp(filename)
end

ind_start = find(timenum_target == datenum(2019,7,1));
ind_end = find(timenum_target == datenum(2019,11,1));

timenum_target = timenum_target(ind_start:ind_end);
temp_target = temp_target(:,ind_start:ind_end);
speed_target = speed_target(:,ind_start:ind_end);
zeta_target = zeta_target(:,ind_start:ind_end);

filename = 'ROMS_stations_6h.nc';
ncid = netcdf.create(filename, 'CLOBBER');
% Dimension
dim_sta = netcdf.defDim(ncid, 'num_sta', length(stations));
dim_time = netcdf.defDim(ncid, 'time', length(timenum_target));  % 'y' dimension of size 20
dim_char = netcdf.defDim(ncid, 'char_len', 50);
% Variable
varid = netcdf.defVar(ncid, 'time', 'double', dim_time);
netcdf.putAtt(ncid, varid, 'long_name', 'time');
netcdf.putAtt(ncid, varid, 'units', 'days since 0000-00-00 00:00:00');
varid = netcdf.defVar(ncid, 'lon', 'double', dim_sta);
netcdf.putAtt(ncid, varid, 'long_name', 'Logitude');
netcdf.putAtt(ncid, varid, 'units', 'degree_east');
varid = netcdf.defVar(ncid, 'lat', 'double', dim_sta);
netcdf.putAtt(ncid, varid, 'long_name', 'Latitude');
netcdf.putAtt(ncid, varid, 'units', 'degree_north');
varid = netcdf.defVar(ncid, 'station', 'char', [dim_char, dim_sta]);
netcdf.putAtt(ncid, varid, 'long_name', 'station name');
varid = netcdf.defVar(ncid, 'id', 'char', [dim_char, dim_sta]);
netcdf.putAtt(ncid, varid, 'long_name', 'station ID');
varid = netcdf.defVar(ncid, 'distance_from_station', 'double', dim_sta);
netcdf.putAtt(ncid, varid, 'long_name', 'distance between ROMS output and CO-OPS or NDBC station');
netcdf.putAtt(ncid, varid, 'units', 'km');
varid = netcdf.defVar(ncid, 'temp', 'double', [dim_time, dim_sta]);
netcdf.putAtt(ncid, varid, 'long_name', 'surface temperature');
netcdf.putAtt(ncid, varid, 'units', '^oC');
varid = netcdf.defVar(ncid, 'zeta', 'double', [dim_time, dim_sta]);
netcdf.putAtt(ncid, varid, 'long_name', 'free-surface');
netcdf.putAtt(ncid, varid, 'units', 'meter');
varid = netcdf.defVar(ncid, 'speed', 'double', [dim_time, dim_sta]);
netcdf.putAtt(ncid, varid, 'long_name', 'surface current speed');
netcdf.putAtt(ncid, varid, 'units', 'meter second-1');
netcdf.endDef(ncid);

netcdf.close(ncid);

ncwrite(filename, 'time', timenum_target);
ncwrite(filename, 'lon', lon_target);
ncwrite(filename, 'lat', lat_target);
ncwrite(filename, 'station', char(station_target)');
ncwrite(filename, 'id', char(id_target)');
ncwrite(filename, 'distance_from_station', distance_from_station);
ncwrite(filename, 'temp', temp_target');
ncwrite(filename, 'zeta', zeta_target');
ncwrite(filename, 'speed', speed_target');

clear; clc

yyyy = 2024;
ystr = num2str(yyyy);

reftime = datenum(yyyy,1,1);
tstr = datestr(reftime, 'yyyy-mm-dd HH:MM:SS');

% ROMS variables
varnames_ROMS = {'Tair', 'Pair', 'Qair', 'rain', 'Uwind', 'Vwind', 'swrad', 'lwrad_down', 'cloud'};
timenames_ROMS = {'tair_time', 'pair_time', 'qair_time', 'rain_time', 'wind_time', 'wind_time', 'srf_time', 'lrf_time', 'cloud_time'};
longnames_ROMS = {...
    'surface_air_temperature', ...
    'surface_air_pressure', ...
    'surface air relative humidity', ...
    'rain fall rate', ...
    'surface u-wind component', ...
    'surface v-wind component', ...
    'net solar shortwave radiation flux', ...
    'downward longwave radiation flux', ...
    'cloud fraction'};
units_ROMS = {...
    'Celsius', ...
    'millibar', ...
    'percentage', ...
    'kilogram meter-2 second-1', ...
    'meter second-1', ...
    'meter second-1', ...
    'watt meter-2', ...
    'watt meter-2', ...
    'nondimensional'};

% ERA5 variables
filepath_ERA5 = '/data/jungjih/Models/ERA5/hourly/';
filenames_ERA5 = {...
    'ERA5', ...
    'ERA5', ...
    'ERA5', ...
    'ERA5', ...
    'ERA5', ...
    'ERA5', ...
    'ERA5', ...
    'ERA5', ...
    'ERA5'};
varnames_ERA5 = {...
    't2m', ...
    'msl', ...
    'd2m', ...
    'mtpr', ...
    'u10', ...
    'v10', ...
    'msnswrf', ...
    'msdwlwrf', ...
    'tcc'};

for vi = 1:length(varnames_ROMS)

    varname_ROMS = varnames_ROMS{vi};
    timename_ROMS = timenames_ROMS{vi};
    longname_ROMS = longnames_ROMS{vi};
    unit_ROMS = units_ROMS{vi};
    filename_ROMS = [varname_ROMS, '_ERA5_', ystr, '.nc'];
    filename_ERA5 = filenames_ERA5{vi};
    varname_ERA5 = varnames_ERA5{vi};
    
    file_ERA5_year = [filepath_ERA5, filename_ERA5, '_', ystr, '.nc'];
    lon = double(ncread(file_ERA5_year, 'longitude'));
    lon(lon>0) = lon(lon>0)-360;
    lat = double(ncread(file_ERA5_year, 'latitude'));
    vari_flip = 0;
    if lat(1) > lat(end)
        lat = flip(lat);
        vari_flip = 1;
    end
    time_tmp = double(ncread(file_ERA5_year, 'time'));
    
    len_lon = length(lon);
    len_lat = length(lat);
    [lat2, lon2] = meshgrid(lat, lon);
    timenum = time_tmp/24 + datenum(1900,1,1);
    ocean_time = timenum - datenum(yyyy,1,1);
    ocean_time(end+1) = yeardays(yyyy);
    ot_unique = unique(ocean_time);
    len_ot = length(ot_unique);
    dindex = [];
    for ti = 1:len_ot
        index_tmp = find(ocean_time == ot_unique(ti));
        if length(index_tmp) > 1
            dindex(ti) = index_tmp(1);
        else
            dindex(ti) = index_tmp;
        end
    end

    vari_ERA5_tmp = ncread(file_ERA5_year, varname_ERA5);
    if vari_flip == 1
        vari_ERA5_tmp = flip(vari_ERA5_tmp,2);
    end
    vari_ERA5_tmp(:,:,end+1) = vari_ERA5_tmp(:,:,end);
    vari_ERA5 = vari_ERA5_tmp(:,:,dindex);

switch varname_ROMS
    case 'Tair'
        vari_ROMS = vari_ERA5 - 273.15; % K to deg C
        lon_Tair = lon2;
        lat_Tair = lat2;
        Tair = vari_ROMS;
    case 'Pair'
        vari_ROMS = vari_ERA5*0.01; % Pa to millibar
        lon_Pair = lon2;
        lat_Pair = lat2;
        Pair = vari_ROMS;
    case 'Qair'
        Dair = vari_ERA5 - 273.15; % K to C

        % roms_matlab/forcing/d_ecmwf2roms.m   
        tsur  = Tair; % 2m temperature
        tdew  = Dair; % 2m dewpoint
        E     = 6.112 * exp( 17.62*tdew ./ (243.12+tdew));
        Es    = 6.112 * exp( 17.62*tsur ./ (243.12+tsur));
        field = 100.0 .* (E ./ Es);

        rhum = field;
        rhum(rhum < 0) = 0;
        rhum(rhum > 100) = 100;
        vari_ROMS = rhum;
    case 'swrad'
        swrad = vari_ERA5;
        swrad(swrad < 0) = 0;
        vari_ROMS = swrad;
    case 'cloud'
        tcc = vari_ERA5;
        tcc(tcc < 0) = 0;
        tcc(tcc > 1) = 1;
        vari_ROMS = tcc;
    otherwise
        vari_ROMS = vari_ERA5;
end

% Create a NetCDF file
ncid = netcdf.create(filename_ROMS, 'clobber');

% Global Attributes
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'type','ROMS Forcing File');
netcdf.putAtt(ncid,varid,'title','Bulk Formula Forcing File');
netcdf.putAtt(ncid,varid,'source','CFSv2 Time-Series');
netcdf.putAtt(ncid,varid,'author','Created by Jihun Jung');
netcdf.putAtt(ncid,varid,'date',datestr(date, 'yyyy-mm-dd'));

% Dimensions
lon_dimID = netcdf.defDim(ncid,'lon', len_lon);
lat_dimID = netcdf.defDim(ncid,'lat', len_lat);
time_dimID = netcdf.defDim(ncid, timename_ROMS, netcdf.getConstant('NC_UNLIMITED'));

% Attributes associated with the variable
time_ID = netcdf.defVar(ncid, timename_ROMS, 'double', time_dimID);
netcdf.putAtt(ncid, time_ID, 'long_name', [longname_ROMS, ' time']);
netcdf.putAtt(ncid, time_ID, 'units', ['days since ', tstr]);

lon_ID = netcdf.defVar(ncid, 'lon', 'double', [lon_dimID lat_dimID]);
netcdf.putAtt(ncid, lon_ID, 'long_name', 'native grid longitude');
netcdf.putAtt(ncid, lon_ID, 'units', 'degree');

lat_ID = netcdf.defVar(ncid, 'lat', 'double', [lon_dimID lat_dimID]);
netcdf.putAtt(ncid, lat_ID, 'long_name', 'native grid latitude');
netcdf.putAtt(ncid, lat_ID, 'units', 'degree');

var_ID = netcdf.defVar(ncid, varname_ROMS, 'double', [lon_dimID lat_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', longname_ROMS);
netcdf.putAtt(ncid, var_ID, 'units', unit_ROMS);
netcdf.putAtt(ncid, var_ID, 'time', timename_ROMS);
netcdf.putAtt(ncid, var_ID, 'coordinates', ['lon lat']);

netcdf.endDef(ncid);

% Write data to variable
netcdf.putVar(ncid, time_ID, 0, len_ot, ot_unique);
netcdf.putVar(ncid, lon_ID, lon2);
netcdf.putVar(ncid, lat_ID, lat2);
% var_permute = permute(var, [3,2,1]);
netcdf.putVar(ncid, var_ID, [0, 0, 0], [len_lon, len_lat, len_ot], vari_ROMS);

netcdf.close(ncid);

disp(varname_ROMS);

end % vi
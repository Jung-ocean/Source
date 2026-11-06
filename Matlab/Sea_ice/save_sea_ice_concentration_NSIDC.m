%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot sea ice concentration with velocity using geotiff file from NSIDC
%
% Geotiff file info
% sea ice concentration 0-1000 (divide by 10 to get percent)
% ocean 0
% pole hole 2510
% coast line 2530
% land 2540
% missing 2550
% Table 5 (https://nsidc.org/sites/default/files/g02135-v003-userguide_1_1.pdf)
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2004:2025;
mm_all = 1:12;

filepath_con = '/data/jungjih/Observations/Sea_ice/SIC/NSIDC/v4/concentration/monthly/';

SIC = NaN(12*length(yyyy_all), 448, 304);
timenum = NaN(12*length(yyyy_all),1);
ti = 1;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        tiffile = [filepath_con, 'N_', ystr, mstr, '_concentration_v4.0.tif'];
        
        [Z,R] = readgeoraster(tiffile,"OutputType","double");
        Z(Z == 2510) = NaN;  % Pole hole
        Z(Z == 2530) = NaN;  % Coast line
        Z(Z == 2540) = NaN;  % Land
        Z(Z == 2550) = NaN;  % Missing
        [X,Y] = worldGrid(R);

        info = geotiffinfo(tiffile);
        [lat,lon] = projinv(info,X,Y);

        timenum(ti) = datenum(yyyy,mm,1);
        SIC(ti,:,:) = Z/10;

        ti = ti + 1;
        disp([ystr, mstr])
    end
end
info = geotiffinfo(tiffile);

% Save NSIDC sea ice concentration as NetCDF
ncfile = 'SIC_NSIDC_v4.nc';

% Delete existing file if present
if isfile(ncfile)
    delete(ncfile);
end

% Dimensions
nt = size(SIC, 1);
ny = size(SIC, 2);
nx = size(SIC, 3);

% Projected coordinates (meters)
x = X(1, :);
y = Y(:, 1);

% Time: days since 2000-01-01 00:00:00
dt = datetime(timenum, 'ConvertFrom', 'datenum');
time = days(dt - datetime(2000, 1, 1));

% Reorder data from time × y × x to x × y × time
SIC_out = permute(single(SIC), [3 2 1]);
lat_out = permute(lat, [2 1]);
lon_out = permute(lon, [2 1]);

% Create NetCDF variables
nccreate(ncfile, 'time', ...
    'Dimensions', {'time', nt}, ...
    'Datatype', 'double');

nccreate(ncfile, 'x', ...
    'Dimensions', {'x', nx}, ...
    'Datatype', 'double');

nccreate(ncfile, 'y', ...
    'Dimensions', {'y', ny}, ...
    'Datatype', 'double');

nccreate(ncfile, 'lat', ...
    'Dimensions', {'x', nx, 'y', ny}, ...
    'Datatype', 'double');

nccreate(ncfile, 'lon', ...
    'Dimensions', {'x', nx, 'y', ny}, ...
    'Datatype', 'double');

nccreate(ncfile, 'crs', ...
    'Datatype', 'int32');

nccreate(ncfile, 'SIC', ...
    'Dimensions', {'x', nx, 'y', ny, 'time', nt}, ...
    'Datatype', 'single', ...
    'DeflateLevel', 4);

% Write data
ncwrite(ncfile, 'time', time);
ncwrite(ncfile, 'x', x);
ncwrite(ncfile, 'y', y);
ncwrite(ncfile, 'lat', lat_out);
ncwrite(ncfile, 'lon', lon_out);
ncwrite(ncfile, 'crs', int32(0));

% Convert double to single only when writing
ncwrite(ncfile, 'SIC', SIC_out);

% Time attributes
ncwriteatt(ncfile, 'time', 'standard_name', 'time');
ncwriteatt(ncfile, 'time', 'long_name', 'Time');
ncwriteatt(ncfile, 'time', 'units', ...
    'days since 2000-01-01 00:00:00');
ncwriteatt(ncfile, 'time', 'calendar', 'gregorian');

% Projected coordinate attributes
ncwriteatt(ncfile, 'x', 'standard_name', ...
    'projection_x_coordinate');
ncwriteatt(ncfile, 'x', 'long_name', 'x coordinate');
ncwriteatt(ncfile, 'x', 'units', 'm');
ncwriteatt(ncfile, 'x', 'axis', 'X');

ncwriteatt(ncfile, 'y', 'standard_name', ...
    'projection_y_coordinate');
ncwriteatt(ncfile, 'y', 'long_name', 'y coordinate');
ncwriteatt(ncfile, 'y', 'units', 'm');
ncwriteatt(ncfile, 'y', 'axis', 'Y');

% Latitude and longitude attributes
ncwriteatt(ncfile, 'lat', 'standard_name', 'latitude');
ncwriteatt(ncfile, 'lat', 'long_name', 'latitude');
ncwriteatt(ncfile, 'lat', 'units', 'degrees_north');

ncwriteatt(ncfile, 'lon', 'standard_name', 'longitude');
ncwriteatt(ncfile, 'lon', 'long_name', 'longitude');
ncwriteatt(ncfile, 'lon', 'units', 'degrees_east');

% Polar stereographic projection attributes
ncwriteatt(ncfile, 'crs', 'grid_mapping_name', ...
    'polar_stereographic');
ncwriteatt(ncfile, 'crs', ...
    'latitude_of_projection_origin', 90.0);
ncwriteatt(ncfile, 'crs', ...
    'straight_vertical_longitude_from_pole', -45.0);
ncwriteatt(ncfile, 'crs', 'standard_parallel', 70.0);
ncwriteatt(ncfile, 'crs', 'false_easting', 0.0);
ncwriteatt(ncfile, 'crs', 'false_northing', 0.0);

ncwriteatt(ncfile, 'crs', 'semi_major_axis', ...
    info.SemiMajor);
ncwriteatt(ncfile, 'crs', 'semi_minor_axis', ...
    info.SemiMinor);
ncwriteatt(ncfile, 'crs', 'inverse_flattening', ...
    info.SemiMajor / (info.SemiMajor - info.SemiMinor));
ncwriteatt(ncfile, 'crs', ...
    'longitude_of_prime_meridian', 0.0);
ncwriteatt(ncfile, 'crs', 'reference_ellipsoid_name', ...
    'Hughes 1980');
ncwriteatt(ncfile, 'crs', 'projected_crs_name', ...
    'WGS 84 / NSIDC Sea Ice Polar Stereographic North');

% SIC attributes
ncwriteatt(ncfile, 'SIC', 'long_name', ...
    'Sea ice concentration');
ncwriteatt(ncfile, 'SIC', 'units', '%');
ncwriteatt(ncfile, 'SIC', 'valid_min', single(0));
ncwriteatt(ncfile, 'SIC', 'valid_max', single(100));
ncwriteatt(ncfile, 'SIC', 'coordinates', 'lat lon');
ncwriteatt(ncfile, 'SIC', 'grid_mapping', 'crs');

% Global attributes
ncwriteatt(ncfile, '/', 'Conventions', 'CF-1.8');
ncwriteatt(ncfile, '/', 'title', ...
    'Monthly Arctic Sea Ice Concentration');
ncwriteatt(ncfile, '/', 'institution', ...
    'National Snow and Ice Data Center (NSIDC)');
ncwriteatt(ncfile, '/', 'source', ...
    'NSIDC Sea Ice Concentration GeoTIFF, Version 4.0');
ncwriteatt(ncfile, '/', 'spatial_resolution', ...
    '25 km nominal grid spacing');
ncwriteatt(ncfile, '/', 'history', ...
    ['Converted from NSIDC GeoTIFF to NetCDF using MATLAB. ' ...
     'Pole hole, coastline, land, and missing-value codes ' ...
     'were set to NaN. SIC stored as single precision.']);

% Verify dimensions
ncdisp(ncfile, 'SIC');
SIC_check = ncread(ncfile, 'SIC');
disp('SIC dimensions read by ncread:');
disp(size(SIC_check));

lat_plot = ncread(ncfile, 'lat');
lon_plot = ncread(ncfile, 'lon');
SIC_plot = ncread(ncfile, 'SIC', [1 1 1], [Inf Inf ,1]);

figure; hold on; grid on
plot_arctic_map
p = pcolorm(lat_plot, lon_plot, SIC_plot);
caxis([0 100])
uistack(p, 'bottom')
c = colorbar;
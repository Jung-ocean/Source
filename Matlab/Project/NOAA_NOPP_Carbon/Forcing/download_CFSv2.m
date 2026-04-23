clear; clc

yyyy_all = 2024;
mm_all = 1:12;

varis = {'tmp2m', 'prmsl', 'q2m', 'prate', 'wnd10m', 'dswsfc', 'dlwsfc', 'tcdcclm'};

wgrib2 = '/data/jungjih/RTDAOW2/barb/grib2/wgrib2/wgrib2';
lon_lim=[-132 -119]+360;
lat_lim=[38 52];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        for vi = 1:length(varis)
            vari = varis{vi};
            filename = [vari, '.gdas.', ystr, mstr, '.grib2'];

            if ~exist(filename)
                link = ...
                    ['https://www.ncei.noaa.gov/data/' ...
                    'climate-forecast-system/access/' ...
                    'operational-analysis/time-series' ...
                    '/', ystr, '/', ystr, mstr, '/' ...
                    filename];

                command = ['wget ', link];
                system(command);

                % grib2 to netcdf
                ncfile = replace(filename, 'grib2', 'nc');
                command = ...
                    [wgrib2, ' '...
                    filename, ' -netcdf ', ncfile];
                system(command);

                lon = ncread(ncfile, 'longitude');
                lat = ncread(ncfile, 'latitude');

                if strcmp(vari, 'prmsl') % pressure fields are more coarser than the other fields
                    lonind = find(lon > min(lon_lim)-0.5 & lon < max(lon_lim)+0.5);
                    latind = find(lat > min(lat_lim)-0.5 & lat < max(lat_lim)+0.5);
                else
                    lonind = find(lon > min(lon_lim) & lon < max(lon_lim));
                    latind = find(lat > min(lat_lim) & lat < max(lat_lim));
                end

                lon1 = num2str(min(lonind)-1); % -1 due to fortran numbering
                lon2 = num2str(max(lonind)-1); % -1 due to fortran numbering
                lat1 = num2str(min(latind)-1); % -1 due to fortran numbering
                lat2 = num2str(max(latind)-1); % -1 due to fortran numbering

                % Make small-domain netcdf file
                command = ...
                    ['ncks -d latitude,', lat1, ',', lat2, ' ' ...
                    '-d longitude,', lon1, ',', lon2, ' ' ...
                    ncfile, ' ', replace(ncfile, '.nc', '_sub.nc')];
                system(command);

                % Delete original nc file
                command = ['rm -f ', ncfile];
                system(command);
            end % ~exist

        end % vi
    end % mi
end % yi

% Filename examples
% tmp2m.gdas.202401.grib2
% prmsl.gdas.202401.grib2
% q2m.gdas.202401.grib2
% prate.gdas.202401.grib2
% wnd10m.gdas.202401.grib2
% dswsfc.gdas.202401.grib2
% dlwsfc.gdas.202401.grib2
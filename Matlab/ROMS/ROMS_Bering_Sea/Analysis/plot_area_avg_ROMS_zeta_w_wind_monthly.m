%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS area averaged zeta with wind monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; %close all

yyyy_all = 2018:2023;
mm_all = 1:12;
startdate = datenum(2018,7,1);

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

filepath_con = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/';
region =  'Gulf_of_Anadyr';
polygon = [;
    -180   60
    -180   65
    -170   65
    -170   60
    -180   60
    ];

[in, on] = inpolygon(g.lon_rho, g.lat_rho, polygon(:,1), polygon(:,2));
mask_target = in./in;
area_target = area.*mask_target;

% Wind
filepath_wind = ['/data/jungjih/Models/ERA5/monthly/'];

% polygon_wind = [;
%     -181.1407   62.6194
%     -173.5578   64.6246
%     -171.1441   63.6253
%     -178.4787   61.5
%     -181.1407   62.6194
%     ];
polygon_wind = [;
    -180   60
    -180   65
    -170   65
    -170   60
    -180   60
    ];

angle = azimuth(61.9925, -179.7011, 64.2886, -172.2554);

figure; hold on; grid on;
plot_map('Bering', 'mercator', 'l')
plotm(polygon(:,2), polygon(:,1))
plotm(polygon_wind(:,2), polygon_wind(:,1), 'LineWidth', 2)

ind = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        ind = ind+1;
        timenum(ind) = datenum(yyyy,mm,15);

        filename_wind = ['ERA5_', ystr, mstr, '.nc'];
        file_wind = [filepath_wind, filename_wind];

        filename = ['Dsm2_spng_', ystr, mstr, '.nc'];
        file_con = [filepath_con, filename];

        if exist(file_con) == 0
            vari_target(ind) = NaN;
        else
            vari = ncread(file_con, 'zeta')';
            vari_target(ind) = sum(vari(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');
        end

        % wind region
        skip = 1;
        npts = [0 0 0 0];

        % wind
        lat = ncread(file_wind, 'latitude');
        lon = ncread(file_wind, 'longitude')-360;

        [lon2, lat2] = meshgrid(lon, lat);

        [in, on] = inpolygon(lon2, lat2, polygon_wind(:,1), polygon_wind(:,2));
        mask_wind = in./in;

        uwind = ncread(file_wind, 'u10')';
        vwind = ncread(file_wind, 'v10')';

        wind_nor = cosd(angle).*uwind - sind(angle).*vwind;
        wind_tan = sind(angle).*uwind + cosd(angle).*vwind;

        wind_tan_mask = wind_tan.*mask_wind;
        wind_target(ind) = mean(wind_tan_mask(:), 'omitnan');

        disp([datestr(datenum(yyyy,mm,15), 'yyyymm')])
    end
end

figure; hold on; grid on
plot(timenum, wind_target);
xticks([datenum(yyyy_all,1,1)])
datetick('x', 'keepticks', 'keeplimits')
ylim([-10 10])
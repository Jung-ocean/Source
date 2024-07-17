%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS svstr with ERA5 wind stress daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2019:2022;
points = [1 2 3 4];
points_name = {'N1', 'N2', 'N3', 'N4'};
points_location = [;
    63.2965, -168.43;
    64.1545, -171.526;
    64.3895, -167.086;
    64.9284, -169.9182;
    ];

% Model
model_filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/ncks/';
g = grd('BSf');
startdate = datenum(2018,7,1);

% Wind
wind_filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/';

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    yyyymmdd_all = [datenum(yyyy,1,1):datenum(yyyy,7,1)];

    for pi = 1:length(points)

        point = points(pi);
        point_lon = points_location(point,2);
        point_lat = points_location(point,1);

        vari_wind_point = [];
        vari_model_point = [];
        for di = 1:length(yyyymmdd_all)

            yyyymmdd = yyyymmdd_all(di);
            yyyymmdd_str = datestr(yyyymmdd, 'yyyymmdd');
            ystr = datestr(yyyymmdd, 'yyyy');
            mstr = datestr(yyyymmdd, 'mm');

            % wind
            wind_filename = ['BSf_ERA5_', ystr, '_', mstr, '_ni2_a_frc.nc'];
            wind_file = [wind_filepath, wind_filename];

            lon_wind = double(ncread(wind_file, 'lon'))';
            lat_wind = double(ncread(wind_file, 'lat'))';
            time_wind = ncread(wind_file, 'sfrc_time') + datenum(1968,05,23);
            vari_uwind = ncread(wind_file, 'Uwind');
            vari_uwind = permute(vari_uwind, [3 2 1]);
            vari_vwind = ncread(wind_file, 'Vwind');
            vari_vwind = permute(vari_vwind, [3 2 1]);

            index = find(floor(time_wind) == yyyymmdd);
            vari_uwind_daily = squeeze(mean(vari_uwind(index,:,:)));
            vari_vwind_daily = squeeze(mean(vari_vwind(index,:,:)));

            vari_uwind_point = interp2(lon_wind, lat_wind, vari_uwind_daily, point_lon, point_lat);
            vari_vwind_point = interp2(lon_wind, lat_wind, vari_vwind_daily, point_lon, point_lat);

            speed = sqrt(vari_uwind_point.*vari_uwind_point + vari_vwind_point.*vari_vwind_point);

            vari_wind_point(di) = 0.0013*1.22*speed*vari_vwind_point;

            % Model
            filenumber = yyyymmdd - startdate + 1;
            fstr = num2str(filenumber, '%04i');
            model_filename = ['svstr_', fstr, '.nc'];
            model_file = [model_filepath, model_filename];

            vari_model = ncread(model_file, 'svstr')';
            vari_model_point(di) = interp2(g.lon_v, g.lat_v, vari_model, point_lon, point_lat);

            disp(yyyymmdd_str)
        end

        pmodel = plot(yyyymmdd_all, vari_model_point, '-', 'Color', [0 0.4471 0.7412]);
        ylim([-2.5 2.5])
        ylabel('ROMS meridional surface stress (N/m^2)')

        yyaxis right
        pwind = plot(yyyymmdd_all, vari_wind_point, '-', 'Color', [0.8510 0.3255 0.0980]);
        ylim([-2.5 2.5]);
        ylabel('ERA5 meridional wind stress (N/m^2)')

        yyaxis left
        set(gca, 'ycolor', [0 0.4471 0.7412])

        xticks([datenum(yyyy,1:12,1)])
        xlim([yyyymmdd_all(1)-1 yyyymmdd_all(end)+1])
        datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')

        title(points_name(point), 'FontSize', 15)

        print([points_name{point}, '_svstr_w_ERA5_windstress_', ystr], '-dpng')
    
        delete(pmodel);
        delete(pwind);
    end % pi
end % yi
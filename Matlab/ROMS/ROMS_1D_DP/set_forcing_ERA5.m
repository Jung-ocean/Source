clear; clc;

filename_out = 'forcing_1D_DP.nc';

yyyy_all = 2018:2023;
mm_all = 1:12;

lon = ncread('../grid/grid_1D_DP.nc', 'lon_rho');
lon = mean(lon(:));
lat = ncread('../grid/grid_1D_DP.nc', 'lat_rho');
lat = mean(lat(:));

filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);
    
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        filename = ['BSf_ERA5_', ystr, '_', mstr, '_ni2_a_frc.nc'];
        file = [filepath, filename];

        if exist(file)
            lon_ERA5 = ncread(file, 'lon');
            lat_ERA5 = ncread(file, 'lat');
            
            lonind = find(lon_ERA5(:,1) > lon-1 & lon_ERA5(:,1) < lon+1);
            latind = find(lat_ERA5(1,:) > lat-1 & lat_ERA5(1,:) < lat+1);

            lon1 = lonind(1)-1; % ncks convention starts from 0
            lon2 = lonind(end)-1;

            lat1 = latind(1)-1; % ncks convention starts from 0
            lat2 = latind(end)-1;

            command = ['ncks', ...
                ' -d ln_rho,', num2str(lon1), ',', num2str(lon2), ...
                ' -d lt_rho,', num2str(lat1), ',', num2str(lat2), ...
                ' ', file, ' ./ERA5_', ystr, mstr, '.nc'];
            system(command)
        end
    end % mi
end % yi

command = ['ncrcat *.nc ./forcing_1D_DP.nc'];
system(command)
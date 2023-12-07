%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Make ROMS forcing using the ECMWF data (Temperature)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clearvars -except target_year casename; close all;

% Setting
casename = 'NWP';
vari = 'Tair';
target_year = 1980; tys = num2str(target_year);

interval_time = 6;
time_forcing = datenum(target_year,1,1):interval_time/24:datenum(target_year+1,1,1);

fpath = 'D:\Data\Atmosphere\ECMWF_DAMO\';
fname = ['ECMWF_Interim_airT_', tys, '.nc'];

ncfile = [fpath, fname];
nc = netcdf(ncfile);
time = nc{'time'}(:);
variable = nc{'t2m'}(:); % t2m = 2 metre temperature
latitude = nc{'latitude'}(:);
longitude = nc{'longitude'}(:);
scale_factor = nc{'t2m'}.scale_factor(:);
add_offset = nc{'t2m'}.add_offset(:);
close(nc)

vari_Kelvin = variable.*scale_factor + add_offset;
vari_Celcius = vari_Kelvin - 273.15;
clearvars variable vari_Kelvin

g = grd(casename);
lon_rho = g.lon_rho; lat_rho = g.lat_rho;
lon_grid = g.lon_rho(1,:); lat_grid = g.lat_rho(:,1);
[len_eta, len_xi] = size(g.mask_rho);

index_lon = find(min(lon_grid) - 1 < longitude & max(lon_grid) + 1 > longitude);
index_lat = find(min(lat_grid) - 1 < latitude & max(lat_grid) + 1 > latitude);

longitude_range = longitude(index_lon);
latitude_range = latitude(index_lat);

[Xi,Yi] = meshgrid(longitude_range,latitude_range);

% ECMWF time = hours since 1900-01-01 00:00:0.0
ftime = time/24 + datenum(1900,01,01,0,0,0);

ot = 0:interval_time/24:yeardays(target_year); % ot = ocean time
len_ot = length(ot);
vari_interp = zeros(len_ot, len_eta, len_xi);  % Preallocating Arrays for speed

for i = 1:length(time_forcing)
    tindex = find(time_forcing(i) == ftime);
    Zi = squeeze(vari_Celcius(tindex,index_lat,index_lon));
    vari_interp(i,:,:) = griddata(Xi, Yi, Zi, lon_grid, lat_grid);
    if mod(i,100) == 0
        disp(['End calculation ', num2str(i), '/', num2str(length(time_forcing))])
    end
end

if leapyear(target_year)
    cycle_length = 366;
else
    cycle_length = 365;
end
% Generate forcing file and write data
outfname = [vari, '_', casename, '_ECMWF_', num2str(target_year), '.nc'];
create_frc_file(outfname,vari,vari_interp,ot,cycle_length);

% Write longitude and latitude information
nc = netcdf.open(outfname,'write');
lon_rho_trans = lon_rho'; lat_rho_trans = lat_rho';
lon_ID = netcdf.inqVarID(nc,'lon_rho');
netcdf.putVar(nc, lon_ID, lon_rho_trans);
lat_ID = netcdf.inqVarID(nc,'lat_rho');
netcdf.putVar(nc, lat_ID, lat_rho_trans);
netcdf.close(nc);

% Plot
figure; plot(mean(mean(vari_interp,2),3))
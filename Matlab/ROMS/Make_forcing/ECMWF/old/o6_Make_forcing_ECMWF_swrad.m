%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Make ROMS forcing using the ECMWF data (Short wave radiation)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clearvars -except target_year casename; close all;

% Setting
casename = 'NWP';
vari = 'swrad';
target_year = 1980; tys = num2str(target_year);

interval_mean = 12;
time_forcing = datenum(target_year,1,1,12,0,0):interval_mean/24:datenum(target_year+1,1,1);

fpath = 'D:\Data\Atmosphere\ECMWF_DAMO\';
fname = ['ECMWF_Interim_ssrd_', tys, '.nc'];

ncfile = [fpath, fname];
nc = netcdf(ncfile);
time = nc{'time'}(:);
variable = nc{'ssrd'}(:); % ssrd = Surface solar radiation downwards
latitude = nc{'latitude'}(:);
longitude = nc{'longitude'}(:);
scale_factor = nc{'ssrd'}.scale_factor(:);
add_offset = nc{'ssrd'}.add_offset(:);
close(nc)

% ECMWF time = hours since 1900-01-01 00:00:0.0
ftime = datestr(time/24 + datenum(1900,01,01,0,0,0), 'yyyymmddHH');

vari_Jm_2 = variable.*scale_factor + add_offset; % Jm_2 = J/m^2
vari_Wm_2 = vari_Jm_2/43200; % Wm_2 = W/m^2
clearvars variable vari_Jm_2

for i = 1:yeardays(target_year)
    index_time1 = find(time_forcing(2*i-1) == ftime);
    index_time2 = find(time_forcing(2*i) == ftime);
    vari_Wm_2_24accumulated(i,:,:) = (vari_Wm_2(2*i-1,:,:) + vari_Wm_2(2*i,:,:))/2;
end

g = grd(casename);
lon_rho = g.lon_rho; lat_rho = g.lat_rho;
lon_grid = g.lon_rho(1,:); lat_grid = g.lat_rho(:,1);
[len_eta, len_xi] = size(g.mask_rho);

index_lon = find(min(lon_grid) - 1 < longitude & max(lon_grid) + 1 > longitude);
index_lat = find(min(lat_grid) - 1 < latitude & max(lat_grid) + 1 > latitude);

longitude_range = longitude(index_lon);
latitude_range = latitude(index_lat);




[Xi,Yi] = meshgrid(longitude,latitude);

gn = grd(casename);
lon_rho = gn.lon_rho; lat_rho = gn.lat_rho;
lon_grid = gn.lon_rho(1,:); lat_grid = gn.lat_rho(:,1);
[len_eta, len_xi] = size(gn.mask_rho);

outfname = [vari, '_', casename, '_ECMWF_', num2str(target_year), '.nc'];

ot = 0.5:1:yd-0.5; % ot = ocean time
len_ot = length(ot);

vari_interp = zeros(len_ot, len_eta, len_xi);  % Preallocating Arrays for speed

for i = 1:len_ot
    Zi = squeeze(vari_Wm_2_24accumulated(i,:,:));
    vari_interp(i,:,:) = griddata(Xi, Yi, Zi, lon_grid, lat_grid);
    if mod(i,100) == 0
        disp(['End calculation ', num2str(i), '/', num2str(len_ot)])
    end
end

% Generate forcing file and write data
create_frc_file(outfname,vari,vari_interp,ot,cycle_length);

% write longitude and latitude information
nc = netcdf.open(outfname,'write');
lon_rho_trans = lon_rho'; lat_rho_trans = lat_rho';
lon_ID = netcdf.inqVarID(nc,'lon_rho');
netcdf.putVar(nc, lon_ID, lon_rho_trans);
lat_ID = netcdf.inqVarID(nc,'lat_rho');
netcdf.putVar(nc, lat_ID, lat_rho_trans);
netcdf.close(nc);
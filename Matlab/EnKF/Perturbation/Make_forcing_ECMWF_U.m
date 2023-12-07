%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Make ROMS forcing using the ECMWF data (U wind)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clc; clear; close all;

% Setting
%casename = 'NWP';
vari = 'Uwind';
%target_year = 2015;
yd = yeardays(target_year);
yyyy = target_year;
if leapyear(yyyy)
    cycle_length = 366.25;
else
    cycle_length = 365.25;
end

%fpath = 'G:\DataAssimilation\Case\NWP\exp_2\forcing\raw\';
fname = ['wind_ECMWF_', num2str(yyyy), '_ens', num2char(ens_num, 2), '.nc'];
ncfile = [fpath, fname];

nc = netcdf(ncfile);
time = nc{'time'}(:);
variable = nc{'u10'}(:); % u10 = 10 metre U wind component
latitude = nc{'latitude'}(:);
longitude = nc{'longitude'}(:);
close(nc)

vari_ms = variable; % ms = m/s

[Xi,Yi] = meshgrid(longitude,latitude);

% ECMWF time = hours since 1900-01-01 00:00:0.0
ftime = datestr(time, 'yyyymmddHH');

gn = grd(casename);
lon_rho = gn.lon_rho; lat_rho = gn.lat_rho;
lon_grid = gn.lon_rho(1,:); lat_grid = gn.lat_rho(:,1);
[len_eta, len_xi] = size(gn.mask_rho);

outfname = [vari, '_', num2str(target_year),'_ens', num2char(ens_num, 2),'.nc'];

ot = 0:1/4:yd-1/4; % ot = ocean time
len_ot = length(ot);

vari_interp = zeros(len_ot, len_eta, len_xi);  % Preallocating Arrays for speed

for i = 1:len_ot
    Zi = squeeze(vari_ms(i,:,:));
    vari_interp(i,:,:) = griddata(Xi, Yi, Zi, lon_grid, lat_grid);
    if mod(i,100) == 0
        disp(['End calculation ', num2str(i), '/', num2str(len_ot)])
    end
end

% Generate forcing file and write data
create_frc_file(outfname,vari,vari_interp,ot,365.25);

% write longitude and latitude information
nc = netcdf.open(outfname,'write');
lon_rho_trans = lon_rho'; lat_rho_trans = lat_rho';
lon_ID = netcdf.inqVarID(nc,'lon_rho');
netcdf.putVar(nc, lon_ID, lon_rho_trans);
lat_ID = netcdf.inqVarID(nc,'lat_rho');
netcdf.putVar(nc, lat_ID, lat_rho_trans);
netcdf.close(nc);
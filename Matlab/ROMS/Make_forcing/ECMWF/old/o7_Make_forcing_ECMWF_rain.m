%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Make ROMS forcing using the ECMWF data (rain)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clearvars -except target_year casename; close all;

% Setting
%casename = 'NWP';
vari = 'rain';
%target_year = 2016;
tys = num2str(target_year);
yd = yeardays(target_year);
yyyy = target_year;
if leapyear(yyyy)
    cycle_length = 366.25;
else
    cycle_length = 365.25;
end

fpath = 'D:\Data\Atmosphere\ECMWF_interim\';
fname = [tys, '-2.nc'];
ncfile = [fpath, fname];

nc = netcdf(ncfile);
time = nc{'time'}(:);
variable = nc{'tp'}(:); % tp = Total precipitation
latitude = nc{'latitude'}(:);
longitude = nc{'longitude'}(:);
scale_factor = nc{'tp'}.scale_factor(:);
add_offset = nc{'tp'}.add_offset(:);
close(nc)

vari_m = variable.*scale_factor + add_offset; % m = meter
vari_ms_1 = vari_m./43200; % ms_1 = m/s

for i = 1:yd
    vari_ms_1_24accumulated(i,:,:) = (vari_ms_1(2*i-1,:,:) + vari_ms_1(2*i,:,:))/2;
end
vari_kgms_1 = 1000*vari_ms_1_24accumulated; % kgms_1 = kgm/s, actually kg/m^2s

[Xi,Yi] = meshgrid(longitude,latitude);

% ECMWF time = hours since 1900-01-01 00:00:0.0
ftime = datestr(time/24 + datenum(1900,01,01,0,0,0), 'yyyymmddHH');

gn = grd(casename);
lon_rho = gn.lon_rho; lat_rho = gn.lat_rho;
lon_grid = gn.lon_rho(1,:); lat_grid = gn.lat_rho(:,1);
[len_eta, len_xi] = size(gn.mask_rho);

outfname = [vari, '_', casename, '_ECMWF_', num2str(target_year), '.nc'];

ot = 0.5:1:yd-0.5; % ot = ocean time
len_ot = length(ot);

vari_interp = zeros(len_ot, len_eta, len_xi);  % Preallocating Arrays for speed

for i = 1:len_ot
    Zi = squeeze(vari_kgms_1(i,:,:));
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
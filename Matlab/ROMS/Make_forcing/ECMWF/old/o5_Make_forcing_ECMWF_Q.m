%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Make ROMS forcing using the ECMWF data (Relative humidity)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clearvars -except target_year casename; close all;

% Setting
casename = 'NWP';
vari = 'Qair';
target_year = 1980; tys = num2str(target_year);

interval_time = 6;
time_forcing = datenum(target_year,1,1):interval_time/24:datenum(target_year+1,1,1);

tfpath = 'D:\Data\Atmosphere\ECMWF_DAMO\';
tfname = ['ECMWF_Interim_airT_', tys, '.nc'];

dfpath = 'D:\Data\Atmosphere\ECMWF_DAMO\';
dfname = ['ECMWF_Interim_dewt_', tys, '.nc'];

tncfile = [tfpath, tfname]; 
tnc = netcdf(tncfile);

dncfile = [dfpath, dfname]; 
dnc = netcdf(dncfile);

time = tnc{'time'}(:);
Dair = dnc{'d2m'}(:); % d2m = 2 metre dewpoint temperature
Tair = tnc{'t2m'}(:); % t2m = 2 metre temperature
latitude = tnc{'latitude'}(:);
longitude = tnc{'longitude'}(:);
Dair_scale_factor = dnc{'d2m'}.scale_factor(:);
Dair_add_offset = dnc{'d2m'}.add_offset(:);
Tair_scale_factor = tnc{'t2m'}.scale_factor(:);
Tair_add_offset = tnc{'t2m'}.add_offset(:);
close(tnc); close(dnc)

Dair_Kelvin = Dair.*Dair_scale_factor + Dair_add_offset;
Tair_Kelvin = Tair.*Tair_scale_factor + Tair_add_offset;
clearvars Dair Tair

Qair = 100*e_sat(Dair_Kelvin)./e_sat(Tair_Kelvin);
clearvars Dair_Kelvin Tair_Kelvin

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
ftime = datestr(time/24 + datenum(1900,01,01,0,0,0), 'yyyymmddHH');

ot = 0:interval_time/24:yeardays(target_year); % ot = ocean time
len_ot = length(ot);
vari_interp = zeros(len_ot, len_eta, len_xi);  % Preallocating Arrays for speed

for i = 1:length(time_forcing)
    tindex = find(time_forcing(i) == ftime);
    Zi = squeeze(Qair(tindex,index_lat,index_lon));
    vari_interp(i,:,:) = griddata(Xi, Yi, Zi, lon_grid, lat_grid);
    if mod(i,100) == 0
        disp(['End calculation ', num2str(i), '/', num2str(len_ot)])
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

% write longitude and latitude information
nc = netcdf.open(outfname,'write');
lon_rho_trans = lon_rho'; lat_rho_trans = lat_rho';
lon_ID = netcdf.inqVarID(nc,'lon_rho');
netcdf.putVar(nc, lon_ID, lon_rho_trans);
lat_ID = netcdf.inqVarID(nc,'lat_rho');
netcdf.putVar(nc, lat_ID, lat_rho_trans);
netcdf.close(nc);

% Plot
figure; plot(mean(mean(vari_interp,2),3))
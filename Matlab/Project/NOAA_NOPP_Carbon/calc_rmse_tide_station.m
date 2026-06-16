%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate tide RMSE using complex amplitude of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

expname = 'Oregon_1km';
g = grd(expname);

yyyy = 2024;
ystr = num2str(yyyy);

datenum_start = datenum(yyyy,1,1);
datenum_end = datenum(yyyy,11,30);

constituents = {'M2', 'S2', 'K1', 'O1'};

load_NOAA_station_info
index = find(lats > min(g.lat_rho(:)) & lats < max(g.lat_rho(:)));
stations = stations(index);
ids = ids(index);
lons = lons(index);
lats = lats(index);

filepath_obs = '/data/jungjih/Observations/NOAA_stations/US_west/';
for i = 1:length(ids)
    id = ids(i);
    idstr = num2str(id);
    lat = lats(i);
    filename_obs = ['WL_', idstr, '_', ystr, '.csv'];
    file = [filepath_obs, filename_obs];
    obs = readtable(file);
    yyyymmdd = datenum(table2array(obs(:,1)));
    HHMM = datenum(table2array(obs(:,2)));
    HHMM = HHMM - floor(HHMM);
    timenum_obs = yyyymmdd + HHMM;
    vari_obs_tmp = table2array(obs(:,5));
    vari_obs(i,:) = vari_obs_tmp;

    interval = 24*diff(timenum_obs(1:2));

    [tidestruc, pout] = t_tide(vari_obs_tmp, ...
        'interval', interval, ...
        'latitude', lat, ...
        'start', timenum_obs(1), ...
        'secular', 'mean', ...
        'rayleigh', 1, ...
        'shallow', 'M10', ...
        'error', 'wboot', ...
        'synthesis', 1);
    for ci = 1:length(constituents)
        cons = constituents{ci};
        index = find(ismember(tidestruc.name, {cons})==1);
        amp_obs(i,ci) = tidestruc.tidecon(index,1);
        pha_obs(i,ci) = tidestruc.tidecon(index,3);
    end
end

pha_obs_radian = pha_obs*(pi/180);
camp_obs = amp_obs.*exp(sqrt(-1)*pha_obs_radian);

% ROMS
[timenum_ROMS, lon_ROMS, lat_ROMS, vari_ROMS] = load_models_zeta_point(expname, datenum_start, datenum_end, lats, lons);
interval = 24*diff(timenum_ROMS(1:2));

for li = 1:length(lon_ROMS)
    vari_tmp = vari_ROMS(li,:);
    lat = lat_ROMS(li);

    [tidestruc, pout] = t_tide(vari_tmp, ...
        'interval', interval, ...
        'latitude', lat, ...
        'start', timenum_ROMS(1), ...
        'secular', 'mean', ...
        'rayleigh', 1, ...
        'shallow', 'M10', ...
        'error', 'wboot', ...
        'synthesis', 1);
    for ci = 1:length(constituents)
        cons = constituents{ci};
        index = find(ismember(tidestruc.name, {cons})==1);
        amp_ROMS(li,ci) = tidestruc.tidecon(index,1);
        pha_ROMS(li,ci) = tidestruc.tidecon(index,3);
    end
end

pha_ROMS_radian = pha_ROMS*(pi/180);
camp_ROMS = amp_ROMS.*exp(sqrt(-1)*pha_ROMS_radian);

rmse_ROMS = sqrt(1/2).*abs(camp_ROMS-camp_obs);

save(['rmse_tide_station_', datestr(datenum_start, 'yyyymmdd'), '_', datestr(datenum_end, 'yyyymmdd'), '.mat'], ...
    'constituents', 'ids', 'stations', 'timenum_obs', 'lats', 'lons', 'vari_obs', ...
    'timenum_ROMS', 'lat_ROMS', 'lon_ROMS', 'vari_ROMS', 'rmse_ROMS')
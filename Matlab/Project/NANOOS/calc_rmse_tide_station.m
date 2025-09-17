%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate tide RMSE using complex amplitude of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy = 2025;
ystr = num2str(yyyy);

datenum_start = datenum(yyyy,1,1);
datenum_end = datenum(yyyy,6,30);

constituents = {'M2', 'S2', 'K1', 'O1', 'MSF'};

load_NOAA_station_info

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
    vari_obs = table2array(obs(:,5));

    interval = 24*diff(timenum_obs(1:2));

    [tidestruc, pout] = t_tide(vari_obs, ...
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

% NANOOS
[timenum_NANOOS, lon_NANOOS, lat_NANOOS, vari_NANOOS] = load_models_zeta_point('NANOOS', datenum_start, datenum_end, lats, lons);
interval = 24*diff(timenum_NANOOS(1:2));

for li = 1:length(lon_NANOOS)
    vari_tmp = vari_NANOOS(li,:);
    lat = lat_NANOOS(li);

    [tidestruc, pout] = t_tide(vari_tmp, ...
        'interval', interval, ...
        'latitude', lat, ...
        'start', timenum_NANOOS(1), ...
        'secular', 'mean', ...
        'rayleigh', 1, ...
        'shallow', 'M10', ...
        'error', 'wboot', ...
        'synthesis', 1);
    for ci = 1:length(constituents)
        cons = constituents{ci};
        index = find(ismember(tidestruc.name, {cons})==1);
        amp_NANOOS(li,ci) = tidestruc.tidecon(index,1);
        pha_NANOOS(li,ci) = tidestruc.tidecon(index,3);
    end
end

pha_NANOOS_radian = pha_NANOOS*(pi/180);
camp_NANOOS = amp_NANOOS.*exp(sqrt(-1)*pha_NANOOS_radian);

rmse_NANOOS = sqrt(1/2).*abs(camp_NANOOS-camp_obs);

% WCOFS
[timenum_WCOFS, lon_WCOFS, lat_WCOFS, vari_WCOFS] = load_models_zeta_point('WCOFS', datenum_start, datenum_end, lats, lons);
interval = 24*diff(timenum_WCOFS(1:2));

for li = 1:length(lon_WCOFS)
    vari_tmp = vari_WCOFS(li,:);
    lat = lat_WCOFS(li);

    [tidestruc, pout] = t_tide(vari_tmp, ...
        'interval', interval, ...
        'latitude', lat, ...
        'start', timenum_WCOFS(1), ...
        'secular', 'mean', ...
        'rayleigh', 1, ...
        'shallow', 'M10', ...
        'error', 'wboot', ...
        'synthesis', 1);
    for ci = 1:length(constituents)
        cons = constituents{ci};
        index = find(ismember(tidestruc.name, {cons})==1);
        amp_WCOFS(li,ci) = tidestruc.tidecon(index,1);
        pha_WCOFS(li,ci) = tidestruc.tidecon(index,3);
    end
end

pha_WCOFS_radian = pha_WCOFS*(pi/180);
camp_WCOFS = amp_WCOFS.*exp(sqrt(-1)*pha_WCOFS_radian);

rmse_WCOFS = sqrt(1/2).*abs(camp_WCOFS-camp_obs);

save(['rmse_tide_station_', datestr(datenum_start, 'yyyymmdd'), '_', datestr(datenum_end, 'yyyymmdd'), '.mat'], ...
    'constituents', 'ids', 'stations', 'lats', 'lons', ...
    'timenum_NANOOS', 'vari_NANOOS', 'rmse_NANOOS', ...
    'timenum_WCOFS', 'vari_WCOFS', 'rmse_WCOFS')
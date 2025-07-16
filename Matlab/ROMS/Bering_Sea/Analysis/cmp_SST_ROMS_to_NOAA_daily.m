%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SST to NOAA station temperature daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4_phi3m1';
filename_header = 'Dsm4_phi3m1_avg';

yyyymmdd_all = [datenum(2018,7,1):datenum(2019,11,30)];

station_name = 'Village Cove, St Paul Island, AK';
station_ID = 9464212;
obs_lat = 57 + 7.5/60;
obs_lon = -[170 + 17.1/60];

% Model
model_filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp,'/daily/'];
g = grd('BSf');
startdate = datenum(2018,7,1);

obs_SST_all = [];
model_SST_all = [];
for di = 1:length(yyyymmdd_all)

    yyyymmdd = yyyymmdd_all(di);
    yyyymmdd_str = datestr(yyyymmdd, 'yyyymmdd');
    ystr = datestr(yyyymmdd, 'yyyy');
    mstr = datestr(yyyymmdd, 'mm');

    % Observation
    obs_filepath = ['/data/jungjih/Observations/NOAA_stations/'];
    obs_filename = ['CO-OPS_', num2str(station_ID), '_met_po_', ystr, '.csv'];
    obs_file = [obs_filepath, obs_filename];

    obs = readtable(obs_file);
    obs_yyyymmdd = table2array(obs(:,1));
    obs_HHMM = table2array(obs(:,2));
    obs_SST = table2array(obs(:,3));

    obs_yyyymmddHHMM = [cell2mat(obs_yyyymmdd) cell2mat(obs_HHMM)];
    obs_timenum = datenum(obs_yyyymmddHHMM, 'yyyy/mm/ddHH:MM');
    obs_timevec = datevec(obs_timenum);

    index = find(floor(obs_timenum) == yyyymmdd);
    obs_SST_all(di) = mean(obs_SST(index));

    % Model
    filenumber = yyyymmdd - startdate + 1;
    fstr = num2str(filenumber, '%04i');
    model_filename = [filename_header, '_', fstr, '.nc'];
    model_file = [model_filepath, model_filename];

    if exist(model_file)
        model_SST = ncread(model_file, 'temp', [1 1 g.N 1], [Inf Inf 1 Inf])';
        dist = sqrt((g.lon_rho - obs_lon).^2 + abs(g.lat_rho - obs_lat).^2);
        [latind, lonind] = find(dist == min(dist(:)));
        model_lon = g.lon_rho(latind, lonind);
        model_lat = g.lat_rho(latind, lonind);
        model_SST_all(di) = model_SST(latind, lonind);
    else
        model_SST_all(di) = NaN;
    end

    disp(datestr(yyyymmdd, 'mmm dd, yyyy'))
end

% Plot
f1 = figure;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(1,2);

nexttile(1)
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');
title(station_name, 'FontSize', 15)

plotm(obs_lat, obs_lon, '.k', 'MarkerSize', 25);
plotm(model_lat, model_lon, 'xr', 'MarkerSize', 15, 'LineWidth', 2);

nexttile(2); hold on; grid on;
title('Daily SST', 'FontSize', 15)

pobs = plot(yyyymmdd_all, obs_SST_all, 'LineWidth', 2);
pmodel = plot(yyyymmdd_all, model_SST_all, 'LineWidth', 2);

xlim([yyyymmdd_all(1)-1 yyyymmdd_all(end)+1])
ylim([-2 12])

set(gca, 'FontSize', 15)

xticks([datenum(2018, 1:12, 1) datenum(2019, 1:12, 1)])
datetick('x', 'mmm, yyyy', 'keepticks')

ylabel('^oC')

l = legend([pobs, pmodel], 'NOAA station', 'ROMS');
l.Location = 'NorthWest';
l.FontSize = 20;

t.TileSpacing = 'compact';
t.Padding = 'compact';

print(['cmp_SST_w_NOAA_', ystr], '-dpng')

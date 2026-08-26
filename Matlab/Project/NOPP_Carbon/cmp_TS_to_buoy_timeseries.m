%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare TS between buoy and model results
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

domain = 'Oregon_1km_large';

% expnames = {'LiveOcean', 'LiveOcean_nudg', 'LiveOcean_nudg_net_swrad', 'LiveOcean_nudg_visc8', 'LiveOcean_nudg_ERA5', 'WCOFS', 'WCOFS_nudg'};
% colors = {'0.4667 0.6745 0.1882', 'g', 'b', 'm', 'k', '0.4941 0.1843 0.5569', '0.0588 1.0000 1.0000'};

expnames = {'LiveOcean', 'WCOFS', 'LiveOcean_rad_out'};
colors = {'g', 'b', 'k'};

cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/', domain, '/Results/General'])

vari_str = 'SSS';

yyyy = 2024;
ystr = num2str(yyyy);

switch vari_str
    case 'SST'
        num_station = 17;
        unit = '^oC';
        ylimit = [6 20];
        legend_location = 'northwest';
    case 'SSS'
        num_station = 3;
        unit = 'psu';
        ylimit = [25 34];
        legend_location = 'southeast';
end
FS = 12;

filepath_obs = '/data/jungjih/Project/NANOOS/Intercomparison/';
filename_obs = [vari_str, '_buoy_daily.mat'];
file_obs = [filepath_obs, filename_obs];
data = load(file_obs);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,4);
t.Padding = 'compact';
t.TileSpacing = 'tight';

for si = 1:num_station
    oindex = si;

    timenum_obs = data.timenum;
    timevec_obs = datevec(timenum_obs);
    station_obs = data.stations{oindex};
    lat_obs = data.lats;
    lon_obs = data.lons;
    vari_obs_tmp = eval(['data.', vari_str, '_daily']);
    index = find(timevec_obs(:,1) == yyyy);
    timenum_obs = timenum_obs(index);
    vari_obs = vari_obs_tmp(oindex,index);

    station = replace(station_obs, ' ', '_');

    % Observation
    ax1 = nexttile(1); hold on; grid on;
    if si == 1
        plot_map(domain, 'mercator', 'l');
        g = grd(domain);
        [cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');
    end

    pp = plotm(lat_obs, lon_obs, '.k', 'MarkerSize', 20);
    px = plotm(lat_obs(oindex), lon_obs(oindex), 'xr', 'MarkerSize', 10, 'LineWidth', 4);

    title('Buoy locations', 'FontSize', FS);

    ax2 = nexttile(2, [1 3]); hold on; grid on;
    p(1) = plot(timenum_obs, vari_obs, '-r', 'LineWidth', 2);

    for ei = 1:length(expnames)
        expname = expnames{ei};
        model = load(['SST_and_SSS_points_', expname, '.mat']);
        timenum_model = model.timenum;
        stations_model = model.stations;
        mindex = find(strcmp(stations_model, station_obs) == 1);
        vari_model_all = eval(['model.', vari_str, '_all']);
        vari_model = vari_model_all(mindex,:);

        p(ei+1) = plot(timenum_model, vari_model, '-', 'Color', colors{ei});
    end
    xticks(datenum(yyyy,1:12,1));
    xlim([datenum(yyyy,1,1)-1 datenum(yyyy,12,31)+1]);
    ylim(ylimit)
    datetick('x', 'mm/dd', 'keepticks', 'keeplimits');
    ylabel(unit);
    set(gca, 'FontSize', 12)

    l = legend(p, ['Obs', replace(expnames, '_', ' ')]);
    l.Location = legend_location;
    l.FontSize = 15;

    title([vari_str, ' in ', ystr], 'FontSize', FS);

    print(['cmp_', vari_str, '_buoy_', station, '_', ystr, '_timeseries'], '-dpng')

    delete(pp);
    delete(px);
    delete(p);
    delete(l);
end
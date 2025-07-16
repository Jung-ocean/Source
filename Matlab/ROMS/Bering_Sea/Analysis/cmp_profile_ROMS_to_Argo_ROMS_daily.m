%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS vertical profile to Argo and ROMS data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

plot_whole_map = 0;

% [30, 36, 46, 47, 54, 58, 59]
% Argo_num_all = [4 5 6 11 29 34 36 37 42 43 45 46 47 54 56 57 58 59 ...
%   64 68 73 84 89 96 102 128 133 ];
Argo_num_all = [34 43 45 46 47 54 56 57 58 59 ...
    73 84 89 96 102 133];

for Ai = 1:length(Argo_num_all)

Argo_num = Argo_num_all(Ai);
ispng = 0;
isgif = 1;

exp = 'Dsm4';

% Model
gc = grd('BSf');
ge = grd('BSf_s7b3');

% Argo
filepath = '/data/sdurski/Observations/ARGO/ARGO_drifters_BS/';
filename = 'Argo_traj_and_prof.mat';
file = [filepath, filename];
load(file)

if plot_whole_map == 1
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('Bering', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

    %caxis([datenum(2019,1,1) datenum(2022,5,1)])
    caxis([datenum(2015,7,1) datenum(2023,1,1)])
    c = colorbar;
    datetick(c, 'y', 'yyyy-mm-dd', 'keeplimits')

    for ai = 1:length(Arg)
        profile = Arg(ai).profile;
        WMO_num = Arg(ai).profile_dir(end-15:end-9);

        lon = [];
        lat = [];
        time = [];
        for pi = 1:length(profile)

            lon = [lon; profile(pi).lon];
            lat = [lat; profile(pi).lat];
            time = [time; profile(pi).time];
        end
        s = scatterm(lat, lon, 20, time, 'filled');

%         title(['Argo ', num2str(ai, '%03i'), ' (', num2str(WMO_num), ')'])
        title(['Argo (', num2str(WMO_num), ')'])

        print(['Argo_map_', num2str(WMO_num)], '-dpng')

%         % Make gif
%         gifname = ['Argo_map_w_date.gif'];
% 
%         frame = getframe(f1);
%         im = frame2im(frame);
%         [imind,cm] = rgb2ind(im,256);
%         if ai == 1
%             imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
%         else
%             imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
%         end

        delete(s);
    end % i
end % plot_whole_map

% Model vs Argo comparison
profile = Arg(Argo_num).profile;
WMO_num = Arg(Argo_num).profile_dir(end-15:end-9);

f1 = figure('visible', 'off'); hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(1,2);

nexttile(1);
plot_map('Bering', 'mercator', 'l')
contourm(gc.lat_rho, gc.lon_rho, gc.h, [50 100 200 1000], 'k');

lon = []; lat = []; time = [];
for pi = 1:length(profile)
    lon = [lon; profile(pi).lon];
    lat = [lat; profile(pi).lat];
    time = [time; profile(pi).time];
end
save(['Argo_num_', num2str(Argo_num, '%03i'), '.mat'], 'lon', 'lat', 'time', 'WMO_num')

timevec = datevec(datenum(datestr(time)));
% tindex = find(timevec(:,1) > 2018 & ismember(timevec(:,2), [1:4]));
tindex = 1:size(timevec,1);
% caxis([floor(min(time(tindex))) floor(max(time(tindex)))])
caxis([datenum(2015,7,1) datenum(2023,1,1)])
c = colorbar;
datetick(c, 'y', 'yyyy-mm-dd', 'keeplimits')

s = scatterm(lat, lon, 20, time, 'filled');

title(['Argo ', num2str(Argo_num, '%03i'), ' (', num2str(WMO_num), ')'])

for ti = 1:length(tindex)
    index = tindex(ti);

    lon_tmp = lon(index);
    lat_tmp = lat(index);
    time_tmp = time(index);
    depth_tmp = -profile(index).pres;

    title(t, datestr(time(index), 'mmm dd, yyyy'), 'FontSize', 20)
    if ti == 1
        p = plotm(lat_tmp, lon_tmp, 'or', 'MArkerSize', 15, 'LineWidth', 4);
    else
        nexttile(t,1)
        delete(p)
        p = plotm(lat_tmp, lon_tmp, 'or', 'MArkerSize', 15, 'LineWidth', 4);
    end

    datenum_target = floor(time_tmp);
    if datenum_target < datenum(2022,1,1) | datenum_target > datenum(2022,6,30)
        continue
    end

    temp_con = load_models_profile_daily('BSf', gc, 'temp', datenum_target, lat_tmp, lon_tmp, depth_tmp);
    salt_con = load_models_profile_daily('BSf', gc, 'salt', datenum_target, lat_tmp, lon_tmp, depth_tmp);
    temp_exp = load_models_profile_daily('BSf_s7b3', ge, 'temp', datenum_target, lat_tmp, lon_tmp, depth_tmp);
    salt_exp = load_models_profile_daily('BSf_s7b3', ge, 'salt', datenum_target, lat_tmp, lon_tmp, depth_tmp);
    
    nexttile(t,2);
    if ti ~= 1 & exist('ax1', 'var') & exist('ax2', 'var')
        cla(ax1); cla(ax2);
    end

    ax1 = nexttile(2); hold on
    plot(ax1, profile(index).salt, depth_tmp, 'r', 'LineWidth', 2);
    plot(ax1, salt_con, depth_tmp, '--r', 'LineWidth', 2);
    plot(ax1, salt_exp, depth_tmp, 'xr', 'LineWidth', 2);
    ax1.XColor = 'r';
    xlim([29 35])
    %ylim([-2500 0])
    ylim([-500 0])
    xlabel('Salinity (psu)')
    ylabel('Pres (~depth, dbar)')

    grid on
    ax1.GridColor = 'k';

    p1 = plot(NaN, NaN, '-k', 'LineWidth', 2);
    p2 = plot(NaN, NaN, '--k', 'LineWidth', 2);
    p3 = plot(NaN, NaN, 'xk', 'LineWidth', 2);
    l = legend([p1, p2, p3], 'Argo', 'ROMS', 'ROMS s7b3');
    l.Location = 'SouthWest';
    l.FontSize = 15;

%     t.TileSpacing = 'compact';
%     t.Padding = 'compact';

    ax2 = axes('Position',ax1.Position,'XAxisLocation','top','YAxisLocation','right','color','none');
    hold on
    plot(ax2,profile(index).temp, depth_tmp, 'b', 'LineWidth', 2);
    plot(ax2, temp_con, depth_tmp, '--b', 'LineWidth', 2);
    plot(ax2, temp_exp, depth_tmp, 'xb', 'LineWidth', 2);
    ax2.XColor = 'b';
    ax2.XAxisLocation = 'top';
    ax2.YTick = [];
    % ax2.YAxisLocation = 'right';
%     ax2.Color = 'none';
    xlim([-2 14])
%     ylim([-2500 0])
    ylim([-500 0])
    xlabel('Temperature (^oC)')

    % Save figure snapshtop
%     print(['Argo_num_', num2str(Argo_num, '%03i'), '_', datestr(time(index), 'yyyymmdd')], '-dpng')
if ispng == 1
    saveas(gcf, ['Argo_num_', num2str(Argo_num, '%03i'), '_', datestr(time(index), 'yyyymmdd'), '.png'])
end

if isgif == 1
    % Make gif
    gifname = ['Argo_num_', num2str(Argo_num, '%03i'), '.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ~exist(gifname) == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end
end

xlabel('')
ax2.XTick = [];
end % ti

clearvars ax1 ax2
close all
end % Ai
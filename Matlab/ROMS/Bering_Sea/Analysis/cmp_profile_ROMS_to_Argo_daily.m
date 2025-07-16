%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS vertical profile to Argo data daily
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
g = grd('BSf_s7b3');
startdate = datenum(2018,7,1);
filepath_model = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_s7b3/daily/'];

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
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

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

    title(t, datestr(time(index), 'mmm dd, yyyy'), 'FontSize', 20)
    if ti == 1
        p = plotm(lat_tmp, lon_tmp, 'or', 'MArkerSize', 15, 'LineWidth', 4);
    else
        nexttile(t,1)
        delete(p)
        p = plotm(lat_tmp, lon_tmp, 'or', 'MArkerSize', 15, 'LineWidth', 4);
    end
    
    filenumber = floor(time_tmp) - startdate + 1;
    fstr = num2str(filenumber, '%04i');
%     filename_model = [exp, '_avg_', fstr,'.nc'];
    filename_model = ['Winter_2021_Dsm4_nKC_avg_', fstr,'.nc'];
    file = [filepath_model, filename_model];
    
    if exist(file) == 0
        zeta = NaN([size(g.lon_rho)]);
        temp = NaN([size(g.lon_rho) g.N]);
        salt = NaN([size(g.lon_rho) g.N]);
    else
        zeta = ncread(file, 'zeta');
        temp = ncread(file, 'temp');
        salt = ncread(file, 'salt');

        if isempty(zeta)
            zeta = NaN([size(g.lon_rho)]);
            temp = NaN([size(g.lon_rho) g.N]);
            salt = NaN([size(g.lon_rho) g.N ]);
        end
    end

    z = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
    dist = sqrt((g.lon_rho - lon_tmp).^2 + abs(g.lat_rho - lat_tmp).^2);
    [lonind, latind] = find(dist == min(dist(:)));

    temp_model = squeeze(temp(lonind, latind, :));
    salt_model = squeeze(salt(lonind, latind, :));
    z_model = squeeze(z(lonind, latind, :));

    nexttile(t,2);
    if ti ~= 1
        cla(ax1); cla(ax2);
    end

    ax1 = nexttile(2); hold on
    plot(ax1, profile(index).salt, -profile(index).pres, 'r', 'LineWidth', 2);
    plot(ax1, salt_model, z_model, '--r', 'LineWidth', 2);
    ax1.XColor = 'r';
    xlim([31 35])
    %ylim([-2500 0])
    ylim([-500 0])
    xlabel('Salinity (psu)')
    ylabel('Pres (~depth, dbar)')

    grid on
    ax1.GridColor = 'k';

    p1 = plot(NaN, NaN, '-k', 'LineWidth', 2);
    p2 = plot(NaN, NaN, '--k', 'LineWidth', 2);
    l = legend([p1, p2], 'Argo', 'ROMS');
    l.Location = 'SouthWest';
    l.FontSize = 25;

%     t.TileSpacing = 'compact';
%     t.Padding = 'compact';

    ax2 = axes('Position',ax1.Position,'XAxisLocation','top','YAxisLocation','right','color','none');
    hold on
    plot(ax2,profile(index).temp, -profile(index).pres, 'b', 'LineWidth', 2);
    plot(ax2, temp_model, z_model, '--b', 'LineWidth', 2);
    ax2.XColor = 'b';
    ax2.XAxisLocation = 'top';
    ax2.YTick = [];
    % ax2.YAxisLocation = 'right';
%     ax2.Color = 'none';
    xlim([0 14])
%     ylim([-2500 0])
    ylim([-500 0])
    if ti == 1
        xlabel('Temperature (^oC)')
    else
        ax2.XTick = [];
    end

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
    if ti == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end
end
end % ti

close all
end % Ai
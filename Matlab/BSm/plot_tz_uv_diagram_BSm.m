%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot time-depth diagram using BSm data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2023;
ystr = num2str(yyyy);
mm_start = 1;
mm_end = 8;
depth_start = 10;

issigma = 0;
ishf = 1;

xlimit = [datenum(yyyy,1,1) datenum(yyyy,8,31)];
ylimit = [-60 0]; % -80

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};

climit = [-20 20];
interval = 4;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color_tmp = redblue;
color = color_tmp( round(linspace(1,length(color_tmp),num_color)) ,:);
unit = 'cm/s';
close all

for si = 3%1:length(stations)
    station = stations{si};
    file = ['uv_1h_', names{si}, '.mat'];
    load(file);
    lat = mean(lat_obs(:), 'omitnan');

    figure;
    set(gcf, 'Position', [1 200 1300 500])
    t = tiledlayout(2,1);
    title(t, [stations{si}, ' station baroclinic (', ystr, ')'])

    tindex = find(timenum_1h > datenum(yyyy,mm_start,1) & timenum_1h < datenum(yyyy,mm_end+1,1));
    timenum = timenum_1h(tindex);
    u_tmp1 = u_obs_1h(:,tindex);
    v_tmp1 = v_obs_1h(:,tindex);

    nanindex = find(sum(isnan(u_tmp1),2) < 0.9.*size(u_tmp1,2));
    depth_tmp = depth_1m(nanindex);
    u_tmp2 = u_tmp1(nanindex,:);
    v_tmp2 = v_tmp1(nanindex,:);

    dindex = find(depth_tmp >= depth_start);
    depth = depth_tmp(dindex);
    u = u_tmp2(dindex,:);
    v = v_tmp2(dindex,:);
    
    for di = 1:length(depth)
        if sum(isnan(u(di,:)),2) > 0
            u_tmp = u(di,:);
            u(di,:) = fillmissing(u_tmp, 'linear', 'EndValues', 'none');
%             figure; hold on; grid on;
%             plot(u(di,:));
%             plot(u_raw);
        end
        if sum(isnan(v(di,:)),2) > 0
            v_tmp = v(di,:);
            v(di,:) = fillmissing(v_tmp, 'linear', 'EndValues', 'none');
%             figure; hold on; grid on;
%             plot(v(di,:));
%             plot(v_raw);
        end
    end

    if ishf == 1
        fs = 1;
        fpass = 1./48; % 48 hr
        for di = 1:size(u,1)
            u_tmp = u(di,:);
            index = find(isnan(u_tmp) == 0);
            u(di,index) = highpass(u_tmp(index), fpass, fs);

            v_tmp = v(di,:);
            v(di,index) = highpass(v_tmp(index), fpass, fs);
        end
        title(t, [stations{si}, ' station baroclinic (', ystr, ', 48 h high-pass filtered)'])
    end

    ubar = mean(u,1);
    vbar = mean(v,1);

    u_baroclinic = u - ubar;
    v_baroclinic = v - vbar;

    nexttile(1); hold on;
    title('Zonal (u)')
    u_baroclinic(u_baroclinic < climit(1)) = climit(1);
    u_baroclinic(u_baroclinic > climit(2)) = climit(2);
    contourf(timenum, -depth, u_baroclinic, contour_interval, 'LineColor', 'none');
    if issigma == 1
        file_sigma = load(['tz_ts_', stations{si}, '_', ystr, '.mat']);
        timenum_sigma = file_sigma.timenum;
        depth_sigma = file_sigma.depth_salt;
        sigma = file_sigma.sigma;
        contour(timenum_sigma, -depth_sigma, sigma, [23:0.5:26.5], 'k');
    end
    xlim(xlimit)
    ylim(ylimit)
    xticks(datenum(yyyy,1:12,1))
    datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
    ylabel('Depth (m)')
    caxis(climit)
    colormap(color)
    c = colorbar;
    c.Ticks = contour_interval;
    c.Title.String = unit;
    set(gca, 'FontSize', 10)
    set(gca,'xticklabel',[])
    
    nexttile(2); hold on;
    title('Meridional (v)')
    v_baroclinic(v_baroclinic < climit(1)) = climit(1);
    v_baroclinic(v_baroclinic > climit(2)) = climit(2);
    contourf(timenum, -depth, v_baroclinic, contour_interval, 'LineColor', 'none');
    if issigma == 1
        timenum_sigma = file_sigma.timenum;
        depth_sigma = file_sigma.depth_salt;
        sigma = file_sigma.sigma;
        contour(timenum_sigma, -depth_sigma, sigma, [23:0.5:26.5], 'k');
    end
    xlim(xlimit)
    ylim(ylimit)
    xticks(datenum(yyyy,1:12,1))
    datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
    ylabel('Depth (m)')
    caxis(climit)
    colormap(color)
    c = colorbar;
    c.Ticks = contour_interval;
    c.Title.String = unit;
    set(gca, 'FontSize', 10)

    t.Padding = 'compact';
    t.TileSpacing = 'compact';

    save(['tz_uv_', stations{si}, '_', ystr], 'lat', 'timenum', 'depth', 'u', 'v', 'ubar', 'vbar', 'u_baroclinic', 'v_baroclinic')
    print(['tz_uv_', stations{si}, '_', ystr], '-dpng')

    % Bottom baroclinic current
    figure; hold on; grid on;
    set(gcf, 'Position', [1 200 1300 500])
    t = tiledlayout(2,1);
    title(t, [stations{si}, ' station baroclinic (', ystr, ', 48 h high-pass filtered)'])
    nexttile(1); hold on; grid on;
    title(['Zonal (u) at ', num2str(depth(end)), ' m depth'])
    plot(timenum, u_baroclinic(end,:), '-k');
    xlim(xlimit)
    ylim([-25 25])
    xticks(datenum(yyyy,1:12,1))
    datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
    ylabel('cm/s')
    set(gca, 'FontSize', 10)
    set(gca,'xticklabel',[])

    nexttile(2); hold on; grid on;
    title(['Meridional (v) at ', num2str(depth(end)), ' m depth'])
    plot(timenum, v_baroclinic(end,:), '-k');
    xlim(xlimit)
    ylim([-25 25])
    xticks(datenum(yyyy,1:12,1))
    datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
    ylabel('cm/s')
    set(gca, 'FontSize', 10)

    t.Padding = 'compact';
    t.TileSpacing = 'compact';

    print(['bc_', stations{si}, '_bottom_', ystr], '-dpng')
end
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
depth_start = 0;

xlimit = [datenum(yyyy,5,1) datenum(yyyy,8,31)];
ylimit = [-60 0]; % -80

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};

for si = 3%1:length(stations)
    station = stations{si};
    file = ['ts_1h_', names{si}, '.mat'];
    load(file);
    lat = mean(lat_obs(:), 'omitnan');
    lon = mean(lon_obs(:), 'omitnan');

    tindex = find(timenum_1h > datenum(yyyy,mm_start,1) & timenum_1h < datenum(yyyy,mm_end+1,1));
    timenum = timenum_1h(tindex);
    temp_tmp1 = temp_obs_1h(:,tindex);
    salt_tmp1 = salt_obs_1h(:,tindex);

    nanindex = find(sum(isnan(temp_tmp1),2) < 0.9.*size(temp_tmp1,2));
    depth_tmp = depth_1m(nanindex);
    temp_tmp2 = temp_tmp1(nanindex,:);
    dindex = find(depth_tmp >= depth_start);
    depth_temp = depth_tmp(dindex);
    temp = temp_tmp2(dindex,:);

    nanindex = find(sum(isnan(salt_tmp1),2) < 0.9.*size(salt_tmp1,2));
    depth_tmp = depth_1m(nanindex);
    salt_tmp2 = salt_tmp1(nanindex,:);
    dindex = find(depth_tmp >= depth_start);
    depth_salt = depth_tmp(dindex);
    salt = salt_tmp2(dindex,:);
    
    for di = 1:length(depth_temp)
        if sum(isnan(temp(di,:)),2) > 0
            temp_tmp = temp(di,:);
            temp(di,:) = fillmissing(temp_tmp, 'linear', 'EndValues', 'none');
        end
    end
    for di = 1:length(depth_salt)
        if sum(isnan(salt(di,:)),2) > 0
            salt_tmp = salt(di,:);
            salt(di,:) = fillmissing(salt_tmp, 'linear', 'EndValues', 'none');
        end
    end
    
    % extrapolation
    index = find(depth_temp > depth_salt(end));
    depth_salt_end = depth_salt(end);
    depth_salt = [depth_salt depth_temp(index)];
    salt_end = salt(end,:);
    for i = 1:length(index)
        salt(end+1,:) = salt_end;
    end

    figure;
    set(gcf, 'Position', [1 200 1300 800])
    t = tiledlayout(4,1);
    title(t, [stations{si}, ' station (', ystr, ')'])

    % Temperature;
    interval = 1;
    climit = [-2 12];
    num_color = diff(climit)/interval;
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    unit = '^oC';

    ax1 = nexttile(1); hold on;
    title('Temperature')
    temp(temp < climit(1)) = climit(1);
    temp(temp > climit(2)) = climit(2);
    contourf(timenum, -depth_temp, temp, contour_interval, 'LineColor', 'none');
    xlim(xlimit)
    ylim(ylimit)
    xticks(datenum(yyyy,1:12,1))
    datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
    ylabel('Depth (m)')
    caxis(climit)
    colormap(ax1, color)
    c = colorbar;
    c.Ticks = contour_interval;
    c.Title.String = unit;
    set(gca, 'FontSize', 10)
    set(gca,'xticklabel',[])

    % Salinity
    interval = 0.4;
    climit = [29 33];
    num_color = diff(climit)/interval;
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    unit = 'psu';

    ax2 = nexttile(2); hold on;
    title('Salinity')
    salt(salt < climit(1)) = climit(1);
    salt(salt > climit(2)) = climit(2);
    contourf(timenum, -depth_salt, salt, contour_interval, 'LineColor', 'none');
    plot(timenum, ones(size(timenum)).*-depth_salt_end, '--k');
    xlim(xlimit)
    ylim(ylimit)
    xticks(datenum(yyyy,1:12,1))
    datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
    ylabel('Depth (m)')
    caxis(climit)
    colormap(ax2, color)
    c = colorbar;
    c.Ticks = contour_interval;
    c.Title.String = unit;
    set(gca, 'FontSize', 10)
    set(gca,'xticklabel',[])

    % Density
    interval = .25;
    climit = [23 26.5];
    num_color = diff(climit)/interval;
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    unit = '\sigma_\theta';

    pres_tmp = sw_pres(depth_salt, lat);
    pres = repmat(pres_tmp', [1,size(salt,2)]);
    temp_interp = [];
    for i = 1:size(temp,2)
        temp_tmp = temp(:,i);
        temp_interp(:,i) = interp1(depth_temp', temp_tmp, depth_salt');
    end
    pden = sw_pden(salt,temp_interp,pres,0);
    sigma = pden - 1000;

    ax3 = nexttile(3); hold on;
    title('Density')
    sigma(sigma < climit(1)) = climit(1);
    sigma(sigma > climit(2)) = climit(2);
    contourf(timenum, -depth_salt, sigma, contour_interval, 'LineColor', 'none');
    xlim(xlimit)
    ylim(ylimit)
    xticks(datenum(yyyy,1:12,1))
    datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
    ylabel('Depth (m)')
    caxis(climit)
    colormap(ax3, color)
    c = colorbar;
    c.Ticks = contour_interval;
    c.Title.String = unit;
    set(gca, 'FontSize', 10)
    set(gca,'xticklabel',[])

    % Density
    interval = .5;
    climit = [23 26.5];
    num_color = diff(climit)/interval;
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    unit = '\sigma_\theta';

    pres_tmp = sw_pres(depth_salt, lat);
    pres = repmat(pres_tmp', [1,size(salt,2)]);
    temp_interp = [];
    for i = 1:size(temp,2)
        temp_tmp = temp(:,i);
        temp_interp(:,i) = interp1(depth_temp', temp_tmp, depth_salt');
    end
    pden = sw_pden(salt,temp_interp,pres,0);
    sigma = pden - 1000;

    % N2
    interval = .5;
    climit = [0 5];
    num_color = diff(climit)/interval;
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    scale = 1e2;
    unit = ['x 10^-^', num2str(log10(scale)), ' s^-^1'];
  
    pden = sw_pden(salt,temp_interp,pres,0);
    [n2,q,p_ave] = sw_bfrq(salt,temp_interp,pres,lat);
    n2(n2<0) = 0;
    n = sqrt(n2).*scale;
    depth_n2 = (depth_salt(2:end) + depth_salt(1:end-1))/2;

    ax4 = nexttile(4); hold on;
    title('Buoyancy frequency (N)')
    n(n < climit(1)) = climit(1);
    n(n > climit(2)) = climit(2);
    contourf(timenum, -depth_n2, n, contour_interval, 'LineColor', 'none');
    xlim(xlimit)
    ylim(ylimit)
    xticks(datenum(yyyy,1:12,1))
    datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
    ylabel('Depth (m)')
    caxis(climit)
    colormap(ax4, color)
    c = colorbar;
    c.Ticks = contour_interval;
    c.Title.String = unit;
    set(gca, 'FontSize', 10)

    t.Padding = 'compact';
    t.TileSpacing = 'compact';

    save(['tz_ts_', stations{si}, '_', ystr, '.mat'], 'timenum', 'depth_temp', 'temp', 'depth_salt', 'salt', 'sigma', 'depth_n2', 'n2', 'scale')
    print(['tz_ts_', stations{si}, '_', ystr], '-dpng')
end
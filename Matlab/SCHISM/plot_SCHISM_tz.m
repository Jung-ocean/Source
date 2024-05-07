clear; clc

temp = load('vari_SCHISM_temp.mat');
depth = temp.depth_SCHISM;
timenum = temp.timenum;
points = temp.points;
temp = temp.vari_SCHISM_w_ini;

salt = load('vari_SCHISM_salt.mat');
salt = salt.vari_SCHISM_w_ini;

titles = {'PD', 'P1', 'P2'};

figure; hold on;
tiledlayout(2,3)

ylimit = [-8000 0];

for pi = 2:size(points,1)

    depth_target = depth(pi,:);
    if pi == 2
        depth_target(2) = -3000;
        depth_target(1) = -3200;
    end

    temp_target = squeeze(temp(pi,:,:));
    salt_target = squeeze(salt(pi,:,:));

    lat = points(pi,2);
    pres = sw_pres(depth_target, lat)';

    clearvars pden
    for ti = 1:size(temp_target,2)
        pden(:,ti) = sw_pden(salt_target(:,ti), temp_target(:,ti), pres, 0);
    end

    nexttile; hold on
    pcolor(timenum, depth_target, temp_target); shading interp
    colormap jet
    [cs, h] = contour(timenum, depth_target, temp_target, 'k');
    clabel(cs,h)

    set(gca, 'Xtick', timenum(1:24:end));
    datetick('x', 'mm/dd HH:MM', 'keepticks')
    ylim(ylimit)
    caxis([0 10])
    ylabel('Depth (m)')
    title([titles{pi}, ', Temperature'])

    nexttile; hold on
    pcolor(timenum, depth_target, salt_target); shading interp
    colormap jet
    [cs, h] = contour(timenum, depth_target, salt_target, 'k');
    clabel(cs,h)

    set(gca, 'Xtick', timenum(1:24:end));
    datetick('x', 'mm/dd HH:MM', 'keepticks')
    ylim(ylimit)
    caxis([31.5 34.5])
    ylabel('Depth (m)')
    title([titles{pi}, ', Salinity'])

    nexttile; hold on
    pcolor(timenum, depth_target, pden); shading interp
    colormap jet
    [cs, h] = contour(timenum, depth_target, pden, 'k');
    clabel(cs,h)

    set(gca, 'Xtick', timenum(1:24:end));
    datetick('x', 'mm/dd HH:MM', 'keepticks')
    ylim(ylimit)
    caxis([1025 1027])
    ylabel('Depth (m)')
    title([titles{pi}, ', Potential density'])
end

set(gcf, 'Position', get(0, 'Screensize'));
pause(3);

print('SCHISM_tz', '-dpng')

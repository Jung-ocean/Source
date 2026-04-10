%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SSS from sat with SLA
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

sat = 'SMOS';

g = grd('BSf');

region = 'NW_Bering';
[lon_lim, lat_lim] = load_domain(region);

vari_str = 'salt';
yyyy = 2022;
ystr = num2str(yyyy);
datenum_start = datenum(yyyy,1,1);
datenum_end = datenum(yyyy,8,31);
dinterval = 4;

climit = [31 33];
interval = 0.1;
[color, contour_interval] = get_color('jet', climit, interval);
unit = 'psu';

switch sat
    case 'SMAP'
        version = 6;
    case 'SMOS'
%         version = 9;
        version = 10;
    case 'CMEMS'
        version = 0;
    case 'SMOS_BEC'
        version = 4;
    case 'SMOS_Arctic'
        version = 2;
    case 'OISSS'
        version = 2;
end

f1 = figure;
set(gcf, 'Position', [1 200 800 500])
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'Color', [.5 .5 .5]);

isfirst = 1;
for ti = datenum_start:dinterval:datenum_end
    timenum = ti;
    title_str = datestr(timenum, 'mmm dd, yyyy');
    title([sat, ' SSS (color) and L4 SLA (5 cm) (', title_str, ')'], 'FontSize', 12)
    
    % SSS
    [lat, lon, SSS] = load_SSS_sat_2d_daily(sat, version, timenum);
    lonind = find(lon > lon_lim(1)-2 & lon < lon_lim(2)+2);
    latind = find(lat > lat_lim(1)-2 & lat < lat_lim(2)+2);
    [lat2, lon2] = meshgrid(lat(latind), lon(lonind));
    SSS = SSS(lonind, latind);
    ps = plot_contourf([], lat2, lon2, SSS, color, climit, contour_interval);

    if isfirst == 1
        c = colorbar;
        c.Title.String = unit;
    end

    % SLA
    [SLA_lat, SLA_lon, SLA] = load_SLA_sat_daily(timenum);
    lonind = find(SLA_lon > lon_lim(1)-2 & SLA_lon < lon_lim(2)+2);
    latind = find(SLA_lat > lat_lim(1)-2 & SLA_lat < lat_lim(2)+2);
    [SLA_lat2, SLA_lon2] = meshgrid(double(SLA_lat(latind)), double(SLA_lon(lonind)));
    SLA = SLA(lonind, latind);

    % Plot SSH
    [pz, ph] = contourm(SLA_lat2, SLA_lon2, SLA, [-3:0.05:3], 'k', 'LineWidth', 1);

    % Make gif
    gifname = [sat, '_SSS_w_SLA_', ystr, '_daily.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if isfirst == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        isfirst = 0;
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    delete(ps)
    delete(ph)
end
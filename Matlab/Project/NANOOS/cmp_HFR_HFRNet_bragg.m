clear; clc

timenum = datenum(2024,5,30);

g = grd('Oregon_1km');

figure; 
set(gcf, 'Position', [1 200 500 800]);
plot_map('Oregon', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
title(datestr(timenum, 'yyyymmdd'), 'FontSize', 15)

% Load HFRNet HFR data
[lon_HFR, lat_HFR, u_HFR, v_HFR] = load_HFR_daily(timenum);
[lat_HFR, lon_HFR] = meshgrid(lat_HFR, lon_HFR);

Fu = scatteredInterpolant(lat_HFR(:), lon_HFR(:), u_HFR(:));
Fv = scatteredInterpolant(lat_HFR(:), lon_HFR(:), v_HFR(:));

interval = 1;
q = plot_vectors('Oregon', lon_HFR, lat_HFR, u_HFR, v_HFR, interval, 'k', 1);

% Load bragg HFR data
[lon_HFR, lat_HFR, u_HFR, v_HFR] = load_HFR_bragg_daily(timenum);

interval = 1;
q = plot_vectors('Oregon', lon_HFR, lat_HFR, u_HFR, v_HFR, interval, 'r', 0);

% Interpolation
u_interp = Fu(lat_HFR, lon_HFR);
v_interp = Fv(lat_HFR, lon_HFR);

interval = 1;
q = plot_vectors('Oregon', lon_HFR, lat_HFR, u_interp, v_interp, interval, 'b', 0);
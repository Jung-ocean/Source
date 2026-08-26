clear; clc; close all

isplot = 1;

datenum_start = datenum(2023,7,1);
dsstr = datestr(datenum_start, 'yyyymmdd');
datenum_end = datenum(2023,7,4);
destr = datestr(datenum_end, 'yyyymmdd');

g = grd('NANOOS');
timenum_ref = datenum(2005,1,1);
lat = g.lat_rho;
lon = g.lon_rho;
H = g.h;
angle = g.angle;
mask = g.mask_rho;
rho0 = 1026;
gconst = 9.8;

% Load model variables
[timenum, zeta, temp, salt, u_bc, v_bc] = load_models_varis_for_IT('NANOOS', g, datenum_start, datenum_end);

% Load background density
avg_pden = load('ROMS_avg_pden.mat');
depth_rhob = avg_pden.depth_extra;
rhob = avg_pden.rhob_extra;

% Baroclinic pressure calculation
p_bc = NaN(size(temp));
dz_4d = NaN(size(temp));
for ti = 1:length(timenum)
    zeta_tmp = zeta(:,:,ti);
    temp_tmp = temp(:,:,:,ti);
    salt_tmp = salt(:,:,:,ti);

    [p_bc_tmp, dz_tmp] = calc_p_bc(g, zeta_tmp, temp_tmp, salt_tmp, rhob, depth_rhob);

    p_bc(:,:,:,ti) = p_bc_tmp;
    dz_4d(:,:,:,ti) = dz_tmp;

    disp(['Baroclinic pressure calculation ', num2str(ti), ' / ', num2str(length(timenum)), ' ...'])
end

% Bandpass filter
dt = 2; % 2 hour
constituent = 'M2';
istest = 0;

u_bc_filtered = tide_bandpass_butter4(u_bc, dt, constituent, istest);
v_bc_filtered = tide_bandpass_butter4(v_bc, dt, constituent, istest);
p_bc_filtered = tide_bandpass_butter4(p_bc, dt, constituent, istest);

% Energy flux
integrand = u_bc_filtered.*p_bc_filtered; % W/m^2
uEF_tmp = squeeze(sum(integrand.*dz_4d,3)); % W/m
uEF_M2 = mean(uEF_tmp,3);

integrand = v_bc_filtered.*p_bc_filtered; % W/m^2
vEF_tmp = squeeze(sum(integrand.*dz_4d,3)); % W/m
vEF_M2 = mean(vEF_tmp,3);

% Save
save(['ROMS_BC_EF_', dsstr, '_', destr, '.mat'], 'timenum', 'lon', 'lat', 'uEF_M2', 'vEF_M2');

% Plot
if isplot == 1
    EF = sqrt(uEF_M2.^2 + vEF_M2.^2);

    unit = 'W/m';
    climit = [0 150];
    interval = [10];
    [color, contour_interval] = get_color('jet', climit, interval);

    f1 = figure; hold on;
    set(gcf, 'Position', [1 200 500 800])
    plot_map('US_west', 'mercator', 'l')
    contourm(lat, lon, g.h, [200 1000], 'k');
    p = plot_contourf([], lat, lon, EF, color, climit, contour_interval);
    c = colorbar;
    c.Title.String = unit;
    c.Ticks = contour_interval;
    title(['ROMS M2 energy flux (', dsstr, ' - ', destr, ')'])

    print(['ROMS_EF_', dsstr, '_', destr], '-dpng')
end
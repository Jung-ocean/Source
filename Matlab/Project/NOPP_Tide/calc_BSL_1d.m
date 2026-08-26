clear; clc; close all

g = grd('BSf');
lat = g.lat_rho;
lon = g.lon_rho;
H = g.h;
H_3d = repmat(H, [1 1 g.N]);
rho0 = 1026;
gconst = 9.8;

datenum_start = datenum(2021,7,1);
datenum_end = datenum(2021,8,31);

lat_target = 51.645;
lon_target = -172.145;

% Similar to World Ocean Atlas standard depth levels (~ 5500 m)
depth_interp = [0:5:100 125:25:500 550:50:2000 2100:100:7500]';
depth_interp = -flipud(depth_interp);

file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2021/Dsm4_mk2/Output/SumFal_2021_Dsm4_mk2_sta.nc';
lat_all = ncread(file, 'lat_rho');
lon_all = ncread(file, 'lon_rho');
ot = ncread(file, 'ocean_time');
timenum_all = ot/60/60/24 + datenum(1968,5,23);

tindex = find(timenum_all > datenum_start-1 & timenum_all < datenum_end+1);
timenum = timenum_all(tindex);

dist = sqrt( (lat_all-lat_target).^2 + (lon_all-lon_target).^2 );
index = find(dist == min(dist));
lat = lat_all(index);
lon = lon_all(index);

figure; hold on;
set(gcf, 'Position', [1 200 1800 300])
t = tiledlayout(1,3);
nexttile(1);
plot_map('Bering', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k')
plotm(lat_all, lon_all, '.r', 'MarkerSize', 20)
plotm(lat, lon, 'og', 'MarkerSize', 20, 'LineWidth', 2)

H = ncread(file, 'h', [index], [1]);
zeta = ncread(file, 'zeta', [index, tindex(1)], [1, length(tindex)]);
temp = squeeze(ncread(file, 'temp', [1 index, tindex(1)], [Inf, 1, length(tindex)]));
salt = squeeze(ncread(file, 'salt', [1 index, tindex(1)], [Inf, 1, length(tindex)]));
salt(salt < 0) = 0;

z_r = squeeze(zlevs(H,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2))';
p = gsw_p_from_z(-abs(z_r), lat);
p(p < 0 ) = NaN;
[SA, in_ocean] = gsw_SA_from_SP(salt,p,lon,lat);
pt = temp;
CT = gsw_CT_from_pt(SA,pt);
dens = gsw_rho(SA,CT,p);

% Tidally averaged field
zeta_avg = mean(zeta);
dens_avg = mean(dens,2);
z_avg = squeeze(zlevs(H,zeta_avg,g.theta_s,g.theta_b,g.hc,g.N,'r',2));
z_tmp = z_avg;
dens_tmp = dens_avg;
dens_interp = interp1(z_tmp, dens_tmp, depth_interp);
rhob = dens_interp;
rhob_fill = fillmissing(rhob, 'nearest');
depth_extra = [-10000; depth_interp; 5];
rhob_extra = [rhob_fill(1); rhob_fill; rhob_fill(end)];

% Snapshot field
BSL = [];
for ti = 1:length(zeta)
    zeta_tmp = zeta(ti);
    temp_tmp = temp(:,ti);
    salt_tmp = salt(:,ti);

    z_tmp = squeeze(zlevs(H,zeta_tmp,g.theta_s,g.theta_b,g.hc,g.N,'r',2));
    z_w = squeeze(zlevs(H,zeta_tmp,g.theta_s,g.theta_b,g.hc,g.N,'w',2));
    dz = z_w(2:end) - z_w(1:end-1);
    p = gsw_p_from_z(-abs(z_tmp), lat);
    p(p < 0 ) = NaN;
    [SA, in_ocean] = gsw_SA_from_SP(salt_tmp,p,lon,lat);
    pt = temp_tmp;
    CT = gsw_CT_from_pt(SA,pt);
    dens_tmp = gsw_rho(SA,CT,p);

    % Background density interpolation
    rhob_snapshot = interp1(depth_extra, rhob_extra, z_tmp);

    % Calculate BSL
    rho_prime = dens_tmp - rhob_snapshot;
    integrand = rho_prime.*gconst.*(1+z_tmp./H);
    p_prime = -sum(integrand.*dz);
    BSL(ti) = p_prime/(rho0*gconst);
end

figure(1)
nexttile(2, [1 2]); hold on; grid on;
plot(timenum, BSL*100, '-k');
ylim([-10 10])
datetick('x', 'mm/dd HH:MM')
ylabel('BSL (cm)')
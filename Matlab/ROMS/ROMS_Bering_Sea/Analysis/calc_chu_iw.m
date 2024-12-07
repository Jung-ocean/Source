function chuiw = calc_chu_iw(file, g, chuiw_ini)

kappa = 0.4;
a1 = 6;
a2 = 0.01;

zeta = ncread(file, 'zeta')';
ui = ncread(file, 'uice')';
vi = ncread(file, 'vice')';
hi = ncread(file, 'hice')';

skip = 1;
npts = [0 0 0 0];
[uice_rho,vice_rho,lonred,latred,maskred] = uv_vec2rho(ui,vi,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
uice_rho = uice_rho.*maskred;
vice_rho = vice_rho.*maskred;

uwater = ncread(file, 'u_sur_eastward')';
vwater = ncread(file, 'v_sur_northward')';

spd = sqrt( (uwater - uice_rho).^2 + (vwater - vice_rho).^2 );
spd = max(spd, 0.15);

z_r_tmp = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
z_r = squeeze(z_r_tmp(g.N,:,:));
z_w_tmp = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
z_w = squeeze(z_w_tmp(g.N,:,:));

z0 = min( max(a2*hi,0.01), 0.1 );
dztop = abs(z_w - z_r);
zdz0 = dztop./z0;
zdz0(zdz0 < a1) = a1;

utauiw = sqrt(chuiw_ini.*spd);
utauiw = max(utauiw, 0.0001);

chuiw = kappa*utauiw./log(zdz0);

end
clear; clc

file_avg = '/data/jungjih/Models/NANOOS/yearly/NANOOS_yearly_2024.nc';

g = grd('NANOOS');
lat = g.lat_rho;
lon = g.lon_rho;
H = g.h;
H_3d = repmat(H, [1 1 g.N]);

% Similar to World Ocean Atlas standard depth levels (~ 5500 m)
depth_interp = [0:5:100 125:25:500 550:50:2000 2100:100:7500]';
depth_interp = -flipud(depth_interp);

% Tidally averaged field
zeta_avg = ncread(file_avg, 'zeta');
temp_avg = ncread(file_avg, 'temp');
salt_avg = ncread(file_avg, 'salt');
z_avg = zlevs(H,zeta_avg,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
z_w = zlevs(H,zeta_avg,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
dz = z_w(:,:,2:end) - z_w(:,:,1:end-1);

SA = salt_avg;
pt = temp_avg;
CT = gsw_CT_from_pt(SA,pt);
pden_avg = gsw_rho(SA,CT,0);

% Background density
index = find(H_3d < 200); % To use density field deeper than 200 m only
pden_avg_200 = pden_avg;
pden_avg_200(index) = NaN;

z_vec = reshape(z_avg,[],g.N);
pden_vec = reshape(pden_avg,[],g.N);
pden_vec_interp = NaN(size(pden_vec,1), length(depth_interp));
for k = 1:size(pden_vec,1)
    z_vec_tmp = z_vec(k,:)';
    pden_vec_tmp = pden_vec(k,:)';
    if all(isnan(pden_vec_tmp))
        continue
    end
    pden_vec_interp(k,:) = interp1(z_vec_tmp, pden_vec_tmp, depth_interp, 'linear', NaN);
end
pden_interp = reshape(pden_vec_interp, [size(lat) length(depth_interp)]);

% Background density only a function of z
rhob = squeeze(mean(mean(pden_interp, 1, 'omitnan'), 2, 'omitnan'));
rhob_fill = fillmissing(rhob, 'nearest');
depth_extra = [-10000; depth_interp; 5];
rhob_extra = [rhob_fill(1); rhob_fill; rhob_fill(end)];

save('ROMS_avg_pden.mat', 'zeta_avg', 'pden_avg', 'z_avg', 'dz', 'depth_extra', 'rhob_extra');
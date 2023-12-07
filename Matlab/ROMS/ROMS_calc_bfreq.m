function n2 = ROMS_calc_bfreq(filename, casename, index)

g = grd(casename);

nc = netcdf(filename);

temp = nc{'temp'}(:);
salt = nc{'salt'}(:);
zeta = nc{'zeta'}(:);

depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
depth(depth > 1000) = NaN;

pdens = zeros(size(depth));
for si = 1:g.N
    pres(si,:,:) = sw_pres(squeeze(depth(si,:,:)), g.lat_rho);
end

S = squeeze(salt(:,:,index));
T = squeeze(temp(:,:,index));
P = squeeze(pres(:,:,index));

[n2,q,p_ave] = sw_bfrq_ROMS(S,T,P);

end

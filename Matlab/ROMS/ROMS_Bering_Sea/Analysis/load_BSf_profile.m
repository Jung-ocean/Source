function profile = load_BSf_profile(g, timenum, lat_target, lon_target)

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4/'];

dist = sqrt((g.lon_rho - lon_target).^2 + abs(g.lat_rho - lat_target).^2);
[lonind, latind] = find(dist == min(dist(:)));

lat = g.lat_rho(lonind, latind);
lon = g.lon_rho(lonind, latind);
h = g.h(lonind, latind);

profile.timenum = timenum;
profile.lat = lat;
profile.lon = lon;
profile.h = h;
filenum = timenum - datenum(2018,7,1) + 1;
fstr = num2str(filenum, '%04i');
filename = ['Dsm4_avg_', fstr, '.nc'];
file = [filepath, filename];
if filenum == 1826
    file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
end
disp(file)
if exist(file)
    try
        zeta = ncread(file, 'zeta', [lonind latind 1], [1 1 Inf]);
        z = squeeze(zlevs(h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2));
        pres = sw_pres(abs(z), lat);
        temp_sigma = squeeze(ncread(file, 'temp', [lonind latind 1 1], [1 1 Inf Inf]));
        salt_sigma = squeeze(ncread(file, 'salt', [lonind latind 1 1], [1 1 Inf Inf]));
        salt_sigma(salt_sigma < 0) = 0;

        pden = sw_pden_ROMS(salt_sigma, temp_sigma, pres, 0);
        drho = pden(2:end) - pden(1:end-1);
        dz = z(2:end) - z(1:end-1);
        [n2,q,p_ave] = sw_bfrq(salt_sigma,temp_sigma,pres,lat);

        ubar_tmp = ncread(file, 'ubar', [lonind-1 latind 1], [2 1 Inf]);
        ubar = mean(ubar_tmp);
        vbar_tmp = ncread(file, 'vbar', [lonind latind-1 1], [1 2 Inf]);
        vbar = mean(vbar_tmp);
        u_tmp = squeeze(ncread(file, 'u', [lonind-1 latind 1 1], [2 1 Inf Inf]));
        u = mean(u_tmp,1)';
        v_tmp = squeeze(ncread(file, 'v', [lonind latind-1 1 1], [1 2 Inf Inf]));
        v = mean(v_tmp,1)';

        profile.temp = temp_sigma;
        profile.salt = salt_sigma;
        profile.pden = pden;
        profile.N2 = n2;
        profile.depth = z;
        profile.ubar = ubar;
        profile.vbar = vbar;
        profile.u = u;
        profile.v = v;
    catch
        profile.temp = NaN;
        profile.salt = NaN;
        profile.pden = NaN;
        profile.N2 = NaN;
        profile.depth = NaN;
        profile.ubar = NaN;
        profile.vbar = NaN;
        profile.u = NaN;
        profile.v = NaN;
    end
else
    profile.temp = NaN;
    profile.salt = NaN;
    profile.pden = NaN;
    profile.N2 = NaN;
    profile.depth = NaN;
    profile.ubar = NaN;
    profile.vbar = NaN;
    profile.u = NaN;
    profile.v = NaN;
end

end
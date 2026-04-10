function profile = load_models_profile(model, g, timenum, lon_target, lat_target)

switch model
    case 'BSf'
        filenum = timenum - datenum(2018,7,1) + 1;
        file = get_ncfilename('Dsm4_mk2', 'avg', filenum);

    case 'NANOOS'
        filepath = ['/home/server/ftp/dist/tides/ingria/ORWA'];
        filenum = timenum - datenum(2005,1,1) + 1;
        fstr = num2str(filenum, '%04i');
        ddmmmyyyy = datestr(timenum, 'dd-mmm-yyyy');
        filename = ['ocean_his_', fstr,  '_', ddmmmyyyy, '.nc'];
        file = [filepath, filename];
end

dist = sqrt((g.lon_rho - lon_target).^2 + abs(g.lat_rho - lat_target).^2);
[lonind, latind] = find(dist == min(dist(:)));

lat = g.lat_rho(lonind, latind);
lon = g.lon_rho(lonind, latind);
h = g.h(lonind, latind);

profile.timenum = timenum;
profile.lat = lat;
profile.lon = lon;
profile.h = h;

disp(file)
if exist(file)
    try
        zeta = ncread(file, 'zeta', [lonind latind 1], [1 1 Inf]);
        z = squeeze(zlevs(h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2));
        pres = gsw_p_from_z(z,lat);
        pres(pres < 0) = NaN;
        temp_sigma = squeeze(ncread(file, 'temp', [lonind latind 1 1], [1 1 Inf Inf]));
        salt_sigma = squeeze(ncread(file, 'salt', [lonind latind 1 1], [1 1 Inf Inf]));
        salt_sigma(salt_sigma < 0) = 0;
        [SA, in_ocean] = gsw_SA_from_SP(salt_sigma,pres,lon,lat);
        pt0 = temp_sigma;
        CT = gsw_CT_from_pt(SA,pt0);
        pden = gsw_rho(SA,CT,0);
        [n2, p_mid] = gsw_Nsquared(SA,CT,pres,lat);

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
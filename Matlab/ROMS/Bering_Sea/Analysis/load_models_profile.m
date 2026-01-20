function profile = load_models_profile(model, g, timenum, lat_target, lon_target)

switch model
    case 'BSf'
        filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4/'];
        filenum = timenum - datenum(2018,7,1) + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['Dsm4_avg_', fstr, '.nc'];
        file = [filepath, filename];

        if filenum == 0119
            file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/Dsm4_rhZop05/Sum_2018_Dsm4_rhZop05_avg_0119.nc';
        elseif filenum == 1640
            file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2022/Dsm4_nKC/SumFal_2022_Dsm4_nKC_avg_1640.nc';
        elseif filenum == 1826
            file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
        end

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
        temp_sigma = squeeze(ncread(file, 'temp', [lonind latind 1 1], [1 1 Inf Inf]));
        salt_sigma = squeeze(ncread(file, 'salt', [lonind latind 1 1], [1 1 Inf Inf]));
        salt_sigma(salt_sigma < 0) = 0;

        SA = salt_sigma;
        pt = temp_sigma;
        CT = gsw_CT_from_pt(SA,pt);
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
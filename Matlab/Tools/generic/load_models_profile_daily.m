function profile = load_models_profile_daily(model, g, timenum, lon_target, lat_target)

addpath(genpath('/home/server/pi/homes/jungjih/Source/Matlab/Tools/gsw'));

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

    case 'Oregon_1km'
        filepath = ['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Output/daily/'];
        filenum = timenum - datenum(2024,1,1) + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['ocean_avg_', fstr, '.nc'];
        file = [filepath, filename];

    case 'LiveOcean'
        filepath = ['/data/jungjih/Models/LiveOcean/daily/'];
        filenum = timenum - datenum(2024,1,1) + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['ocean_avg_', fstr, '.nc'];
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
            zeta = ncread(file, 'zeta', [lonind latind 1], [1 1 Inf]);
        z = squeeze(zlevs(h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2));
        z_w = squeeze(zlevs(h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w',2));
        dz = z_w(2:end) - z_w(1:end-1);
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

        u_tmp = squeeze(ncread(file, 'u', [lonind-1 latind 1 1], [2 1 Inf Inf]));
        u = mean(u_tmp,1)';
        v_tmp = squeeze(ncread(file, 'v', [lonind latind-1 1 1], [1 2 Inf Inf]));
        v = mean(v_tmp,1)';
        try
            ubar_tmp = ncread(file, 'ubar', [lonind-1 latind 1], [2 1 Inf]);
            vbar_tmp = ncread(file, 'vbar', [lonind latind-1 1], [1 2 Inf]);
            ubar = mean(ubar_tmp);
            vbar = mean(vbar_tmp);
        catch
            ubar = sum(u.*dz)./sum(dz);
            vbar = sum(v.*dz)./sum(dz);
        end
        profile.temp = temp_sigma;
        profile.salt = salt_sigma;
        profile.pden = pden;
        profile.N2 = n2;
        profile.depth = z;
        profile.ubar = ubar;
        profile.vbar = vbar;
        profile.u = u;
        profile.v = v;
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

rmpath(genpath('/home/server/pi/homes/jungjih/Source/Matlab/Tools/gsw'));

end
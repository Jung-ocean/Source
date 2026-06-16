function data = load_models_uv_profile_daily(model, g, timenum_target, lon_target, lat_target, h_target)

yyyymmdd = datestr(timenum_target, 'yyyymmdd');

h = g.h;
lat = g.lat_rho;
lon = g.lon_rho;
F = scatteredInterpolant(lon(:), lat(:), ones(size(lon(:))));
wgs84 = wgs84Ellipsoid("km");

f = figure('Visible', 'off');
[ll, c] = contour(lon, lat, h, [abs(h_target) abs(h_target)]);
close(f)
dist = distance(ll(2,:),ll(1,:),lat_target,lon_target,wgs84);
index = find(dist == min(dist));
lat_target_model = ll(2,index);
lon_target_model = ll(1,index);

lat_u = g.lat_u;
lon_u = g.lon_u;
Fu = scatteredInterpolant(lon_u(:), lat_u(:), ones(size(lon_u(:))));
lat_v = g.lat_v;
lon_v = g.lon_v;
Fv = scatteredInterpolant(lon_v(:), lat_v(:), ones(size(lon_v(:))));

switch model
    case 'Oregon_1km'
        filepath = '/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Output/daily/';
        filenum = timenum_target - datenum(2024,1,1) + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['ocean_avg_', fstr, '.nc'];
        file = [filepath, filename];
    
    case 'NANOOS'
        filepath = '/data/jungjih/Models/NANOOS/daily/';
        filename = ['NANOOS_', yyyymmdd, '.nc'];
        file = [filepath, filename];

    case 'WCOFS'
        yyyymmdd = datestr(timenum_target+1, 'yyyymmdd');
        disp('Adding a day to the WCOFS data...')

        filepath = '/data/jungjih/Models/WCOFS/daily_3D/';
        filename = ['nos.wcofs.avg.nowcast.', yyyymmdd, '.t03z.nc'];
        file = [filepath, filename];
        if ~exist(file)
            filename = ['wcofs.t03z.', yyyymmdd, '.avg.nowcast.nc'];
            file = [filepath, filename];
        end

    case 'BSf'
        filepath = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4/';
        filenum = timenum_target - datenum(2018,7,1) + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['Dsm4_avg_', fstr, '.nc'];
        file = [filepath, filename];

    case 'BSf_s7b3'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_s7b3/daily/';
        filenum = timenum_target - datenum(2018,7,1) + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['Winter_2021_Dsm4_nKC_avg_', fstr, '.nc'];
        file = [filepath, filename];
end

if exist(file)

        u_model = ncread(file, 'u');
        v_model = ncread(file, 'v');

        u_tmp = []; v_tmp = [];
        for ni = 1:g.N
            u_2d = u_model(:,:,ni);
            Fu.Values = u_2d(:);
            u_tmp(ni,:) = Fu(lon_target_model, lat_target_model);

            v_2d = v_model(:,:,ni);
            Fv.Values = v_2d(:);
            v_tmp(ni,:) = Fv(lon_target_model, lat_target_model);
        end
        
        angle_model = ncread(file, 'angle');
        F.Values = angle_model(:);
        angle = F(lon_target_model, lat_target_model);

        cosa = cos(angle);
        sina = sin(angle);
        u = u_tmp.*cosa - v_tmp.*sina;
        v = v_tmp.*cosa + u_tmp.*sina;
        
    zeta_model = ncread(file, 'zeta');
    F.Values = zeta_model(:);
    zeta = F(lon_target_model, lat_target_model);
    z_r = squeeze(zlevs(h_target,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2));
    z_w = squeeze(zlevs(h_target,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w',2));
    dz = z_w(2:end) - z_w(1:end-1);

    data.u = u;
    data.v = v;
    data.lon = lon_target_model;
    data.lat = lat_target_model;
    data.h = h_target;
    data.z_r = z_r;
    data.z_w = z_w;
    data.dz = dz;
    
    disp([model, ' ', yyyymmdd, '...'])
    if min(dist) > 4
        disp('No data: min distance is longer than 4 km')
        data = NaN;
    else
        disp(['Loading ubar and vbar (min distance = ', num2str(min(dist)), ' km)']);
    end

else
    data = NaN;
    disp(['No data: no such file'])
end

end
function vari = load_models_profile_monthly(model, g, vari_str, yyyy, mm, lat_target, lon_target, depth_target)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');

h = g.h;
lat = g.lat_rho;
lon = g.lon_rho;

wgs84 = wgs84Ellipsoid("km");
dist = distance(lat(:),lon(:),lat_target,lon_target,wgs84);
index = find(dist == min(dist));
[lonind,latind] = ind2sub(size(g.lat_rho),index);

switch model
    case 'NANOOS'
        filepath = '/data/jungjih/Models/NANOOS/daily/';
        filename = ['NANOOS_', yyyymmdd, '.nc'];
        file = [filepath, filename];

    case 'WCOFS'
        yyyymmdd = datestr(datenum_target+1, 'yyyymmdd');
        disp('Adding a day to the WCOFS data...')

        filepath = '/data/jungjih/Models/WCOFS/daily_3D/';
        filename = ['nos.wcofs.avg.nowcast.', yyyymmdd, '.t03z.nc'];
        file = [filepath, filename];
        if ~exist(file)
            filename = ['wcofs.t03z.', yyyymmdd, '.avg.nowcast.nc'];
            file = [filepath, filename];
        end

    case 'BSf'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/monthly/';
        filename = ['Dsm4_', ystr, mstr, '.nc'];
        file = [filepath, filename];

    case 'BSf_s7b3'
        filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_s7b3/monthly/';
        filename = ['Dsm4_', ystr, mstr, '.nc'];
        file = [filepath, filename];
end

if exist(file)

    if strcmp(vari_str, 'u')
        vari_tmp1 = squeeze(ncread(file, vari_str, [lonind latind 1 1], [1 1 Inf Inf]));
        vari_tmp2 = squeeze(ncread(file, vari_str, [lonind+1 latind 1 1], [1 1 Inf Inf]));
        vari_tmp = (vari_tmp1 + vari_tmp2)/2;
    elseif strcmp(vari_str, 'v')
        vari_tmp1 = squeeze(ncread(file, vari_str, [lonind latind 1 1], [1 1 Inf Inf]));
        vari_tmp2 = squeeze(ncread(file, vari_str, [lonind latind+1 1 1], [1 1 Inf Inf]));
        vari_tmp = (vari_tmp1 + vari_tmp2)/2;
    elseif strcmp(vari_str, 'pden')
        temp = squeeze(ncread(file, 'temp', [lonind latind 1 1], [1 1 Inf Inf]));
        salt = squeeze(ncread(file, 'salt', [lonind latind 1 1], [1 1 Inf Inf]));

        SA = salt;
        pt = temp;
        CT = gsw_CT_from_pt(SA,pt);
        pden = gsw_rho(SA,CT,0);
        vari_tmp = pden;
    else
        vari_tmp = squeeze(ncread(file, vari_str, [lonind latind 1 1], [1 1 Inf Inf]));
    end

    zeta = ncread(file, 'zeta', [lonind latind 1], [1 1 Inf]);
    depth = squeeze(zlevs(h(lonind, latind),zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2));
    vari = interp1(depth,vari_tmp,depth_target);
    if min(depth) > depth_target
        disp(['Maximum depth (', num2str(min(depth)), ' m) is shallower than the target depth (', num2str(depth_target), ' m). Bottom value is loaded'])
        vari = vari_tmp(1);
    end

    disp([model, ' ', ystr, mstr, '...'])
    if min(dist) > 2
        disp('No data: min distance is longer than 2 km')
        vari = vari.*NaN;
    end

else
    vari = NaN(size(depth_target));
    disp(['No data: no such file'])
end

end
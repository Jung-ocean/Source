function profile = load_HYCOM_profile(lon_target, lat_target, timenum)

timevec = datevec(timenum);
yyyy = timevec(:,1);
ystr = num2str(yyyy);
mm = timevec(:,2);
mstr = num2str(mm, '%02i');
dd = timevec(:,3);
dstr = num2str(dd, '%02i');
yyyymmdd = datestr(timenum, 'yyyymmdd');

filepath = ['/data/sdurski/HYCOM_extract/Bering_Sea/', ystr, 'Y/'];
filename = ['HYCOM_glbyBeringSea_', yyyymmdd, '.nc'];
file = [filepath, filename];

if exist(file)
    lon_tmp = ncread(file, 'Longitude');
    lat_tmp = ncread(file, 'Latitude');
    depth = -ncread(file, 'depths');

    londist = abs(lon_tmp(:,1) - lon_target);
    lonind = find(londist == min(londist));
    if length(lonind) > 1
        lonind = lonind(1);
    end
    latdist = abs(lat_tmp(1,:) - lat_target);
    latind = find(latdist == min(latdist));
    if length(latind) > 1
        latind = latind(1);
    end

    lon = lon_tmp(lonind, latind);
    lat = lat_tmp(lonind, latind);

    temp_tmp = squeeze(ncread(file, 'Temp', [lonind, latind, 1, 1], [1, 1, Inf, Inf]));
    temp = mean(temp_tmp,2);
    salt_tmp = squeeze(ncread(file, 'Salt', [lonind, latind, 1, 1], [1, 1, Inf, Inf]));
    salt = mean(salt_tmp,2);

    p = gsw_p_from_z(depth,lat);
    p(p < 0 ) = NaN;
    [SA, in_ocean] = gsw_SA_from_SP(salt,p,lon,lat);
    % Potential temperature
    pt0 = gsw_pt0_from_t(SA,temp,p);
    % Potential density
    % CT = gsw_CT_from_t(SA,temp,p);
    CT = gsw_CT_from_pt(SA,pt0);
    pden = gsw_rho(SA,CT,0);

    profile.lon = lon;
    profile.lat = lat;
    profile.depth = depth;
    profile.temp = temp;
    profile.pt0 = pt0;
    profile.salt = salt;
    profile.SA = SA;
    profile.pden = pden;

    disp(['Loading HYCOM profile on ', yyyymmdd, ' from ', file])

else
    profile = NaN;
    disp(['No such file on ', yyyymmdd])
end

end
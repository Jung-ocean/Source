clear; clc

domain = 'Oregon_1km_large';
cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/', domain, '/Results/General']);

models = {'LiveOcean', 'WCOFS', 'Oregon_1km_large'};

gm = grd(domain);
lon_rho = gm.lon_rho;
lat_rho = gm.lat_rho;
Fm = scatteredInterpolant(lat_rho(:), lon_rho(:), 0.*lat_rho(:));

gl = grd('LiveOcean');
lon_rho = gl.lon_rho;
lat_rho = gl.lat_rho;
Fl = scatteredInterpolant(lat_rho(:), lon_rho(:), 0.*lat_rho(:));

gw = grd('WCOFS');
lon_rho = gw.lon_rho;
lat_rho = gw.lat_rho;
Fw = scatteredInterpolant(lat_rho(:), lon_rho(:), 0.*lat_rho(:));

load_NDBC_info
lat_obs = lats;
lon_obs = lons;

timenum = datenum(2024,1,1):datenum(2024,12,31);

for ei = 1:length(models)
    model = models{ei};

    switch model
        case 'Oregon_1km_large'
            F = Fm;
        case 'LiveOcean'
            F = Fl;
        case 'WCOFS'
            F = Fw;
    end

    SST_all = [];
    SSS_all = [];
    for ti = timenum
        timenum_tmp = ti;
        timevec = datevec(timenum_tmp);
        yyyy = timevec(:,1);
        mm = timevec(:,2);
        dd = timevec(:,3);
        SST = load_models_surf_daily(model, 'temp', yyyy, mm, dd);
        F.Values = SST(:);
        SST_interp = F(lat_obs, lon_obs);
        SST_all = [SST_all SST_interp];

        SSS = load_models_surf_daily(model, 'salt', yyyy, mm, dd);
        F.Values = SSS(:);
        SSS_interp = F(lat_obs, lon_obs);
        SSS_all = [SSS_all SSS_interp];
    end
    save(['SST_and_SSS_points_', model], 'timenum', 'stations', 'lat_obs', 'lon_obs', 'SST_all', 'SSS_all');

end

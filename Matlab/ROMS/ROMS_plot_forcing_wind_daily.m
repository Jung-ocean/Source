%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS wind forcing
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; %close all

source = 'ERA5';

filepath = '.\';
ufilename = 'Uwind_EYECS_ERA5_2020.nc';
vfilename = 'Vwind_EYECS_ERA5_2020.nc';

domain_case = 'southern';

g = grd('EYECS');
cosa = cos(g.angle); sina = sin(g.angle);

mask_nan = g.mask_rho./g.mask_rho;

yyyy = 2020; ystr = num2str(yyyy);
refday = datenum(yyyy,1,1,0,0,0);

for di = 7:8
    
    datenum_start = datenum(yyyy,6,di,0,0,0); dss = datestr(datenum_start, 'yyyymmdd');
    datenum_end = datenum(yyyy,6,di,18,0,0); des = datestr(datenum_end, 'yyyymmdd');
    
    ot_start = datenum_start - refday;
    ot_end = datenum_end - refday;
    
    ufile = [filepath, ufilename];
    vfile = [filepath, vfilename];
    
    unc = netcdf(ufile);
    ot = unc{'Uwind_time'}(:);
    
    vnc = netcdf(vfile);
    
    index_start = find(ot == ot_start);
    index_end = find(ot == ot_end);
    
    u = unc{'Uwind'}(index_start:index_end, :, :);
    v = vnc{'Vwind'}(index_start:index_end, :, :);
    
    u_mean_raw = squeeze(mean(u));
    v_mean_raw = squeeze(mean(v));
    
    u_mean = squeeze(u_mean_raw.*cosa - v_mean_raw.*sina);
    v_mean = squeeze(v_mean_raw.*cosa + u_mean_raw.*sina);
    
    figure;
    map_J(domain_case);
    puv = puv_J(['ECMWF_', domain_case]);
    
    % Target figure
    w_target = (u_mean+sqrt(-1).*v_mean);
    h_target = m_psliceuv(g.lon_rho, g.lat_rho, w_target, puv.interval, puv.scale_factor, puv.color);
    
    % Scale
    h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
    
    % Text
    m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text, 'fontweight', 'bold', 'color', puv.scale_text_color)
    
    % Observation
    load(['G:\내 드라이브\Research\Counter_current\Observation\Tidal_station_wind\2020_GM_wind.mat']);
    
    time1 = timenum_unique - datenum(2020,1,1)+1;
    index = find(time1 == ot_start + 1);
    
    uwind = uwind_daily(index);
    vwind = vwind_daily(index);
    w = (uwind+sqrt(-1).*vwind);
    h1 = m_psliceuv(127.308889,34.028333, w, puv.interval, puv.scale_factor, 'b');
    
    stations = {'거문도', '거제도', '통영'};
    for si = 1:length(stations)
        station = stations{si};
        load(['G:\내 드라이브\Research\Counter_current\Observation\Buoy_KMA\observation\Buoy_KMA_', station, '.mat']);
        
        index = ot_start + 1;
        
        uwind = uwind_daily(index);
        vwind = vwind_daily(index);
        w = (uwind+sqrt(-1).*vwind);
        h1 = m_psliceuv(lon,lat, w, puv.interval, puv.scale_factor, 'b');
    end
    
    title(['Wind ', dss], 'fontsize', 20)
    saveas(gcf, [source, '_wind_', dss, '.png'])
    
    close(unc)
    close(vnc)
    
end
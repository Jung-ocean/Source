clear; clc; close all

year = 2016; ystr = num2str(year);
month = 6:8;
path_all = ['G:\OneDrive - SNU\Model\ROMS\Case\Lab\Lab_wind\', ystr, '\'];

g = grd('Lab');
mask_rho = g.mask_rho;
ind_nan = find(mask_rho == 0);

refday = datenum(2011,1,1,0,0,0);

puv.scale_factor = 3;
puv.interval = 15;
puv.scale_Loc = [127.4, 36.5];
puv.scale_text_Loc = [127.4, 36.3];
puv.color = [0.3020    0.7490    0.9294];

u_monthly = zeros([length(month), size(mask_rho)]);
v_monthly = zeros([length(month), size(mask_rho)]);
for mi = 1:length(month)
    target_month = month(mi);
    mstr = num2char(target_month,2);
    endday = eomday(year, target_month);
    u_daily = zeros; v_daily = zeros;
    for di = 1:endday
        filepath = [ystr, mstr, num2char(di,2), '00\']
        
        ufilename = 'UM_yw3km_Uwind.nc';
        ufile = [path_all, filepath, ufilename];
        unc = netcdf(ufile);
        u = unc{'Uwind'}(:);
        ot = unc{'ocean_time'}(:);
        lon = unc{'lon_rho'}(:);
        lat = unc{'lat_rho'}(:);
        close(unc)
        utime = datestr(ot + refday, 'yyyymmdd');
        ind = find(str2num(utime) == str2num(filepath(1:end-3)));
        u_daily = u_daily + mean(u(ind,:,:),1);
        if sum(sum(isnan(u_daily)) ~= 0)
            di
            pause
        end
        
        vfilename = 'UM_yw3km_Vwind.nc';
        vfile = [path_all, filepath, vfilename];
        vnc = netcdf(vfile);
        v = vnc{'Vwind'}(:);
        ot = vnc{'ocean_time'}(:);
        close(vnc)
        vtime = datestr(ot + refday, 'yyyymmdd');
        ind = find(str2num(vtime) == str2num(filepath(1:end-3)));
        v_daily = v_daily + mean(v(ind,:,:),1);
        if sum(sum(isnan(v_daily)) ~= 0)
            di
            pause
        end
    end
    u_monthly(mi, :, :) = u_daily./endday;
    v_monthly(mi, :, :) = v_daily./endday;
    clear u_daily v_daily
end

for mi = 1:length(month)
    target_month = month(mi);
    mstr = num2char(target_month,2);
    
    cosa = cos(g.angle);
    sina = sin(g.angle);
    
    u_target = squeeze(u_monthly(mi,:,:)).*cosa - squeeze(v_monthly(mi,:,:)).*sina;
    v_target = squeeze(v_monthly(mi,:,:)).*cosa + squeeze(u_monthly(mi,:,:)).*sina;
            
    figure;
    map_J('YECS_flt_small')
    
    % Target figure
    w_target = squeeze(u_target+sqrt(-1).*v_target);
    w_target(ind_nan) = NaN;
    h_target = m_psliceuv(lon, lat, w_target, puv.interval, puv.scale_factor, puv.color);
    
    % Scale
    h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), 2.0, 1, puv.scale_factor, 'r');
    
    % Text
    m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), '2m/s', 'fontweight', 'bold')
    
    title(['Monthly wind ', ystr, mstr], 'fontsize', 20)
    
    saveas(gcf, ['wind_', ystr, mstr, '.png'])
end
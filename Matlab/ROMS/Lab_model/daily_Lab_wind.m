clear; clc; close all

year = 2020; ystr = num2str(year);

day_start = datenum(year, 09, 21);
day_end =  datenum(year, 09, 21);

path_all = ['G:\내 드라이브\Model\ROMS\Case\Lab\Lab_wind\', ystr, '\'];

g = grd('Lab');
mask_rho = g.mask_rho;
ind_nan = find(mask_rho == 0);

refday = datenum(2011,1,1,0,0,0);

puv.scale_factor = 1.5;
puv.interval = 8;
puv.scale_Loc = [127.4, 36.5];
puv.scale_text_Loc = [127.4, 36.3];
puv.color = [0.3020    0.7490    0.9294];

for di = day_start:day_end
    
    mmdd_file = datestr(di-1,'mmdd');
    yyyymmdd_file = [ystr, mmdd_file];
    
    mmdd = datestr(di,'mmdd');
    yyyymmdd = [ystr, mmdd];
    
    filepath = [yyyymmdd_file, '00\'];
    
    ufilename = 'UM_yw3km_Uwind.nc';
    ufile = [path_all, filepath, ufilename];
    unc = netcdf(ufile);
    u = unc{'Uwind'}(:);
    ot = unc{'ocean_time'}(:);
    close(unc)
    utime = datestr(ot + refday + 9/24, 'yyyymmdd');
    ind = find(str2num(utime) == str2num(yyyymmdd));
    u_daily = squeeze(mean(u(ind,:,:),1));
    %         if sum(sum(isnan(u_daily)) ~= 0)
    %             di
    %             pause
    %         end
    
    vfilename = 'UM_yw3km_Vwind.nc';
    vfile = [path_all, filepath, vfilename];
    vnc = netcdf(vfile);
    v = vnc{'Vwind'}(:);
    ot = vnc{'ocean_time'}(:);
    close(vnc)
    vtime = datestr(ot + refday + 9/24, 'yyyymmdd');
    ind = find(str2num(vtime) == str2num(yyyymmdd));
    v_daily = squeeze(mean(v(ind,:,:),1));
    %         if sum(sum(isnan(v_daily)) ~= 0)
    %             di
    %             pause
    %         end
    
    cosa = cos(g.angle);
    sina = sin(g.angle);
    
    u_target = u_daily.*cosa - v_daily.*sina;
    v_target = v_daily.*cosa + u_daily.*sina;
    
    figure;
    map_J('yeonpyeong')
    
    % Target figure
    w_target = squeeze(u_target+sqrt(-1).*v_target);
    %w_target(ind_nan) = NaN;
    h_target = m_psliceuv(g.lon_rho, g.lat_rho, w_target, puv.interval, puv.scale_factor, puv.color);
    
    % Scale
    h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), 2.0, 1, puv.scale_factor, 'r');
    
    % Text
    m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), '2m/s', 'fontweight', 'bold')
    
    title([yyyymmdd, ' 일평균'], 'fontsize', 20)
    
    saveas(gcf, ['wind_', yyyymmdd, '.png'])
    
end
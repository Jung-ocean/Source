%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate ice momentum balance using quicksave file
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

lon_target = -177.5;
lat_target = 62.5;

yyyy = 2021;
mm_start = 5;
mm_end = 5;
startdate = datenum(2018,7,1);

if yyyy < 2021
    exp = 'Dsm4_phiZo';
else
    exp = 'Dsm4_nKC';
end
ystr = num2str(yyyy);
ystr_qck = num2str(yyyy-1);
filepath = ['/data/sdurski/ROMS_BSf/Output/Ice/Winter_', ystr_qck, '/', exp, '/'];
filenum_start = 4*(datenum(yyyy,mm_start,1,0,0,0) - startdate - 0.25);
filenum_end = 4*(datenum(yyyy,mm_end,eomday(yyyy,mm_end),18,0,0) - startdate - 0.25);

ERA5_filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/';

g = grd('BSf');
dx = 1./g.pm;
dx_u = rho2u_2d(dx);
dx_v = rho2v_2d(dx);
dy = 1./g.pn;
dy_u = rho2u_2d(dy);
dy_v = rho2v_2d(dy);
gconst = 9.8; % m/s^2
rhoice = 900; % kg/m^3
rho0 = 1025; % kg/m^3

lat1d = g.lat_rho(:,1);
dis = abs(lat1d - lat_target);
latind = find(dis == min(dis));
lon1d = g.lon_rho(1,:);
dis = abs(lon1d - lon_target);
lonind = find(dis == min(dis));

lon_u = g.lon_u(latind,lonind);
lat_u = g.lat_u(latind,lonind);
lon_v = g.lon_v(latind,lonind);
lat_v = g.lat_v(latind,lonind);

%%% Initial chuiw
filenum_his = (datenum(yyyy,mm_start,1,0,0,0) - startdate); 
fstr_his = num2str(filenum_his, '%04i');
filename_his = ['Winter_', ystr_qck, '_Dsm4_nKC_his_', fstr_his, '.nc'];
file_his = [filepath, filename_his];
chuiw_ini = ncread(file_his, 'chu_iw')'; % yesterday 12:00

filenum_tmp = filenum_start-1; 
fstr_tmp = num2str(filenum_tmp, '%04i');
filename_tmp = ['Winter_', ystr_qck, '_', exp, '_qck_', fstr_tmp, '.nc'];
file_tmp = [filepath, filename_tmp];

chuiw = calc_chu_iw(file_tmp, g, chuiw_ini); % yesterday 18:00
chuiw_ini = chuiw;
%%%

% Initial field
filenum = filenum_start;
fstr = num2str(filenum, '%04i');
filename_ini = ['Winter_', ystr_qck, '_', exp, '_qck_', fstr, '.nc'];
file_ini = [filepath, filename_ini];
t_ini = ncread(file_ini, 'ocean_time')';
f = ncread(file_ini, 'f')';
f_u = rho2u_2d(f);
f_v = rho2v_2d(f);
hi_ini = ncread(file_ini, 'hice')';
hi_ini_u = rho2u_2d(hi_ini);
hi_ini_v = rho2v_2d(hi_ini);
u_ini = ncread(file_ini, 'uice')';
v_ini = ncread(file_ini, 'vice')';

hiu_ini = hi_ini_u.*u_ini; % m^2/s
hiv_ini = hi_ini_v.*v_ini; % m^2/s

hiu(1) = hiu_ini(latind, lonind);
hiv(1) = hiv_ini(latind, lonind);

di = 0;
for fi = filenum_start:filenum_end
    di = di+1;
    filenum = fi; fstr = num2str(filenum, '%04i');
    
    % End field
    filename_end = ['Winter_', ystr_qck, '_', exp, '_qck_', num2str(filenum+1, '%04i'), '.nc'];
    file_end = [filepath, filename_end];
    t_end = ncread(file_end, 'ocean_time')';
    hi_end = ncread(file_end, 'hice')';
    hi_end_u = rho2u_2d(hi_end);
    hi_end_v = rho2v_2d(hi_end);
    u_end = ncread(file_end, 'uice')';
    v_end = ncread(file_end, 'vice')';

    hiu_end = hi_end_u.*u_end; % m^2/s
    hiv_end = hi_end_v.*v_end; % m^2/s

    hdudt_tmp = hi_end_u.*(u_end-u_ini)/(t_end-t_ini);
    u_accel1(di) = hdudt_tmp(latind, lonind);
    u_ini = u_end;

    hdvdt_tmp = hi_end_v.*(v_end-v_ini)/(t_end-t_ini);
    v_accel1(di) = hdvdt_tmp(latind, lonind);
    v_ini = v_end;

    dhiudt_tmp = (hiu_end - hiu_ini)/(t_end-t_ini);
    u_accel(di) = dhiudt_tmp(latind, lonind);
    hiu(di+1) = hiu_end(latind, lonind);
    hiu_ini = hiu_end;

    dhivdt_tmp = (hiv_end - hiv_ini)/(t_end-t_ini);
    v_accel(di) = dhivdt_tmp(latind, lonind);
    hiv(di+1) = hiv_end(latind, lonind);
    hiv_ini = hiv_end;

    t_ini = t_end;

    % Quicksave field
    filename_qck = ['Winter_', ystr_qck, '_', exp, '_qck_', fstr, '.nc'];
    file_qck = [filepath, filename_qck];
    ot = ncread(file_qck, 'ocean_time');
    timenum(di) = ot/60/60/24 + datenum(1968,5,23);
    SST = ncread(file_qck, 'temp_sur')';
    SST_u = interp2(g.lon_rho, g.lat_rho, SST, lon_u, lat_u);
    SST_v = interp2(g.lon_rho, g.lat_rho, SST, lon_v, lat_v);
    ui = ncread(file_qck, 'uice')';
    ui_v(di) = interp2(g.lon_u, g.lat_u, ui, lon_v, lat_v);
    ui_rho = u2rho_2d(ui);
    uwater = ncread(file_qck, 'u_sur_eastward')';
    vi = ncread(file_qck, 'vice')';
    vi_u(di) = interp2(g.lon_v, g.lat_v, vi, lon_u, lat_u);
    vi_rho = v2rho_2d(vi);
    vwater = ncread(file_qck, 'v_sur_northward')';
    hi = ncread(file_qck, 'hice')';
    hi_u = rho2u_2d(hi);
    hi_v = rho2v_2d(hi);
    zeta = ncread(file_qck, 'zeta')';
    aice = ncread(file_qck, 'aice')';
    aice_u = interp2(g.lon_rho, g.lat_rho, aice, lon_u, lat_u);
    aice_v = interp2(g.lon_rho, g.lat_rho, aice, lon_v, lat_v);
    chuiw = calc_chu_iw(file_qck, g, chuiw_ini);
    chuiw_ini = chuiw;
    
    % ERA5 field
    timevec = datevec(timenum(di)); 
    mstr = datestr(timenum(di), 'mm');

    ERA5_filename = ['BSf_ERA5_', ystr, '_', mstr, '_ni2_a_frc.nc'];
    ERA5_file = [ERA5_filepath, '/', ERA5_filename];

    ERA5_lon = double(ncread(ERA5_file, 'lon'))';
    ERA5_lat = double(ncread(ERA5_file, 'lat'))';
    ERA5_time = double(ncread(ERA5_file, 'sfrc_time')) + datenum(1968,5,23);
    Uwind = ncread(ERA5_file, 'Uwind');
    Vwind = ncread(ERA5_file, 'Vwind');
    Pair = ncread(ERA5_file, 'Pair');
    Tair = ncread(ERA5_file, 'Tair');
    Qair = ncread(ERA5_file, 'Qair')*100;
    swrad = ncread(ERA5_file, 'swrad');
    lwrad = ncread(ERA5_file, 'lwrad_down');

    tindex = find(ERA5_time == timenum(di));

    ERA5_uwind = squeeze(Uwind(:,:,tindex))';
    ERA5_vwind = squeeze(Vwind(:,:,tindex))';
    ERA5_pair = squeeze(Pair(:,:,tindex))';
    ERA5_tair = squeeze(Tair(:,:,tindex))';
    ERA5_qair = squeeze(Qair(:,:,tindex))';
    ERA5_swrad = squeeze(swrad(:,:,tindex))';
    ERA5_lwrad = squeeze(lwrad(:,:,tindex))';

    Uwind_u = interp2(ERA5_lon, ERA5_lat, ERA5_uwind, lon_u, lat_u);
    Vwind_u = interp2(ERA5_lon, ERA5_lat, ERA5_vwind, lon_u, lat_u);
    Wspeed_u = sqrt(Uwind_u.*Uwind_u + Vwind_u.*Vwind_u);
    Pair_u = interp2(ERA5_lon, ERA5_lat, ERA5_pair, lon_u, lat_u);
    Tair_u = interp2(ERA5_lon, ERA5_lat, ERA5_tair, lon_u, lat_u);
    Qair_u = interp2(ERA5_lon, ERA5_lat, ERA5_qair, lon_u, lat_u);
    swrad_u = interp2(ERA5_lon, ERA5_lat, ERA5_swrad, lon_u, lat_u);
    lwrad_u = interp2(ERA5_lon, ERA5_lat, ERA5_lwrad, lon_u, lat_u);
    
    Uwind_v = interp2(ERA5_lon, ERA5_lat, ERA5_uwind, lon_v, lat_v);
    Vwind_v = interp2(ERA5_lon, ERA5_lat, ERA5_vwind, lon_v, lat_v);
    Wspeed_v = sqrt(Uwind_v.*Uwind_v + Vwind_v.*Vwind_v);
    Pair_v = interp2(ERA5_lon, ERA5_lat, ERA5_pair, lon_v, lat_v);
    Tair_v = interp2(ERA5_lon, ERA5_lat, ERA5_tair, lon_v, lat_v);
    Qair_v = interp2(ERA5_lon, ERA5_lat, ERA5_qair, lon_v, lat_v);
    swrad_v = interp2(ERA5_lon, ERA5_lat, ERA5_swrad, lon_v, lat_v);
    lwrad_v = interp2(ERA5_lon, ERA5_lat, ERA5_lwrad, lon_v, lat_v);

    % u momentum
    % Advection
    hiui = hi.*ui_rho;
    dhiui_x = hiui(:,2:end) - hiui(:,1:end-1);
    adv1_tmp = ui.*(dhiui_x./dx_u);
    adv1 = interp2(g.lon_u, g.lat_u, adv1_tmp, lon_u, lat_u);

    dhiui_y = hiui(2:end,:) - hiui(1:end-1,:);
    adv2_tmp = vi.*(dhiui_y./dy_v);
    adv2 = interp2(g.lon_v, g.lat_v, adv2_tmp, lon_u, lat_u);

    u_adv(di) = -(adv1 + adv2);

    % Coriolis
    hifv = hi_v.*f_v.*vi; % m^2/s^2
    
    u_cor(di) = interp2(g.lon_v, g.lat_v, hifv, lon_u, lat_u);

    % Sea level gradient
    dzeta_x = zeta(:,2:end) - zeta(:,1:end-1);
    grd_tmp = -hi_u.*gconst.*(dzeta_x./dx_u); % m^2/s^2
    
    u_grd(di) = grd_tmp(latind, lonind);

    % Ice-ocean stress
    tau_wx_tmp = rho0.*aice.*chuiw.*(ui_rho - uwater); % N/m^2
    tau_wx = interp2(g.lon_rho, g.lat_rho, tau_wx_tmp, lon_u, lat_u);
   
    u_ostr(di) = -(1/rhoice)*tau_wx; % m^2/s^2
%     u_ostr(di) = -tau_wx; 

    % Atm-ice stress
    A=coare30vn_ref(Uwind_u,Vwind_u,10,Tair_u,2,Qair_u,2,Pair_u,SST_u,swrad_u,lwrad_u,lat_u,600,10,10,10);
    rhoair = A(end);
    cd_ai = 0.003*( 1-cos(pi*min(hi+0.05,1)) );
    cd_ai_u = interp2(g.lon_rho, g.lat_rho, cd_ai, lon_u, lat_u);
    tau_ax = rhoair.*cd_ai_u.*Uwind_u.*Wspeed_u; % N/m^2
    
    u_astr(di) = (aice_u/rhoice)*tau_ax; % m^2/s^2

    % v momentum
    % Advection
    hivi = hi.*vi_rho;
    dhivi_x = hivi(:,2:end) - hivi(:,1:end-1);
    adv1_tmp = ui.*(dhivi_x./dx_u);
    adv1 = interp2(g.lon_u, g.lat_u, adv1_tmp, lon_v, lat_v);

    dhivi_y = hivi(2:end,:) - hivi(1:end-1,:);
    adv2_tmp = vi.*(dhivi_y./dy_v);
    adv2 = interp2(g.lon_v, g.lat_v, adv2_tmp, lon_v, lat_v);

    v_adv(di) = -(adv1 + adv2);

    % Coriolis
    hif = hi.*f;
    hifu = hi_u.*f_u.*ui; % m^2/s^2
    
    v_cor(di) = -interp2(g.lon_u, g.lat_u, hifu, lon_v, lat_v);

    % Sea level gradient
    dzeta_y = zeta(2:end,:) - zeta(1:end-1,:);
    grd_tmp = -hi_v.*gconst.*(dzeta_y./dy_v); % m^2/s^2
    
    v_grd(di) = grd_tmp(latind, lonind);

    % Ice-ocean stress
    tau_wy_tmp = aice.*chuiw.*(vi_rho - vwater); % m^2/s^2
    tau_wy = interp2(g.lon_rho, g.lat_rho, tau_wy_tmp, lon_v, lat_v);
   
%     v_ostr(di) = (1/rhoice)*tau_wy; % m^2/s^2
    v_ostr(di) = -tau_wy; 

    % Atm-ice stress
    A=coare30vn_ref(Vwind_v,Uwind_u,10,Tair_v,2,Qair_v,2,Pair_v,SST_v,swrad_v,lwrad_v,lat_v,600,10,10,10);
    rhoair = A(end);
    cd_ai = 0.003*(1-cos(pi*min(hi+0.05,1)));
    cd_ai_v = interp2(g.lon_rho, g.lat_rho, cd_ai, lon_v, lat_v);
    tau_ay = rhoair.*cd_ai_v.*Vwind_v.*Wspeed_v; % N/m^2
    
    v_astr(di) = (aice_v/rhoice)*tau_ay; % m^2/s^2

    disp(datestr(timenum(di), 'yyyymmdd HH:MM ...'))
end

figure; hold on; grid on;
direction = 'v';
varis = {'accel', 'adv', 'cor', 'grd', 'ostr', 'astr'};
sum = zeros;
for vi = 1:length(varis)
    vari = eval([direction, '_', varis{vi}]);
    if vi == 1
    plot(timenum, vari, '-k', 'LineWidth', 2)
    else
    plot(timenum, vari)
    sum = sum+vari;
    end
end
plot(timenum, sum, '-r')
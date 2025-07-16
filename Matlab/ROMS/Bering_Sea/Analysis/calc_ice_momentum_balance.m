%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate ice momentum balance
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; %close all

exp='Dsm4';

yyyy = 2021;

% 2021
% lon_target = -176;
% lat_target = 62.6;
lon_target = -177.5;
lat_target = 64;
% 2022
% lon_target = -176;
% lat_target = 63.5;

ystr = num2str(yyyy);
mm_start = 5;
mm_end = 5;
startdate = datenum(2018,7,1);

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];
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

filenum_start = datenum(yyyy, mm_start, 1) - startdate + 1;
filenum_end = datenum(yyyy, mm_end, eomday(yyyy,mm_end)) - startdate + 1;

filename_ini = [exp, '_his_', num2str(filenum_start, '%04i'), '.nc'];
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

hiu_his(1) = hiu_ini(latind, lonind);
hiv_his(1) = hiv_ini(latind, lonind);

di = 0;
for fi = filenum_start:filenum_end
    di = di+1;
    filenum = fi; fstr = num2str(filenum, '%04i');

    % History field
    filename_his = [exp, '_his_', num2str(filenum+1, '%04i'), '.nc'];
    file_his = [filepath, filename_his];
    t_end = ncread(file_his, 'ocean_time')';
    hi_end = ncread(file_his, 'hice')';
    hi_end_u = rho2u_2d(hi_end);
    hi_end_v = rho2v_2d(hi_end);
    u_end = ncread(file_his, 'uice')';
    v_end = ncread(file_his, 'vice')';

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
    hiu_his(di+1) = hiu_end(latind, lonind);
    hiu_ini = hiu_end;

    dhivdt_tmp = (hiv_end - hiv_ini)/(t_end-t_ini);
    v_accel(di) = dhivdt_tmp(latind, lonind);
    hiv_his(di+1) = hiv_end(latind, lonind);
    hiv_ini = hiv_end;

    t_ini = t_end;

    % Average field
    filename_avg = [exp, '_avg_', fstr, '.nc'];
    file_avg = [filepath, filename_avg];
    ot = ncread(file_avg, 'ocean_time');
    timenum(di) = ot/60/60/24 + datenum(1968,5,23);
    SST = ncread(file_avg, 'temp', [1 1 g.N 1], [Inf Inf 1 Inf])';
    SST_u = interp2(g.lon_rho, g.lat_rho, SST, lon_u, lat_u);
    SST_v = interp2(g.lon_rho, g.lat_rho, SST, lon_v, lat_v);
    ui = ncread(file_avg, 'uice')';
    ui_v(di) = interp2(g.lon_u, g.lat_u, ui, lon_v, lat_v);
    ui_rp = u2rho_2d(ui);
    uwater = ncread(file_avg, 'u', [1 1 g.N 1], [Inf Inf 1 Inf])';
    vi = ncread(file_avg, 'vice')';
    vi_u(di) = interp2(g.lon_v, g.lat_v, vi, lon_u, lat_u);
    vi_rp = v2rho_2d(vi);
    vwater = ncread(file_avg, 'v', [1 1 g.N 1], [Inf Inf 1 Inf])';
    hi = ncread(file_avg, 'hice')';
    hi_up = rho2u_2d(hi);
    hi_vp = rho2v_2d(hi);
    hi_u(di) = interp2(g.lon_rho, g.lat_rho, hi, lon_u, lat_u);
    hi_v(di) = interp2(g.lon_rho, g.lat_rho, hi, lon_v, lat_v);
    hif = hi.*f;
    hif_u(di) = interp2(g.lon_rho, g.lat_rho, hif, lon_u, lat_u);
    hif_v(di) = interp2(g.lon_rho, g.lat_rho, hif, lon_v, lat_v);
    sustr = ncread(file_avg, 'sustr')';
    sustr_u = interp2(g.lon_u, g.lat_u, sustr, lon_u, lat_u);
    svstr = ncread(file_avg, 'svstr')';
    svstr_v = interp2(g.lon_v, g.lat_v, svstr, lon_v, lat_v);
    zeta = ncread(file_avg, 'zeta')';
    aice = ncread(file_avg, 'aice')';
    aice_u = interp2(g.lon_rho, g.lat_rho, aice, lon_u, lat_u);
    aice_v = interp2(g.lon_rho, g.lat_rho, aice, lon_v, lat_v);
    chu_iw = ncread(file_avg, 'chu_iw')'; % m/s
    chu_iw_u = interp2(g.lon_rho, g.lat_rho, chu_iw, lon_u, lat_u);
    chu_iw_v = interp2(g.lon_rho, g.lat_rho, chu_iw, lon_v, lat_v);
    sig11 = ncread(file_avg, 'sig11')'; % N/m
    sig12 = ncread(file_avg, 'sig12')'; % N/m
    sig22 = ncread(file_avg, 'sig22')'; % N/m

    % ERA5 field
    timevec = datevec(timenum(di) - 0.5); % -0.5 because ROMS output time is centered on 00H
    mstr = datestr(timenum(di) - 0.5, 'mm');

    ERA5_filename = ['BSf_ERA5_', ystr, '_', mstr, '_ni2_a_frc.nc'];
    ERA5_file = [ERA5_filepath, '/', ERA5_filename];

    ERA5_lon = double(ncread(ERA5_file, 'lon'))';
    ERA5_lat = double(ncread(ERA5_file, 'lat'))';
    ERA5_time = double(ncread(ERA5_file, 'sfrc_time'));
    Uwind = ncread(ERA5_file, 'Uwind');
    Vwind = ncread(ERA5_file, 'Vwind');
    Pair = ncread(ERA5_file, 'Pair');
    Tair = ncread(ERA5_file, 'Tair');
    Qair = ncread(ERA5_file, 'Qair')*100;
    swrad = ncread(ERA5_file, 'swrad');
    lwrad = ncread(ERA5_file, 'lwrad_down');

    ERA5_timenum = ERA5_time + datenum(1968,5,23);
    ERA5_timevec = datevec(ERA5_timenum);
    tindex = find(ERA5_timenum >= timenum(di) -0.5 & ERA5_timenum < timenum(di) +0.5);
    ERA5_uwind_daily = mean(Uwind(:,:,tindex),3)';
    ERA5_vwind_daily = mean(Vwind(:,:,tindex),3)';
    ERA5_pair_daily = mean(Pair(:,:,tindex),3)';
    ERA5_tair_daily = mean(Tair(:,:,tindex),3)';
    ERA5_qair_daily = mean(Qair(:,:,tindex),3)';
    ERA5_swrad_daily = mean(swrad(:,:,tindex),3)';
    ERA5_lwrad_daily = mean(lwrad(:,:,tindex),3)';

    Uwind_u = interp2(ERA5_lon, ERA5_lat, ERA5_uwind_daily, lon_u, lat_u);
    Vwind_u = interp2(ERA5_lon, ERA5_lat, ERA5_vwind_daily, lon_u, lat_u);
    Wspeed_u = sqrt(Uwind_u.*Uwind_u + Vwind_u.*Vwind_u);
    Pair_u = interp2(ERA5_lon, ERA5_lat, ERA5_pair_daily, lon_u, lat_u);
    Tair_u = interp2(ERA5_lon, ERA5_lat, ERA5_tair_daily, lon_u, lat_u);
    Qair_u = interp2(ERA5_lon, ERA5_lat, ERA5_qair_daily, lon_u, lat_u);
    swrad_u = interp2(ERA5_lon, ERA5_lat, ERA5_swrad_daily, lon_u, lat_u);
    lwrad_u = interp2(ERA5_lon, ERA5_lat, ERA5_lwrad_daily, lon_u, lat_u);

    Uwind_v = interp2(ERA5_lon, ERA5_lat, ERA5_uwind_daily, lon_v, lat_v);
    Vwind_v = interp2(ERA5_lon, ERA5_lat, ERA5_vwind_daily, lon_v, lat_v);
    Wspeed_v = sqrt(Uwind_v.*Uwind_v + Vwind_v.*Vwind_v);
    Pair_v = interp2(ERA5_lon, ERA5_lat, ERA5_pair_daily, lon_v, lat_v);
    Tair_v = interp2(ERA5_lon, ERA5_lat, ERA5_tair_daily, lon_v, lat_v);
    Qair_v = interp2(ERA5_lon, ERA5_lat, ERA5_qair_daily, lon_v, lat_v);
    swrad_v = interp2(ERA5_lon, ERA5_lat, ERA5_swrad_daily, lon_v, lat_v);
    lwrad_v = interp2(ERA5_lon, ERA5_lat, ERA5_lwrad_daily, lon_v, lat_v);

    % u momentum
    % Advection
    hiui = hi.*ui_rp;
    dhiui_x = hiui(:,2:end) - hiui(:,1:end-1);
    adv1_tmp = ui.*(dhiui_x./dx_u);
    adv1 = interp2(g.lon_u, g.lat_u, adv1_tmp, lon_u, lat_u);

    dhiui_y = hiui(2:end,:) - hiui(1:end-1,:);
    adv2_tmp = vi.*(dhiui_y./dy_v);
    adv2 = interp2(g.lon_v, g.lat_v, adv2_tmp, lon_u, lat_u);

    u_adv(di) = -(adv1 + adv2);

    % Coriolis
    hifv = hi_vp.*f_v.*vi; % m^2/s^2

    u_cor(di) = interp2(g.lon_v, g.lat_v, hifv, lon_u, lat_u);

    % Sea level gradient
    dzeta_x = zeta(:,2:end) - zeta(:,1:end-1);
    grd_tmp = -hi_up.*gconst.*(dzeta_x./dx_u); % m^2/s^2

    u_grd(di) = grd_tmp(latind, lonind);

    % Ice-ocean stress
    %     tau_wx = chu_iw_u*rho0*uwater(latind, lonind); % N/m^2
    A=coare30vn_ref(Uwind_u,Vwind_u,10,Tair_u,2,Qair_u,2,Pair_u,SST_u,swrad_u,lwrad_u,lat_u,600,10,10,10);
    sustr_aw = (1-aice_u).*double(A(2));
    %     sustr_aw = (1-aice_u).*rhoair.*cd.*Uwind_u.*Wspeed_u;
    tau_wx = -(sustr_u - sustr_aw); % N/m^2

    u_ostr(di) = (1/rhoice)*tau_wx; % m^2/s^2

    % Atm-ice stress
    rhoair = A(end);
    cd_ai = 0.003*( 1-cos(pi*min(hi+0.05,1)) );
    cd_ai_u = interp2(g.lon_rho, g.lat_rho, cd_ai, lon_u, lat_u);
    tau_ax = rhoair.*cd_ai_u.*Uwind_u.*Wspeed_u; % N/m^2

    u_astr(di) = (aice_u/rhoice)*tau_ax; % m^2/s^2

    % Internal ice stress
    dsig11 = sig11(:,2:end) - sig11(:,1:end-1);
    istress_1 = interp2(g.lon_u, g.lat_u, dsig11./dx_u, lon_u, lat_u); % N/m^2

    dsig12 = sig12(2:end,:) - sig12(1:end-1,:);
    istress_2 = interp2(g.lon_v, g.lat_v, dsig12./dy_v, lon_u, lat_u); % N/m^2

    u_istr(di) = (1/rhoice).*(istress_1 + istress_2);

    % v momentum
    % Advection
    hivi = hi.*vi_rp;
    dhivi_x = hivi(:,2:end) - hivi(:,1:end-1);
    adv1_tmp = ui.*(dhivi_x./dx_u);
    adv1 = interp2(g.lon_u, g.lat_u, adv1_tmp, lon_v, lat_v);

    dhivi_y = hivi(2:end,:) - hivi(1:end-1,:);
    adv2_tmp = vi.*(dhivi_y./dy_v);
    adv2 = interp2(g.lon_v, g.lat_v, adv2_tmp, lon_v, lat_v);

    v_adv(di) = -(adv1 + adv2);

    % Coriolis
    hifu = hi_up.*f_u.*ui; % m^2/s^2

    v_cor(di) = -interp2(g.lon_u, g.lat_u, hifu, lon_v, lat_v);

    % Sea level gradient
    dzeta_y = zeta(2:end,:) - zeta(1:end-1,:);
    grd_tmp = -hi_vp.*gconst.*(dzeta_y./dy_v); % m^2/s^2

    v_grd(di) = grd_tmp(latind, lonind);

    % Ice-ocean stress
    %     tau_wy = chu_iw_v*rho0*vwater(latind, lonind); % N/m^2
    A=coare30vn_ref(Vwind_v,Uwind_u,10,Tair_v,2,Qair_v,2,Pair_v,SST_v,swrad_v,lwrad_v,lat_v,600,10,10,10);
    svstr_aw = (1-aice_v).*double(A(2));
    %     svstr_aw = (1-aice_v).*rhoair.*cd.*Vwind_v.*Wspeed_v;
    tau_wy = -(svstr_v - svstr_aw); % N/m^2

    v_ostr(di) = (1/rhoice)*tau_wy; % m^2/s^2

    % Atm-ice stress
    rhoair = A(end);
    cd_ai = 0.003*(1-cos(pi*min(hi+0.05,1)));
    cd_ai_v = interp2(g.lon_rho, g.lat_rho, cd_ai, lon_v, lat_v);
    tau_ay = rhoair.*cd_ai_v.*Vwind_v.*Wspeed_v; % N/m^2

    v_astr(di) = (aice_v/rhoice)*tau_ay; % m^2/s^2

    % Internal ice stress
    sig21 = sig12;
    dsig21 = sig21(:,2:end) - sig21(:,1:end-1);
    istress_1 = interp2(g.lon_u, g.lat_u, dsig21./dx_u, lon_v, lat_v); % N/m^2

    dsig22 = sig22(2:end,:) - sig22(1:end-1,:);
    istress_2 = interp2(g.lon_v, g.lat_v, dsig22./dy_v, lon_v, lat_v); % N/m^2

    v_istr(di) = (1/rhoice).*(istress_1 + istress_2);

    disp(datestr(timenum(di), 'yyyymmdd HH:MM ...'))
end

lon = lon_target;
lat = lat_target;

save(['ice_momentum_balance_', ystr, '.mat'], ...
    'lon', 'lat', 'timenum', ...
    'ui_v', 'vi_u', 'hi_u', 'hi_v', 'hif_u', 'hif_v', ...
    'u_accel', 'u_adv', 'u_cor', 'u_grd', 'u_ostr', 'u_astr', 'u_istr',  ...
    'v_accel', 'v_adv', 'v_cor', 'v_grd', 'v_ostr', 'v_astr', 'v_istr')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate ice momentum balance using station file
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2022;
ystr = num2str(yyyy);
mm = 5;
dd_start = 1;
dd_end = 5;
startdate = datenum(2018,7,1);

staind = 33;

g = grd('BSf');

if yyyy < 2021

else
    exp = 'Dsm4_nKC';
end

filepath = ['/data/sdurski/ROMS_BSf/Output/Ice/Winter_2021/', exp, '/'];
filename = ['Winter_2021_', exp, '_sta.nc'];
file = [filepath, filename];
ot = ncread(file, 'ocean_time');
timenum = ot/60/60/24 + datenum(1968,5,23);
timevec = datevec(timenum);
lat_tmp = ncread(file, 'lat_rho');
lon_tmp = ncread(file, 'lon_rho');
lat = lat_tmp(staind);
lon = lon_tmp(staind);

f = ncread(g.grd_file, 'f')';
f = interp2(g.lon_rho, g.lat_rho, f, lon, lat);
dx = 1./g.pm;
dx_u = rho2u_2d(dx);
dx_v = rho2v_2d(dx);
dy = 1./g.pn;
dy_u = rho2u_2d(dy);
dy_v = rho2v_2d(dy);
gconst = 9.8; % m/s^2
rhoice = 900; % kg/m^3
rho0 = 1025; % kg/m^3

%%%
hi = double(ncread(file, 'hice', [staind,1], [1,Inf]));
ui = ncread(file, 'uice', [staind,1], [1,Inf]);
vi = ncread(file, 'vice', [staind,1], [1,Inf]);
sustr = ncread(file, 'sustr', [staind,1], [1,Inf]);
svstr = ncread(file, 'svstr', [staind,1], [1,Inf]);
zeta = ncread(file, 'zeta', [staind,1], [1,Inf]);
aice = ncread(file, 'aice', [staind,1], [1,Inf]);
chu_iw = ncread(file, 'chu_iw', [staind,1], [1,Inf]);
sig11 = ncread(file, 'sig11', [staind,1], [1,Inf]);
sig12 = ncread(file, 'sig12', [staind,1], [1,Inf]);
sig22 = ncread(file, 'sig22', [staind,1], [1,Inf]);

SST = squeeze(ncread(file, 'temp', [g.N, staind,1], [1, 1,Inf]));
uwater = squeeze(ncread(file, 'u', [g.N, staind,1], [1, 1,Inf]));
vwater = squeeze(ncread(file, 'v', [g.N, staind,1], [1, 1,Inf]));
%%%

ERA5_filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/';

ind_start = find(timenum == datenum(yyyy,mm,dd_start));
ind_end = find(timenum == datenum(yyyy,mm,dd_end));

t_ini = ot(ind_start);
hi_ini = hi(ind_start);
u_ini = ui(ind_start);
v_ini = vi(ind_start);

hiu_ini = hi_ini.*u_ini; % m^2/s
hiv_ini = hi_ini.*v_ini; % m^2/s

hiu(1) = hiu_ini;
hiv(1) = hiv_ini;

di = 0;
for ti = ind_start:ind_end
    di = di+1;
    
    % History field
    t_end = ot(ti+1);
    hi_end = hi(ti+1);
    u_end = ui(ti+1);
    v_end = vi(ti+1);

    hiu_end = hi_end.*u_end; % m^2/s
    hiv_end = hi_end.*v_end; % m^2/s

    hdudt_tmp = hi_end.*(u_end-u_ini)/(t_end-t_ini);
    u_accel1(di) = hdudt_tmp;
    u_ini = u_end;

    hdvdt_tmp = hi_end.*(v_end-v_ini)/(t_end-t_ini);
    v_accel1(di) = hdvdt_tmp;
    v_ini = v_end;

    dhiudt_tmp = (hiu_end - hiu_ini)/(t_end-t_ini);
    u_accel(di) = dhiudt_tmp;
    hiu_his(di+1) = hiu_end;
    hiu_ini = hiu_end;

    dhivdt_tmp = (hiv_end - hiv_ini)/(t_end-t_ini);
    v_accel(di) = dhivdt_tmp;
    hiv_his(di+1) = hiv_end;
    hiv_ini = hiv_end;

    t_ini = t_end;

    % ERA5 field
    timenum_tmp = timenum(ti);
    yyyy_mm = datestr(timenum_tmp, 'yyyy_mm');

    ERA5_filename = ['BSf_ERA5_', yyyy_mm, '_ni2_a_frc.nc'];
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

    index = find(ERA5_time == timenum_tmp);
    if ~isempty(index)
        ERA5_uwind = Uwind(:,:,index)';
        ERA5_vwind = Vwind(:,:,index)';
        ERA5_pair = Pair(:,:,index)';
        ERA5_tair = Tair(:,:,index)';
        ERA5_qair = Qair(:,:,index)';
        ERA5_swrad = swrad(:,:,index)';
        ERA5_lwrad = lwrad(:,:,index)';

        Uwind = interp2(ERA5_lon, ERA5_lat, ERA5_uwind, lon, lat);
        Vwind = interp2(ERA5_lon, ERA5_lat, ERA5_vwind, lon, lat);
        Wspeed = sqrt(Uwind.*Uwind + Vwind.*Vwind);
        Pair = interp2(ERA5_lon, ERA5_lat, ERA5_pair, lon, lat);
        Tair = interp2(ERA5_lon, ERA5_lat, ERA5_tair, lon, lat);
        Qair = interp2(ERA5_lon, ERA5_lat, ERA5_qair, lon, lat);
        swrad = interp2(ERA5_lon, ERA5_lat, ERA5_swrad, lon, lat);
        lwrad = interp2(ERA5_lon, ERA5_lat, ERA5_lwrad, lon, lat);
    else
        index1 = find(ERA5_time < timenum_tmp);
        index1 = max(index1);
        index2 = find(ERA5_time > timenum_tmp);
        index2 = min(index2);

        varis = {'Uwind', 'Vwind', 'Pair', 'Tair', 'Qair', 'swrad', 'lwrad'};
        for ii = 1:length(varis)
            vari = eval(varis{ii});
            vari1 = interp2(ERA5_lon, ERA5_lat, vari(:,:,index1)', lon, lat);
            vari2 = interp2(ERA5_lon, ERA5_lat, vari(:,:,index2)', lon, lat);
            eval([varis{ii}, '=interp1([ERA5_time(index1) ERA5_time(index2)], [vari1 vari2], timenum_tmp);'])
        end
        Wspeed = sqrt(Uwind.*Uwind + Vwind.*Vwind);
    end
   
    % u momentum
    % Advection
%     hiui = hi.*ui_rho;
%     dhiui_x = hiui(:,2:end) - hiui(:,1:end-1);
%     adv1_tmp = ui.*(dhiui_x./dx_u);
%     adv1 = interp2(g.lon_u, g.lat_u, adv1_tmp, lon_u, lat_u);
% 
%     dhiui_y = hiui(2:end,:) - hiui(1:end-1,:);
%     adv2_tmp = vi.*(dhiui_y./dy_v);
%     adv2 = interp2(g.lon_v, g.lat_v, adv2_tmp, lon_u, lat_u);
% 
%     u_adv(di) = -(adv1 + adv2);

    % Coriolis
    hifv = hi(ti).*f.*vi(ti); % m^2/s^2
    
    u_cor(di) = hifv;

    % Sea level gradient
%     dzeta_x = zeta(:,2:end) - zeta(:,1:end-1);
%     grd_tmp = -hi_u.*gconst.*(dzeta_x./dx_u); % m^2/s^2
%     
%     u_grd(di) = grd_tmp(latind, lonind);

    % Ice-ocean stress
    %     tau_wx = chu_iw_u*rho0*uwater(latind, lonind); % N/m^2
    A=coare30vn_ref(Uwind,Vwind,10,Tair,2,Qair,2,Pair,SST(ti),swrad,lwrad,lat,600,10,10,10);
    sustr_aw = (1-aice(ti)).*double(A(2));
%     sustr_aw = (1-aice_u).*rhoair.*cd.*Uwind_u.*Wspeed_u;
    tau_wx = -(sustr(ti) - sustr_aw); % N/m^2
   
    u_ostr(di) = (1/rhoice)*tau_wx; % m^2/s^2

    % Atm-ice stress
    rhoair = A(end);
    cd_ai = 0.003*( 1-cos(pi*min(hi(ti)+0.05,1)) );
    tau_ax = rhoair.*cd_ai.*Uwind.*Wspeed; % N/m^2
    
    u_astr(di) = (aice(ti)/rhoice)*tau_ax; % m^2/s^2

    % Internal ice stress
%     dsig11 = sig11(:,2:end) - sig11(:,1:end-1);
%     istress_1 = interp2(g.lon_u, g.lat_u, dsig11./dx_u, lon_u, lat_u); % N/m^2
% 
%     dsig12 = sig12(2:end,:) - sig12(1:end-1,:);
%     istress_2 = interp2(g.lon_v, g.lat_v, dsig12./dy_v, lon_u, lat_u); % N/m^2
% 
%     u_istr(di) = (1/rhoice).*(istress_1 + istress_2);

    % v momentum
    % Advection
%     hivi = hi.*vi_rho;
%     dhivi_x = hivi(:,2:end) - hivi(:,1:end-1);
%     adv1_tmp = ui.*(dhivi_x./dx_u);
%     adv1 = interp2(g.lon_u, g.lat_u, adv1_tmp, lon_v, lat_v);
% 
%     dhivi_y = hivi(2:end,:) - hivi(1:end-1,:);
%     adv2_tmp = vi.*(dhivi_y./dy_v);
%     adv2 = interp2(g.lon_v, g.lat_v, adv2_tmp, lon_v, lat_v);
% 
%     v_adv(di) = -(adv1 + adv2);

    % Coriolis
    hifu = hi(ti).*f.*ui(ti); % m^2/s^2
    
    v_cor(di) = -hifu;

    % Sea level gradient
%     dzeta_y = zeta(2:end,:) - zeta(1:end-1,:);
%     grd_tmp = -hi_v.*gconst.*(dzeta_y./dy_v); % m^2/s^2
%     
%     v_grd(di) = grd_tmp(latind, lonind);

    % Ice-ocean stress
    %     tau_wy = chu_iw_v*rho0*vwater(latind, lonind); % N/m^2
    A=coare30vn_ref(Vwind,Uwind,10,Tair,2,Qair,2,Pair,SST(ti),swrad,lwrad,lat,600,10,10,10);
    svstr_aw = (1-aice(ti)).*double(A(2));
    %     svstr_aw = (1-aice_v).*rhoair.*cd.*Vwind_v.*Wspeed_v;
    tau_wy = -(svstr(ti) - svstr_aw); % N/m^2

    v_ostr(di) = (1/rhoice)*tau_wy; % m^2/s^2

    % Atm-ice stress
    rhoair = A(end);
    cd_ai = 0.003*(1-cos(pi*min(hi(ti)+0.05,1)));
    tau_ay = rhoair.*cd_ai.*Vwind.*Wspeed; % N/m^2
    
    v_astr(di) = (aice(ti)/rhoice)*tau_ay; % m^2/s^2

    % Internal ice stress
%     sig21 = sig12;
%     dsig21 = sig21(:,2:end) - sig21(:,1:end-1);
%     istress_1 = interp2(g.lon_u, g.lat_u, dsig11./dx_u, lon_v, lat_v); % N/m^2
% 
%     dsig22 = sig22(2:end,:) - sig22(1:end-1,:);
%     istress_2 = interp2(g.lon_v, g.lat_v, dsig12./dy_v, lon_v, lat_v); % N/m^2
% 
%     v_istr(di) = (1/rhoice).*(istress_1 + istress_2);

    disp(datestr(timenum(ti), 'yyyymmdd HH:MM ...'))
end

ddd
figure; hold on; grid on;
direction = 'u';
varis = {'accel', 'cor', 'ostr', 'astr'};
sum = zeros;
for vi = 1:length(varis)
    vari = eval([direction, '_', varis{vi}]);
    if vi == 1
    plot(timenum(ind_start:ind_end), vari, '-k', 'LineWidth', 2)
    else
    plot(timenum(ind_start:ind_end), vari)
    sum = sum+vari;
    end
end
plot(timenum(ind_start:ind_end), sum, '-r')
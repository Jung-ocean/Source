%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate ice volume balance
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
ExpID='Dsm4';
filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', ExpID, '/'];
aveBoxName='GOA'; % 'ORE4346', 'SCA'
issub = 0;

yyyy_all = 2020:2022;
mm_start = 1;
mm_end = 7;
startdate = datenum(2018,7,1);

g = grd('BSf');

for yi = 1:length(yyyy_all)

yyyy = yyyy_all(yi); ystr = num2str(yyyy);

% fnumSTR=208;
% fnumEND=218;
% 2021
% fnumSTR=1034; fnumEND=1093;
fnumSTR= datenum(yyyy, mm_start, 1) - startdate + 1; 
fnumEND= datenum(yyyy, mm_end+1, 1) - startdate + 1; 

avg_fileHead=[filepath, ExpID, '_avg_'];
his_fileHead=[filepath, ExpID, '_his_'];
% dia_fileHead=[filepath, ExpID, '/Winter_2021_Dsm4_nKC_dia_'];
grdfile='/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_DsmV2_grid.nc';

Cp=3985; % J/kg/K
rho0 = 1025; % kg/m3
rhow = 1000; % kg/m3
rhoice = 900; % km/m^3

% END OF INPUTS ^^^^^^^^

% Read grid file:
lon_rho=ncread(grdfile,'lon_rho');
lat_rho=ncread(grdfile,'lat_rho');
mask_rho=ncread(grdfile,'mask_rho');
pm=ncread(grdfile,'pm');
pn=ncread(grdfile,'pn');
h=ncread(grdfile,'h');
dx=1./pm;
dy=1./pn;
dxdy=dx.*dy;
dy_u = rho2u_2d(dy')';
dx_v = rho2v_2d(dx')';

lon_u=ncread(grdfile,'lon_u');
lat_u=ncread(grdfile,'lat_u');
mask_u=ncread(grdfile,'mask_u');

lon_v=ncread(grdfile,'lon_v');
lat_v=ncread(grdfile,'lat_v');
mask_v=ncread(grdfile,'mask_v');

if issub == 1
    lon_rho = lon_rho(623:1070,606:957);
    lat_rho = lat_rho(623:1070,606:957);
    mask_rho = mask_rho(623:1070,606:957);
    pm = pm(623:1070,606:957);
    pn = pn(623:1070,606:957);
    h = h(623:1070,606:957);
    dx=1./pm;
    dy=1./pn;
    dxdy = dx.*dy;

    mask_u = mask_u(623:1070-1,606:957);
    mask_v = mask_v(623:1070,606:957-1);
end

% Vertical grid parameters:
% fname1=[his_fileHead int2strPAD(fnumSTR,4) '.nc'];
fname1=[his_fileHead num2str(fnumSTR, '%04i') '.nc'];
% N=read_ncdim(fname1,'s_rho');
finfo = ncinfo(fname1, 's_rho');
N = finfo.Size;
Vtransform=ncread(fname1,'Vtransform');
Vstretching=ncread(fname1,'Vstretching');
theta_s=ncread(fname1,'theta_s');     % parameter for stretching near surf
theta_b=ncread(fname1,'theta_b');     % parameter for stretching near bott
Tcline=ncread(fname1,'Tcline');     % thermocline depth

% A domain mask:
grd.lon_rho=lon_rho;
grd.lat_rho=lat_rho;
grd.mask_rho=mask_rho;
grd.h=h;
mask_ave=customMask(aveBoxName,grd);

fnums=fnumSTR:fnumEND;
nf=length(fnums);

[xi_rho,eta_rho]=size(lon_rho);

dTdt=nan*zeros(nf,1);
t_avg=nan*zeros(nf,1);
T_avg=nan*zeros(nf,1);
aice_avg = nan*zeros(nf,1);
thermo = nan*zeros(nf,1);
dyn = nan*zeros(nf,1);

% some inst quantities:
t_his=nan*zeros(nf+1,1);
T_his=nan*zeros(nf+1,1);

for it=0:nf % start from 0 to first compute instantaneus V and ave T at t=0
 
 %%% HIS based values, fnum1
 if it>0
  T0=T1;
  t0=t1;
 end
 
 if it==0
  fnum1=fnums(1); % file number for his file at the end of interval
 else
  fnum0=fnums(it); % file number for his file at the beginning, also avg
  fnum1=fnum0+1;
 end
 %  fname=[his_fileHead int2strPAD(fnum1,4) '.nc'];
 fname=[his_fileHead num2str(fnum1, '%04i') '.nc'];

 disp(' ');
 disp(fname);
 t1=ncread(fname,'ocean_time');
 hice = ncread(fname,'hice'); % m
 T = dxdy.*hice; % m^3; ice volume
  
 % - inst V 
 % - area-ave T based on inst volume
 [T1,A1]=aave(T,dxdy,mask_ave);
 
 if it>0
  dTdt(it)=(T1-T0)/(t1-t0);
 end
 
 t_his(it+1)=t1;
 T_his(it+1)=T1;
   
 %%% AVG & DIA based values:
 if it>0
  % read avg fields:
  %   fname=[avg_fileHead int2strPAD(fnum0,4) '.nc'];
  fname=[avg_fileHead num2str(fnum0, '%04i') '.nc'];
  disp(fname);
  t_avg(it)=ncread(fname,'ocean_time');
  zeta_avg=double(ncread(fname,'zeta'));
  SST = double(ncread(fname,'temp', [1 1 g.N 1], [Inf Inf 1 Inf]));
  SSS = double(ncread(fname,'salt', [1 1 g.N 1], [Inf Inf 1 Inf]));
  SSS(SSS<0) = 0;

  % Hz:
  % vertical coordinates (change with zeta):
  %   z_w=get_z3D_use_zeta(h,zeta_avg,'w',N,Vtransform,Vstretching, ...
  %                        theta_s,theta_b,Tcline);
  %   Hz=z_w(:,:,2:end)-z_w(:,:,1:end-1);
  z_r = zlevs(h,zeta_avg,theta_s,theta_b,Tcline,N,'r',Vtransform);
  z_r_surf = squeeze(z_r(g.N,:,:));
  
  pres_surf = sw_pres(abs(z_r_surf), lat_rho);
  rhoo = sw_pden_ROMS(SSS, SST, pres_surf, 0);

  hice = double(ncread(fname,'hice'));
  T = dxdy.*hice;
  
  aice = double(ncread(fname,'aice'));
  wio = double(ncread(fname,'wio')); % m^3/s
  wai = double(ncread(fname,'wai')); % m^3/s
  wao = double(ncread(fname,'wao')); % m^3/s
  wfr = double(ncread(fname,'wfr')); % m^3/s
  uice = double(ncread(fname,'uice')); % m/s
  vice = double(ncread(fname,'vice')); % m/s
  
  [T_avg(it),A_avg]=aave(T,dxdy,mask_ave);

  [aice_avg(it),A_avg]=aave(aice,dxdy,mask_ave);

%   thermo_tmp = dxdy.*(rhoice./rhoo).*(aice.*(wio-wai) + (1-aice).*wao + wfr);
  thermo_tmp = dxdy.*(rhoo./rhoice).*(aice.*(wio-wai) + (1-aice).*wao + wfr);
  [thermo(it),A_avg]=aave(thermo_tmp,dxdy,mask_ave);

  [xi_rho,eta_rho]=size(mask_ave);

  % Dynamic
%   pdirection = [-1 1];
%   trans = calc_bflux(uice, vice, hice, dx, dy, mask_ave, mask_rho, pdirection);
%   dyn(it) = trans;

  hice(mask_rho==0)=0;
  uice(mask_u==0)=0;
  vice(mask_v==0)=0;

  hice_u = rho2u_2d(hice')';
  hice_v = rho2v_2d(hice')';

  FU = uice.*hice_u.*dy_u; % m^3/s
  FV = vice.*hice_v.*dx_v; % m^3/s
%   FU(mask_u==0)=0;
%   FV(mask_v==0)=0;
  divU=nan*zeros(xi_rho,eta_rho);
  ii=2:xi_rho-1;
  jj=2:eta_rho-1;
  divU(ii,jj)= FU(ii,jj)-FU(ii-1,jj)+FV(ii,jj)-FV(ii,jj-1);
  divU = dxdy.*divU; % volume
  divU(mask_ave==0)=0;
  Bflux=sum(sum(divU)); % volume flux outside the ave area, m3/s

  dyn(it) = -Bflux./A_avg;
 end
end

figure; hold on; grid on;
plot(dTdt, '-k', 'LineWidth', 2);
plot(thermo, '-r');
plot(dyn, '-b');
plot(thermo + dyn, '--m')

save(['ice_volume_Balance_', aveBoxName, '_', ystr, '_new.mat'], ...
    'grd', 'mask_ave', 'dxdy', ...
    't_his', 'T_his', 't_avg', 'T_avg', ...
    'dTdt', 'aice_avg', 'thermo', 'dyn')
end
dd
%res=dTdt-Adv-Qatm-Hdiff;
%res_opt=dTdt-Adv_opt-Qatm-Hdiff;
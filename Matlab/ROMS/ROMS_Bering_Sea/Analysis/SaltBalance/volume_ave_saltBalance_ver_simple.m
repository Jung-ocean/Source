% 10/11/2024 J. Jung
% This is a simplified version of volume_ave_saltBalnace_saveFile.m 
% that calculates every term except for the advection in the dia file
% 
% 3/19/2021: taken from volume_ave_heatBalance_useRomsFluxes.m on the PC. 
% The option used is verified to have balance in the cumulative terms
% (1) tend is computed using instantaneous T and V values. 
% (2) Adv is computed as the volume ave temp adv minus boundary volume flux (Huom, Hvon) times the 
%     volume ave T. 
% (3) Qatm .. as usual. 

clear all;
ExpID='Dsm4';
filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', ExpID, '/'];
aveBoxName='GOA'; % 'ORE4346', 'SCA'
issub = 0;

yyyy_all = 2019:2022;
mm_start = 1;
mm_end = 8;
startdate = datenum(2018,7,1);

g = grd('BSf');
%%% River info from input file
riverfile = '/data/jungjih/ROMS_BSf/River/BS_6rivers_others_2017_2022.nc';
rtime = ncread(riverfile, 'river_time');
rtrans = abs(ncread(riverfile, 'river_transport'));
ypos = ncread(riverfile, 'river_Eposition');
xpos = ncread(riverfile, 'river_Xposition');
rdir = ncread(riverfile, 'river_direction');

for r = 1:length(xpos)
    switch rdir(r)
        case 0
            lon_river(r) = g.lon_u(ypos(r)+1,xpos(r));
            lat_river(r) = g.lat_u(ypos(r)+1,xpos(r));
        case 1
            lon_river(r) = g.lon_v(ypos(r),xpos(r)+1);
            lat_river(r) = g.lat_v(ypos(r),xpos(r)+1);
    end
end
polygon = [;
    -180.9180   62.3790
    -172.9734   64.3531
    -178.7092   66.7637
    -184.1599   64.8934
    -180.9180   62.3790
    ];
[in, on] = inpolygon(lon_river, lat_river, polygon(:,1), polygon(:,2));

rtrans_area = sum(rtrans(in,:),1);
rtime_filenum = (datenum(1968,5,23) + rtime) - startdate + 1;
%%%

for yi = 1:length(yyyy_all)

yyyy = yyyy_all(yi); ystr = num2str(yyyy);

% fnumSTR=208;
% fnumEND=218;
% 2021
% fnumSTR=1034; fnumEND=1093;
fnumSTR= datenum(yyyy, mm_start, 1) - startdate + 1; 
fnumEND= datenum(yyyy, mm_end+1, 1) - startdate + 1; 

% Outputs will be in 2 files, AVG and HIS (since just one file with inf dim):
% fnameOUT_AVG=['./' ExpID '/STATS/volume_ave_heatBalance_avg_' ExpID '_' aveBoxName '.nc'];
% fnameOUT_HIS=['./' ExpID '/STATS/volume_ave_heatBalance_his_' ExpID '_' aveBoxName '.nc'];
fnameOUT_AVG=['./volume_ave_saltBalance_avg_' ExpID '_' aveBoxName '.nc'];
fnameOUT_HIS=['./volume_ave_saltBalance_his_' ExpID '_' aveBoxName '.nc'];

createNewFilesYes=0; 

avg_fileHead=[filepath, ExpID, '_avg_'];
his_fileHead=[filepath, ExpID, '_his_'];
% dia_fileHead=[filepath, ExpID, '/Winter_2021_Dsm4_nKC_dia_'];
grdfile='/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_DsmV2_grid.nc';

Cp=3985; % J/kg/K
rho0=1025; % kg/m3
rhow = 1000; % kg/m3

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
%Adv=nan*zeros(nf,1);
Adv_opt=nan*zeros(nf,1);
Adv_open = nan*zeros(nf,1);
% Qatm=nan*zeros(nf,1);
Ssurf = nan*zeros(nf,1);
Satm = nan*zeros(nf,1);
Hdiff=nan*zeros(nf,1);
Vdiff=nan*zeros(nf,1);
t_avg=nan*zeros(nf,1);
V_avg=nan*zeros(nf,1);
T_avg=nan*zeros(nf,1);
T_surf_avg = nan*zeros(nf,1);
aice_avg = nan*zeros(nf,1);
Uflux_avg = nan*zeros(nf,1);
Uflux_open_avg = nan*zeros(nf,1);
Uflux_river = nan*zeros(nf,1);

% some inst quantities:
t_his=nan*zeros(nf+1,1);
V_his=nan*zeros(nf+1,1);
T_his=nan*zeros(nf+1,1);
T_surf_his = nan*zeros(nf+1,1);

for it=0:nf % start from 0 to first compute instantaneus V and ave T at t=0
 
 %%% HIS based values, fnum1
 if it>0
  T0=T1;
  V0=V1;
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
 zeta=double(ncread(fname,'zeta'));
 %  T=double(ncread(fname,'temp'));
 T=double(ncread(fname,'salt'));
 T_surf = squeeze(T(:,:,N));
 
 % Hz:
 % vertical coordinates (change with zeta):
 %  z_w=get_z3D_use_zeta(h,zeta,'w',N,Vtransform,Vstretching, ...
 %                       theta_s,theta_b,Tcline);
 z_w = zlevs(h,zeta,theta_s,theta_b,Tcline,N,'w',Vtransform);
 z_w = permute(z_w, [2,3,1]);
 Hz=z_w(:,:,2:end)-z_w(:,:,1:end-1);
 
 % - inst V 
 % - volume-ave T based on inst volume
 [T1,V1]=vave(T,Hz,dxdy,mask_ave);
 % - area-ave T based on inst volume
 [T1_surf,A1]=aave(T_surf,dxdy,mask_ave);
 
 if it>0
  dTdt(it)=(T1-T0)/(t1-t0);
 end
 
 t_his(it+1)=t1;
 T_his(it+1)=T1;
 T_surf_his(it+1) = T1_surf;
 V_his(it+1)=V1;
 
 %%% AVG & DIA based values:
 if it>0
  % read avg fields:
  %   fname=[avg_fileHead int2strPAD(fnum0,4) '.nc'];
  fname=[avg_fileHead num2str(fnum0, '%04i') '.nc'];
  disp(fname);
  t_avg(it)=ncread(fname,'ocean_time');
  zeta_avg=double(ncread(fname,'zeta'));
  T=double(ncread(fname,'salt'));
  T_surf = squeeze(T(:,:,N));
%   Fu=squeeze(double(ncread(fname,'Huon'))); % m3/s
%   Fv=squeeze(double(ncread(fname,'Hvom'))); % m3/s
%   if issub == 1
%         Fu = Fu(623:1070-1,606:957,:);
%         Fv = Fv(623:1070,606:957-1,:);
%   end
  %FTu=squeeze(double(ncread(fname,'Huon_temp'))); % m3 C / s
  %FTv=squeeze(double(ncread(fname,'Hvom_temp'))); % m3 c / s
  %   swrad=double(ncread(fname,'swrad'));
  %   lwrad=double(ncread(fname,'lwrad'));
  %   qsen =double(ncread(fname,'sensible'));
  %   qlat =double(ncread(fname,'latent'));
  ssflux = squeeze(double(ncread(fname,'ssflux'))); % (E-P)*SALT m / s
  evaporation = squeeze(double(ncread(fname,'evaporation'))); % kg / m2s
  rain = squeeze(double(ncread(fname,'rain'))); % kg / m2s
  aice = squeeze(double(ncread(fname,'aice')));

  % Hz:
  % vertical coordinates (change with zeta):
  %   z_w=get_z3D_use_zeta(h,zeta_avg,'w',N,Vtransform,Vstretching, ...
  %                        theta_s,theta_b,Tcline);
  %   Hz=z_w(:,:,2:end)-z_w(:,:,1:end-1);
  z_w = zlevs(h,zeta_avg,theta_s,theta_b,Tcline,N,'w',Vtransform);
  z_w = permute(z_w, [2,3,1]);
  Hz=z_w(:,:,2:end)-z_w(:,:,1:end-1);

  % volume and volume-ave salt from the time avg fields:
  [T_avg(it),V_avg(it)]=vave(T,Hz,dxdy,mask_ave);

  % area and area-ave salt from the time avg fields:
  [T_surf_avg(it),A_avg]=aave(T_surf,dxdy,mask_ave);

  % depth-integrated fluxes through the boundary of the domain defined by 
  % mask_ave
%   Uflux=bflux(Fu,Fv,mask_u,mask_v,mask_ave);
%   Uflux_avg(it) = Uflux;

%   Uflux_open=bflux_open(Fu,Fv,mask_u,mask_v,mask_ave);
%   Uflux_open_avg(it) = Uflux_open;
    
  %TUflux=bflux(FTu,FTv,mask_u,mask_v,mask_ave);
  %Adv(it)=-( TUflux - Uflux*T_avg(it))/V_avg(it);
  
  % Atm flux:
  %   q=swrad+lwrad+qsen+qlat;
  %   [Q,A]=aave(q,dxdy,mask_ave); % Area ave q, AA = control area
  %   Qatm(it)=Q*A/(Cp*rho0*V_avg(it));
  ss = ssflux;
  [SS,A]=aave(ss,dxdy,mask_ave); % Area ave ss, AA = control area
  Ssurf(it)=SS*A/V_avg(it);

  emp = evaporation - abs(rain); % negative rain = snow and ice
  Semp = T_surf.*emp;
  [SEMP,A]=aave(Semp,dxdy,mask_ave); % Area ave ss, AA = control area
  Satm(it)=SEMP*A/(rhow*V_avg(it));

  [aice_tmp,A]=aave(aice,dxdy,mask_ave); % Area ave ss, AA = control area
  aice_avg(it)=aice_tmp;

  % HDIFF, Adv_opt
  %   fname=[dia_fileHead int2strPAD(fnum0,4) '.nc'];
%   fname=[dia_fileHead num2str(fnum0, '%04i') '.nc'];
%   disp(fname);
  %   hdiff=squeeze(double(ncread(fname,'temp_hdiff')));
%   hdiff=squeeze(double(ncread(fname,'salt_hdiff')));
%   vdiff=squeeze(double(ncread(fname,'salt_vdiff')));
  %   hadv=squeeze(double(ncread(fname,'temp_hadv')));
%   hadv=squeeze(double(ncread(fname,'salt_hadv')));
  
%   [Hdiff(it),V_avg_tmp]=vave(hdiff,Hz,dxdy,mask_ave);
%   [Vdiff(it),V_avg_tmp]=vave(vdiff,Hz,dxdy,mask_ave);
%   [hadv_ave,V_avg_tmp]=vave(hadv,Hz,dxdy,mask_ave);
%   Adv_opt(it)=-(-hadv_ave*V_avg_tmp-Uflux*T_avg(it))/V_avg_tmp;

%   Adv_open(it)=-(-hadv_ave*V_avg_tmp-Uflux_open*T_avg(it))/V_avg_tmp;
    
    index = find(rtime_filenum == fnum0);
    Uflux_river(it) = rtrans_area(index);
 end
end

save(['saltBalance_', aveBoxName, '_', ystr, '.mat'], 'grd', 'mask_ave', ...
    't_his', 'V_his', 'T_his', 'T_surf_his', ...
    't_avg', 'V_avg', 'T_avg', 'T_surf_avg', ...
    'dTdt', 'Ssurf', 'Satm', ...
    'aice_avg', 'Uflux_river')

end
dd
%res=dTdt-Adv-Qatm-Hdiff;
%res_opt=dTdt-Adv_opt-Qatm-Hdiff;

timeUnits=ncreadatt(fname,'ocean_time','units');

%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUTS:
%%%%%%%%%%%%%%%%%%%%%%%

if createNewFilesYes || ~exist(fnameOUT_AVG) || ~exist(fnameOUT_HIS)

 %%%%%%%%%%%%%%%%%%%%%%%%%%
 % Create the output files:
 %%%%%%%%%%%%%%%%%%%%%%%%%%
 k=0;

 k=k+1;
 vars(k).name='mask_ave';
 vars(k).datatype='int32';
 vars(k).dimensions={'xi_rho',xi_rho,'eta_rho',eta_rho};
 vars(k).attributes{1}={'long_name','mask_ave'}; 

 k=k+1;
 vars(k).name='avg_time';
 vars(k).datatype='double';
 vars(k).dimensions={'avg_time',Inf};
 vars(k).attributes{1}={'long_name','ocean_time for time ave (avg,dia) fields'};
 vars(k).attributes{2}={'units',timeUnits};

 k=k+1;
 vars(k).name='temp_avg';
 vars(k).datatype='single';
 vars(k).dimensions={'avg_time',length(t_avg)};
 vars(k).attributes{1}={'long_name','time averaged, volume averaged temperature'};
 vars(k).attributes{2}={'units','C s-1'};

 k=k+1;
 vars(k).name='dTdt';
 vars(k).datatype='single';
 vars(k).dimensions={'avg_time',length(t_avg)};
 vars(k).attributes{1}={'long_name','tendency term, dT/dt'};
 vars(k).attributes{2}={'units','C s-1'};

 k=k+1;
 vars(k).name='Qadv';
 vars(k).datatype='single';
 vars(k).dimensions={'avg_time',length(t_avg)};
 vars(k).attributes{1}={'long_name','oceanic_temp_flux volume averaged term'};
 vars(k).attributes{2}={'units','C s-1'};

 k=k+1;
 vars(k).name='Qatm';
 vars(k).datatype='single';
 vars(k).dimensions={'avg_time',length(t_avg)};
 vars(k).attributes{1}={'long_name','atm_temp_flux volume averaged term'};
 vars(k).attributes{2}={'units','C s-1'};

 k=k+1;
 vars(k).name='hdiff';
 vars(k).datatype='single';
 vars(k).dimensions={'avg_time',length(t_avg)};
 vars(k).attributes{1}={'long_name','hdiff volume averaged term'};
 vars(k).attributes{2}={'units','C s-1'};

 create_timeSer_file(fnameOUT_AVG,vars);

 % CREATE HIS FILE:
 clear vars;
 k=0;

 k=1;
 vars(k).name='mask_ave';
 vars(k).datatype='int32';
 vars(k).dimensions={'xi_rho',xi_rho,'eta_rho',eta_rho};
 vars(k).attributes{1}={'long_name','mask_ave'};

 k=k+1;
 vars(k).name='his_time';
 vars(k).datatype='double';
 vars(k).dimensions={'his_time',Inf};
 vars(k).attributes{1}={'long_name','ocean_time for instantaneous (his) fields'};
 vars(k).attributes{2}={'units',timeUnits};

 k=k+1;
 vars(k).name='temp_his';
 vars(k).datatype='single';
 vars(k).dimensions={'his_time',length(t_his)};
 vars(k).attributes{1}={'long_name','volume average instantaneous temperature'};
 vars(k).attributes{2}={'units','C'};

 create_timeSer_file(fnameOUT_HIS,vars);

end


% Output variables:

% - AVG:
ncwrite(fnameOUT_AVG,'mask_ave',mask_ave);

ncwrite(fnameOUT_AVG,'avg_time',t_avg,fnumSTR);
ncwrite(fnameOUT_AVG,'temp_avg',T_avg,fnumSTR);
ncwrite(fnameOUT_AVG,'dTdt',dTdt,fnumSTR);
ncwrite(fnameOUT_AVG,'Qadv',Adv_opt,fnumSTR);
ncwrite(fnameOUT_AVG,'Qatm',Qatm,fnumSTR);
ncwrite(fnameOUT_AVG,'hdiff',Hdiff,fnumSTR);

% - HIS:
ncwrite(fnameOUT_HIS,'mask_ave',mask_ave);

ncwrite(fnameOUT_HIS,'his_time',t_his,fnumSTR);
ncwrite(fnameOUT_HIS,'temp_his',T_his,fnumSTR);


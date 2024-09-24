% 3/19/2021: taken from volume_ave_heatBalance_useRomsFluxes.m on the PC. 
% The option used is verified to have balance in the cumulative terms
% (1) tend is computed using instantaneous T and V values. 
% (2) Adv is computed as the volume ave temp adv minus boundary volume flux (Huom, Hvon) times the 
%     volume ave T. 
% (3) Qatm .. as usual. 


clear all;
ExpID='Exp42a';
aveBoxName='CMCB'; % 'ORE4346', 'SCA'

fnumSTR=1;
fnumEND=736;

% Outputs will be in 2 files, AVG and HIS (since just one file with inf dim):
fnameOUT_AVG=['../' ExpID '/STATS/volume_ave_heatBalance_avg_' ExpID '_' aveBoxName '.nc'];
fnameOUT_HIS=['../' ExpID '/STATS/volume_ave_heatBalance_his_' ExpID '_' aveBoxName '.nc'];

createNewFilesYes=0; 

avg_fileHead=['../' ExpID '/AVG/roms_avg_'];
his_fileHead=['../' ExpID '/HIS/roms_his_'];
dia_fileHead=['../' ExpID '/DIA/roms_dia_'];
grdfile='../Prm/grd_wcofs_large_visc200.nc';

Cp=3985; % J/kg/K
rho0=1025; % kg/m3

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

% Vertical grid parameters:
fname1=[his_fileHead int2strPAD(fnumSTR,4) '.nc'];
N=read_ncdim(fname1,'s_rho');
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
Qatm=nan*zeros(nf,1);
Hdiff=nan*zeros(nf,1);
t_avg=nan*zeros(nf,1);
V_avg=nan*zeros(nf,1);

T_avg=nan*zeros(nf,1);

% some inst quantities:
t_his=nan*zeros(nf+1,1);
V_his=nan*zeros(nf+1,1);
T_his=nan*zeros(nf+1,1);





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
 fname=[his_fileHead int2strPAD(fnum1,4) '.nc'];
 disp(' ');
 disp(fname);
 t1=ncread(fname,'ocean_time');
 zeta=double(ncread(fname,'zeta'));
 T=double(ncread(fname,'temp'));
 
 % Hz:
 % vertical coordinates (change with zeta):
 z_w=get_z3D_use_zeta(h,zeta,'w',N,Vtransform,Vstretching, ...
                      theta_s,theta_b,Tcline);
 Hz=z_w(:,:,2:end)-z_w(:,:,1:end-1);
 
 % - inst V 
 % - volume-ave T based on inst volume
 [T1,V1]=vave(T,Hz,dxdy,mask_ave);
 
 if it>0
  dTdt(it)=(T1-T0)/(t1-t0);
 end
 
 t_his(it+1)=t1;
 T_his(it+1)=T1;
 V_his(it+1)=V1;
 
 %%% AVG & DIA based values:
 if it>0
  % read avg fields:
  fname=[avg_fileHead int2strPAD(fnum0,4) '.nc'];
  disp(fname);
  t_avg(it)=ncread(fname,'ocean_time');
  zeta_avg=double(ncread(fname,'zeta'));
  T=double(ncread(fname,'temp'));
  Fu=squeeze(double(ncread(fname,'Huon'))); % m3/s
  Fv=squeeze(double(ncread(fname,'Hvom'))); % m3/s
  %FTu=squeeze(double(ncread(fname,'Huon_temp'))); % m3 C / s
  %FTv=squeeze(double(ncread(fname,'Hvom_temp'))); % m3 c / s
  swrad=double(ncread(fname,'swrad'));
  lwrad=double(ncread(fname,'lwrad'));
  qsen =double(ncread(fname,'sensible'));
  qlat =double(ncread(fname,'latent'));
  
  % Hz:
  % vertical coordinates (change with zeta):
  z_w=get_z3D_use_zeta(h,zeta_avg,'w',N,Vtransform,Vstretching, ...
                       theta_s,theta_b,Tcline);
  Hz=z_w(:,:,2:end)-z_w(:,:,1:end-1);   

  % volume and volume-ave temp from the time avg fields:
  [T_avg(it),V_avg(it)]=vave(T,Hz,dxdy,mask_ave);

  % depth-integrated fluxes through the boundary of the domain defined by 
  % mask_ave
  Uflux=bflux(Fu,Fv,mask_u,mask_v,mask_ave);
  %TUflux=bflux(FTu,FTv,mask_u,mask_v,mask_ave);
  
  %Adv(it)=-( TUflux - Uflux*T_avg(it))/V_avg(it);
  
  % Atm flux:
  q=swrad+lwrad+qsen+qlat;
  [Q,A]=aave(q,dxdy,mask_ave); % Area ave q, AA = control area
  Qatm(it)=Q*A/(Cp*rho0*V_avg(it));

  % HDIFF, Adv_opt
  fname=[dia_fileHead int2strPAD(fnum0,4) '.nc'];
  disp(fname);
  hdiff=squeeze(double(ncread(fname,'temp_hdiff')));
  hadv=squeeze(double(ncread(fname,'temp_hadv')));
  
  [Hdiff(it),V_avg_tmp]=vave(hdiff,Hz,dxdy,mask_ave);
  [hadv_ave,V_avg_tmp]=vave(hadv,Hz,dxdy,mask_ave);
  Adv_opt(it)=-(-hadv_ave*V_avg_tmp-Uflux*T_avg(it))/V_avg_tmp;
  
 end
end

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

% - AVG:
ncwrite(fnameOUT_HIS,'mask_ave',mask_ave);

ncwrite(fnameOUT_HIS,'his_time',t_his,fnumSTR);
ncwrite(fnameOUT_HIS,'temp_his',T_his,fnumSTR);








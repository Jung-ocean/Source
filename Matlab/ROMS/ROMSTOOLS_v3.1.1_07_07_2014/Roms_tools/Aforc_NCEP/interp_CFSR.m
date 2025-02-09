function interp_CFSR(NCEP_dir,Y,M,Roa,interp_method,...
                     lon1,lat1,mask1,tin,...
		     nc_frc,nc_blk,lon,lat,angle,tout,Get_My_Data)

%
% Read the local NCEP files and perform the interpolations
%
%
% 1: Air temperature: Convert from Kelvin to Celsius
%
vname='Temperature_height_above_ground';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
tair=squeeze(nc{vname}(tin,:,:));
close(nc);
tair=get_missing_val(lon1,lat1,mask1.*tair,nan,Roa,nan);
tair=tair-273.15;
tair=interp2(lon1,lat1,tair,lon,lat,interp_method);
%
% 2: Relative humidity: Convert from % to fraction
%
% Get Specific Humidity [Kg/Kg]
%
vname='Specific_humidity';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
shum=squeeze(nc{vname}(tin,:,:));
close(nc);
shum=get_missing_val(lon1,lat1,mask1.*shum,nan,Roa,nan);
shum=interp2(lon1,lat1,shum,lon,lat,interp_method);
%
% computes specific humidity at saturation (Tetens  formula)
% (see air_sea tools, fonction qsat)
%
rhum=shum./qsat(tair);
%
% 3: Precipitation rate: Convert from [kg/m^2/s] to cm/day
%
vname='Precipitation_rate';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
prate=squeeze(nc{vname}(tin,:,:));
close(nc);
prate=get_missing_val(lon1,lat1,mask1.*prate,nan,Roa,nan);
prate=prate*0.1*(24.*60.*60.0);
prate=interp2(lon1,lat1,prate,lon,lat,interp_method);
prate(abs(prate)<1.e-4)=0;
%
% 4: Net shortwave flux: [W/m^2]
%      ROMS convention: downward = positive
%
% Downward solar shortwave
%
vname='Downward_Short-Wave_Rad_Flux';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
dswrf=squeeze(nc{vname}(tin,:,:));
close(nc);
dswrf=get_missing_val(lon1,lat1,mask1.*dswrf,nan,Roa,nan);
%  
% Upward solar shortwave
% 
vname='Upward_Short-Wave_Rad_Flux';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
uswrf=squeeze(nc{vname}(tin,:,:));
close(nc);
uswrf=get_missing_val(lon1,lat1,mask1.*uswrf,nan,Roa,nan);
%  
%  Net solar shortwave radiation  
%
radsw=dswrf - uswrf;
%----------------------------------------------------  
% GC le 31 03 2009
%  radsw is NET solar shortwave radiation
%  no more downward only solar radiation
% GC  bug fix by F. Marin IRD/LEGOS
%-----------------------------------------------------
radsw=interp2(lon1,lat1,radsw,lon,lat,interp_method);
radsw(radsw<1.e-10)=0;
%
% 5: Net outgoing Longwave flux:  [W/m^2]
%      ROMS convention: positive upward (opposite to nswrf !!!!)
%
% Get the net longwave flux [W/m^2]
%
%  5.1 get the downward longwave flux [W/m^2]
%
vname='Downward_Long-Wave_Rad_Flux';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
dlwrf=squeeze(nc{vname}(tin,:,:));
close(nc);
dlwrf=get_missing_val(lon1,lat1,mask1.*dlwrf,nan,Roa,nan);
%
%  5.2 get the upward longwave flux [W/m^2]
%
vname='Upward_Long-Wave_Rad_Flux';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
ulwrf=squeeze(nc{vname}(tin,:,:));
close(nc);
ulwrf=get_missing_val(lon1,lat1,mask1.*ulwrf,nan,Roa,nan);
%  
%  Net longwave flux 
%
radlw=interp2(lon1,lat1,ulwrf-dlwrf,lon,lat,interp_method);
%
% get the  downward longwave heat flux  
%
radlw_in=interp2(lon1,lat1,dlwrf,lon,lat,interp_method);
%
% 6: Wind & Wind stress [m/s]
%
vname='U-component_of_wind';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
uwnd=squeeze(nc{vname}(tin,:,:));
close(nc)
uwnd=get_missing_val(lon1,lat1,mask1.*uwnd,nan,Roa,nan);
uwnd=interp2(lon1,lat1,uwnd,lon,lat,interp_method);
%
vname='V-component_of_wind';
nc=netcdf([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc']);
vwnd=squeeze(nc{vname}(tin,:,:));
close(nc)
vwnd=get_missing_val(lon1,lat1,mask1.*vwnd,nan,Roa,nan);
vwnd=interp2(lon1,lat1,vwnd,lon,lat,interp_method);
%
% Compute the stress
%
wspd=sqrt(uwnd.^2+vwnd.^2);
[Cd,uu]=cdnlp(wspd,10.);
rhoa=air_dens(tair,rhum*100);
tx=Cd.*rhoa.*uwnd.*wspd;
ty=Cd.*rhoa.*vwnd.*wspd;
%
% Rotations on the ROMS grid
%
cosa=cos(angle);
sina=sin(angle);
%
sustr=rho2u_2d(tx.*cosa+ty.*sina);
svstr=rho2v_2d(ty.*cosa-tx.*sina);
%
% uwnd et vwnd sont aux points 'rho'
%
u10=rho2u_2d(uwnd.*cosa+vwnd.*sina);
v10=rho2v_2d(vwnd.*cosa-uwnd.*sina);
%
% Fill the ROMS files
%
if ~isempty(nc_frc)
  nc_frc{'sustr'}(tout,:,:)=sustr;
  nc_frc{'svstr'}(tout,:,:)=svstr;
end
if ~isempty(nc_blk)
  nc_blk{'tair'}(tout,:,:)=tair;
  nc_blk{'rhum'}(tout,:,:)=rhum;
  nc_blk{'prate'}(tout,:,:)=prate;
  nc_blk{'wspd'}(tout,:,:)=wspd;
  nc_blk{'radlw'}(tout,:,:)=radlw;
  nc_blk{'radlw_in'}(tout,:,:)=radlw_in;
  nc_blk{'radsw'}(tout,:,:)=radsw;
  nc_blk{'uwnd'}(tout,:,:)=u10;
  nc_blk{'vwnd'}(tout,:,:)=v10;
%  nc_blk{'sustr'}(tout,:,:)=sustr;
%  nc_blk{'svstr'}(tout,:,:)=svstr;
end



function create_OGCM(fname,lon,lat,depth,time,...
                     temp,salt,u,v,ssh,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create the OGCM file
%
%  Further Information:  
%  http://www.brest.ird.fr/Roms_tools/
%  
%  This file is part of ROMSTOOLS
%
%  ROMSTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  ROMSTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    6-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
missval=NaN;
disp('    Create the OGCM file')
nc=netcdf(fname,'clobber');
nc.description = 'HYCOM data (http://tds.hycom.org/)';
nc.author = 'Created by CSKIM';
nc.date = date;
redef(nc);

[latT, lonT] = size(lon);

nc('lonT')=lonT;
nc('latT')=latT;
nc('depth')=length(depth);
nc('time')=length(time);
% 
nc{'depth'}=ncdouble('depth') ;
nc{'depth'}.units=ncchar('meters');
nc{'depth'}.units='meters';
nc{'time'}=ncdouble('time') ;
% 
nc{'lon'}=ncdouble('latT','lonT') ;
nc{'lon'}.units=ncchar('degrees_east');
nc{'lon'}.units='degrees_east';
nc{'lat'}=ncdouble('latT','lonT') ;
nc{'lat'}.units=ncchar('degrees_north');
nc{'lat'}.units='degrees_north';
% 
nc{'ssh'}=ncfloat('time','latT','lonT') ;
nc{'ssh'}.long_name=ncchar('SEA LEVEL HEIGHT');
nc{'ssh'}.long_name='SEA LEVEL HEIGHT';
nc{'ssh'}.units=ncchar('m');
nc{'ssh'}.units='m';
nc{'ssh'}.missing_value=missval;
nc{'ssh'}.FillValue_=missval;

nc{'ubar'}=ncfloat('time','latT','lonT') ;
nc{'ubar'}.long_name=ncchar('ZONAL BAROTROPIC VELOCITY');
nc{'ubar'}.long_name='ZONAL BAROTROPIC VELOCITY';
nc{'ubar'}.units=ncchar('m/sec');
nc{'ubar'}.units='m/sec';
nc{'ubar'}.missing_value=missval;
nc{'ubar'}.FillValue_=missval;

nc{'vbar'}=ncfloat('time','latT','lonT') ;
nc{'vbar'}.long_name=ncchar('MERIDIONAL BAROTROPIC VELOCITY');
nc{'vbar'}.long_name='MERIDIONAL BAROTROPIC VELOCITY';
nc{'vbar'}.units=ncchar('m/sec');
nc{'vbar'}.units='m/sec';
nc{'vbar'}.missing_value=missval;
nc{'vbar'}.FillValue_=missval;

nc{'temp'}=ncfloat('time','depth','latT','lonT') ;
nc{'temp'}.long_name=ncchar('TEMPERATURE');
nc{'temp'}.long_name='TEMPERATURE';
nc{'temp'}.units=ncchar('deg. C');
nc{'temp'}.units='deg. C';
nc{'temp'}.missing_value=missval;
nc{'temp'}.FillValue_=missval;

nc{'salt'}=ncfloat('time','depth','latT','lonT') ;
nc{'salt'}.long_name=ncchar('SALINITY');
nc{'salt'}.long_name='SALINITY';
nc{'salt'}.units=ncchar('ppt');
nc{'salt'}.units='ppt';
nc{'salt'}.missing_value=missval;
nc{'salt'}.FillValue_=missval;

nc{'u'}=ncfloat('time','depth','latT','lonT') ;
nc{'u'}.long_name=ncchar('ZONAL VELOCITY');
nc{'u'}.long_name='ZONAL VELOCITY';
nc{'u'}.units=ncchar('m/sec');
nc{'u'}.units='m/sec';
nc{'u'}.missing_value=missval;
nc{'u'}.FillValue_=missval;

nc{'v'}=ncfloat('time','depth','latT','lonT') ;
nc{'v'}.long_name=ncchar('MERIDIONAL VELOCITY');
nc{'v'}.long_name='MERIDIONAL VELOCITY';
nc{'v'}.units=ncchar('m/sec');
nc{'v'}.units='m/sec';
nc{'v'}.missing_value=missval;
nc{'v'}.FillValue_=missval;

% nc{'lonU'}=ncdouble('lonU') ;
% nc{'lonU'}.units=ncchar('degrees_east');
% nc{'lonU'}.units='degrees_east';
% nc{'latU'}=ncdouble('latU') ;
% nc{'latU'}.units=ncchar('degrees_north');
% nc{'latU'}.units='degrees_north';
% nc{'lonV'}=ncdouble('lonV') ;
% nc{'lonV'}.units=ncchar('degrees_east');
% nc{'lonV'}.units='degrees_east';
% nc{'latV'}=ncdouble('latV') ;
% nc{'latV'}.units=ncchar('degrees_north');
% nc{'latV'}.units='degrees_north';

eval(['nc{''time''}.units = ncchar(''days since 1-Jan-',num2str(Yorig),' 00:00:0.0'');'])
eval(['nc{''time''}.units = ''days since 1-Jan-',num2str(Yorig),' 00:00:0.0'';'])

endef(nc);
%
% File the file
%
disp('    Fill the OGCM file')
nc{'depth'}(:)=depth;
nc{'lat'}(:)=lat;
nc{'lon'}(:)=lon;
% nc{'latU'}(:)=latU;
% nc{'lonU'}(:)=lonU;
% nc{'latV'}(:)=latV;
% nc{'lonV'}(:)=lonV;
%
for tndx=1:length(time)
%
  nc{'time'}(tndx)=time(tndx);
%
  if length(time)==1
    nc{'ssh'}(tndx,:,:)=ssh;
    u1=u;
    v1=v;
    nc{'u'}(tndx,:,:,:)=u1;
    nc{'v'}(tndx,:,:,:)=v1;
    nc{'temp'}(tndx,:,:,:)=temp;
    nc{'salt'}(tndx,:,:,:)=salt;
  else
    nc{'ssh'}(tndx,:,:)=squeeze(ssh(tndx,:,:));
    u1=squeeze(u(tndx,:,:,:));
    v1=squeeze(v(tndx,:,:,:));
    nc{'u'}(tndx,:,:,:)=u1;
    nc{'v'}(tndx,:,:,:)=v1;
    nc{'temp'}(tndx,:,:,:)=squeeze(temp(tndx,:,:,:));
    nc{'salt'}(tndx,:,:,:)=squeeze(salt(tndx,:,:,:));
  end
%
% Compute the barotropic velocities
%
  masku=isfinite(u1);
  maskv=isfinite(v1);
  u1(isnan(u1))=0;
  v1(isnan(v1))=0;
  dz=gradient(depth);
  NZ=length(depth);
  du=0*squeeze(u1(1,:,:));
  zu=du;
  dv=0*squeeze(v1(1,:,:));
  zv=dv;
  for k=1:NZ
    du=du+dz(k)*squeeze(u1(k,:,:));
    zu=zu+dz(k)*squeeze(masku(k,:,:));
    dv=dv+dz(k)*squeeze(v1(k,:,:));
    zv=zv+dz(k)*squeeze(maskv(k,:,:));
  end
  du(zu==0)=NaN;
  dv(zv==0)=NaN;
  zu(zu==0)=NaN;
  zv(zv==0)=NaN;
  ubar=du./zu;
  vbar=dv./zv;
%
  nc{'ubar'}(tndx,:,:)=ubar;
  nc{'vbar'}(tndx,:,:)=vbar;
%
end
%
close(nc)
%
return

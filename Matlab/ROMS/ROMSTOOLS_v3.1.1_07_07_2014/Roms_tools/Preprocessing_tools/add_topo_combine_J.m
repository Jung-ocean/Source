function h=add_topo_combine_J(grdname,toponame)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% add a topography (here etopo2) to a ROMS grid
%
% the topogaphy matrix is coarsened prior
% to the interpolation on the ROMS grid tp
% prevent the generation of noise due to 
% subsampling. this procedure ensure a better
% general volume conservation.
%
% Last update Pierrick Penven 8/2006.
%
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr 
%
%  Updated    Aug-2006 by Pierrick Penven
%  Updated    2006/10/05 by Pierrick Penven (dl depend of model
%                                           resolution at low resolution)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  read roms grid
%
nc=netcdf(grdname);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
result=close(nc);
%
% Get ROMS averaged resolution
%
dx=mean(mean(1./pm));
dy=mean(mean(1./pn));
dx_roms=mean([dx dy]);
disp(['   ROMS resolution : ',num2str(dx_roms/1000,3),' km'])
%
dl=max([1 2*(dx_roms/(60*1852))]);
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
%  open the topo file
%
nc=netcdf(toponame);
tlon=nc{'x'}(:);
tlat=nc{'y'}(:);
%
%  get a subgrid
%
j=find(tlat>=latmin & tlat<=latmax);
i1=find(tlon-360>=lonmin & tlon-360<=lonmax);
i2=find(tlon>=lonmin & tlon<=lonmax);
i3=find(tlon+360>=lonmin & tlon+360<=lonmax);
x=cat(1,tlon(i1)-360,tlon(i2),tlon(i3)+360);
y=tlat(j);
%
%  Read data
%
if ~isempty(i2)
  topo=-nc{'z'}(j,i2);
else
  topo=[];
end
if ~isempty(i1)
  topo=cat(2,-nc{'z'}(j,i1),topo);
end
if ~isempty(i3)
  topo=cat(2,topo,-nc{'z'}(j,i3));
end
result=close(nc);
%
% open second topo file and combine two topo files
%
g30s = load('D:\Data\Ocean\Bathymetry\KorBathy30s.mat');
g30s_lon = g30s.xbathy;
g30s_lat = g30s.ybathy;
g30s_topo = g30s.zbathy;
g30s_topo(g30s_topo < -1) = 0;

xmindist = abs(tlon - g30s_lon(1));
xmaxdist = abs(tlon - g30s_lon(end));
ymindist = abs(tlat - g30s_lat(1));
ymaxdist = abs(tlat - g30s_lat(end));

xminind = find(xmindist == min(xmindist));
xmaxind = find(xmaxdist == min(xmaxdist));
yminind = find(ymindist == min(ymindist));
ymaxind = find(ymaxdist == min(ymaxdist));

[tlon_within_30s, tlat_within_30s] = meshgrid(tlon(xminind:xmaxind), tlat(yminind:ymaxind));
topo_30s_to_1m = griddata(g30s_lon, g30s_lat, g30s_topo, tlon_within_30s, tlat_within_30s);
topo_30s_to_1m(isnan(topo_30s_to_1m) == 1) = 0;

nc=netcdf(toponame);
topo1=-nc{'z'}(:);
close(nc)
topo1(yminind:ymaxind, xminind:xmaxind) = topo_30s_to_1m;

topo = topo1(j,i2);

%
% Get TOPO averaged resolution
%
R=6367442.76;
deg2rad=pi/180;
dg=mean(x(2:end)-x(1:end-1));
dphi=y(2:end)-y(1:end-1);
dy=R*deg2rad*dphi;
dx=R*deg2rad*dg*cos(deg2rad*y);
dx_topo=mean([dx ;dy]);
disp(['   Topography data resolution : ',num2str(dx_topo/1000,3),' km'])
%
% Degrade TOPO resolution
%
n=0;
while dx_roms>(dx_topo)
  n=n+1;
%  
  x=0.5*(x(2:end)+x(1:end-1));
  x=x(1:2:end);
  y=0.5*(y(2:end)+y(1:end-1));
  y=y(1:2:end);
%
  topo=0.25*(topo(2:end,1:end-1)  +topo(2:end,2:end)+...
             topo(1:end-1,1:end-1)+topo(1:end-1,2:end));
  topo=topo(1:2:end,1:2:end);   
%  
  dg=mean(x(2:end)-x(1:end-1));
  dphi=y(2:end)-y(1:end-1);
  dy=R*deg2rad*dphi;
  dx=R*deg2rad*dg*cos(deg2rad*y);
  dx_topo=mean([dx ;dy]);
end
disp(['   Topography resolution halved ',num2str(n),' times'])
disp(['   New topography resolution : ',num2str(dx_topo/1000,3),' km'])
%
%  interpolate the topo
%
h=interp2(x,y,topo,lon,lat,'cubic');
%
return

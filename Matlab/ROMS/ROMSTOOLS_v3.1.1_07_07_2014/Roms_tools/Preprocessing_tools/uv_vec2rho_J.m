function [ured,vred,lonred,latred,maskred]=...
         uv_vec2rho_J(u,v,lon,lat,angle,mask,skip,npts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put a uv current field in the carthesian frame
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
u = u'; v = v'; lon = lon'; lat = lat'; angle = angle'; mask = mask';
%
%  Boundaries
%
lat=rempoints(lat,npts);
lon=rempoints(lon,npts);
mask=rempoints(mask,npts);
angle=rempoints(angle,npts);
u=rempoints(u,npts);
v=rempoints(v,npts);
%
%  Values at rho points.
%
ur=u2rho_2d(u);
vr=v2rho_2d(v);
%
%  Rotation
%
cosa = cos(angle);
sina = sin(angle);
u = ur.*cosa - vr.*sina;
v = vr.*cosa + ur.*sina;
%
%  Skip
%
[M,L]=size(lon);
imin=floor(0.5+0.5*skip);
imax=floor(0.5+L-0.5*skip);
jmin=ceil(0.5+0.5*skip);
jmax=ceil(0.5+M-0.5*skip);
ured=u(jmin:skip:jmax,imin:skip:imax);
vred=v(jmin:skip:jmax,imin:skip:imax);
latred=lat(jmin:skip:jmax,imin:skip:imax);
lonred=lon(jmin:skip:jmax,imin:skip:imax);
maskred=mask(jmin:skip:jmax,imin:skip:imax);
%
%  Apply mask
%
ured=maskred.*ured;
vred=maskred.*vred;
lonred=lonred;
latred=latred;

ured = ured';
vred = vred';
lonred = lonred';
latred = latred';
maskred = maskred';
return

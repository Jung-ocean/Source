function [z]=get_depths_J(fname,gname,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the depths of the sigma levels
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
%  Copyright (c) 2002-2006 by Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = gname;
h = g.h;
%
% open history file
%
nc=netcdf(fname);
zeta=squeeze(nc{'zeta'}(:,:));
theta_s=g.theta_s;
if (isempty(theta_s))
    %  disp('Rutgers version')
    theta_s=g.theta_s;
    theta_b=g.theta_b;
    Tcline=g.Tcline;
else
    %  disp('AGRIF/UCLA version');
    theta_b=g.theta_b;
    Tcline=g.Tcline;
    hc=g.hc;
end
if (isempty(Tcline))
    %  disp('UCLA version');
    hc=g.hc;
else
    hmin=min(min(h));
    hc=min(hmin,Tcline);
end

N=g.N;

if hc == 5
    Vtransform = 1;
else
    Vtransform = 2;
end

if Vtransform == 2
    hc=Tcline;
end
close(nc)
%
%
%
if isempty(zeta)
    zeta=0.*h;
end

vtype=type;
if (type=='u')|(type=='v')
    vtype='r';
end
z=zlevs(h,zeta,theta_s,theta_b,hc,N,vtype,Vtransform);
if type=='u'
    z=rho2u_3d(z);
end
if type=='v'
    z=rho2v_3d(z);
end
return

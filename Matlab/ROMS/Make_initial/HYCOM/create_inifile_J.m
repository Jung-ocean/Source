function create_inifile(inifile,gridfile,title,...
                         theta_s,theta_b,hc,N,time,clobber,vtransform)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function nc=create_inifile(inifile,gridfile,theta_s,...
%                  theta_b,hc,N,ttime,stime,utime,... 
%                  cycle,clobber)
%
%   This function create the header of a Netcdf climatology 
%   file.
%
%   Input: 
% 
%   inifile      Netcdf initial file name (character string).
%   gridfile     Netcdf grid file name (character string).
%   theta_s      S-coordinate surface control parameter.(Real)
%   theta_b      S-coordinate bottom control parameter.(Real)
%   hc           Width (m) of surface or bottom boundary layer
%                where higher vertical resolution is required 
%                during stretching.(Real)
%   N            Number of vertical levels.(Integer)  
%   time         Initial time.(Real) 
%   clobber      Switch to allow or not writing over an existing
%                file.(character string) 
%
%   Output
%
%   nc       Output netcdf object.
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
%  Modified by J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Creating the file : ',inifile])
if nargin < 10
   disp([' NO VTRANSFORM parameter found'])
   disp([' USE TRANSFORM default value vtransform = 1'])
   vtransform = 1; 
   vstretching = 1;
else
    vstretching = 4;
end
disp([' VTRANSFORM = ',num2str(vtransform)])
disp([' VSTRETCHING = ',num2str(vstretching)])
%
%  Read the grid file
%
nc=netcdf(gridfile);
h=nc{'h'}(:);  
mask=nc{'mask_rho'}(:);
close(nc);
hmin=min(min(h(mask==1)));
if vtransform ==1;
    if hc > hmin
        error([' hc (',num2str(hc),' m) > hmin (',num2str(hmin),' m)'])
    end
end
[Mp,Lp]=size(h);
L=Lp-1;
M=Mp-1;
Np=N+1;
%
%  Create the initial file
%
type = 'INITIAL file' ; 
history = 'ROMS' ;
ncid = netcdf.create(inifile, 'clobber');
%
%  Create dimensions
%
xi_u_dimID = netcdf.defDim(ncid,'xi_u', L);
xi_v_dimID = netcdf.defDim(ncid,'xi_v', Lp);
xi_rho_dimID = netcdf.defDim(ncid,'xi_rho', Lp);
eta_u_dimID = netcdf.defDim(ncid,'eta_u', Mp);
eta_v_dimID = netcdf.defDim(ncid,'eta_v', M);
eta_rho_dimID = netcdf.defDim(ncid,'eta_rho', Mp);
s_rho_dimID = netcdf.defDim(ncid,'s_rho', N);
s_w_dimID = netcdf.defDim(ncid,'s_w', Np);
tracer_dimID = netcdf.defDim(ncid,'tracer', 2);
time_dimID = netcdf.defDim(ncid, 'time', 0);
one_dimID = netcdf.defDim(ncid, 'one', 1);
%
%  Create variables
%
spherical_ID = netcdf.defVar(ncid, 'spherical', 'char', one_dimID);
Vtransform_ID = netcdf.defVar(ncid, 'Vtransform', 'int', one_dimID);
Vstretching_ID = netcdf.defVar(ncid, 'Vstretching', 'int', one_dimID);
tstart_ID = netcdf.defVar(ncid, 'tstart', 'double', one_dimID);
tend_ID = netcdf.defVar(ncid, 'tend', 'double', one_dimID);
theta_s_ID = netcdf.defVar(ncid, 'theta_s', 'double', one_dimID);
theta_b_ID = netcdf.defVar(ncid, 'theta_b', 'double', one_dimID);
Tcline_ID = netcdf.defVar(ncid, 'Tcline', 'double', one_dimID);
hc_ID = netcdf.defVar(ncid, 'hc', 'double', one_dimID);
sc_r_ID = netcdf.defVar(ncid, 'sc_r', 'double', s_rho_dimID);
Cs_r_ID = netcdf.defVar(ncid, 'Cs_r', 'double', s_rho_dimID);
ocean_time_ID = netcdf.defVar(ncid, 'ocean_time', 'double', time_dimID);
scrum_time_ID = netcdf.defVar(ncid, 'scrum_time', 'double', time_dimID);
u_ID = netcdf.defVar(ncid, 'u', 'double', [xi_u_dimID eta_u_dimID s_rho_dimID time_dimID]);
v_ID = netcdf.defVar(ncid, 'v', 'double', [xi_v_dimID eta_v_dimID s_rho_dimID time_dimID]);
ubar_ID = netcdf.defVar(ncid, 'ubar', 'double', [xi_u_dimID eta_u_dimID time_dimID]);
vbar_ID = netcdf.defVar(ncid, 'vbar', 'double', [xi_v_dimID eta_v_dimID time_dimID]);
zeta_ID = netcdf.defVar(ncid, 'zeta', 'double', [xi_rho_dimID eta_rho_dimID time_dimID]);
temp_ID = netcdf.defVar(ncid, 'temp', 'double', [xi_rho_dimID eta_rho_dimID s_rho_dimID time_dimID]);
salt_ID = netcdf.defVar(ncid, 'salt', 'double', [xi_rho_dimID eta_rho_dimID s_rho_dimID time_dimID]);
%
%  Create attributes
%
netcdf.putAtt(ncid, Vtransform_ID, 'long_name', 'vertical terrain-following transformation equation');
%
netcdf.putAtt(ncid, Vstretching_ID, 'long_name', 'vertical terrain-following stretching function');
%
netcdf.putAtt(ncid, tstart_ID, 'long_name', 'start processing day');
netcdf.putAtt(ncid, tstart_ID, 'unit', 'day');
%
netcdf.putAtt(ncid, tend_ID, 'long_name', 'end processing day');
netcdf.putAtt(ncid, tend_ID, 'unit', 'day');
%
netcdf.putAtt(ncid, theta_s_ID, 'long_name', 'S-coordinate surface control parameter');
netcdf.putAtt(ncid, theta_s_ID, 'unit', 'nondimensional');
%
netcdf.putAtt(ncid, theta_b_ID, 'long_name', 'S-coordinate bottom control parameter');
netcdf.putAtt(ncid, theta_b_ID, 'unit', 'nondimensional');
%
netcdf.putAtt(ncid, Tcline_ID, 'long_name', 'S-coordinate surface/bottom layer width');
netcdf.putAtt(ncid, Tcline_ID, 'unit', 'meter');
%
netcdf.putAtt(ncid, hc_ID, 'long_name', 'S-coordinate parameter, critical depth');
netcdf.putAtt(ncid, hc_ID, 'unit', 'meter');
%
netcdf.putAtt(ncid, sc_r_ID, 'long_name', 'S-coordinate at RHO-points');
netcdf.putAtt(ncid, sc_r_ID, 'unit', 'nondimensional');
netcdf.putAtt(ncid, sc_r_ID, 'valid_min', '-1');
netcdf.putAtt(ncid, sc_r_ID, 'valid_max', '0');
%
netcdf.putAtt(ncid, Cs_r_ID, 'long_name', 'S-coordinate stretching curves at RHO-points');
netcdf.putAtt(ncid, Cs_r_ID, 'unit', 'nondimensional');
netcdf.putAtt(ncid, Cs_r_ID, 'valid_min', '-1');
netcdf.putAtt(ncid, Cs_r_ID, 'valid_max', '0');
%
netcdf.putAtt(ncid, ocean_time_ID, 'long_name', 'time since initialization');
netcdf.putAtt(ncid, ocean_time_ID, 'unit', 'second');
%
netcdf.putAtt(ncid, scrum_time_ID, 'long_name', 'time since initialization');
netcdf.putAtt(ncid, scrum_time_ID, 'unit', 'second');
%
netcdf.putAtt(ncid, u_ID, 'long_name', 'u-momentum component');
netcdf.putAtt(ncid, u_ID, 'unit', 'meter second-1');
%
netcdf.putAtt(ncid, v_ID, 'long_name', 'v-momentum component');
netcdf.putAtt(ncid, v_ID, 'unit', 'meter second-1');
%
netcdf.putAtt(ncid, ubar_ID, 'long_name', 'vertically integrated u-momentum component');
netcdf.putAtt(ncid, ubar_ID, 'unit', 'meter second-1');
%
netcdf.putAtt(ncid, vbar_ID, 'long_name', 'vertically integrated v-momentum component');
netcdf.putAtt(ncid, vbar_ID, 'unit', 'meter second-1');
%
netcdf.putAtt(ncid, zeta_ID, 'long_name', 'free-surface');
netcdf.putAtt(ncid, zeta_ID, 'unit', 'meter');
%
netcdf.putAtt(ncid, temp_ID, 'long_name', 'potential temperature');
netcdf.putAtt(ncid, temp_ID, 'unit', 'Celsius');
%
netcdf.putAtt(ncid, salt_ID, 'long_name', 'salinity');
netcdf.putAtt(ncid, salt_ID, 'unit', 'PSU');
%
% Create global attributes
%
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'title', title);
netcdf.putAtt(ncid,varid,'date', date);
netcdf.putAtt(ncid,varid,'clim_file', inifile);
netcdf.putAtt(ncid,varid,'grd_file', gridfile);
netcdf.putAtt(ncid,varid,'type', type);
netcdf.putAtt(ncid,varid,'history', history);
netcdf.putAtt(ncid,varid,'author','Created by Jihun Jung');
%
% Leave define mode
%
netcdf.endDef(ncid);
%
% Compute S coordinates
%
[sc_r,Cs_r,sc_w,Cs_w] = scoordinate(theta_s,theta_b,N,hc,vtransform);
%disp(['vtransform=',num2str(vtransform)])
%
% Write variables
%
nc = netcdf(inifile, 'w');
nc{'spherical'}(:)='T';
nc{'Vtransform'}(:)=vtransform;
nc{'Vstretching'}(:)=vstretching;
nc{'tstart'}(:) =  time; 
nc{'tend'}(:) =  time; 
nc{'theta_s'}(:) =  theta_s; 
nc{'theta_b'}(:) =  theta_b; 
nc{'Tcline'}(:) =  hc; 
nc{'hc'}(:) =  hc; 
nc{'sc_r'}(:) =  sc_r; 
nc{'Cs_r'}(:) =  Cs_r; 
nc{'scrum_time'}(1) =  time*24*3600; 
nc{'ocean_time'}(1) =  time*24*3600; 
nc{'u'}(:) =  0; 
nc{'v'}(:) =  0; 
nc{'zeta'}(:) =  0; 
nc{'ubar'}(:) =  0; 
nc{'vbar'}(:) =  0; 
nc{'temp'}(:) =  0; 
nc{'salt'}(:) =  0; 
close(nc);
%
% Synchronize on disk
%
netcdf.close(ncid);
return
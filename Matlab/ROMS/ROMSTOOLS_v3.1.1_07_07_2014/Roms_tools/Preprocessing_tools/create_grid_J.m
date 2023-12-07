function  create_grid_J(L,M,grdname,title)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf gridfile
%       L: total number of psi points in x direction
%       M: total number of psi points in y direction
%       grdname: name of the grid file
%       title: title in the netcdf file
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
Lp=L+1;
Mp=M+1;

ncid = netcdf.create(grdname, 'clobber');

%
%  Create dimensions
%

xi_u_dimID = netcdf.defDim(ncid, 'xi_u', L);
xi_v_dimID = netcdf.defDim(ncid, 'xi_v', Lp);
xi_rho_dimID = netcdf.defDim(ncid, 'xi_rho', Lp);
xi_psi_dimID = netcdf.defDim(ncid, 'xi_psi', L);
eta_u_dimID = netcdf.defDim(ncid, 'eta_u', Mp);
eta_v_dimID = netcdf.defDim(ncid, 'eta_v', M);
eta_rho_dimID = netcdf.defDim(ncid, 'eta_rho', Mp);
eta_psi_dimID = netcdf.defDim(ncid, 'eta_psi', M);
one_dimID = netcdf.defDim(ncid, 'one', 1);
two_dimID = netcdf.defDim(ncid, 'two', 2);
four_dimID = netcdf.defDim(ncid, 'four', 4);
bath_dimID = netcdf.defDim(ncid, 'bath', 1);

%
%  Create variables and attributes
%

var_ID = netcdf.defVar(ncid, 'xl', 'double', one_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'domain length in the XI-direction');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'el', 'double', one_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'domain length in the ETA-direction');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'depthmin', 'double', one_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Shallow bathymetry clipping depth');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'depthmax', 'double', one_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Deep bathymetry clipping depth');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'spherical', 'char', one_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Grid type logical switch');
netcdf.putAtt(ncid, var_ID, 'option_T', 'spherical');

var_ID = netcdf.defVar(ncid, 'angle', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'angle between xi axis and east');
netcdf.putAtt(ncid, var_ID, 'units', 'degree');

var_ID = netcdf.defVar(ncid, 'h', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Final bathymetry at RHO-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'hraw', 'double', [xi_rho_dimID eta_rho_dimID bath_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Working bathymetry at RHO-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'alpha', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Weights between coarse and fine grids at RHO-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'f', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Coriolis parameter at RHO-points');
netcdf.putAtt(ncid, var_ID, 'units', 'second-1');

var_ID = netcdf.defVar(ncid, 'pm', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'curvilinear coordinate metric in XI');
netcdf.putAtt(ncid, var_ID, 'units', 'meter-1');

var_ID = netcdf.defVar(ncid, 'pn', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'curvilinear coordinate metric in ETA');
netcdf.putAtt(ncid, var_ID, 'units', 'meter-1');

var_ID = netcdf.defVar(ncid, 'dndx', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'xi derivative of inverse metric factor pn');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'dmde', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'eta derivative of inverse metric factor pm');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'x_rho', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'x location of RHO-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'x_u', 'double', [xi_u_dimID eta_u_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'x location of U-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'x_v', 'double', [xi_v_dimID eta_v_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'x location of V-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'x_psi', 'double', [xi_psi_dimID eta_psi_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'x location of PSI-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'y_rho', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'y location of RHO-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'y_u', 'double', [xi_u_dimID eta_u_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'y location of U-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'y_v', 'double', [xi_v_dimID eta_v_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'y location of V-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'y_psi', 'double', [xi_psi_dimID eta_psi_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'y location of PSI-points');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');

var_ID = netcdf.defVar(ncid, 'lon_rho', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'longitude of RHO-points');
netcdf.putAtt(ncid, var_ID, 'units', 'degree_east');

var_ID = netcdf.defVar(ncid, 'lon_u', 'double', [xi_u_dimID eta_u_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'longitude of U-points');
netcdf.putAtt(ncid, var_ID, 'units', 'degree_east');

var_ID = netcdf.defVar(ncid, 'lon_v', 'double', [xi_v_dimID eta_v_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'longitude of V-points');
netcdf.putAtt(ncid, var_ID, 'units', 'degree_east');

var_ID = netcdf.defVar(ncid, 'lon_psi', 'double', [xi_psi_dimID eta_psi_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'longitude of PSI-points');
netcdf.putAtt(ncid, var_ID, 'units', 'degree_east');

var_ID = netcdf.defVar(ncid, 'lat_rho', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'latitude of RHO-points');
netcdf.putAtt(ncid, var_ID, 'units', 'degree_north');

var_ID = netcdf.defVar(ncid, 'lat_u', 'double', [xi_u_dimID eta_u_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'latitude of U-points');
netcdf.putAtt(ncid, var_ID, 'units', 'degree_north');

var_ID = netcdf.defVar(ncid, 'lat_v', 'double', [xi_v_dimID eta_v_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'latitude of V-points');
netcdf.putAtt(ncid, var_ID, 'units', 'degree_north');

var_ID = netcdf.defVar(ncid, 'lat_psi', 'double', [xi_psi_dimID eta_psi_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'latitude of PSI-points');
netcdf.putAtt(ncid, var_ID, 'units', 'degree_north');

var_ID = netcdf.defVar(ncid, 'mask_rho', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'mask on RHO-points');
netcdf.putAtt(ncid, var_ID, 'option_0', 'land');
netcdf.putAtt(ncid, var_ID, 'option_1', 'water');

var_ID = netcdf.defVar(ncid, 'mask_u', 'double', [xi_u_dimID eta_u_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'mask on U-points');
netcdf.putAtt(ncid, var_ID, 'option_0', 'land');
netcdf.putAtt(ncid, var_ID, 'option_1', 'water');

var_ID = netcdf.defVar(ncid, 'mask_v', 'double', [xi_v_dimID eta_v_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'mask on V-points');
netcdf.putAtt(ncid, var_ID, 'option_0', 'land');
netcdf.putAtt(ncid, var_ID, 'option_1', 'water');

var_ID = netcdf.defVar(ncid, 'mask_psi', 'double', [xi_psi_dimID eta_psi_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'mask on PSI-points');
netcdf.putAtt(ncid, var_ID, 'option_0', 'land');
netcdf.putAtt(ncid, var_ID, 'option_1', 'water');

%
% Create global attributes
%

varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'title', title);
netcdf.putAtt(ncid,varid,'date',datestr(date, 'yyyymmdd'));
netcdf.putAtt(ncid,varid,'type', 'ROMS grid file');

netcdf.endDef(ncid);
netcdf.close(ncid);

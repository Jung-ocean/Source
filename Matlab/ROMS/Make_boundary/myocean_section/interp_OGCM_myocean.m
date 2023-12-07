function interp_OGCM_myocean(OGCM_dir,OGCM_prefix,year,month,Roa,interp_method,...
    Z,tin,nc_clm,nc_bry,g,angle,h,tout,obc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Read the local OGCM files and perform the interpolations
%
% Ok, I am lazy and I did not do something special for the bry files...
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
%  Copyright (c) 2005-2006 by Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%  Updated    6-Sep-2006 by Pierrick Penven : Nothing special for the bry file
%  Update    13-Sep-2009 by Gildas Cambon :   Begin treatments case  for the bry
%  file, no to be continued ...
%  Updated    5-Nov-2006 by Pierrick Penven : A bit of cleaning...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conserv = 0; % same barotropic velocities as the OGCM
Vtransform = 2;
Vstretching = 4;

directions = {'south', 'east', 'north', 'west'};

%
disp(['  Horizontal interpolation: ',...
    'myocean ','Y',num2str(year),'M',num2str(month),'.nc'])
%
%
% ROMS grid angle
%
cosa = cos(angle);
sina = sin(angle);
%
% Open the OGCM file
%
nc = netcdf([OGCM_dir,OGCM_prefix, 'east_monthly_',num2str(year), num2char(month,2),'.nc']);
missvalue = nc{'ssh'}.FillValue_(:);
close(nc)
%
% Interpole data on the OGCM Z grid and ROMS horizontal grid
%
%
% Read and extrapole the 2D variables
%

for di = 1:length(directions)
    dir = directions{di};
    filename = ['myocean_', dir, '_monthly_', num2str(year), num2char(month,2),'.nc'];
    nc = netcdf([OGCM_dir, filename]);
    lon_raw = nc{'longitude'}(:);
    lat_raw = nc{'latitude'}(:);
    zeta_raw = nc{'ssh'}(:);
    zeta_raw(zeta_raw == missvalue) = nan;
    zeta_fill = fillmissing(zeta_raw,'linear');
    eval(['zeta_', dir, '_raw = zeta_fill;'])
    close(nc)
end

%
% Read and extrapole the 3D variables
%
NZ = length(Z);
dz = gradient(Z);

varis = {'temperature', 'salinity', 'u', 'v'};
for di = 1:length(directions)
    dir = directions{di};
    
    for vi = 1:length(varis)
        var = varis{vi};
        filename = ['myocean_', dir, '_monthly_', num2str(year), num2char(month,2),'.nc'];
        nc = netcdf([OGCM_dir, filename]);
        lon_raw = nc{'longitude'}(:); eval(['lon_', dir, '= lon_raw;'])
        lat_raw = nc{'latitude'}(:);  eval(['lat_', dir, '= lat_raw;'])
        var_raw = squeeze(nc{var}(:));
        close(nc)
        var_raw(var_raw == missvalue) = NaN;
        index = find(isnan(var_raw)==1);
        
        for hi = 1:length(var_raw)
            var_raw(:,hi) = fillmissing(var_raw(:,hi), 'linear');
        end
        for ni = 1:NZ
            var_raw(ni,:) = fillmissing(var_raw(ni,:), 'linear');
        end
        
        eval([var, '_', dir, '_raw = var_raw;'])
        
    end
    dz_2d = repmat(-dz, [1, length(eval(['u_', dir, '_raw']))]);
    dz_2d(index) = 0;
    eval(['ubar_', dir,'_raw = sum(u_', dir, '_raw.*dz_2d)./sum(dz_2d);']);
    eval(['vbar_', dir,'_raw = sum(v_', dir, '_raw.*dz_2d)./sum(dz_2d);']);
    
end

%
%Initialisation in case of bry files
%
if ~isempty(nc_bry)
    if obc(1)==1
        
        grid_raw = lon_south;
        grid_interp_rho = g.lon_rho(1,:);
        grid_interp_u = g.lon_u(1,:);
        grid_interp_v = g.lon_v(1,:);
        
        zeta_south = interp1(grid_raw, zeta_south_raw, grid_interp_rho);
        ubar_south = interp1(grid_raw, ubar_south_raw, grid_interp_u);
        vbar_south = interp1(grid_raw, vbar_south_raw, grid_interp_v);
        
        for ni = 1:NZ
            u_south(ni,:) = interp1(grid_raw, u_south_raw(ni,:), grid_interp_u);
            v_south(ni,:) = interp1(grid_raw, v_south_raw(ni,:), grid_interp_v);
            temp_south(ni,:) = interp1(grid_raw, temperature_south_raw(ni,:), grid_interp_rho);
            salt_south(ni,:) = interp1(grid_raw, salinity_south_raw(ni,:), grid_interp_rho);
        end
        
    end
    if obc(2)==1
        grid_raw = lat_east;
        grid_interp_rho = g.lat_rho(:,end);
        grid_interp_u = g.lat_u(:,end);
        grid_interp_v = g.lat_v(:,end);
        
        zeta_east = interp1(grid_raw, zeta_east_raw, grid_interp_rho);
        ubar_east = interp1(grid_raw, ubar_east_raw, grid_interp_u);
        vbar_east = interp1(grid_raw, vbar_east_raw, grid_interp_v);
        
        for ni = 1:NZ
            u_east(ni,:) = interp1(grid_raw, u_east_raw(ni,:), grid_interp_u);
            v_east(ni,:) = interp1(grid_raw, v_east_raw(ni,:), grid_interp_v);
            temp_east(ni,:) = interp1(grid_raw, temperature_east_raw(ni,:), grid_interp_rho);
            salt_east(ni,:) = interp1(grid_raw, salinity_east_raw(ni,:), grid_interp_rho);
        end
        
    end
    if obc(3)==1
        
        grid_raw = lon_north;
        grid_interp_rho = g.lon_rho(end,:);
        grid_interp_u = g.lon_u(end,:);
        grid_interp_v = g.lon_v(end,:);
        
        zeta_north = interp1(grid_raw, zeta_north_raw, grid_interp_rho);
        ubar_north = interp1(grid_raw, ubar_north_raw, grid_interp_u);
        vbar_north = interp1(grid_raw, vbar_north_raw, grid_interp_v);
        
        for ni = 1:NZ
            u_north(ni,:) = interp1(grid_raw, u_north_raw(ni,:), grid_interp_u);
            v_north(ni,:) = interp1(grid_raw, v_north_raw(ni,:), grid_interp_v);
            temp_north(ni,:) = interp1(grid_raw, temperature_north_raw(ni,:), grid_interp_rho);
            salt_north(ni,:) = interp1(grid_raw, salinity_north_raw(ni,:), grid_interp_rho);
        end
        
    end
    if obc(4)==1
        grid_raw = lat_west;
        grid_interp_rho = g.lat_rho(:,1);
        grid_interp_u = g.lat_u(:,1);
        grid_interp_v = g.lat_v(:,1);
        
        zeta_west = interp1(grid_raw, zeta_west_raw, grid_interp_rho);
        ubar_west = interp1(grid_raw, ubar_west_raw, grid_interp_u);
        vbar_west = interp1(grid_raw, vbar_west_raw, grid_interp_v);
        
        for ni = 1:NZ
            u_west(ni,:) = interp1(grid_raw, u_west_raw(ni,:), grid_interp_u);
            v_west(ni,:) = interp1(grid_raw, v_west_raw(ni,:), grid_interp_v);
            temp_west(ni,:) = interp1(grid_raw, temperature_west_raw(ni,:), grid_interp_rho);
            salt_west(ni,:) = interp1(grid_raw, salinity_west_raw(ni,:), grid_interp_rho);
        end
        
    end
end

%
% Get the ROMS vertical grid
%
disp('  Vertical interpolations')
if ~isempty(nc_clm)
    theta_s = nc_clm{'theta_s'}(:);
    theta_b = nc_clm{'theta_b'}(:);
    hc = nc_clm{'hc'}(:);
    N = length(nc_clm('sc_r'));
end
if ~isempty(nc_bry)
    theta_s = nc_bry{'theta_s'}(:);
    theta_b = nc_bry{'theta_b'}(:);
    hc = nc_bry{'hc'}(:);
    N = length(nc_bry('sc_r'));
end
%
% Add an extra bottom layer (-100000m) and an extra surface layer (+100m)
% to prevent vertical extrapolations
%
Z = [100;Z;-100000];
%
% ROMS vertical grid
%
zeta = zeros(size(g.lon_rho));
zeta(1,:) = fillmissing(zeta_south,'linear');
zeta(end,:) = fillmissing(zeta_north,'linear');
zeta(:,1) = fillmissing(zeta_west,'linear');
zeta(:,end) = fillmissing(zeta_east,'linear');

zr = zlevs(h,zeta,theta_s,theta_b,hc,N,'r', Vtransform);
zu = rho2u_3d(zr);
zv = rho2v_3d(zr);
zw = zlevs(h,zeta,theta_s,theta_b,hc,N,'w', Vtransform);
dzr = zw(2:end,:,:)-zw(1:end-1,:,:);
dzu = rho2u_3d(dzr);
dzv = rho2v_3d(dzr);
%
%
% Vertical interpolation in case of clim file
%
%
%
%
% Vertical interpolation in case of bry files
%
%
if ~isempty(nc_bry)
    %
    %South
    %
    if obc(1) == 1
        [u_south,v_south,...
            ubar_south,vbar_south,...
            temp_south,salt_south]=vinterp_OGCM_myocean(zr(:,1,:),zu(:,1,:),zv(:,1,:),...
            dzr(:,1,:),dzu(:,1,:),dzv(:,1,:),...
            u_south,v_south,...
            ubar_south,vbar_south,...
            temp_south,salt_south,...
            N,Z,conserv);
    end
    
    if obc(2) == 1
        [u_east,v_east,...
            ubar_east,vbar_east,...
            temp_east,salt_east]=vinterp_OGCM_myocean(zr(:,:,end),zu(:,:,end),zv(:,:,end),...
            dzr(:,:,end),dzu(:,:,end),dzv(:,:,end),...
            u_east,v_east,...
            ubar_east,vbar_east,...
            temp_east,salt_east,...
            N,Z,conserv);
    end
    if obc(3) == 1
        [u_north,v_north,...
            ubar_north,vbar_north,...
            temp_north,salt_north]=vinterp_OGCM_myocean(zr(:,end,:),zu(:,end,:),zv(:,end,:),...
            dzr(:,end,:),dzu(:,end,:),dzv(:,end,:),...
            u_north,v_north,...
            ubar_north,vbar_north,...
            temp_north,salt_north,...
            N,Z,conserv);
    end
    if obc(4) == 1
        [u_west,v_west,...
            ubar_west,vbar_west,...
            temp_west,salt_west]=vinterp_OGCM_myocean(zr(:,:,1),zu(:,:,1),zv(:,:,1),...
            dzr(:,:,1),dzu(:,:,1),dzv(:,:,1),...
            u_west,v_west,...
            ubar_west,vbar_west,...
            temp_west,salt_west,...
            N,Z,conserv);
    end
end   %~isempty(nc_bry)
%--------------------------------------------------------------

%
%  fill the files
%
%
% Boundary file
%
if ~isempty(nc_bry)
    if obc(1) == 1
        nc_bry{'zeta_south'}(tout,:) = zeta_south;
        nc_bry{'temp_south'}(tout,:,:) = temp_south;
        nc_bry{'salt_south'}(tout,:,:) = salt_south;
        nc_bry{'u_south'}(tout,:,:) = u_south;
        nc_bry{'v_south'}(tout,:,:) = v_south;
        nc_bry{'ubar_south'}(tout,:,:) = ubar_south;
        nc_bry{'vbar_south'}(tout,:,:) = vbar_south;
    end
    if obc(2) == 1
        nc_bry{'zeta_east'}(tout,:) = zeta_east;
        nc_bry{'temp_east'}(tout,:,:) = temp_east;
        nc_bry{'salt_east'}(tout,:,:) = salt_east;
        nc_bry{'u_east'}(tout,:,:) = u_east;
        nc_bry{'v_east'}(tout,:,:) = v_east;
        nc_bry{'ubar_east'}(tout,:,:) = ubar_east;
        nc_bry{'vbar_east'}(tout,:,:) = vbar_east;
    end
    if obc(3) == 1
        nc_bry{'zeta_north'}(tout,:) = zeta_north;
        nc_bry{'temp_north'}(tout,:,:) = temp_north;
        nc_bry{'salt_north'}(tout,:,:) = salt_north;
        nc_bry{'u_north'}(tout,:,:) = u_north;
        nc_bry{'v_north'}(tout,:,:) = v_north;
        nc_bry{'ubar_north'}(tout,:,:) = ubar_north;
        nc_bry{'vbar_north'}(tout,:,:) = vbar_north;
    end
    if obc(4) == 1
        nc_bry{'zeta_west'}(tout,:) = zeta_west;
        nc_bry{'temp_west'}(tout,:,:) = temp_west;
        nc_bry{'salt_west'}(tout,:,:) = salt_west;
        nc_bry{'u_west'}(tout,:,:) = u_west;
        nc_bry{'v_west'}(tout,:,:) = v_west;
        nc_bry{'ubar_west'}(tout,:,:) = ubar_west;
        nc_bry{'vbar_west'}(tout,:,:) = vbar_west;
    end
end
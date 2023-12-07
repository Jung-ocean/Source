function data=ext_data_OGCM_HYCOM(nc,X,Y,vname,tndx,lon,lat,k,missvalue,Roa,interp_method,obc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extrapole one horizontal ECCO (or Data) slice on a ROMS grid
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
%  Contributions of P. Marchesiello (IRD) and J. Lefevre (IRD)
%
%  Updated    6-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% extrapolation parameters
%
default = 0;
if strcmp(vname,'SAVE') | strcmp(vname,'salt') | strcmp(vname,'SALT')
    default = 34.6;
end

% open boundaries (1 = open , [S E N W])
if obc(1) == 1
    lon_model = lon(1,:)
    lat_model = lat(1,:)
    
    
    
end
if obc(2) == 1
    lon_model = lon(:,end)
    lat_model = lat(:,end)
end
if obc(3) == 1
    lon_model = lon(end,:)
    lat_model = lat(end,:)
end
if obc(4) == 1
    lon_model = lon(:,1)
    lat_model = lat(:,1)
end











%
% Get the ROMS grid extension + a little margin (~ 2 data grid points)
%
dx = max(abs(gradient(X)));
dy = max(abs(gradient(Y)));
dl = 2*max([dx dy]);
%
lonmin = min(min(lon)) - dl;
lonmax = max(max(lon)) + dl;
latmin = min(min(lat)) - dl;
latmax = max(max(lat)) + dl;
%
% Extract a data subgrid
%
j = find(Y >= latmin & Y <= latmax);
i1 = find(X-360 >= lonmin & X-360 <= lonmax);
i2 = find(X >= lonmin & X <= lonmax);
i3 = find(X+360 >= lonmin & X+360 <= lonmax);
if ~isempty(i2)
    x = X(i2);
else
    x = [];
end
if ~isempty(i1)
    x = cat(2,X(i1)-360,x);
end
if ~isempty(i3)
    x = cat(2,x,X(i3)+360);
end
y = Y(j);

latind = find(Y(:,1) > latmin - 5);
lonind = find(X(1,:) < lonmax + 5);

X_sub = X(latind, lonind);
Y_sub = Y(latind, lonind);

%
%  Get dimensions
%
ndims = length(dim(nc{vname}));
%
% Get data (Horizontal 2D matrix)
%
if ~isempty(i2)
    if ndims == 2
        %data = squeeze(nc{vname}(j,i2));
        data = squeeze(nc{vname}(latind, lonind));
    elseif ndims == 3
        %data = squeeze(nc{vname}(k,j,i2)); % HYCOM
        data = squeeze(nc{vname}(k,latind, lonind)); % HYCOM
    elseif ndims==4
        %data = squeeze(nc{vname}(tndx,k,j,i2));
        data = squeeze(nc{vname}(tndx,k,latind, lonind));
    else
        error(['Bad dimension number ',num2str(ndims)])
    end
else
    data = [];
end

%==========================================================================
% if ~isempty(i1)
%     if ndims == 2
%         data = cat(2,squeeze(nc{vname}(j,i1)),data);
%     elseif ndims == 3
%         %     data=cat(2,squeeze(nc{vname}(tndx,j,i1)),data);
%         data = cat(2,squeeze(nc{vname}(k,j,i1)),data);  % HYCOM
%     elseif ndims == 4
%         data = cat(2,squeeze(nc{vname}(tndx,k,j,i1)),data);
%     else
%         error(['Bad dimension number ',num2str(ndims)])
%     end
% end
% if ~isempty(i3)
%     if ndims == 2
%         data = cat(2,data,squeeze(nc{vname}(j,i3)));
%     elseif ndims == 3
%         %     data=cat(2,data,squeeze(nc{vname}(tndx,j,i3)));
%         data = cat(2,data,squeeze(nc{vname}(k,j,i3)));  % HYCOM
%     elseif ndims == 4
%         data = cat(2,data,squeeze(nc{vname}(tndx,k,j,i3)));
%     else
%         error(['Bad dimension number ',num2str(ndims)])
%     end
% end
%==========================================================================

%
% Perform the extrapolation
%
%[data,interp_flag] = get_missing_val(x,y,data,missvalue,Roa,default);
[data,interp_flag] = get_missing_val(X_sub,Y_sub,data,missvalue,Roa,default);
%
% Interpolation on the ROMS grid
%

if interp_flag==0
    %data = interp2(x,y,data,lon,lat,'nearest');
    data = griddata(X_sub,Y_sub,data,lon,lat,'nearest'); % J
else
    %data = interp2(x,y,data,lon,lat,interp_method);
    data = griddata(X_sub,Y_sub,data,lon,lat,interp_method); % J
end
%
return
function [data,z,lon,lat,t] = roms_islice(file,var,time,iindex,grd)
% [data,z,lon,lat,t] = roms_islice(file,var,time,iindex,grd)
% Get a constant-i slice out of a ROMS history, averages or restart file
%
% $Id: roms_islice.m 443 2016-07-12 20:42:13Z robertson $
%
% Inputs
%    file = his or avg nc file
%    var = variable name
%    time = time index in nc file
%    iindex = i index of the required slice
%    grd (optional) is the structure of grid coordinates from roms_get_grid
%
% Outputs
%
%    data = the 2d slice at requested depth
%    z (2d) matrix of depths
%    lon,lat = horizontal coordinates along the slice
%    t = time in days for the data
%
% John Wilkin

% July 2016 (JLW) fixed bug in the padding/extrapolation to sea surface
%           added padding/extrapolation to sea floor

% get the data
data = nc_varget(file,var,[time-1 0 0 iindex-1],[1 -1 -1 1]);

% THIS STEP TO ACCOMMODATE NC_VARGET RETURNING A TIME LEVEL WITH
% LEADING SINGLETON DIMENSION - BEHAVIOR THAT DIFFERS BETWEEN JAVA AND
% MATLAB OPENDAP INTERFACES - 11 Dec, 2012
data = squeeze(data);

% this change (2013-05-23) to accommodate Forecast Model Run
% Collection (FMRC) which changes the time coordinate to be named
% "time" but leaves the attribute of the variable pointed to ocean_time
info = nc_vinfo(file,var);
time_variable = info.Dimensions(end).Name;
t = nc_varget(file,time_variable,time-1,1);

% determine where on the C-grid these values lie
varcoords = nc_attget(file,var,'coordinates');
if ~isempty(strfind(varcoords,'_u'))
  pos = 'u';
elseif ~isempty(strfind(varcoords,'_v'))
  pos = 'v';
elseif ~isempty(strfind(varcoords,'_rho'))
  pos = 'rho';
else
  error('Unable to parse the coordinates variables to know where the data fall on C-grid')
end

% check the grid information
if nargin<5 || (nargin==5 && isempty(grd))
  % no grd input given so try to get grd_file name from the file
  grd = roms_get_grid(file,file);
else
  if ischar(grd)
    grd = roms_get_grid(grd,file);
  else
    % input was a grd structure but check that it includes the z values
    if ~isfield(grd,'z_r')
      try
        grd = roms_get_grid(grd,file,0,1);
      catch
        error('grd does not contain z values');
      end
    end
  end
end

% get section depth coordinates
z_r = grd.z_r;
z_w = grd.z_w;
isw = false;

switch pos
  
  case 'u'
    % average z_r to Arakawa-C u points
    % this might be redundant if z u,v values are already in structure
    z = 0.5*(z_r(:,:,1:(end-1))+z_r(:,:,2:end));
    zw = 0.5*(z_w(:,:,1:(end-1))+z_w(:,:,2:end));
    x = grd.lon_u;
    y = grd.lat_u;
    mask = grd.mask_u;
    
  case 'v'
    % average z_r to Arakawa-C v points
    z = 0.5*(z_r(:,1:(end-1),:)+z_r(:,2:end,:));
    zw = 0.5*(z_w(:,1:(end-1),:)+z_w(:,2:end,:));
    x = grd.lon_v;
    y = grd.lat_v;
    mask = grd.mask_v;
    
  otherwise
    % for temp, salt, rho, w
    z = z_r;
    zw = z_w;
    x = grd.lon_rho;
    y = grd.lat_rho;
    mask = grd.mask_rho;
    if size(data,1) ~= size(z,1)
      % trap the var=='omega' case
      % but omega can be N or N+1 depending on whether a rst or his file
      z = grd.z_w;
      isw = true;
    end
    
end

% extract the j slices of the coordinates
z = z(:,:,iindex);

if ~isw
  % pad z to sea surface and seafloor for plotting
  z_surf = squeeze(zw(end,:,iindex));
  z_surf = z_surf(:)';
  z_bot = squeeze(zw(1,:,iindex));
  z_bot = z_bot(:)';
  z = [z_bot; z; z_surf];
  data = [data(1,:); squeeze(data); data(end,:)];
end

lon = repmat(x(:,iindex)',[size(z,1) 1]);
lat = repmat(y(:,iindex)',[size(z,1) 1]);

% land/sea mask
dry = mask==0;
mask(dry) = NaN;
mask = repmat(mask(:,iindex)',[size(z,1) 1]);

% remove singleton dimensions
z = squeeze(z);
data = mask.*squeeze(data);

function [data,x,y,t,grd] = roms_zslice(file,var,time,depth,grd)
% $Id: roms_zslice.m 446 2016-07-12 20:45:20Z robertson $
% Get a constant-z slice out of a ROMS history, averages or restart file
% [data,x,y] = roms_zslice(file,var,time,depth,grd)
%
% Inputs
%    file = his or avg nc file
%    var = variable name
%    time = time index in nc file, a datestr format string, or 'last'
%    depth = depth in metres of the required slice
%    grd (optional) is the structure of grid coordinates from roms_get_grid
%
% Outputs
%
%    data = the 2d slice at requested depth
%    x,y = horizontal coordinates
%    t = time in days for the data
%
% John Wilkin

% accommodate idiots who give positive z when it should be negative
depth = -abs(depth);

if ~nc_isvar(file,var)
  error([ 'No ' var ' in ' file])
end

% allow for time in datestr format
if ischar(time)
  fdnums = nj_time(file,var);
  if ~any(strcmp(time,{'end','last','latest'}))
    dnum = datenum(time);
    if dnum >= fdnums(1) && dnum <= fdnums(end)
      % date is in the file
      [~,time] = min(abs(dnum-fdnums));
      time = time(1); % in case request falls exactly between output times
    else
      % date string was not in the file
      disp(['Date ' time ' is not between the dates in the file:'])
      disp([datestr(fdnums(1),0) ' to ' datestr(fdnums(end),0)])
      return
    end
  else
    % date string was logically 'latest'
    time = length(fdnums);
  end
  t = fdnums(time);
else
  % get the time
  Iv = nc_vinfo(file,var);
  time_variable = Iv.Dimensions(end).Name;
  t = nc_varget(file,time_variable,time-1,1);
end

% check the grid 
if nargin<5 || (nargin==5 && isempty(grd))
  % no grd input given so try to get grd_file name from the history file
  grd_file = file;
  grd = roms_get_grid(grd_file,file);
else
  if ischar(grd)
    grd = roms_get_grid(grd,file);
  else
    % input was a grd structure but check that it includes the z values
    if ~isfield(grd,'z_r')
      error('grd does not contain z values');
    end
  end
end

% get the 3D chunk of data to be zsliced
data = nc_varget(file,var,[time-1 0 0 0],[1 -1 -1 -1]);

% THIS STEP TO ACCOMMODATE NC_VARGET RETURNING A TIME LEVEL WITH
% LEADING SINGLETON DIMENSION - BEHAVIOR THAT DIFFERS BETWEEN JAVA AND
% MATLAB OPENDAP INTERFACES - 11 Dec, 2012
data = squeeze(data);

% slice at requested depth
[data,x,y] = roms_zslice_var(data,1,depth,grd);

switch roms_cgridpos(size(data),grd)
  case 'u'
    mask = grd.mask_u;
  case 'v'
    mask = grd.mask_v;
  case 'psi'
    mask = grd.mask_psi;
  case 'rho'
    mask = grd.mask_rho;
end

% Apply mask to catch shallow water values where the z interpolation does
% not create NaNs in the data
if 1
  mask(mask==0) = NaN;
  data = data.*mask;
end

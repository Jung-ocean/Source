function [thedata,thegrid,han] = roms_sview(file,var,time,k,grd,vec_d,uscale,varargin)
% $Id: roms_sview.m 451 2016-08-23 14:07:25Z wilkin $
% [theData,theGrid,theHan] = roms_sview(file,var,time,k,grd,vec_d,uscale,varargin)
% 
% Inputs:
%
% file  = roms his/avg/rst/dia etc netcdf file
%         (Will also work for forcing files for most variables 
%          including vector wind or stress) 
%      or ctl structure from jgr_timectl
%
% var   = name of the ROMS output variable to plot
%         'ubarmag' or 'vbarmag' will plot velocity magnitude computed
%         from (ubar,vbar)
%
%         if isstruct(var) then
%            var.name is the variable name
%            var.cax  is the color axis range
%         if strcmp(var,'Chlorophyll') with a captial C
%            then chlorophyll data are log transformed before pcolor
%
% time  = time index into nc FILE
%      or string giving date/time (in DATESTR format) in which case the
%         function finds the closest time index to that time
%
% k     = index of vertical (s-coordinate) level of horizontal slice 
%       if k==0 any vector plot will be for ubar,vbar
%
% grd can be 
%       grd structure (from roms_get_grid)
%       grd_file name
%       [] will attempt to get grid from file
%
% vec_d = density (decimation factor) of velocity vectors to plot over 
%       if 0 no vectors are plotted
%
% uscale = vector length scale
%
% varargin are quiver arguments passed on to roms_quiver
%
% Outputs:
% 
% thedata = structure of pcolored data and velocities
% thegrid = roms grid structure
% han = structure of handles for pcolor, quiver and title objects
%
% John Wilkin

if nargin == 0
  error('Usage: roms_sview(file,var,time,k,grd,vec_d,uscale,varargin)');
end

if ~isstruct(file)
  % check only if input TIME is in datestr format, and if so find the 
  % time index in FILE that is the closest
  if ischar(time)      
    fdnums = roms_get_date(file,-1);
    if strcmp(time,'latest')
      time = length(fdnums);
    else
      dnum = datenum(time);
      if dnum >= fdnums(1) && dnum <= fdnums(end)
        [~,time] = min(abs(dnum-fdnums));
        time = time(1);
      else
        warning(' ')
        disp(['Requested date ' time ' is not between the dates in '])
        disp([file ' which are ' datestr(fdnums(1),0) ' to ' ])
        disp(datestr(fdnums(end),0))
        thedata = -1;
        return
      end
    end
  end
else
  % assume input FILE is actually ctl structure from e.g. jge_timctl
  % treat TIME as the index into the time variable in ctl
  % but allowing for TIME being in datestr format in which case the 
  % appropriate nearest time index is sought  
  [file,time] = roms_filetime_fromctl(file,time);
end

if nargin < 5
  grd = [];
end

% a sneaky little trick to allow me to send a caxis range through 
% the input - should really be done with attribute/value pairs
if isstruct(var)
  cax = var.cax;  
  var = var.name;
else 
  cax = 'auto';
end

varlabel = caps(strrep_(var));
if strcmp(varlabel,'Temp')
  varlabel = 'Temperature';
end

% another sneaky trick to force log transformation of chlorophyll
% ... give input varname with a capital C
log_chl = 0;
if strcmp(var,'Chlorophyll')
  log_chl = 1;
  var = 'chlorophyll';
end

% check that we don't have an empty netcdf file. If so, return an error
% code rather than crash - so this can be trapped within a loop over many
% files (all this to catch the case that sometimes an average file is
% created but not written because of a bad restart).
% try 
%   ocean_time = nc_varget(file,'ocean_time');
%   if length(ocean_time) == 0
%     warning(['ocean_time has no data ... exiting'])
%     thedata = -1;
%     return
%   end
% catch
%   try
%     tname = nc_attget(file,var,'time');
%     ocean_time = nc_varget(file,tname);
%   catch
%     thedata = -1;
%     warning(['No ocean_time variable in ' file])
%     return
%   end
% end

%% get the data

% figure out whether a 2-D or 3-D variable by testing the dimensions of the
% variable
switch var
  case {'ubarmag','vbarmag'}
    vartest = 'ubar';
  case 'stress'
    vartest = 'sustr';
  case 'bstress'
    vartest = 'bustr';
  case 'wind'
    vartest = 'Uwind';
  case 'umag'
    vartest = 'u';
  otherwise
    vartest = var;
end
Vi = ncinfo(file,vartest);
dimNames = {Vi.Dimensions.Name};
if any(strcmp(dimNames,'s_rho')) || any(strcmp(dimNames,'s_w'))
  START = [time-1 1 k-1  0  0]; % 2nd dim is for perfect restart files
  COUNT = [1      1 1   -1 -1];
  depstr = [ ' Level ' int2str(k) ' '];
else
  START = [time-1 1  0  0];
  COUNT = [1      1 -1 -1];
  depstr = ' depth average';
end
% perfect restart files have an added dimension named 'two'
if ~any(strcmp(dimNames,'two')) && ~any(strcmp(dimNames,'three'))
  START(2) = [];
  COUNT(2) = [];
end

switch var
  % two-dimensional variables
  % there must be a better way to do this test!
  case { 'ubarmag','vbarmag'}
    datau = squeeze(nc_varget(file,'ubar',START,COUNT));
    datau = datau(:,[1 1:end end]);
    datau = av2(datau')';
    datav = squeeze(nc_varget(file,'vbar',START,COUNT));
    datav = datav([1 1:end end],:);
    datav = av2(datav);
    data = abs(datau+sqrt(-1)*datav);
    depstr =  ' depth average ';
    % var = 'ubar'; % for time handling
  case 'stress'
    warning('option not debugged yet')
    datau = squeeze(nc_varget(file,'sustr',START,COUNT));
    datau = datau(:,[1 1:end end]);
    datau = av2(datau')';
    datav = squeeze(nc_varget(file,'svstr',START,COUNT));
    datav = datav([1 1:end end],:);
    datav = av2(datav);
    data = abs(datau+sqrt(-1)*datav);
    depstr =  ' at surface ';
    % var = 'sustr'; % for time handling
  case 'bstress'
    warning('option not debugged yet')
    datau = squeeze(nc_varget(file,'bustr',START,COUNT));
    datau = datau(:,[1 1:end end]);
    datau = av2(datau')';
    datav = squeeze(nc_varget(file,'bvstr',START,COUNT));
    datav = datav([1 1:end end],:);
    datav = av2(datav);
    data = abs(datau+sqrt(-1)*datav);
    depstr =  ' at bottom ';
    % var = 'bustr'; % for time handling
  case 'wind'
    datau = squeeze(nc_varget(file,'Uwind',START,COUNT));
    datav = squeeze(nc_varget(file,'Vwind',START,COUNT));
    data = abs(datau+sqrt(-1)*datav);
    depstr =  ' 10 m above surface ';
    % var = 'Uwind'; % for time handling
  case 'umag'
    datau = squeeze(nc_varget(file,'u',START,COUNT));   
    datau(isnan(datau)==1) = 0; 
    datau = datau(:,[1 1:end end]);
    datau = av2(datau')';   
    datav = squeeze(nc_varget(file,'v',START,COUNT));
    datav(isnan(datav)==1) = 0;
    datav = datav([1 1:end end],:);
    datav = av2(datav);
    data = abs(datau+sqrt(-1)*datav);
    depstr = [ ' Level ' int2str(k) ' '];
    % var = 'temp'; % for time handling
  otherwise
    data = squeeze(nc_varget(file,var,START,COUNT));
end

%% get the appropriate land/sea or wet/dry mask
usewetdry = nc_isvar(file,'wetdry_mask_rho');
if usewetdry % wet dry mask exists in file
  try % override with preference
    usewetdry = getpref('ROMS_WILKIN','USE_WETDRY_MASK');
  catch % no preference - assume not
    usewetdry = false;
  end
end
pos = roms_cgridpos(data,grd);
ma = ['mask_' pos];
lo = ['lon_' pos];
la = ['lat_' pos];
if usewetdry
  mask = squeeze(nc_varget(file,['wetdry_' ma],[time-1 0 0],[1 -1 -1]));
else
  mask = grd.(ma);
end
x = grd.(lo);
y = grd.(la);
mask(mask==0) = NaN;

%%
if log_chl
  data = max(0.01,data);
  data = (log10(data)+1.4)/0.012;
  ct = [0.01 .03 .1 .3 1 3 10 30 66.8834];
  logct = (log10(ct)+1.4)/0.012;
  cax = range(logct);
end

%% special handling for some grids to blank out regions
if isfield(grd,'special')
  if iscell(grd.special)
    % potentially several special options
    vlist = grd.special;
  else
    % single option but copy to cell for handling below
    vlist{1} = grd.special;
  end
  for k=1:length(vlist)
    opt = char(vlist{k});
    switch char(opt)
      case 'jormask'
        %           for opt = vlist
        %     opt = char
        %     switch char(opt)
        %       case 'jormask'
        % apply Jay O'Reilly's mask to trim the plotted nena data
        xpoly = [-82 -79.9422 -55.3695 -55.3695 -82];
        ypoly = [24.6475 24.6475 44.0970 46 46];
        ind = inside(x,y,xpoly,ypoly);
        mask(ind==0) = NaN;
      case 'nestedge'
        xpoly = vlist{k+1}(:,1);
        ypoly = vlist{k+1}(:,2);
        ind = inside(x,y,xpoly,ypoly);
        mask(ind==1) = NaN;
        break
      case 'logdata'
        % this would be a better place to log transform data before
        % plotting
    end
  end
end

%% make the plot
hanpc = pcolorjw(x,y,data.*mask);
caxis(cax);
hancb = colorbar;

%%
if log_chl
  set(hancb,'ytick',logct(1:end-1),'yticklabel',ct)
  set(get(hancb,'xlabel'),'string','mg m^{-3}')
end

%% add vectors
if nargin > 5
  if vec_d
    
    % nc = netcdf(file);
    % add vectors
    % ! sorry, this doesn't allow for {u,v}bar vectors on a 3d variable
    if k>0
      u = nc_varget(file,'u',START,COUNT);
      v = nc_varget(file,'v',START,COUNT);
      depstr = [depstr ' Vectors at level ' int2str(k) ' '];
    else
      u = nc_varget(file,'ubar',START,COUNT);
      v = nc_varget(file,'vbar',START,COUNT);
      % a forcing file won't have u,v ...
      if isempty(u)
        u = nc_varget(file,'sustr',START,COUNT);
        v = nc_varget(file,'svstr',START,COUNT);
        depstr = [depstr ' Wind stress vectors '];
      else
        depstr = [depstr ' Depth average velocity vectors '];
      end
    end
    if nargin < 7
      uscale = 1;
    end
    u = squeeze(u);
    v = squeeze(v);
    u(isnan(u)==1) = 0;
    v(isnan(v)==1) = 0;
    hanquiver = roms_quivergrd(u,v,grd,vec_d,uscale,varargin{:});
  end
end

%% change plotaspectratio to be approximately Mercator
% if you don't like this, add variable nolatlon (=1) to the grd structure
% to disable this
if isfield(grd,'nolatlon')
  if grd.nolatlon ~= 1
    set(gca,'DataAspectRatio',[1 cos(mean(ylim)*pi/180) 1]);
  end
else
    set(gca,'DataAspectRatio',[1 cos(mean(ylim)*pi/180) 1]);
end

%% my trick to plot a coast if it knows how to do this from the grd_file
% name
try
  if strfind('leeuwin',grd.grd_file)
    gebco_eez(0,'k')
  elseif strfind('eauc',grd.grd_file)
    plotnzb
  elseif strfind('nena',grd.grd_file)
    plotnenacoast(3,'k') 
  elseif strfind('sw06',grd.grd_file)
    plotnenacoast(3,'k')
  end
catch
end

% get the time/date
[t,tdate] = roms_get_date(file,time,0);

% label
titlestr{1} = ['file: ' strrep_(file)];
titlestr{2} = [varlabel ' ' tdate ' ' depstr];
hantitle = title(titlestr);

% pass data to outputs
if nargout > 0
  thedata.x = x;
  thedata.y = y;
  thedata.data = data;
  thedata.t = t;
  thedata.tstr = tdate;
  thedata.tindex = time;
  if nargin > 5
    if vec_d
      thedata.u = u;
      thedata.v = v;
    end
  end
end
if nargout > 1
  thegrid = grd;
end
if nargout > 2
  han.title = hantitle;
  han.pcolor = hanpc;
  han.colorbar = hancb;
  if exist('hanquiver','var')
    han.quiver = hanquiver;
  end
end

function str = caps(str)
str = lower(str);
str(1) = upper(str(1));

function s = strrep_(s)
s = strrep(s,'\','\\');
s = strrep(s,'_','\_');
s = strrep(s,'^','\^');

function a = av2(a)
%AV2	grid average function.  
%       If A is a vector [a(1) a(2) ... a(n)], then AV2(A) returns a 
%	vector of averaged values:
%	[ ... 0.5(a(i+1)+a(i)) ... ]  
%
%       If A is a matrix, the averages are calculated down each column:
%	AV2(A) = 0.5*(A(2:m,:) + A(1:m-1,:))
%
%	TMPX = AV2(A)   will be the averaged A in the column direction
%	TMPY = AV2(A')' will be the averaged A in the row direction
%
%	John Wilkin 21/12/93
[m,n] = size(a);
if m == 1
	a = 0.5 * (a(2:n) + a(1:n-1));
else
	a = 0.5 * (a(2:m,:) + a(1:m-1,:));
end

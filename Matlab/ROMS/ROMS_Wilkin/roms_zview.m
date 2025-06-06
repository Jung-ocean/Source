function [thedata,thegrid,han] = roms_zview(file,var,time,depth,grd,vec_d,uscale,varargin)
% [Data,Grid,Han] = roms_zview(file,var,time,depth,grd,vec_d,uscale,varargin)
% Plot a constant-z slice out of a ROMS history, averages or restart file
%
% $Id: roms_zview.m 451 2016-08-23 14:07:25Z wilkin $
%
% Inputs:
%
% file  = roms his/avg/rst/dia etc netcdf file
%
% var   = name of the ROMS output variable to plot
%         or 'umag' for velocity magnitude computed from u,v
%
%         if isstruct(var) then
%            var.name is the variable name
%            var.cax  is the color axis range
%         if strcmp(var,'Chlorophyll')
%            then chlorophyll data are log transformed before pcolor
%
% time  = time index into nc FILE
%      or date/time string (in DATESTR format 0) 'dd-mmm-yyyy HH:MM:SS'
%      in which case the function finds the closest time index to that time
%
% depth = z depth of horizontal slice (m)
%       if depth==0 any vector plot will be for ubar,vbar
%
% grd can be
%       grd structure, output from roms_get_grid << RECOMMENDED
%       grd_file name
%       [] will attempt to get grid from the first input (file)
%
%     RECOMMENDED best practise is to load grd structure from the actual
%     output file you are using. This guarantees you get the correct
%     coordinates: grd = roms_get_grid(file,file)
%       See the help on roms_get_grid to understand about using zeta for 
%     to enable calculating time-varying vertical coordinates if this is 
%     important to you in plotting
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
% Data = structure of pcolored data and velocities
% Grid = roms grid structure
% Han = structure of handles for pcolor, quiver and title objects
%
% John Wilkin

if nargin == 0
  help roms_zview
  return
end

if isstruct(file)
  error('roms_timectl structure from rnt tools not supported')
  % [file,time] = roms_filetime_fromctl(file,time);
end
  
% check if input TIME is in datestr format, and if so find the
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

if nargin < 5
  grd = [];
end

% sneaky trick to send a preset caxis range through the input - should 
% really be done with attribute/value pairs.
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

% sneaky trick to force log transformation of chlorophyll
% ... give input varname with a capital C
log_chl = 0;
if strcmp(var,'Chlorophyll')
  log_chl = 1;
  var = 'chlorophyll';
end

% pcolor plot of the variable
switch var
  case { 'ubar','vbar','zeta','Hsbl','h','f','pm','pn',...
      'swrad','SST','dQdSST','shflux','swflux','SSS',...
      'sustr','svstr','Uwind','Vwind','Tair','Pair',...
      'sensible','latent'}
    [data,x,y,t,grd] = roms_2dslice(file,var,time,grd);
    depstr = [];
  case 'umag'
    [datau,x,t,t,grd] = roms_zslice(file,'u',time,depth,grd);
    datav = roms_zslice(file,'v',time,depth,grd);
    % average to rho points
    datau(isnan(datau)==1) = 0;
    datav(isnan(datav)==1) = 0;    
    datau = datau(:,[1 1:end end]);
    datau = av2(datau')';
    datav = datav([1 1:end end],:);
    datav = av2(datav);
    data = abs(datau+sqrt(-1)*datav);
    var = 'temp'; % for mask and time handling
    x = grd.lon_rho;
    y = grd.lat_rho;
    [datau,x,y,t,grd] = roms_zslice(file,var,time,depth,grd);
    depstr = [' - Vectors at depth ' num2str(abs(depth)) ' m '];
  otherwise
    [data,x,y,t,grd] = roms_zslice(file,var,time,depth,grd);
    depstr = [' - Depth ' num2str(abs(depth)) ' m '];
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

% switch var
%   case { 'u','ubar','sustr'}
%     mask = grd.mask_u;
%   case { 'v','vbar','svstr'}
%     mask = grd.mask_v;
%   otherwise
%     mask = grd.mask_rho_nan;
% end
% mask(mask==0) = NaN;
% 
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

% ********************************************************************
% make the actual pcolor plot
hanpc = pcolorjw(x,y,data.*mask);

caxis(cax);
hancb = colorbar;

if log_chl
  set(hancb,'ytick',logct(1:end-1),'yticklabel',ct)
  set(get(hancb,'xlabel'),'string','mg m^{-3}')
end

if nargin > 5
  if vec_d
    % add vectors
    % ! sorry, this doesn't allow for {u,v}bar vectors on a 3d variable
    if depth
      u = roms_zslice(file,'u',time,depth,grd);
      v = roms_zslice(file,'v',time,depth,grd);
      if isempty(depstr)
        depstr = [' - Vectors at depth ' num2str(abs(depth)) ' m '];
      end
    else
      try
        % a forcing file won't have u,v ...
        u = roms_2dslice(file,'ubar',time,grd);
        v = roms_2dslice(file,'vbar',time,grd);
      catch
        % ... failing that look for wind stress
        % (should make this more general to allow for plotting
        % wind at 10m, but that would be on rho-points no u,v-points
        % so some extra checking is required -- maybe try to use
        % roms_addvect or roms_sview instead ... something for later)
        u = roms_2dslice(file,'sustr',time,grd);
        v = roms_2dslice(file,'svstr',time,grd);
        depstr = ' - Wind stress vectors ';
      end
      if isempty(depstr)
        depstr = ' - Vectors for depth-average velocity ';
      end
    end
    if nargin < 7
      uscale = 1;
    end
    u(isnan(u)==1) = 0;
    v(isnan(v)==1) = 0;
    [hanquiver,dataq] = roms_quivergrd(u,v,grd,vec_d,uscale,varargin{:});
  end
end

% change plotaspectratio to be approximately Mercator
% if you don't like this, add variable nolatlon (=1) to the grd structure
% to disable this
if isfield(grd,'nolatlon')
  if grd.nolatlon ~= 1
    set(gca,'DataAspectRatio',[1 cos(mean(ylim)*pi/180) 1]);
  end
else
  set(gca,'DataAspectRatio',[1 cos(mean(ylim)*pi/180) 1]);
end

% my trick to plot a coast if it knows how to do this from the grd_file
% name
try
  if strfind(grd.grd_file,'leeuwin')
    gebco_eez(0,'k')
  elseif strfind(grd.grd_file,'eauc')
    plotnzb
  elseif strfind(grd.grd_file,'nena')
    plotnenacoast(3,'k')
  elseif strfind(grd.grd_file,'sw06')
    plotnenacoast(3,'k')
  end
catch
end

% get the time/date
[t,tdate] = roms_get_date(file,time,0);

% label
titlestr{1} = char(['file: ' strrep_(file)]);
titlestr{2} = [varlabel ' ' tdate ' ' depstr];
hantitle = title(titlestr);

% pass data to outputs
if nargout > 0
  thedata.x = x;
  thedata.y = y;
  thedata.data = data;
  thedata.t = t;
  thedata.tstr = tdate;
  if nargin > 5
    if vec_d
      thedata.u = u;
      thedata.v = v;
    end
  end
  if exist('dataq','var')==1
    thedata.ue = dataq.ue;
    thedata.vn = dataq.vn;
    thedata.xq = dataq.x;
    thedata.yq = dataq.y;
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

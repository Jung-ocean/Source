% This script will create a river runoff FORCING NetCDF file.
%
% Paul Goodman's modification of useast_rivers.m (J. Wilkin)
% BJ Choi's modification AUG 2, 2004.

%add_ocean_toolboxes;

IWRITE=1;
IPLOT=1;

%-----------------------------------------------------------------------
% specify the input files
%-----------------------------------------------------------------------

% roms grid
% grd_file ='E:\Working\roms\1_4\input\grid_test\no_smoding\roms_grd_1_4.nc';
grd_file ='D:\matlab\roms\input\roms_grd_yw_5m_square.nc';
N = 20; % Number of vertical levels

% the new netcdf forcing file - river data will be appended
%Fname = 'E:\Working\roms\1_4\input\ecco\roms_eas4_river.nc';
Fname = 'roms_river.nc';

% load the river flow data structure
Rname = 'eas_rivers_discharge';
load(Rname)
if ~exist('River')
  error([ 'Structure ''River'' does not exist in ' Rname])
end

% get the roms grid
% we need this to find the grid indices corresponding to the lon/lat
% locations of the dat
grd = roms_get_grid(grd_file);

%-----------------------------------------------------------------------
%  Set river name, location, and runoff direction.
%-----------------------------------------------------------------------
%
%  Notice that for now the river identification number is that of the
%  river count.  This variable is needed to fool ROMS generic IO
%  interphase; it can be any real number since will never used.
%
%  River.lon  = nominal longitude of river mouth (this routine finds i,j)
%  River.lat  = nominal latitude of river mouth (this routine finds i,j)
%
%  River.dir  = 0 for flow entering cell through u-direction face
%             = 1 for flow entering cell through v-direction face
%
%  River.Xpos,Ypos = the i,j index of the u-point or v-point location on 
%             the ROMS C-grid thyat defines the face of the cell through
%             which the river enters. 
%             The river input is added to the appropriate ubar, vbar, u, 
%             v, and tracer fluxes on this face.
%
%  River.sens = 1 for river flow in the positive u or v direction
%             = -1 for river flow in the negative u or v direction, 
%             This factor multiplies the river flow rate Q (>0) (see
%             sources.h for why this is done)
%
%  River.flag can have any of the following values:
%             = 0,  All Tracer source/sink are off.
%             = 1,  Only temperature is on.
%             = 2,  Only salinity is on.
%             = 3,  Both temperature and salinity are on. 
%
%  This is documented further in ROMS sources.h

Nrivers = length(River.lon);

%-----------------------------------------------------------------------
% Find the ij coordinates of the river lat/lon points
%-----------------------------------------------------------------------

for r = 1:Nrivers
  
  River.num(r) = r;

  % The logic below checks whether the u-face or v-face is the better 
  % approximation to the nominal location of the river mouth, and assigns 
  % River.dir accordingly. 
  % The sign of diff(rhomask) is used to determine whether the flow 
  % enters from the NSEW

  % case flow enters cell through u-direction face
  glon = grd.lon_u;
  glat = grd.lat_u;
  % keep only u-faces that are coastline
  drhomask = diff(grd.mask_rho')';
  notcoast = find(drhomask==0);
  glon(notcoast) = NaN;
  glat(notcoast) = NaN;
  % find the u-face closest to the river mouth
  [J,I,du] = closest(glon,glat,River.lon(r),River.lat(r));

  % assume this is best option until we test v-face
  River.Xpos(r) = I;
  River.Ypos(r) = J-1; % ROMS u points start from index j=0
  River.dir(r)  = 0;
  River.sens(r) = drhomask(J,I);
  River.glon(r) = glon(J,I);
  River.glat(r) = glat(J,I);

  % case flow enters cell through v-direction face
  glon = grd.lon_v;
  glat = grd.lat_v;
  % keep only v-faces that are coastline
  drhomask = diff(grd.mask_rho);
  notcoast = find(drhomask==0);
  glon(notcoast) = NaN;
  glat(notcoast) = NaN;
  % find the v-face closest to the river mouth
  [J,I,dv] = closest(glon,glat,River.lon(r),River.lat(r));
  
  if dv < du 
    % overwrite because v-face result is closer to river mouth
    River.Xpos(r) = I-1; % ROMS v points start from index i=0
    River.Ypos(r) = J;   
    River.dir(r)  = 1;
    River.sens(r) = drhomask(J,I);
    River.glon(r) = glon(J,I);
    River.glat(r) = glat(J,I);
  end
 
end

if IPLOT
  clf
  % plot the original and selected lon/lat to check that the lookup was done 
  % sensibly
  pcolorjw(grd.lon_rho,grd.lat_rho,grd.mask_rho_nan)
% amerc;
  % shading faceted
% plotnenacoast(2)
  hold on
  han = plot(River.lon,River.lat,'r^');
  set(han,'markersize',10,'MarkerFaceColor',get(han,'color'))
  han = plot(River.glon,River.glat,'bd');
  set(han,'markersize',10,'MarkerFaceColor',get(han,'color'))
  han = plot([River.lon; River.glon],[River.lat; River.glat],'r-');
  set(han,'linewidth',2)
  for r=1:length(River.lon)
    han = text(River.lon(r),River.lat(r),...
	[ ' (' int2str(r) ') ' deblank(River.Name(r,:))]);
    set(han,'fontsize',12)
  end  
  hold off
end

for r=1:Nrivers  
  River.vshape(r,1:N)=1/N;
  River.trans(r,:) = River.sens(r)*River.trans(r,:);
end

  detailstr = ['The ' int2str(Nrivers) ' Rivers are : '];
for r=1:Nrivers;  
  detailstr = [detailstr int2str(r) '. ' strcat(River.Name(r,:)) ', '];
end
  detailstr = [detailstr(1:end-2) '.'];
  

%  River.time is evenly spaced through the year of 365.25 days
cycle=365.25;
River.time = [1/24:1/12:23/24]*365.25;
% cycle=360.;
% River.time = [15:30:345];
River.time_units = 'days';


% temp/salt get used, or not, according to the value of River.flag 
salt = 0;
%temp = 0;
temp_max=20;
temp_min=3;
amp=(temp_max-temp_min)/2;
factor=2*pi/12;
for i=1:length(River.time)
temp(i)=amp*( sin(factor*(i-5)) + 1 )+temp_min;
end


for i=1:length(River.time)
 % River.temp(:,:,i)=ones([Nrivers N]).*temp(i);
  River.salt(:,:,i)=ones([Nrivers N]).*salt;
end

%keyboard
%River.salt(41,:,:) = 28.9;

%-----------------------------------------------------------------------
%  Create empty river data FORCING NetCDF file.
%-----------------------------------------------------------------------

  disp([ 'Creating ' Fname '...'])

      create_empty_EAS_rivers

%-----------------------------------------------------------------------
%  Write river data into existing FORCING NetCDF file.
%-----------------------------------------------------------------------

  disp([ 'Appending rivers data to ' Fname '...'])
%  disp('paused...');pause
%  [Vname,status]=wrt_rivers(Fname,River);

%     write_rivers
     
     nc = netcdf(Fname,'write');
     
theVarname = 'river';
nc{theVarname}(:) = River.num;

theVarname = 'river_Xposition';
nc{theVarname}(:) = River.Xpos;

theVarname = 'river_Eposition';
nc{theVarname}(:) = River.Ypos;

theVarname = 'river_direction';
nc{theVarname}(:) = River.dir;

theVarname = 'river_flag';
nc{theVarname}(:) = River.flag;

theVarname = 'river_Vshape';
nc{theVarname}(:,:) = River.vshape;

theVarname = 'river_time';
nc{theVarname}(:) = River.time;

theVarname = 'river_transport';
nc{theVarname}(:,:) = River.trans';

%theVarname = 'river_temp';
%nc{theVarname}(:,:,:) = permute(River.temp,[3 2 1]);

theVarname = 'river_salt';
nc{theVarname}(:,:,:) = permute(River.salt,[3 2 1]);

result = close(nc);  
     
     

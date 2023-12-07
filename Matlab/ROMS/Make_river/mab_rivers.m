% This script adds river runoff data to an existing FORCING NetCDF file.
%
% John Wilkin's modification of njb_rivers.m (H. Arango)

IWRITE=0;

%-----------------------------------------------------------------------
% specify the input files
%-----------------------------------------------------------------------

% roms grid
grd_file = '/home/wilkin/roms/nena/in/roms_nena_grid_4.nc';
N = 30; % Number of vertical levels

% the existing netcdf forcing file - river data will be appended
Fname = '/home/wilkin/roms/nena/in/NENA_frc93_3b.nc'; % NCEP 3-daily (Levin)

% the river flow data file
Rname= 'mab_rivers_test.dat';

%-----------------------------------------------------------------------
% get the roms grid
% we need this to find the grid indices corresponding to the lon/lat
% locations of the dat
%-----------------------------------------------------------------------

grd = roms_get_grid(grd_file);

%-----------------------------------------------------------------------
%  Set out river name, location, and runoff direction.
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

r = 1;
Name = 'Delaware-Schuylkill';
River.Name(r,1:length(Name)) = Name;
River.lon(r) = -75.5236;
River.lat(r) = 39.4288;
River.flag(r) = 2;

r = 2;
Name = 'Hudson';
River.Name(r,1:length(Name)) = Name;
River.lon(r) = -74.0514;
River.lat(r) = 40.6508;
River.flag(r) = 2;

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

  % case flow enters cell through v-direction face
  glon = grd.lon_v;
  glat = grd.lat_v;
  % keep only v-faces that are coastline
  drhomask = diff(grd.mask_rho);
  notcoast = find(drhomask==0);
  glon(notcoast) = NaN;
  glat(notcoast) = NaN;
  % find the u-face closest to the river mouth
  [J,I,dv] = closest(glon,glat,River.lon(r),River.lat(r));
  
  if dv < du 
    % overwrite because v-face result is closer to river mouth
    River.Xpos(r) = I-1; % ROMS v points start from index i=0
    River.Ypos(r) = J;   
    River.dir(r)  = 1;
    River.sens(r) = drhomask(J,I);
  end
 
end


%-----------------------------------------------------------------------
%  Read in river data.
%-----------------------------------------------------------------------

Rdat = load(Rname);

scale = 0.3048^3; % ft^3/s to m^3/s


River.Qmean(1) = scale*mean(Rdat(:,4));  % Delaware and Schuylkill
River.Qmean(2) = scale*mean(Rdat(:,7));  % Hudson

Year  = [1992 1993 1994 2000];
Month = [1    1    1    1];
Day   = [1    1    1    1];



%-----------------------------------------------------------------------
%  Fill river data into structure array.
%-----------------------------------------------------------------------
%
%  The nondimensional river mass transport vertical shape profile MUST
%  add to UNITY, sum(River.vshape(i,:))=1.

% River.time=julian(Year,Month,Day,12.0)-2440000;

% Reference date for NENA (and NATL) simulation is 01-Jan-1992
base_date = [1992 1 1 0 0 0];
River.time = julian(Year,Month,Day)-julian(base_date);
River.time_units = basedate2str(base_date);
Nrec = length(River.time);

for r=1:Nrivers
  
  % put transport time series in a vector
  River.trans(r,:) = River.Qmean(r)*ones(size(River.time));
  River.vshape(r,1:N)=1/N;

end

salt = 0;
temp = 0;

for i=1:Nrec
  River.temp(:,:,i)=ones([Nrivers N]).*temp;
  River.salt(:,:,i)=ones([Nrivers N]).*salt;
end

%-----------------------------------------------------------------------
%  Write river data into existing FORCING NetCDF file.
%-----------------------------------------------------------------------


disp([ 'Appending rivers data to ' Fname '...'])
if (IWRITE)
  [Vname,status]=wrt_rivers(Fname,River);
end

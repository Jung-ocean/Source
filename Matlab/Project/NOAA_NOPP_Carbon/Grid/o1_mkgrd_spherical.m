% AK, 05/26/2010
% make a new roms grid, rectangular domain
% SD I am modifying this to make the domain rectangular in cartesian space
% such that it's a pure rectangular grid in x-y.
% JJ, 04/10/2026
% I am modifying this to make the Oregon coast domain
clear all;

grid_file='./grid_Oregon_1km_1.nc';

%=== USER INPUTS: ===============
define_dx1_yes=1; 

if define_dx1_yes
 % - define nominal resolution in km (same in both directions)
 dx1 = 1; % nominal resolution in km
%else 
 % - define dlon, dlat:
% dlon = 7.75e-02 ;
% dlat = 4.1299999e-02 ; 
end

% SD Specify the longitude and latitude limits, 
% the longitude limit is just an approximation
% Given the latitude along the lower domain boundary
% the longitudes will be calculated out from the center point in lon.
lon_lim=[-126.5 -123.5];
lat_lim=[42 48];

% Calculate the distance between the two chosen longitudes along the lower
% latitude on an earth ellipsoid to determine how many grid points there
% will be in i-('earth', 'ellipsoid', 'km')
lowlat_londist = departure(lon_lim(1), lon_lim(2), lat_lim(1), referenceSphere('earth', 'km'));

% Actually this function above gives us the relationship between angle and
% distance in meters at any latitude on an earth ellipsoid.
% So we can use this function to determine dkm/dlat at each latitude of our
% rho grid and thus determine the full cartesian grid.
hilat_londist = departure(lon_lim(1), lon_lim(2), lat_lim(2), referenceSphere('earth', 'km'));
midlat_londist = departure(lon_lim(1), lon_lim(2), 0.5.*(lat_lim(1)+lat_lim(2)), referenceSphere('earth', 'km'));

% Let's set the resolution to 2km at our midlatitude, with higher resolution t the north and lower resolution to the south. 
% determine a center longitude.
% Adjust the lon limits so that an even number of grid points fit between
% the endpoints.
Lp=fix(midlat_londist./dx1)+1;
%lowlat_londist=(fix(lowlat_londist./dx1)+1).*dx1

lon_cent=lon_lim(1)+0.5*(lon_lim(2)-lon_lim(1));

% set the center longitude as the x=0 location and find grid points at 2 km
% intervals northward until the northern limit latitude is exceeded.
last_lat=lat_lim(1);
ltp(1)=lat_lim(1);
lat_dist=meridianarc(lat_lim(1)*pi./180,lat_lim(2)*pi./180, referenceSphere('earth','km'));
Mp=fix(lat_dist./dx1)+1
lat_dist=(fix(lat_dist./dx1)+1).*dx1;
lat_lim(2)=meridianfwd(lat_lim(1)*pi./180,lat_dist,referenceSphere('earth','km'))*180/pi;
arc_dist(1)=departure(0, 1, lat_lim(1), referenceSphere('earth','km'));
yp(1)=0.0;

for ij=2:Mp
  ltp(ij)=meridianfwd(ltp(ij-1)/180*pi,dx1,referenceSphere('earth','km'))*180/pi;
  arc_dist(ij)=departure(0,1,ltp(ij),referenceSphere('earth','km'));
  yp(ij)=yp(ij-1)+dx1*1000;
end

%given the arc_dist at the center latitude and the total angular distance
%between endpoints determine the number of grid points in the i-direction
%Lp=fix((lon_lim(2)-lon_lim(1))*arc_dist(1)./dx1)+1;
cent_arc_dist = mean(arc_dist(479:480));
Lp=fix((lon_lim(2)-lon_lim(1))*cent_arc_dist(1)./dx1)+1;

% For each latitude determine the relationship between angle and metric arc
% distance.   
% If there are an odd number of points, center lon is a p point,
% otherwise it is half way between p- points.
if (mod(Lp,2))
    xp =(-(Lp-1)*dx1./2:dx1:(Lp-1)*dx1./2)*1000;
    Lpp=Lp
    lnp=lon_lim(1):(lon_lim(2)-lon_lim(1))./(Lp-1):lon_lim(2);
else
    xp =(-(Lp)*dx1./2+0.5*dx1:dx1:(Lp)*dx1./2+0.5*dx1)*1000;
    Lpp=Lp+1
    lnp=lon_lim(1):(lon_lim(2)-lon_lim(1))./(Lp):lon_lim(2);
end

% calculate the longitudes of all the rho points.
% Now we are making a 'spherical' grid. That is lat and lon intervals are
% constant such that the grid boxes are orthogonal on the surface of a
% sphere.
for ij=1:length(ltp)
%    lnpa(:,ij)=xp./1000./arc_dist(ij)+lon_cent;
     ltpa(:,ij)=ones([Lpp 1])*ltp(ij);
end
for ii=1:Lp
    lnpa(ii,:)=ones([1 length(ltp)])*lnp(ii);
end

% Make a quick figure to look at the grid overlaid on the coastlines.
gshhsFolder='/data/jungjih/Coastline/GSHHS_shp/l/';

% shapepathE = fullfile(gshhsFolder,'wdb_f_Ru_coast');
% shapepathW = fullfile(gshhsFolder,'wdb_f_AK_coast');
shapepath = fullfile(gshhsFolder,['GSHHS_l_L1']);

% east_coast=shaperead(shapepathE,'UseGeoCoords',true);
% west_coast=shaperead(shapepathW,'UseGeoCoords',true);
coastline=shaperead(shapepath,'UseGeoCoords',true);

figure(1)
clf
axesm('Mercator', 'MapLatlimit',[lat_lim(1) lat_lim(2)],'MapLonLim',[lon_lim(1) lon_lim(2)]);
% geoshow(east_coast,'FaceColor',[0.6 0.6 0.6]);
% geoshow(west_coast,'FaceColor',[0.6 0.6 0.6]);
geoshow(coastline,'FaceColor',[0.6 0.6 0.6]);

% hlpm=linem(ltpa(1:20:end,1:20:end),lnpa(1:20:end,1:20:end));
% set(hlpm,'LineStyle','none','Marker','o','Color','b');

xlim=[min(min(lnpa)) max(max(lnpa))];
ylim=[min(min(ltpa)) max(max(ltpa))];

%%
%xlim=[141.5 151.5];
%ylim=[-45 -37];
%outfile='/home/jaguar/kurapov/Tas_2010/Prm/grd_tas_00.nc';

%xlim=[-134 -120.5];
%ylim=[34.6 50];
%outfile='/home/europe/data2/kurapov/OR_2km/Prm/grd_or2km_00.nc';

%roms_grd_cdl='/home/jaguar/sdurski/ROMS/Data/ROMS/Grid/Bering_Sea/tmp_roms_grid.cdl';

%routine for reading bathym at lon_rho,lat_rho:
% calling: h=bath_routine_name(lon_rho+lon_offset,lat_rho,xlim+lon_offset,ylim);
%bath_routine='read_aleut_bath'; % OR2km: 'read_or_etopo_bath';

lon_offset=0;

plot_pnts_yes=0;

%=== END USER INPUTS ============

% -- Length of the domain, Lx & Ly (km) (for plotting)
%Rearth=6400;
%Lx=Rearth*cos(pi*mean(ylim)/180).*diff(xlim)*pi/180;
%Ly=Rearth*diff(ylim)*pi/180;

% -- Coordinate arrays
Rearth = earthRadius('km');

if define_dx1_yes
 dlon=dx1/(Rearth*cos(pi*mean(ylim)/180))*180/pi;
 dlat=dx1/(Rearth)*180/pi;
end

% psi coordinates, 2 cells added in each dir, 
% compared to final roms psi grid
lon=[xlim(1)-dlon:dlon:xlim(2)+dlon];
lat=[ylim(1)-dlat:dlat:ylim(2)+dlat];
[lat,lon]=meshgrid(lat,lon);

% % SD my lnpa and ltpa are lon and lat below
% lon=lnpa;
% lat=ltpa;

% rho coordinates (extended, 2 extra rows of cells on each side)
lon_rho=0.25*(lon(1:end-1,1:end-1)+...
              lon(1:end-1,2:end  )+...
              lon(2:end  ,2:end  )+...
              lon(2:end  ,1:end-1));
lat_rho=0.25*(lat(1:end-1,1:end-1)+...
              lat(1:end-1,2:end  )+...
              lat(2:end  ,2:end  )+...
              lat(2:end  ,1:end-1));
lon_u=0.5*(lon_rho(1:end-1,:)+lon_rho(2:end,:));
lat_u=0.5*(lat_rho(1:end-1,:)+lat_rho(2:end,:));

lon_v=0.5*(lon_rho(:,1:end-1)+lon_rho(:,2:end));
lat_v=0.5*(lat_rho(:,1:end-1)+lat_rho(:,2:end));

lon_psi=0.25*(lon_rho(1:end-1,1:end-1)+...
              lon_rho(1:end-1,2:end  )+...
              lon_rho(2:end  ,2:end  )+...
              lon_rho(2:end  ,1:end-1));
lat_psi=0.25*(lat_rho(1:end-1,1:end-1)+...
              lat_rho(1:end-1,2:end  )+...
              lat_rho(2:end  ,2:end  )+...
              lat_rho(2:end  ,1:end-1));

% -- pm, pn
dx=1000*Rearth*cos(pi*lat_rho(2:end-1,:)/180).*...
   (lon_u(2:end,:)-lon_u(1:end-1,:))*pi/180;

dy=1000*Rearth*(lat_v(:,2:end)-lat_v(:,1:end-1))*pi/180;
% % SD pm and pn are explicitly specified by making the grid strictly dx1
% % resolution.
% pm=1./dx1*ones(size(lon_rho))./1000;
% pn=1./dx1*ones(size(lon_rho))./1000;
pm = 1./dx;
pn = 1./dy;
% -- dmde, dndx (need twice extended psi grid)
% -- central difference
dmde=0.5*(dx(:,3:end)-dx(:,1:end-2));
dndx=0.5*(dy(3:end,:)-dy(1:end-2,:));
% dmde=zeros(size(lon_rho));
% dndx=zeros(size(lon_rho));

lon_rho=lon_rho(2:end-1,2:end-1);
lat_rho=lat_rho(2:end-1,2:end-1);
lon_u=lon_u(2:end-1,2:end-1);
lat_u=lat_u(2:end-1,2:end-1);
lon_v=lon_v(2:end-1,2:end-1);
lat_v=lat_v(2:end-1,2:end-1);
lon_psi=lon(3:end-2,3:end-2);
lat_psi=lat(3:end-2,3:end-2);
pm=pm(:,2:end-1);
pn=pn(2:end-1,:);
dx=1./pm;
dy=1./pn;

% x and y coordinates (ok, let's fill those):
lon0=mean(xlim);
lat0=mean(ylim);

% % SD get the interior rho u and v x positions.
% xrx=0.5*(xp(2:end)+xp(1:end-1));
% yrx=0.5*(yp(2:end)+yp(1:end-1));
% xri=xrx(2:end-1)';
% yri=yrx(2:end-1);

% x_rho=repmat(xrx',[1 Mp-1]);
% y_rho=repmat(yrx,[Lpp-1 1]);

x_rho=Rearth*1000*cos(lat0*pi/180)*(lon_rho-lon0)*pi/180;
y_rho=Rearth*1000*(lat_rho-lat0)*pi/180;
x_u=0.5*(x_rho(1:end-1,:)+x_rho(2:end,:));
y_u=0.5*(y_rho(1:end-1,:)+y_rho(2:end,:));
x_v=0.5*(x_rho(:,1:end-1)+x_rho(:,2:end));
y_v=0.5*(y_rho(:,1:end-1)+y_rho(:,2:end));
x_psi=0.5*(x_v(1:end-1,:)+x_v(2:end,:));
y_psi=0.5*(y_u(:,1:end-1)+y_u(:,2:end));


% add some rho points to plot
hlpr=linem(lat_rho([1:20:end end],[1:20:end end]),lon_rho([1:20:end end],[1:20:end end]));
set(hlpr,'LineStyle','none','Marker','.','Color','r');

hlpu=linem(lat_u([1:20:end end],[1:20:end end]),lon_u([1:20:end end],[1:20:end end]));
set(hlpu,'LineStyle','none','Marker','x','Color','g');

hlpv=linem(lat_v([1:20:end end],[1:20:end end]),lon_v([1:20:end end],[1:20:end end]));
set(hlpv,'LineStyle','none','Marker','p','Color','y');

%%
% Danielson DEM Alaska bathymetric dataset.  http://mather.sfos.uaf.edu/~seth/bathy/
% ARB_file='/home/grindylow/sdurski/ROMS/Grid_generation/Grids/AlaskaRegionBathymetricDEMv1.04.grd';
% lon_rho_arb=ncread(ARB_file,'x');
% lat_rho_arb=double(ncread(ARB_file,'y'));
% h_arb=ncread(ARB_file,'z');
% lon_rho_arba=repmat(lon_rho_arb-360,[1 length(lat_rho_arb)]);
% lat_rho_arba=repmat(lat_rho_arb',[length(lon_rho_arb) 1]);

GMRT_file = '/data/jungjih/Models/DEM/GMRT/GMRTv4_4_1_20260411topo.grd';
lon_rho_GMRT = ncread(GMRT_file, 'lon');
lat_rho_GMRT = ncread(GMRT_file, 'lat');
altitude_GMRT = ncread(GMRT_file, 'altitude'); % positive upward

[lat_rho_GMRT2, lon_rho_GMRT2] = meshgrid(lat_rho_GMRT, lon_rho_GMRT);

% -- Depth: h, hraw
%eval(['h=' bath_routine '(lon_rho+lon_offset,lat_rho,xlim+lon_offset,ylim);']);
%  Grab bathymetry from ARB file.
% Just set the depth to the average depth over the region of interest.
% [iln,ilt]=find(lon_rho_arba>lon_lim(1) & lon_rho_arba<lon_lim(2)  &...
%                lat_rho_arba>lat_lim(1) & lat_rho_arba<lat_lim(2));

% Generate a meshgrid 
% [ln,lt] = meshgrid(lon_rho_arb,lat_rho_arb);
% h2 = interp2(ln, lt, h_arb', lon_rho, lat_rho,'Linear');
% or a slow way of doing things is
% Fbath = scatteredInterpolant(double(lon_rho_arba(:)),double(lat_rho_arba(:)),h_arb(:));
Fbath = scatteredInterpolant(double(lon_rho_GMRT2(:)),double(lat_rho_GMRT2(:)),altitude_GMRT(:));
h=-Fbath(lon_rho,lat_rho); % original data is positive upward
%h=-ones(size(lon_rho)).*mean(mean(h_arb(iln,ilt)));
%h=-ones(size(lon_rho)).*-10;
%Alternatively use the specified depth at the station
%h=ones(size(lon_rho)).*h_sta;


%h(find(h<0))=0;



%%

% -- Coriolis par:
Omega=2*pi/(24*3600);
f=2*Omega*sin(lat_rho*pi/180);

%dmde_chk=-1000*Rearth*sin(lat_rho*pi/180)*dlon*dlat*(pi/180)^2;
%maxerrdmde=max(max(abs(dmde_chk-dmde)));
%disp(['Max error in dmde, num-ana: ' num2str(maxerrdmde) ' m']);

% -- Mask:
mask_rho=ones(size(lon_rho));
mask_u=ones(size(lon_u));
mask_v=ones(size(lon_v));
mask_psi=ones(size(lon_psi));

% mask_rho(find(h>=0))=0;
mask_rho(find(h<=0))=0;

mask_u=0.5*(mask_rho(1:end-1,:)+mask_rho(2:end,:));
mask_u(find(mask_u~=1))=0;

mask_v=0.5*(mask_rho(:,1:end-1)+mask_rho(:,2:end));
mask_v(find(mask_v~=1))=0;

mask_psi=0.25*(mask_rho(1:end-1,1:end-1)+...
               mask_rho(1:end-1,2:end)  +...
               mask_rho(2:end  ,2:end)  +...
               mask_rho(2:end  ,1:end-1));
mask_psi(find(mask_psi~=1))=0;
 
% figure;
% set(gcf,'position',[100 10  850 1100],...
%    'paperposition',[0 0 8.5 11]);
%
% px=7.5;
% ha=axes('units','in','position',[1 3 px px*Ly/Lx]);
%
% plot(x_psi,y_psi,'k-');hold on;
% plot(x_psi',y_psi','k-');
% plot(x_rho,y_rho,'r.','markersize',6);
% plot(x_u,y_u,'>b','markersize',6);
% plot(x_v,y_v,'^g','markersize',6);


%%
%%%%%%% SAVING %%%%%%%%%%%%%%%%%
[xi_rho,eta_rho]=size(lon_rho);
[xi_u,eta_u]=size(lon_u);
[xi_v,eta_v]=size(lon_v);
[xi_psi,eta_psi]=size(lon_psi);
spherical='T';
hraw=h;
angle=zeros(xi_rho,eta_rho);
%xl=Lx*1000;
%el=Ly*1000;
xl=x_u(end,1)-x_u(1,1);
el=y_v(1,end)-y_v(1,1);

%eval(['!cp ' roms_grd_cdl ' tmp.cdl']);

% Lets just generate a netcdf file from scratch here...but borrowing
% information from a temp grid file.

grid_id = netcdf.create(grid_file,'CLOBBER');

GDim(1).id=netcdf.defDim(grid_id,'xi_psi',xi_psi);
GDim(2).id=netcdf.defDim(grid_id,'xi_rho',xi_rho);
GDim(3).id=netcdf.defDim(grid_id,'xi_u',xi_u);
GDim(4).id=netcdf.defDim(grid_id,'xi_v',xi_v);
GDim(5).id=netcdf.defDim(grid_id,'eta_psi',eta_psi);
GDim(6).id=netcdf.defDim(grid_id,'eta_rho',eta_rho);
GDim(7).id=netcdf.defDim(grid_id,'eta_u',eta_u);
GDim(8).id=netcdf.defDim(grid_id,'eta_v',eta_v);
netcdf.close(grid_id);

grid_id=netcdf.open(grid_file,'WRITE');
netcdf.reDef(grid_id);

  lst={'spherical','xl','el', ...
       'h','f','pm','pn','dndx','dmde',...
       'x_rho','y_rho','lon_rho','lat_rho','angle','mask_rho', ...
       'x_psi','lon_psi','lat_psi','y_psi','mask_psi' ...
       'x_u','y_u','lon_u','lat_u','mask_u', ...
       'x_v','y_v','lon_v','lat_v','mask_v'};
% Create variables.
var(1).id=netcdf.defVar(grid_id,lst{1},'char',[]);
for ik=2:3
  var(ik).id=netcdf.defVar(grid_id,lst{ik},'double',[]);
end
for ik=4:15
  var(ik).id=netcdf.defVar(grid_id,lst{ik},'double',[GDim(2).id GDim(6).id]);
end   
for ik=16:20
    var(ik).id=netcdf.defVar(grid_id,lst{ik},'double',[GDim(1).id GDim(5).id]);
end
for ik=21:25
     var(ik).id=netcdf.defVar(grid_id,lst{ik},'double',[GDim(3).id GDim(7).id]);
end
for ik=26:30
     var(ik).id=netcdf.defVar(grid_id,lst{ik},'double',[GDim(4).id GDim(8).id]);
end

netcdf.close(grid_id)

% write variables
for k=1:length(lst)
   va=lst{k};
   ncwrite(grid_file,va,eval(va));
end

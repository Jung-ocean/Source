clc;clear all;close all

title='Upwelling ideal';
config='Upwelling ideal';

grdname = ['roms_grid_upwelling_ideal_5km.nc'];

hmin = 10;
hmax = 5000;
hmax_coast = 10;

load ideal_5km.mat
Lonr=lon_rho;Latr=lat_rho;
[Lonu,Lonv,Lonp]=rho2uvp(Lonr); 
[Latu,Latv,Latp]=rho2uvp(Latr);
%
%  Coriolis parameter
%
%f=4*pi*sin(pi*Latr/180)/(24*3600);
f=ones(size(lat_rho)).*1e-4;
%
% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[M,L]=size(Latp);
disp([' LLm = ',num2str(L-1)])
disp([' MMm = ',num2str(M-1)])
create_grid_J(L,M,grdname,title);

disp(' ')
disp(' Fill the grid file...')
nc=netcdf(grdname,'write');
nc{'lat_u'}(:)=Latu;
nc{'lon_u'}(:)=Lonu;
nc{'lat_v'}(:)=Latv;
nc{'lon_v'}(:)=Lonv;
nc{'lat_rho'}(:)=Latr;
nc{'lon_rho'}(:)=Lonr;
nc{'lat_psi'}(:)=Latp;
nc{'lon_psi'}(:)=Lonp;

result=close(nc);
%
%  Compute the metrics
%
disp(' ')
disp(' Compute the metrics...')
[pm,pn,dndx,dmde]=get_metrics(grdname);
xr=0.*pm;
yr=xr;
for i=1:L
  xr(:,i+1)=xr(:,i)+2./(pm(:,i+1)+pm(:,i));
end
for j=1:M
  yr(j+1,:)=yr(j,:)+2./(pn(j+1,:)+pn(j,:));
end
[xu,xv,xp]=rho2uvp(xr);
[yu,yv,yp]=rho2uvp(yr);
dx=1./pm;
dy=1./pn;
dxmax=max(max(dx/1000));
dxmin=min(min(dx/1000));
dymax=max(max(dy/1000));
dymin=min(min(dy/1000));
disp(' ')
disp([' Min dx=',num2str(dxmin),' km - Max dx=',num2str(dxmax),' km'])
disp([' Min dy=',num2str(dymin),' km - Max dy=',num2str(dymax),' km'])

%
% Compute the mask
%
h(h<hmin)=0;
maskr=h>0;
maskr=process_mask(maskr);

[masku,maskv,maskp]=uvp_mask(maskr);


%
%  Angle between XI-axis and the direction
%  to the EAST at RHO-points [radians].
%
angle=get_angle(Latu,Lonu);
%
%  Write it down
%
disp(' ')
disp(' Write it down...')
nc=netcdf(grdname,'write');
nc{'h'}(:)=h;
nc{'hraw'}(:)=h;
nc{'pm'}(:)=pm;
nc{'pn'}(:)=pn;
nc{'dndx'}(:)=dndx;
nc{'dmde'}(:)=dmde;
nc{'mask_u'}(:)=masku;
nc{'mask_v'}(:)=maskv;
nc{'mask_psi'}(:)=maskp;
nc{'mask_rho'}(:)=maskr;
nc{'x_u'}(:)=xu;
nc{'y_u'}(:)=yu;
nc{'x_v'}(:)=xv;
nc{'y_v'}(:)=yv;
nc{'x_rho'}(:)=xr;
nc{'y_rho'}(:)=yr;
nc{'x_psi'}(:)=xp;
nc{'y_psi'}(:)=yp;
nc{'angle'}(:)=angle;
nc{'f'}(:)=f;
nc{'spherical'}(:)='T';
result=close(nc);
disp(' ')
disp(['  Size of the grid:  L = ',...
      num2str(L),' - M = ',num2str(M)])
%
% make a plot
%
disp(' ')
disp(' Do a plot...')
themask=ones(size(maskr));
themask(maskr==0)=NaN; 
domaxis=[min(min(Lonr)) max(max(Lonr)) min(min(Latr)) max(max(Latr))];
colaxis=[min(min(h)) max(max(h))];
% fixcolorbar([0.25 0.05 0.5 0.03],colaxis,...
%             'Topography',10)
width=1;
height=0.8;
subplot('position',[0. 0.14 width height])
m_proj('mercator',...
       'lon',[domaxis(1) domaxis(2)],...
       'lat',[domaxis(3) domaxis(4)]);
m_pcolor(Lonr,Latr,h.*themask);
%shading interp
% caxis(colaxis)
hold on
m_contour(Lonr,Latr,h,[hmin 100 200 500 1000 2000 4000],'k--');
% if ~isempty(coastfileplot)
%   m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
% else
%  m_gshhs_l('patch',[.9 .9 .9])
% end
m_grid('box','fancy',...
       'xtick',5,'ytick',5,'tickdir','out',...
       'fontsize',7);
hold off
%
% End
%

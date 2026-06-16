clear all;

infile = 'grid_Oregon_1km_1.nc';
outfile = 'grid_Oregon_1km_2.nc';

hmin=3;
mrksize=6;
isauto_hmin = 0;

Case= 'OR';

if     strcmp(Case,'OR')
    lon = ncread(infile, 'lon_rho');
    lat = ncread(infile, 'lat_rho');
    xlims=[min(lon(:)) max(lon(:))];
    ylims=[min(lat(:)) max(lat(:))];

    axpos=[0.1 0.2 0.6 0.7]; % axes position

elseif strcmp(Case,'Bering')
 xlims=[-182.7830 -157.0180];
 ylims=[50.0090 66.3203 ];
  
 axpos=[0.1 0.2 0.8 0.7]; % axes position
 
elseif strcmp(Case,'Bering_full')
 xlims=[153-360 -155.0180];
 ylims=[48.0090 67.0 ];
  
 axpos=[0.1 0.2 0.8 0.7]; % axes position

end

plt_fine_bath_contours_YES=1;

if plt_fine_bath_contours_YES

 if strcmp(Case,'OR')

  finebathfile=infile;
  varlist={'lon_rho','lat_rho','h'};
  a=read_whole_field(finebathfile,varlist);
  lon_fine=a.lon_rho;
  lat_fine=a.lat_rho;
  hfine=a.h;
%   [lat_fine, lon_fine] = meshgrid(lat_fine, lon_fine);

 elseif strcmp(Case,'OR_2km')

  finebathfile='/home/europe/kurapov/BATHYMETRY_OR_12sec/uswest_etopo1.nc';
   a=read_whole_field(finebathfile,{'lon','lat','z'});
   lon_fine=a.lon;
   lat_fine=a.lat;
   hfine=-a.z;

 elseif strcmp(Case,'Amukta')

  finebathfile='/home/europe/data2/kurapov/Aleut/Dat/so_ak_crm_gmt_v2_grd.nc';

  a=read_whole_field('../Dat/so_ak_crm_gmt_v2_grd.nc',{'lon','lat','z'});
  lon_fine=a.lon-360;
  lat_fine=a.lat;
  hfine=-a.z;

  ii=findin(lon_fine,xlims);
  jj=findin(lat_fine,ylims);

  lon_fine=lon_fine(ii);
  lat_fine=lat_fine(jj);
  hfine=hfine(ii,jj);
  [lat_fine,lon_fine]=meshgrid(lat_fine,lon_fine);
  
  elseif strcmp(Case,'Tas')

   finebathfile='/home/europe/kurapov/BATHYMETRY_OR_12sec/tas_etopo1.nc';
   a=read_whole_field(finebathfile,{'lon','lat','z'});
   lon_fine=a.lon;
   lat_fine=a.lat;
   hfine=-a.z;
   
 elseif strcmp(Case,'Bering');
%   [Z1, refvec] = etopo('/Users/sdurski/ROMS/Grid//Bathymetric_data_sets/etopo1_ice_c_f4/etopo1_ice_c.flt', 1, ...
%                    [50 66], [176 180]);
%   del_ltln=1./refvec(1);

% % positions of cell centers in longitude are
%   lon_rho_et1=refvec(3)+0.5*del_ltln:del_ltln:length(Z1(1,:))*del_ltln+refvec(3);
% % lets subtract 360 degrees from this...
%   lon_rho_et1s=lon_rho_et1-360.0;
%   h_et1=Z1; 
   
%   [Z2, refvec] = etopo('/Users/sdurski/ROMS/Grid//Bathymetric_data_sets/etopo1_ice_c_f4/etopo1_ice_c.flt', 1, ...
%                    [50 66], [-180 -152]);
%  % positions of cell centers in longitude are
%   lon_rho_et2=refvec(3)+0.5*del_ltln:del_ltln:length(Z2(1,:))*del_ltln+refvec(3);
%   lat_rho_et=refvec(2)-0.5*del_ltln:-del_ltln:-length(Z2(:,1))*del_ltln+refvec(2);
%   lat_rho_etr=lat_rho_et(end:-1:1);
%   h_et2=Z2;
% % append the two pieces in h and lon
%   lat_fine=lat_rho_etr;
%   lon_fine=[lon_rho_et1s, lon_rho_et2];
%   hfine=[-h_et1, -h_et2];
%    ARB_file='/Users/sdurski/ROMS/Grid/Bathymetric_data_sets/AlaskaRegionBathymetricDEMv1.04.grd'
%    lon_glbl=ncread(ARB_file,'x');
%    lat_glbl=ncread(ARB_file,'y');
%    lon_indx1=find(lon_glbl>=165 & lon_glbl<=208);
%    lat_indx1=find(lat_glbl>=50.0 & lat_glbl<=68);
%    
%    lon_fine=lon_glbl(lon_indx1)-360;
%    lat_fine=lat_glbl(lat_indx1);
%    start=[lon_indx1(1) lat_indx1(1)];
%    count=[length(lon_indx1) length(lat_indx1)];
%    hfine=-ncread(ARB_file,'z',start,count)';
     lon_fine=ncread(infile,'lon_rho');
     lat_fine=ncread(infile,'lat_rho');
     hfine=-ncread(infile,'h');
 elseif strcmp(Case,'Bering_full');
     lon_fine=ncread(infile,'lon_rho');
     lat_fine=ncread(infile,'lat_rho');
     hfine=ncread(infile,'h');
 elseif strcmp(Case,'Yaq_Bay');
     lon_fine=ncread(infile,'lon_rho');
     lat_fine=ncread(infile,'lat_rho');
     hfine=ncread(infile,'h');     
 elseif strcmp(Case,'Mar_Res');
     lon_fine=ncread(infile,'lon_rho');
     lat_fine=ncread(infile,'lat_rho');
     hfine=ncread(infile,'h');     
 end % choice of Case 

end

eval(['!cp ' infile ' ' outfile]);

lon_rho=ncread(outfile,'lon_rho');
lat_rho=ncread(outfile,'lat_rho');
mask_rho=ncread(outfile,'mask_rho');
h=ncread(outfile,'h');
h0=h;

[nx,ny]=size(lon_rho);

mask_rho1=mask_rho;

nband=2;
% ii=[2:nx-1];
% jj=[2:ny-1];
% chk=mask_rho(ii-1,jj+1)+mask_rho(ii  ,jj+1)+mask_rho(ii+1,jj+1)+...
%     mask_rho(ii-1,jj  )+mask_rho(ii  ,jj  )+mask_rho(ii+1,jj  )+...
%     mask_rho(ii-1,jj-1)+mask_rho(ii  ,jj-1)+mask_rho(ii+1,jj-1);

% [i1,j1]=find(chk~=9 & chk~=0);
[i1,j1]=find(mask_rho==0);
i1=i1+1;
j1=j1+1;

L1=length(i1);
lon1=zeros(L1,1);
lat1=zeros(L1,1);
msk_plt=zeros(nx,ny);
% for k=1:L1
%  lon1(k)=lon_rho(i1(k),j1(k));
%  lat1(k)=lat_rho(i1(k),j1(k));
%  ii=[max(i1(k)-nband,1):min(i1(k)+nband,nx)];
%  jj=[max(j1(k)-nband,1):min(j1(k)+nband,ny)];
%  msk_plt(ii,jj)=1;
% end
% 
msk_plt=mask_rho;

hf=figure;
set(gcf,'position',[40 40 1300 900],'paperposition',[0 0 1400 950]);
ha=axes('position',axpos);

% SD to not lose the top toolbar ...
set(hf,'Toolbar','figure');

xp=[lon_rho(1,1) lon_rho(nx,1) lon_rho(nx,ny) lon_rho(1,ny) lon_rho(1,1)];
yp=[lat_rho(1,1) lat_rho(nx,1) lat_rho(nx,ny) lat_rho(1,ny) lat_rho(1,1)];
pl1=plot(xp,yp,'k-');

hold on;

if plt_fine_bath_contours_YES
 [cc,hh]=contour(lon_fine,lat_fine,hfine,[100 50 25],'c-');
 set(hh,'linewidth',1);
 if strcmp(Case,'Yaq_Bay'),    %Consider areas as much as 2m above mean sea level for Yaquina Bay
     [cc,hh]=contour(lon_fine,lat_fine,hfine,[2 12000],'r-');
 else
     [cc,hh]=contour(lon_fine,lat_fine,hfine,[0 12000],'r-');
 end
 set(hh,'linewidth',2);
 [cc,hh]=contour(lon_fine,lat_fine,hfine,[hmin 12000],'g-');
 set(hh,'linewidth',2);
% colormap lines;
end

if isauto_hmin == 1
    mask_rho1(h < hmin) = 0;
end

in1=find(msk_plt==1 & mask_rho1==1);
in0=find(msk_plt==1 & mask_rho1==0);
pl2=plot(lon_rho(in1),lat_rho(in1),'bs','markersize',mrksize);
plot(lon_rho(in0),lat_rho(in0),'gs','markersize',mrksize);

set(gca,'xlim',xlims,'ylim',ylims);

htoggle = uicontrol('Style','togglebutton','String','Toggle',...
          'units','normalized',...
          'position',[0.1 0.1 0.25 0.03],...
          'Callback','mkgrd_toggle_one_pnt_mod');

hmaskreg = uicontrol('Style','togglebutton','String','Mask region',...
          'units','normalized',...
          'position',[0.4 0.1 0.25 0.03],...
          'Callback','mkgrd_mask_region_mod_2');

hwatrreg = uicontrol('Style','togglebutton','String','Water region',...
          'units','normalized',...
          'position',[0.4 0.06 0.25 0.03],...
          'Callback','mkgrd_water_region_mod_2');
            
hsave =  uicontrol('Style','pushbutton','String','Save',...
          'units','normalized',...
          'position',[0.7 0.1 0.25 0.03],...
          'Callback','mkgrd_save_mod');

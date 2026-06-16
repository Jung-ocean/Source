% Grid bathym:

% Note: This involves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FINE BATHYMETRY SMOOTHING 
% (integrate the heat equation: no flux condition at open
% boundaries, specified depth h=hmin at the coast) 
% Intermediate smoothed maps are saved in H12
% Then, later, the best choice will be determined through the GUI process
% CSD I'm going to try to do things a bit differently
% below now. I'm going to calculate r factors and use a 
% procedure like Martinhi and Barteen (2006) to smooth the bathymetry
% in order to meet r-factor criteria. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
%infile='.nc';
%outfile='/home/europe/data2/kurapov/Aleut/Prm/grd_amukta_sd_2.nc';
infile='grid_Oregon_1km_2.nc';
outfile='grid_Oregon_1km_3.nc';

%infile  ='/home/europe/data2/kurapov/OR_2km/Prm/grd_or2km_02.nc';
%outfile ='/home/europe/data2/kurapov/OR_2km/Prm/grd_or2km_03.nc';
eval(['!cp ' infile ' ' outfile]);

hmin=3;

Case='OR'; %'Bering'; % 'Amukta','OR','Tas','OR_2km'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ THE INPUT GRID FILE WITH PROPER MASK:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%a=read_whole_field(infile,{'lon_rho','lat_rho','mask_rho','h'});
%lon_rho=a.lon_rho;
%lat_rho=a.lat_rho;
%mask_rho=a.mask_rho;
%h_old=a.h; % possibly, for plotting
lon_rho=ncread(infile,'lon_rho');
lat_rho=ncread(infile,'lat_rho');
mask_rho=ncread(infile,'mask_rho');
mask_u = ncread(infile,'mask_u');
mask_v = ncread(infile,'mask_v');
h_old=ncread(infile,'h');


[xi_rho,eta_rho]=size(lon_rho);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XLIMS, YLIMS TO CLIP BATHYM FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlims=[lon_rho(1,1) lon_rho(end,end)]+[-0.5 0.5];
ylims=[lat_rho(1,1) lat_rho(end,end)]+[-0.5 0.5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ BATHYM FILE:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Case,'Amukta')

  finebathfile='/home/europe/data2/kurapov/Aleut/Dat/so_ak_crm_gmt_v2_grd.nc';

  a=read_whole_field(finebathfile,{'lon','lat','z'});
  lon12=a.lon-360;
  lat12=a.lat;
  h12=-a.z;

  ii=findin(lon12,xlims);
  jj=findin(lat12,ylims);

  lon12=lon12(ii);
  lat12=lat12(jj);
  h12=h12(ii,jj);
  [lat12,lon12]=meshgrid(lat12,lon12);

elseif strcmp(Case,'Tas')
  finebathfile='/home/europe/kurapov/BATHYMETRY_OR_12sec/tas_etopo1.nc';
  a=read_whole_field(finebathfile,{'lon','lat','z'});
  lon12=a.lon;
  lat12=a.lat;
  h12=-a.z;

  lon12=fliplr(lon12);
  lat12=fliplr(lat12);
  h12  =fliplr(h12);
 
elseif strcmp(Case, 'OR')
    GMRT_file = '/data/jungjih/Models/DEM/GMRT/GMRTv4_4_1_20260411topo.grd';
    lon_rho_GMRT = ncread(GMRT_file, 'lon');
    lat_rho_GMRT = ncread(GMRT_file, 'lat');
    altitude_GMRT = ncread(GMRT_file, 'altitude'); % positive upward

    [lat12, lon12] = meshgrid(lat_rho_GMRT, lon_rho_GMRT);
    h12 = -altitude_GMRT;

elseif strcmp(Case,'OR_2km')

  finebathfile='/home/europe/kurapov/BATHYMETRY_OR_12sec/uswest_etopo1.nc';
  a=read_whole_field(finebathfile,{'lon','lat','z'});
  lon12=a.lon;
  lat12=a.lat;
  h12=-a.z;

  lon12=fliplr(lon12);
  lat12=fliplr(lat12);
  h12  =fliplr(h12);

  
elseif strcmp(Case,'Bering') || strcmp(Case,'Bering_full')
   RBathFile = '/home/grindylow/sdurski/ROMS/Grid_generation/Grids/AlaskaRegionBathymetricDEMv1.04.grd';
   lon_bs=double(ncread(RBathFile, 'x'));
   lat_bs=double(ncread(RBathFile, 'y'));
   depth_bs3 = double(ncread(RBathFile,'z'));
   lon_fgrd=lon_bs-360;
   lat_fgrd=lat_bs;
   h12=-depth_bs3;
   [lat12,lon12]=meshgrid(lat_fgrd,lon_fgrd);

   % Read in second bathymetry for comparison.
   RBathFile2 = '/home/grindylow/sdurski/ROMS/Grid_generation/Grids/GEBCO_2022_sub_ice_topo.nc';
   lon_bs2=double(ncread(RBathFile2, 'lon'));
   lon_bs2(lon_bs2>0) = lon_bs2(lon_bs2>0)-360;
   lat_bs2=double(ncread(RBathFile2, 'lat'));
   ind_e = find(lon_bs2>=-180 & lon_bs2<=xlims(2)+0.2);
   ind_w = find(lon_bs2>=xlims(1)-0.2 & lon_bs2<-180);
   ind_ns = find(lat_bs2>=ylims(1)-0.2 & lat_bs2<=ylims(2)+0.2);

   depth_bs32_e = double(ncread(RBathFile2,'elevation',  ...
                  [ind_e(1) ind_ns(1)],[length(ind_e) length(ind_ns)]));
   depth_bs32_w = double(ncread(RBathFile2,'elevation',  ...
                  [ind_w(1) ind_ns(1)],[length(ind_w) length(ind_ns)]));
   depth_bs32 = [depth_bs32_w; depth_bs32_e];
   lon_fgrd2=[lon_bs2(ind_w); lon_bs2(ind_e)];
   lat_fgrd2=lat_bs2(ind_ns);
   h122=-depth_bs32;
   % Find the subset corresponding to the region of interest.
   [lat122,lon122]=meshgrid(lat_fgrd2,lon_fgrd2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extended lon_rho, lat_rho, mask_rho
% (one rho point in each direction):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lon_ext=lon_rho;
lat_ext=lat_rho;
mask_ext=mask_rho;

%-
dlon=lon_ext(2,:)-lon_ext(1,:);
lon_ext=[lon_ext(1,:)-dlon;lon_ext];
lat_ext=[lat_ext(1,:)     ;lat_ext];
mask_ext=[mask_ext(1,:)     ;mask_ext];
%-
dlon=lon_ext(end,:)-lon_ext(end-1,:);
lon_ext=[lon_ext; lon_ext(end,:)+dlon];
lat_ext=[lat_ext; lat_ext(end,:)     ];
mask_ext=[mask_ext;mask_ext(end,:)     ];
%-
dlat=lat_ext(:,2)-lat_ext(:,1);
lat_ext=[lat_ext(:,1)-dlat lat_ext];
lon_ext=[lon_ext(:,1)      lon_ext];
mask_ext=[mask_ext(:,1)    mask_ext];
%-
dlat=lat_ext(:,end)-lat_ext(:,end-1);
lat_ext=[lat_ext lat_ext(:,end)+dlat];
lon_ext=[lon_ext lon_ext(:,end)];
mask_ext=[mask_ext mask_ext(:,end)];

lon_psi=0.25*(lon_ext(1:end-1,1:end-1)+...
              lon_ext(1:end-1,2:end  )+...
              lon_ext(2:end  ,1:end-1)+...
              lon_ext(2:end  ,2:end  ));
lat_psi=0.25*(lat_ext(1:end-1,1:end-1)+...
              lat_ext(1:end-1,2:end  )+...
              lat_ext(2:end  ,1:end-1)+...
              lat_ext(2:end  ,2:end  ));
lon_u = Cgrd_avg(lon_rho,1);
lat_u = Cgrd_avg(lat_rho,1);
lon_v = Cgrd_avg(lon_rho,2);
lat_v = Cgrd_avg(lat_rho,2);



[dx12,dy12]=lonlat2dxdy(lon12,lat12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% msk_ext_1: mask also sea points next to coast
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For now let's not mask the coastal sea points and see how things go...
mask_ext_1=mask_ext;
%[nx1,ny1]=size(mask_ext);
% for i1=1:nx1
% for j1=1:ny1
%  if mask_ext(i1,j1)==0
%   mask_ext_1(max(1,i1-1):min(nx1,i1+1),j1)=0;
%   mask_ext_1(i1,max(j1-1,1):min(ny1,j1+1))=0;
%  end
% end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the mask for the fine bathymetry, based on
% interpolation of mask_ext_1 (on the fine bathym., 
% masked points will be assigned depth hmin and 
% not changed during the smoothing process)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msk=interp2(lat_ext,lon_ext,mask_ext_1,lat12,lon12);
msk(find(msk<0.25))=0;
msk(find(msk>0))=1;

% figure;
% plot(lon_psi,lat_psi,'k-');
% hold on;
% plot(lon_psi',lat_psi','k-');
% plot(lon_rho(find(mask_rho==0)),lat_rho(find(mask_rho==0)),'bs','markerfacecolor','b');
% plot(lon12(find(msk==0)),lat12(find(msk==0)),'r.');
% plot(lon12(find(msk==1)),lat12(find(msk==1)),'c.');

h12(find(msk==0))=hmin;

% % CSD Before we do fine bathymetry smoothing, let's take a look at the r
% % factors 
h_old1 = interp2(lat12,lon12,h12,lat_rho,lon_rho);
% h_old2 = interp2(lat122,lon122,h122,lat_rho,lon_rho);

% % The GEBCO bathymetry is garbage in a number of places in the western
% % Aleutian islands. In particular there are near-coast points where the
% % bathymetry plunges downward in GEBCO. This is not the case for the ARB
% % So let me replace 'bad' GEBCO values with ARB values in these regions
% % under these conditions
% % 1) the depth (h_old1) is less than 150 m
% % 2) i<=800, j<=700
% % 3) (h_old1-h_old2)/abs(h_old1).*mask <=-4
% % Condition 3 is to select locations with extreme differences.
% h_mod = h_old2;
% hmmx = 150;
% irng = 1:800;
% jrng = 1:700;
% rmfac = (h_old1-h_old2)./abs(h_old1);
% h_old1_sub =h_old1(irng,jrng);
% h_mod_sub = h_old2(irng,jrng);
% ind = find(h_old1_sub<=150 & rmfac(irng,jrng).*mask_rho(irng,jrng) <=-3);
% % check for h_old1 values that are invalid because they are too shallow
% % or are land points.
% indL = find(h_old1_sub(ind)<=10);   % say anything less than -10 is invalid
% h_old1_sub(ind(indL))=10;
% 
% h_mod_sub(ind)=h_old1_sub(ind);
% h_mod(irng,jrng)=h_mod_sub;
h_mod = h_old1;

% we set land-masked coastal edge values equal to average of bordering 
% sea values so that when we calculate an r-factor it doesn't highlight
% coastal points. ...this doesn't really work well. Let's go back to
% setting masked to hmin.
% (This next line takes a while....)
%h_noland = set_land_edge_depths(h_old2, mask_rho);
h_noland = h_mod;
h_noland(h_noland<hmin) = hmin;

% Lets filter sections of the grid at a time so as not to over-filter
% regions that need less. 
box_size = 50;  % use a 50x50 size box
[L,M] = size(h_noland);Lm=L-1; Mm = M-1;

istarts = find(mod(1:L,box_size-1)==1);
iends = find(mod(1:L,box_size-1)==0);
if (iends(end)<istarts(end)), 
    iends = [iends L];
end
jstarts = find(mod(1:M,box_size-1)==1);
jends = find(mod(1:M,box_size-1)==0);
if (jends(end)<jstarts(end)), 
    jends = [jends M];
end

h_sm = h_noland;
[rx0,ry0]=rfactor0(h_sm);
for ib = 1:length(istarts)
    for jb = 1:length(jstarts)
        ic = jb+(ib-1)*length(istarts);
        irng=istarts(ib):min(iends(ib)+2,L); % add a couple points of overlap
        irngu = istarts(ib):min(iends(ib)+1,Lm); 
        jrng=jstarts(jb):min(jends(jb)+2,M); 
        jrngv = jstarts(jb):min(jends(jb)+1,Mm);
        fmsku = mask_u(irngu,jrng);
        fmskv = mask_v(irng,jrngv);
        h_in=h_sm(irng,jrng);
        [h_out,itc(ib,jb),rmx(ib,jb),fmx(ib,jb)] = bath_filt_select(h_in, fmsku, fmskv, 0.25, 0.01);
        h_sm(irng,jrng) = h_out;
        lon(ib,jb)=mean(mean(lon_rho(irng,jrng)));
        lat(ib,jb)=mean(mean(lat_rho(irng,jrng)));  
        msk(ib,jb)=(sum(sum((mask_rho(irng,jrng)==1)))>0);
        ic,
    end
end
h_sm(mask_rho == 0) = hmin;
[rx0s,ry0s] = rfactor0(h_sm);

ncwrite(outfile,'h',h_sm);

%[rx0,ry0] = rfactor0(h_noland);
% The r-factors above do not zero out masked areas.

% dhx = -(diff(h_noland.*mask_rho,1,1));   % written as h_1 - h_2
% dhy = -(diff(h_noland.*mask_rho,1,2));
% hsmx = h_noland(1:end-1,:).*mask_rho(1:end-1,:) ...
%       +h_noland(2:end,:).*mask_rho(2:end,:);
% hsmy = h_noland(:,1:end-1).*mask_rho(:,1:end-1)  ...
%       +h_noland(:,2:end).*mask_rho(:,2:end);
% rx0 = dhx./hsmx.*mask_u;
% ry0 = dhy./hsmy.*mask_v;

% There is another r-factor rx1 which is the Haney number or hydrostatic
% stability number which also takes into account the s-coordinate details
% by considering the layers thicknesses.
% So let's select s-coordinate parameters and check this criteria too.
% for now let's set parameters to match the previous Eastern Bering Sea
% simulation. 
% s.N= 45;
% s.theta_s=2.0;
% s.theta_b= 0.0;
% s.Tcline = -50;
% s.Vtransform= 2;
% s.Vstretching= 4;
% zeta = zeros(size(h_old));
% [z,sc,Cs]=scoord_full_grid(-h_noland,zeta,s,1); % one for w-points.

% original way of smoothing is below...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FINE BATHYMETRY SMOOTHING 
% (integrate the heat equation: no flux condition at open
% boundaries, specified depth h=hmin at the coast) 
% Intermediate smoothed maps are saved in H12
% Then, later, the best choice will be determined through the GUI process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ds=100;
% ntimes=25;
% totalsteps=75;
% ntries=round(totalsteps/ntimes);
% 
% H12=zeros([size(h12) ntries+1]);    % <- series of fine grid smoothed bathym
% H12(:,:,1)=h12;
% 
% % plot intermediate results:
% figure;
% set(gcf,'position',[40 40 850 1100],'paperposition',[40 40 850 1100]);
% ha=axes('position',[0.1 0.2 0.6 0.7]);
% [cc,hh]=contour(lon12,lat12,h12,[2000 1000 200 100 hmin+0.01],'k-');
% drawnow;
% 
% for k=1:ntries
%  H12(:,:,k+1)=smooth_bathy_conv(lon12,lat12,H12(:,:,k),msk,dx12,dy12,ds,ntimes);
%  hold on;
%  if exist('hh2')
%   delete(hh2);
%   clear cc2 hh2;
%  end
%  [cc2,hh2]=contour(lon12,lat12,H12(:,:,k+1),[2000 1000 200 100 hmin+0.01],'r-');
%  title(['fine res., k=' num2str(k)]);
%  drawnow;
% end
% 
% % Sampling smoothing results at lon_rho, lat_rho
% h_12=zeros([size(lon_rho) ntries+1]);
% for k=1:ntries+1
%  h_12(:,:,k)=interp2(lat12,lon12,H12(:,:,k),lat_rho,lon_rho);
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % FINAL CHOICE (GUI)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% figure;
% set(gcf,'position',[40 40 850 1100],'paperposition',[40 40 850 1100]);
% ha=axes('position',[0.1 0.2 0.6 0.7]);
% [cc,hh]=contour(lon12,lat12,h12,[2000 1000 200 100 hmin+0.01],'k-');
% hold on;
% 
% k12=1;
% 
% [cc1,hh1]=contour(lon_rho,lat_rho,h_12(:,:,k12),[2000 1000 200 100 hmin+0.01],'r-');
% title(['current choice: fine grid ' num2str(k12)]);
% drawnow;
% 
% hslide12 = uicontrol('Style', 'slider','Min',1,'Max',ntries+1,'Value',k12,...
%            'SliderStep',[1/ntries 1/ntries],...
%            'units','normalized',...
%            'Position', [0.12 0.1 0.2 0.02],...
%            'Callback','mkgrd_slide');
% 
% hchk      = uicontrol('Style','pushbutton','String','checkout',...
%             'units','normalized',...
%             'position',[0.7 0.1 0.2 0.02],...
%             'Callback','mkgrd_chkout_mod');

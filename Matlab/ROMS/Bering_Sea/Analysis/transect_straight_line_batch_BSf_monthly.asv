% This is a script to extract data at a collection of sections from ROMS

clear all
% addpath(genpath('/home/grindylow/sdurski/matlab_tools/ROMS_general_tools'));

exp = 'Dsm4';
region = 'Gulf_of_Anadyr_NW_SE';
yyyy = 2022;
mm_all = 1:11;

ln_scl=110000;
lt_scl=ln_scl.*cos(60/180*pi);

% From ROMS
file_i.dir='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng';
file_i.prefix='Dsm2_spng_avg';
%file_i=Rfile_collect_2(file_i,datenum(1968,5,23));
%save(sprintf('%s/%s_file_info.mat',file_i.dir,file_i.prefix),'-v7.3','file_i');
load(sprintf('%s/MAT_files/%s_file_info.mat',file_i.dir,file_i.prefix));
%file_i=file_F;
load('/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_DsmV2_grid.mat');
% file_i.dir='/home/jaguar/data7/sdurski/ROMS/Output/NE_P/FlN2/';
% file_i.prefix='Flr4_avg';
file_i.yyyy = yyyy;
file_i.filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
file_i.exp = exp;

% start_day=datenum(yyyy,mm(1),1);
% end_day=datenum(yyyy,mm(end)+1,1);

% fname=char(sprintf('%s%s_0350.nc',file_i.dir,file_i.prefix))
% Rgridfile=ncreadatt(fname,'/','grd_file');

% This is a bit odd but we have different lengths for the Rvar and fld
% vectors because we process both components of velocity under 'vel', 
% so we need to associate fld indicies with the Rvar indicies

% Rvarname={'u','v','rel_vort','temp','salt','AKt','w','zeta','aice','hice'};
% varDim=[      3   3   3   3   3          3    3     2     2    2];
% RvarDim={'u3d','v3d','p3d','r3d','r3d','w3d','w3d','r2d','r2d','r2d'};

%Rvarname={'u','v','rel_vort'};
% varDim=[      3   3   3   ];
% RvarDim={'u3d','v3d','p3d'};

Rvarname={'u',   'v',  'temp', 'salt', 'w',   'AKt',  'zeta', 'aice', 'sustr', 'svstr'};
varDim=[   3      3     3       3       3       3        2       2       2        2];
RvarDim={ 'u3d', 'v3d','r3d',  'r3d',  'w3d',  'r3d',  'r2d',  'r2d',  'u2d',   'v2d'};

% 
% Rvarname={'rel_vort'};
% varDim=[3];
% RvarDim={'p3d'};
% 

% Rvarname={'wai','wao','wio','wfr','uice','vice','sustr','svstr','bustr','bvstr'};
% varDim=[   2     2     2     2     2      2      2       2       2       2];
% RvarDim={'r2d','r2d','r2d','r2d','u2d','v2d',   'u2d'  ,'v2d'  , 'u2d' ,'v2d'  };

% Rvarname={'Uwind','Vwind'};
% varDim=[2    2];
% RvarDim={'r2d','r2d'};


% fld(2).cnt_rng=-0.25:0.02:0.25;
% fld(3).cnt_rng=-0.25:0.02:0.25;
% fld(4).cnt_rng=-2:1:11;
% fld(5).cnt_rng=31:0.2:34;

% from the start and end points generate a uniform grid of data points to
% attain the fields on
% lonsec=lon_start:0.02:lon_end;
% find the latitudes that correspond with the longitudes along the transect
% there is certainly a more correct way to do this on a spherical earth
% (rhumb distance?).
% slope=(lat_end-lat_start)./(lon_end-lon_start);
% latsec=lat_start+slope.*(lonsec-lon_start);
% zsec=-550:10:0;
% Specify the number of vertical levels to consider 
Nvlvl=45;

% lonseca=repmat(lonsec', [1 Nvlvl]);
% latseca=repmat(latsec', [1 Nvlvl]);
% zseca=repmat(zsec,[length(lonsec) 1]);

% read in the necesary file information

% ROMS
%file_i=file_i_collect_2(file_i,datenum(1968,5,23));
%-----
% ROMS
% fname=char(sprintf('%s%s',file_i.dir,char(file_i.name(1))));
% %Grid=grid_arrays_new_badx(fname,Rgridfile);
% Grid=grid_arrays_new_2(fname,Rgridfile);
%load('/home/aruba/vol1/sdurski/ROMS/Output/Bering_Sea/Winter/Ice_Improve/file_info_ice_clnd1_avg.mat','Grid'); 
%load /home/aruba/vol3/sdurski/ROMS/Output/Bering_Sea/Htr/file_info_ice_clnd1_htr_his.mat file_i3d Grid

% We now want to also calculate the relative vorticity, 
% to do this we can either have an interpolant at psi points or 
% average to 'interior' rho points.  
% as a first try let's go with the psi-points.
Grid.dxp=Cgrd_avg(Grid.dxu,2);
Grid.dyp=Cgrd_avg(Grid.dyv,1);
Grid.ln_p=Cgrd_avg(Grid.ln_u,2);
Grid.lt_p=Cgrd_avg(Grid.lt_v,1);
Grid.zp=Cgrd_avg(Grid.zu,2);

Grid.ln_rv=reshape(repmat(Grid.ln_r,[1 1 Grid.N]),[Grid.L*Grid.M*Grid.N 1]);
Grid.lt_rv=reshape(repmat(Grid.lt_r,[1 1 Grid.N]),[Grid.L*Grid.M*Grid.N 1]);
Grid.ln_uv=reshape(repmat(Grid.ln_u,[1 1 Grid.N]),[(Grid.L-1)*Grid.M*Grid.N 1]);
Grid.lt_uv=reshape(repmat(Grid.lt_u,[1 1 Grid.N]),[(Grid.L-1)*Grid.M*Grid.N 1]);
Grid.ln_vv=reshape(repmat(Grid.ln_v,[1 1 Grid.N]),[Grid.L*(Grid.M-1)*Grid.N 1]);
Grid.lt_vv=reshape(repmat(Grid.lt_v,[1 1 Grid.N]),[Grid.L*(Grid.M-1)*Grid.N 1]);

ln_rvp=reshape(repmat(Grid.ln_r,[1 1 Grid.N+2]),[Grid.L*Grid.M*(Grid.N+2) 1]);
lt_rvp=reshape(repmat(Grid.lt_r,[1 1 Grid.N+2]),[Grid.L*Grid.M*(Grid.N+2) 1]);
ln_wvp=reshape(repmat(Grid.ln_r,[1 1 Grid.N+1]),[Grid.L*Grid.M*(Grid.N+1) 1]);
lt_wvp=reshape(repmat(Grid.lt_r,[1 1 Grid.N+1]),[Grid.L*Grid.M*(Grid.N+1) 1]);
ln_uvp=reshape(repmat(Grid.ln_u,[1 1 Grid.N+2]),[(Grid.L-1)*Grid.M*(Grid.N+2) 1]);
lt_uvp=reshape(repmat(Grid.lt_u,[1 1 Grid.N+2]),[(Grid.L-1)*Grid.M*(Grid.N+2) 1]);
ln_vvp=reshape(repmat(Grid.ln_v,[1 1 Grid.N+2]),[Grid.L*(Grid.M-1)*(Grid.N+2) 1]);
lt_vvp=reshape(repmat(Grid.lt_v,[1 1 Grid.N+2]),[Grid.L*(Grid.M-1)*(Grid.N+2) 1]);

lt_pvp=reshape(repmat(Grid.lt_p,[1 1 Grid.N+2]),[(Grid.L-1)*(Grid.M-1)*(Grid.N+2) 1]);
ln_pvp=reshape(repmat(Grid.ln_p,[1 1 Grid.N+2]),[(Grid.L-1)*(Grid.M-1)*(Grid.N+2) 1]);

Grid.ln_rv2d=reshape(Grid.ln_r,[Grid.L*Grid.M 1]);
Grid.lt_rv2d=reshape(Grid.lt_r,[Grid.L*Grid.M 1]);
Grid.ln_uv2d=reshape(Grid.ln_u,[(Grid.L-1)*Grid.M 1]);
Grid.lt_uv2d=reshape(Grid.lt_u,[(Grid.L-1)*Grid.M 1]);
Grid.ln_vv2d=reshape(Grid.ln_v,[Grid.L*(Grid.M-1) 1]);
Grid.lt_vv2d=reshape(Grid.lt_v,[Grid.L*(Grid.M-1) 1]);
Grid.ln_pv2d=reshape(Grid.ln_p,[(Grid.L-1)*(Grid.M-1) 1]);
Grid.lt_pv2d=reshape(Grid.lt_p,[(Grid.L-1)*(Grid.M-1) 1]);

Grid.z_rv=reshape(Grid.zr,[Grid.L*Grid.M*Grid.N 1]);
Grid.z_uv=reshape(Grid.zu,[(Grid.L-1)*Grid.M*Grid.N 1]);
Grid.z_vv=reshape(Grid.zv,[Grid.L*(Grid.M-1)*Grid.N 1]);

z_rp=zeros([Grid.L Grid.M Grid.N+2]);
z_rp(:,:,2:end-1)=Grid.zr;
z_rp(:,:,1)=Grid.zw(:,:,1);
z_rp(:,:,end)=Grid.zw(:,:,end);
z_rvp=reshape(z_rp,[Grid.L*Grid.M*(Grid.N+2) 1]);
clear z_rp

z_wp=zeros([Grid.L Grid.M Grid.N+1]);
z_wp=Grid.zw;
z_wvp=reshape(z_wp,[Grid.L*Grid.M*(Grid.N+1) 1]);
clear z_wp

z_up=zeros([Grid.L-1 Grid.M Grid.N+2]);
z_up(:,:,2:end-1)=Grid.zu;
z_up(:,:,1)=0.5*(Grid.zw(2:end,:,1)+Grid.zw(1:end-1,:,1));
z_up(:,:,end)=0.5*(Grid.zw(2:end,:,end)+Grid.zw(1:end-1,:,end));
z_uvp=reshape(z_up,[(Grid.L-1)*Grid.M*(Grid.N+2) 1]);
clear z_up

z_vp=zeros([Grid.L Grid.M-1 Grid.N+2]);
z_vp(:,:,2:end-1)=Grid.zv;
z_vp(:,:,1)=0.5*(Grid.zw(:,2:end,1)+Grid.zw(:,1:end-1,1));
z_vp(:,:,end)=0.5*(Grid.zw(:,2:end,end)+Grid.zw(:,1:end-1,end));
z_vvp=reshape(z_vp,[Grid.L*(Grid.M-1)*(Grid.N+2) 1]);
clear z_vp


z_pp=zeros([Grid.L-1 Grid.M-1 Grid.N+2]);
z_pp(:,:,2:end-1)=Grid.zp;
z_pp(:,:,1)=0.25.*(Grid.zw(1:end-1,1:end-1,1)+Grid.zw(2:end,1:end-1,1)+ ...
                   Grid.zw(1:end-1,2:end,1)+Grid.zw(2:end,2:end,1));
z_pp(:,:,end)=zeros(size(z_pp(:,:,1)));
z_pvp=reshape(z_pp,[(Grid.L-1)*(Grid.M-1)*(Grid.N+2) 1]);
clear z_pp

% calculate dz/dx and dz/dy for true horizontal gradient approximations.
% at horizontal and vertical rho points.  ..just copy interior values to
% edges as necessary.
dz_dx=zeros(size(Grid.zr));
dz_dy=zeros(size(Grid.zr));

dz_dx(2:end-1,:,:)=diff(Grid.zu,1,1)./2000;   % HARDWIRED for 2 km uniform grid !!
dz_dx(1,:,:)=dz_dx(2,:,:);
dz_dx(end,:,:)=dz_dx(end-1,:,:);

dz_dy(:,2:end-1,:)=diff(Grid.zv,1,2)./2000;
dz_dy(:,1,:)=dz_dy(:,2,:);
dz_dy(:,end,:)=dz_dy(:,end-1,:);

Rcount_r=[Grid.L Grid.M Grid.N 1];
Rcount_w=[Grid.L Grid.M Grid.N+1 1];
Rcount_r2d=[Grid.L Grid.M 1];
Rcount_u2d=[Grid.L-1 Grid.M 1];
Rcount_v2d=[Grid.L Grid.M-1 1];

Rcount_u=[Grid.L-1 Grid.M Grid.N 1];
Rcount_v=[Grid.L Grid.M-1 Grid.N 1];

% Select some transects to extract data on.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lonu_f=[-172.5 -166];    % cross shelf Nunivak
% latu_f=[56.5 64];
% 
% lonu_f=[-178.9 -170.58];    % cross shelf Nunivak
% latu_f=[57.63 63.25];
%   lonu_f=[-179.7 -170.58];    % cross shelf St. Lawrence
%   latu_f=[57.63 63.25];       % slightly modified for clnd3 run to cut through interesting event

% Perpindicular to the St. Lawrence transect, from Nunivak to Chukotka.  
% lonu_f=[-180 -166.15];    % cross shelf Nunivak
% latu_f=[65 61.6];       % 

% Perpindicular to the Nunivak transect from northern chukotka penninsula
% out to the shelf break...hopefully roughly along the axis of the Anadyr
% current.  

% Cape Navarin- Canyon
%lonu_f=[-178 -181.25  ]
%latu_f=[61 62.5]

% Zhemchug transect
%lonu_f = [-179.5 -171.5];
%latu_f = [56 59.5];

% Russian Coast transects
% Trans_label = 'Russia_Khatyrka_crosshore';
% lonu_f = [-184.75 -182.5];
% latu_f = [62.25 60.25];

% Trans_label = 'Russia_along_Shirshov_ridge';
% lonu_f = [-189.75 -189.5];
% latu_f = [60 57];

% Trans_label = 'Anadyr_Basin_NW_to_SE_2';
% lonu_f = [-180.1 -173.5];
% latu_f = [65 61.5];

switch region
    case 'Gulf_of_Anadyr_NW_SE'
        Trans_label = 'Gulf_of_Anadyr_NW_SE';
        lonu_f = [-180.1 -173.5];
        latu_f = [65 61.5];

    case 'Gulf_of_Anadyr'
        Trans_label = 'Gulf_of_Anadyr';
%         lonu_f = [-181.1458 -173.4779];
%         latu_f = [62.7068 64.5947];
        lonu_f = [-181.1100 -173.1215];
        latu_f = [62.7941 64.5319];

    case 'Bering_Strait'
        Trans_label = 'Bering_Strait';
        lonu_f = [-170.9092 -167.7536];
        latu_f = [65.9476 65.6381];

    case 'Anadyr_Strait'
        Trans_label = 'Anadyr_Strait';
        lonu_f = [-173.1215 -171.5040];
        latu_f = [64.5319 63.4801];
            
    case 'Shpanberg_Strait'
        Trans_label = 'Shpanberg_Strait';
        lonu_f = [-168.9263 -164.6972];
        latu_f = [63.2776 62.8325];

    case 'Cape_Navarin'
        Trans_label = 'Cape_Navarin';
        lonu_f = [-181.1100 -178.7333];
        latu_f = [62.7941 61.2621];

    case 'Slope'
        Trans_label = 'Slope';
        lonu_f = [-180.6479 -164.6049];
        latu_f = [62.7713 54.6082];
    
    case 'Navarin_Matthew'
        Trans_label = 'Navarin_Matthew';
        lonu_f = [-181.1100 -172.9703];
        latu_f = [62.7941 60.5403];

    case 'Mattew_Lawrence'
        Trans_label = 'Mattew_Lawrence';
        lonu_f = [-172.9703 -171.5040];
        latu_f = [60.5403 63.4801];
end

%lonu_f=[-174.333 -180];
%latu_f=[64.666 61.2];
% lonu_f=[-179.00 -170.6];    % Alongshelf transect (outer shelf).
% latu_f=[61.95 57.46];

% lonu_f=[-171.95 -167.4];   % C-line 
% latu_f=[59.92 60.7];

% lonu_f=[-169.8 -167.9];   % S-line
% latu_f=[56.5 59.9];

%lonu_f=[-174.5 -166];   % N-line
%latu_f=[62.2 61.8];

% lonu_f=[-179.72 -171.51];    % Alongshelf transect (farther out on shelf).
% latu_f=[61.47 57.14];
% lonu_f=[-177.9 -169.34];    % Alongshelf transect (farther out on shelf).
% latu_f=[62.43 58.18];

%lonu_f=[-178.5 -168.5];   % along shelf
%latu_f=[61.75 57.];

% we now have a smoothed set of line segments. 
% Next we want to distribute 
% points evenly along this smooth curve.. more or less.
for ij=1:length(latu_f)-1
   [slen(ij),azimuth]=distance(latu_f(ij), lonu_f(ij), latu_f(ij+1), lonu_f(ij+1), ...
        almanac('earth', 'ellipsoid', 'km'));
end 
slen=[0; slen];
sltot=sum(slen);
nseg=fix(sltot)./2;  % for 2 km resolution along path.
cumulativeLen = cumsum(slen);
finalStepLocs = linspace(0,cumulativeLen(end), nseg);
pathXY(:,1)=lonu_f;
pathXY(:,2)=latu_f;
pathLnLt= interp1(cumulativeLen, pathXY, finalStepLocs);

Seg(1).lat=pathLnLt(:,2);
Seg(1).lon=pathLnLt(:,1);
% calculate the ds and azimuthal angle of each segment
for ij=1:length(Seg(1).lon)-1
   [Seg(1).ds(ij),Seg(1).azimuth(ij)]=distance(Seg(1).lat(ij), Seg(1).lon(ij),  ...
        Seg(1).lat(ij+1), Seg(1).lon(ij+1), almanac('earth', 'ellipsoid', 'km'));
end
Seg.ln_scl=110000;
Seg.lt_scl=ln_scl.*cos(60/180*pi);

xtra_lon=0.04;
xtra_lat=0.03;
        
% define collection of grid points to be used in the interpolant.  add points 
% to the south and northern ends of the segment to make the box slightly
% bigger.
for iss=1:length(Seg)
    lon_end=Seg(iss).lon(end);
    lon_start=Seg(iss).lon(1);
    lat_end=Seg(iss).lat(end);
    lat_start=Seg(iss).lat(1);
    %
   % from the start and end points generate a uniform grid of data points to
    % attain the fields on ....here I am using 2 km resolution...and doing
    % this as a great arc on an earth ellipsoid, for better or worse...I
    % figure the great arc is the shortest distance between two points on a
    % sphere, so although the angle relative to true north technically
    % changes along a great arc, it's the closest representation to a
    % straight line on a sphere.
        
    Seg(iss).s_sec=[0 cumsum(Seg(iss).ds)];
    % Let the grid points that are being interpolated to be the midpoints
    % of the points specified in Seg.lon and Seg.lat.
    Seg(iss).latsec=0.5*(Seg(iss).lat(2:end)+Seg(iss).lat(1:end-1));
    Seg(iss).lonsec=0.5*(Seg(iss).lon(2:end)+Seg(iss).lon(1:end-1));
    
    Seg(iss).lonseca=repmat(Seg(iss).lonsec, [1 Nvlvl]);
    Seg(iss).latseca=repmat(Seg(iss).latsec, [1 Nvlvl]);

    Seg(iss).lonsecwa=repmat(Seg(iss).lonsec, [1 Nvlvl+1]);
    Seg(iss).latsecwa=repmat(Seg(iss).latsec, [1 Nvlvl+1]);
    
    % Since our transect is arguably a curve on the sphere rather than a
    % straight line, let's replace our rectangular bounding box idea used
    % earlier to determine nearby points with a polygon specifically linked
    % to our specified line segment..so it's something of a curved bounding
    % box. ... This will allow us to interpolate onto arbitrarily shaped
    % transects ultimately (although sharp bends might be  an issue..)
    
    % first determine corner points perpindicular to our line a specified distance
    % to each side of endpoints of an extended line segment
    %cl_sec=[-2*Seg(iss).ds(1) Seg(iss).s_sec(1:10:end) Seg(iss).slen+2*Seg(iss).ds(1)];
    [cl_box_lt1,cl_box_ln1]=reckon(lat_start, lon_start, ...
        -8,Seg(iss).azimuth(1), almanac('earth', 'ellipsoid', 'km'));
    [cl_box_lt2,cl_box_ln2]=reckon(lat_end, lon_end, ...
        8,Seg(iss).azimuth(end), almanac('earth', 'ellipsoid', 'km'));
    % reckon will automatically wrap around longitudes to positive values,
    % so we need to 'enforce' values below -180 in order to fit into our
    % 'western hemisphere' grids.
    if cl_box_ln1>0, cl_box_ln1=cl_box_ln1-360; end
    if cl_box_ln2>0, cl_box_ln2=cl_box_ln2-360; end
    
    cl_box_lt=[cl_box_lt1; Seg(iss).lat; cl_box_lt2];
    cl_box_ln=[cl_box_ln1; Seg(iss).lon; cl_box_ln2];
    azbx=[Seg(iss).azimuth(1) Seg(iss).azimuth(1) Seg(iss).azimuth Seg(iss).azimuth(end)];
    % Determine box corners... 10 km wide box
    for ibp=1:length(cl_box_lt)
        [edge1_box_lt(ibp),edge1_box_ln(ibp)]=reckon(cl_box_lt(ibp), cl_box_ln(ibp), ...
            5,azbx(ibp)-90, almanac('earth', 'ellipsoid', 'km'));
        [edge2_box_lt(ibp),edge2_box_ln(ibp)]=reckon(cl_box_lt(ibp), cl_box_ln(ibp), ...
            5,azbx(ibp)+90, almanac('earth', 'ellipsoid', 'km'));
    end
    % again we have to enforce western hemisphere coordinates.
    edge1_box_ln(edge1_box_ln>0)=edge1_box_ln(edge1_box_ln>0)-360;
    edge2_box_ln(edge2_box_ln>0)=edge2_box_ln(edge2_box_ln>0)-360;

% subsample since we have way too many points defining this polygon.  
 ids=4
    trans_box_lon=[edge1_box_ln(1:ids:end) edge1_box_ln(end) ...
                  edge2_box_ln(end:-ids:1) edge2_box_ln(1) edge1_box_ln(1)];
    trans_box_lat=[edge1_box_lt(1:ids:end) edge1_box_lt(end) ...
                  edge2_box_lt(end:-ids:1) edge2_box_lt(1) edge1_box_lt(1)];
   % NOTE:  This next step can take an extremely long time for some reason (+10 minutes! for 
   % long paths.  But we only need to do it once.             .. or maybe
   % we can get away with just doing the 2d. The indicies into a 3d array
   % that correspond to the same i,j locations at different k levels are
   % just the 2D index +(Grid.L*Grid.M)*ik  (for a rho-point array).
%    Seg(iss).Rindx_nearby_r=find(strcmp(inpolygon(Grid.ln_rv,Grid.lt_rv,trans_box_lon,trans_box_lat));
    Seg(iss).Rindx_nearby_r2d=find(inpolygon(Grid.ln_rv2d,Grid.lt_rv2d,trans_box_lon,trans_box_lat));
    Seg(iss).Rindx_nearby_u2d=find(inpolygon(Grid.ln_uv2d,Grid.lt_uv2d,trans_box_lon,trans_box_lat));
    Seg(iss).Rindx_nearby_v2d=find(inpolygon(Grid.ln_vv2d,Grid.lt_vv2d,trans_box_lon,trans_box_lat));
    Seg(iss).Rindx_nearby_p2d=find(inpolygon(Grid.ln_pv2d,Grid.lt_pv2d,trans_box_lon,trans_box_lat));
    
%    Seg(iss).Rindx_nearby_u=find(strcmp(inpolygon(Grid.ln_uv,Grid.lt_uv,trans_box_lon,trans_box_lat));
%    Seg(iss).Rindx_nearby_v=find(strcmp(inpolygon(Grid.ln_vv,Grid.lt_vv,trans_box_lon,trans_box_lat));
    iss
end

% Create the 3d index arrays, fill them in one ik-level at a time using the
% 2d points determined above.
Nrpts=Grid.L.*Grid.M;
Nirpts=length(Seg(iss).Rindx_nearby_r2d);
Nupts=(Grid.L-1).*Grid.M;
Niupts=length(Seg(iss).Rindx_nearby_u2d);
Nvpts=Grid.L.*(Grid.M-1);
Nivpts=length(Seg(iss).Rindx_nearby_v2d);
Nppts=(Grid.L-1).*(Grid.M-1);
Nippts=length(Seg(iss).Rindx_nearby_p2d);

for iss=1:length(Seg)
  for ik=1:Grid.N+2
    irng=1+(ik-1)*Nirpts:ik*Nirpts;
    Seg(iss).Rindx_nearby_rp(irng)=Seg(iss).Rindx_nearby_r2d+Nrpts.*(ik-1);
    irng=1+(ik-1)*Niupts:ik*Niupts;
    Seg(iss).Rindx_nearby_up(irng)=Seg(iss).Rindx_nearby_u2d+Nupts.*(ik-1);
    irng=1+(ik-1)*Nivpts:ik*Nivpts;
    Seg(iss).Rindx_nearby_vp(irng)=Seg(iss).Rindx_nearby_v2d+Nvpts.*(ik-1);
    irng=1+(ik-1)*Nippts:ik*Nippts;
    Seg(iss).Rindx_nearby_pp(irng)=Seg(iss).Rindx_nearby_p2d+Nppts.*(ik-1);
  end
end
% For w-points we collect these points slightly differently.
for iss=1:length(Seg)
  for ik=1:Grid.N+1
    irng=1+(ik-1)*Nirpts:ik*Nirpts;
    Seg(iss).Rindx_nearby_wp(irng)=Seg(iss).Rindx_nearby_r2d+Nrpts.*(ik-1);
  end
end

% Determine the smallest box that encloses the necessary points for each
% grid type, so that a subset of the field can be read in.
for iss=1:length(Seg),
    [ii,ij]=ind2sub([Grid.L Grid.M],Seg(iss).Rindx_nearby_r2d); 
    Seg(iss).iLr=min(ii):max(ii);
    Seg(iss).iMr=min(ij):max(ij);
    [ii,ij]=ind2sub([Grid.L-1 Grid.M],Seg(iss).Rindx_nearby_u2d); 
    Seg(iss).iLu=min(ii):max(ii);
    Seg(iss).iMu=min(ij):max(ij);
    [ii,ij]=ind2sub([Grid.L Grid.M-1],Seg(iss).Rindx_nearby_v2d); 
    Seg(iss).iLv=min(ii):max(ii);
    Seg(iss).iMv=min(ij):max(ij);
end

% Interpolate the bathymetry onto the specific segment lines.

  Fld_intrp=scatteredInterpolant(reshape(Grid.ln_r,[Grid.L.*Grid.M 1]),   ...
                               reshape(Grid.lt_r,[Grid.L.*Grid.M 1]),   ... 
                               reshape(-Grid.h,[Grid.L.*Grid.M 1]));
                            
for iss=1:length(Seg)
  Seg(iss).depth=Fld_intrp(Seg(iss).lonsec, Seg(iss).latsec);
  [Seg(iss).zseca,Seg(iss).sc,Seg(iss).Cs]=scoord_new_1d_newest(-Seg(iss).depth,zeros(size(Seg(iss).depth))', ...
                                    Grid,0, ...
                                    0,1,0);
  [Seg(iss).zsecaw,sc,Cs]=scoord_new_1d_newest(-Seg(iss).depth,zeros(size(Seg(iss).depth))', ...
                                    Grid,1, ...
                                    0,1,0);       
end


% Use the depth profile at the section to determine a sigma coordinate and
% the zlevels to interpolate to.

% Create a mask at each transect...
  Fld_intrp_msk=scatteredInterpolant(reshape(Grid.ln_r,[Grid.L.*Grid.M 1]),   ...
                               reshape(Grid.lt_r,[Grid.L.*Grid.M 1]),   ... 
                               reshape(Grid.mask_r,[Grid.L.*Grid.M 1]));
                              
for iss=1:length(Seg)
  tmp=Fld_intrp_msk(Seg(iss).lonsec, Seg(iss).latsec);
  indx=find(tmp<0.99);
  Seg(iss).mask2d=ones(size(tmp));
  Seg(iss).mask2d(indx)=NaN;
  Seg(iss).mask=ones(size(Seg(iss).lonseca));
  for ik=1:Nvlvl
    Seg(iss).mask(indx,:)=NaN;
  end
end

%----
% latlim=[min(min(Grid.lt_r)) max(max(Grid.lt_r))];
% lonlim=[min(min(Grid.ln_r)) max(max(Grid.ln_r))];
% ax = axesm('mercator', 'MapLatLimit', [latlim(1)+4 latlim(2)-5], 'MapLonLimit', [lonlim(1) lonlim(2)]);
% gridm;
% mlabel; plabel

% for the purposes of parallelization we keep the size of all the
% vectors being passed to a parfor loop quite small, so let me clip the
% segments of the vectors needed for each calculation prior to the parfor
% loops. ...  These variables are a bit extraneous really but we will leave
% this in for now...

for iss=1:length(Seg)
  G(iss).ln_uv=ln_uvp(Seg(iss).Rindx_nearby_up).*ln_scl;
  G(iss).lt_uv=lt_uvp(Seg(iss).Rindx_nearby_up).*lt_scl;
  G(iss).z_uv=z_uvp(Seg(iss).Rindx_nearby_up);
  G(iss).ln_vv=ln_vvp(Seg(iss).Rindx_nearby_vp).*ln_scl;
  G(iss).lt_vv=lt_vvp(Seg(iss).Rindx_nearby_vp).*lt_scl;
  G(iss).z_vv=z_vvp(Seg(iss).Rindx_nearby_vp);
  G(iss).ln_pv=ln_pvp(Seg(iss).Rindx_nearby_pp).*ln_scl;
  G(iss).lt_pv=lt_pvp(Seg(iss).Rindx_nearby_pp).*lt_scl;
  G(iss).z_pv=z_pvp(Seg(iss).Rindx_nearby_pp);
  
  G(iss).ln_rv=ln_rvp(Seg(iss).Rindx_nearby_rp).*ln_scl;
  G(iss).lt_rv=lt_rvp(Seg(iss).Rindx_nearby_rp).*lt_scl;
  G(iss).z_rv=z_rvp(Seg(iss).Rindx_nearby_rp);
  G(iss).ln_wv=ln_wvp(Seg(iss).Rindx_nearby_wp).*ln_scl;
  G(iss).lt_wv=lt_wvp(Seg(iss).Rindx_nearby_wp).*lt_scl;
  G(iss).z_wv=z_wvp(Seg(iss).Rindx_nearby_wp);
  
  G(iss).ln_rv2d=Grid.ln_rv2d(Seg(iss).Rindx_nearby_r2d).*ln_scl;
  G(iss).lt_rv2d=Grid.lt_rv2d(Seg(iss).Rindx_nearby_r2d).*lt_scl;
  G(iss).ln_uv2d=Grid.ln_uv2d(Seg(iss).Rindx_nearby_u2d).*ln_scl;
  G(iss).lt_uv2d=Grid.lt_uv2d(Seg(iss).Rindx_nearby_u2d).*lt_scl;
  G(iss).ln_vv2d=Grid.ln_vv2d(Seg(iss).Rindx_nearby_v2d).*ln_scl;
  G(iss).lt_vv2d=Grid.lt_vv2d(Seg(iss).Rindx_nearby_v2d).*lt_scl;
end

    
% ind_start=find(file_i.times>=start_day);
% ind_end=find(file_i.times>=end_day);
% if isempty(ind_end)
%     ind_end=ind_start(end);
%     Nt=length(ind_start);
% else
%     Nt=ind_end(1)-ind_start(1)+1
% end

% for now just go from the start to however many records we have
% Nt=length(ind_start);
Nt=length(mm_all);
% Preallocate space for the Field structure

for iv=1:length(Rvarname),
    if varDim(iv)==2,
       Sec(iss).(Rvarname{iv})=zeros([length(Seg(iss).lonsec) Nt]);
    elseif varDim(iv)==3,
       Sec(iss).(Rvarname{iv})=zeros([length(Seg(iss).lonsec) Nvlvl Nt]);
    end
end

% Generate scattered interpolants for u-points, v-points, rho-points,
% w-points and psi-points.  
Fld_intrp_r2d=scatteredInterpolant(G(iss).ln_rv2d, G(iss).lt_rv2d, ...
            zeros(size(Seg(iss).Rindx_nearby_r2d)),'linear');    
Fld_intrp_u2d=scatteredInterpolant(G(iss).ln_uv2d, G(iss).lt_uv2d, ...
            zeros(size(Seg(iss).Rindx_nearby_u2d)),'linear');
Fld_intrp_v2d=scatteredInterpolant(G(iss).ln_vv2d, G(iss).lt_vv2d, ...
            zeros(size(Seg(iss).Rindx_nearby_v2d)),'linear');        

Fld_intrp_u=scatteredInterpolant(G(iss).ln_uv, G(iss).lt_uv, G(iss).z_uv, ...
                                 zeros(size(Seg(iss).Rindx_nearby_up))','linear');
Fld_intrp_v=scatteredInterpolant(G(iss).ln_vv, G(iss).lt_vv, G(iss).z_vv, ...
                                 zeros(size(Seg(iss).Rindx_nearby_vp))','linear');
Fld_intrp_r=scatteredInterpolant(G(iss).ln_rv, G(iss).lt_rv, G(iss).z_rv, ...
                                 zeros(size(Seg(iss).Rindx_nearby_rp))','linear');
Fld_intrp_w=scatteredInterpolant(G(iss).ln_wv, G(iss).lt_wv, G(iss).z_wv, ...
                                 zeros(size(Seg(iss).Rindx_nearby_wp))','linear');
Fld_intrp_p=scatteredInterpolant(G(iss).ln_pv, G(iss).lt_pv, G(iss).z_pv, ...
                                 zeros(size(Seg(iss).Rindx_nearby_pp))','linear');

                            

% Collect all the data along the transect
% ROMS
% Ntt=ind_end(1)-ind_start(1);
% timeh=file_i.times(ind_start:ind_end);
fprintf('Interpolation \n');

% IN this iteration we send each field off as a batch job to a processor.
% Because we have 6 processors on this machine, we wait after the 6th job
% is returned before dispatching any more jobs....this might be unnecessary..
% it is..as.. the disk reading is the limiting rate.

% The next step in the optimization of this will be to identify the
% smallest box that encloses the transect and only read in that chunk of
% each field.
% time_ind_rng=ind_start(1):ind_end(1)-1;
time_ind_rng=mm_all;

% only submit 5 batch jobs max, at a time
tic;
for iv=1:min(length(Rvarname),5)
    switch RvarDim{iv}
        case {'r2d'}   
            Job(iv).id=batch('interp_to_transect_r2d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M], ...
                Rvarname{iv},Fld_intrp_r2d},'Pool',3);
        case {'u2d'}   
            Job(iv).id=batch('interp_to_transect_u2d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M], ...
                Rvarname{iv},Fld_intrp_u2d},'Pool',3);
        case {'v2d'}   
            Job(iv).id=batch('interp_to_transect_v2d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M], ...
                Rvarname{iv},Fld_intrp_v2d},'Pool',3);
        case {'r3d'}    
            Job(iv).id=batch('interp_to_transect_r3d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                Rvarname{iv},Fld_intrp_r},'Pool',3);
        case {'u3d'}
            Job(iv).id=batch('interp_to_transect_u3d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                Rvarname{iv},Fld_intrp_u},'Pool',3);
        case {'v3d'}
            Job(iv).id=batch('interp_to_transect_v3d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                Rvarname{iv},Fld_intrp_v},'Pool',3);
        case {'w3d'}
            Job(iv).id=batch('interp_to_transect_w3d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                Rvarname{iv},Fld_intrp_w},'Pool',3);
        case {'p3d'}
            Job(iv).id=batch('interp_to_transect_rel_vort_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                Grid.dxp,Grid.dyp,Fld_intrp_p},'Pool',3);
    end
end

for iv=1:min(length(Rvarname),5),
  wait(Job(iv).id);
end
% Work the next 5
if length(Rvarname)>5
    for iv=6:min(length(Rvarname),10),
        switch RvarDim{iv}
            case {'r2d'}
                Job(iv).id=batch('interp_to_transect_r2d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M], ...
                    Rvarname{iv},Fld_intrp_r2d},'Pool',3);
            case {'u2d'}   
                Job(iv).id=batch('interp_to_transect_u2d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M], ...
                Rvarname{iv},Fld_intrp_u2d},'Pool',3);
            case {'v2d'}   
                Job(iv).id=batch('interp_to_transect_v2d_nc_monthly',1, ...
                {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M], ...
                Rvarname{iv},Fld_intrp_v2d},'Pool',3);

            case {'r3d'}
                Job(iv).id=batch('interp_to_transect_r3d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                    Rvarname{iv},Fld_intrp_r},'Pool',3);
            case {'u3d'}
                Job(iv).id=batch('interp_to_transect_u3d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                    Rvarname{iv},Fld_intrp_u},'Pool',3);
            case {'v3d'}
                Job(iv).id=batch('interp_to_transect_v3d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                    Rvarname{iv},Fld_intrp_v},'Pool',3);
            case {'w3d'}
                Job(iv).id=batch('interp_to_transect_w3d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                    Rvarname{iv},Fld_intrp_w},'Pool',3);
            case {'p3d'}
                Job(iv).id=batch('interp_to_transect_rel_vort_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                    Grid.dxp,Grid.dyp,Fld_intrp_p},'Pool',3);
        end
    end
    % Fetch the output of each job
    for iv=6:min(length(Rvarname),10),
        wait(Job(iv).id);
    end
end

if length(Rvarname)>10,
    for iv=11:length(Rvarname),
        switch RvarDim{iv}
            case {'r2d'}
                Job(iv).id=batch('interp_to_transect_r2d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M], ...
                    Rvarname{iv},Fld_intrp_r2d},'Pool',3);
            case {'u2d'}
                Job(iv).id=batch('interp_to_transect_u2d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M],...
                    Rvarname{iv},Fld_intrp_u2d},'Pool',3);
            case {'v2d'}
                Job(iv).id=batch('interp_to_transect_v2d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M],...
                    Rvarname{iv},Fld_intrp_v2d},'Pool',3);

            case {'r3d'}
                Job(iv).id=batch('interp_to_transect_r3d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N],...
                    Rvarname{iv},Fld_intrp_r},'Pool',3);
            case {'u3d'}
                Job(iv).id=batch('interp_to_transect_u3d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                    Rvarname{iv},Fld_intrp_u},'Pool',3);
            case {'v3d'}
                Job(iv).id=batch('interp_to_transect_v3d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                    Rvarname{iv},Fld_intrp_v},'Pool',3);
            case {'w3d'}
                Job(iv).id=batch('interp_to_transect_w3d_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N],...
                    Rvarname{iv},Fld_intrp_w},'Pool',3);
            case {'p3d'}
                Job(iv).id=batch('interp_to_transect_rel_vort_nc_monthly',1, ...
                    {Seg,iss,time_ind_rng,file_i,[Grid.L Grid.M Grid.N], ...
                    Grid.dxp,Grid.dyp,Fld_intrp_p},'Pool',3);
        end
    end
    % Fetch the output of each job
    for iv=11:length(Rvarname),
        wait(Job(iv).id);
    end
end

toc;

for iv=1:length(Rvarname),
    Jt=fetchOutputs(Job(iv).id);
    Sec(iss).(Rvarname{iv})=Jt{1};
end
for iv=1:length(Rvarname),
    delete(Job(iv).id);
    clear Jt;
end

% timeR=times;
% timeR=file_i.times(time_ind_rng); 
timeR = datenum(yyyy,mm_all,15);
fprintf('\n Done \n')  

% calculate normal and tangential velocities (this depends on how we want
% to define these directions relative to the orientation of the section
for it = 1:length(time_ind_rng)
    for ik= 1:Grid.N
        Sec(iss).v_n(:,ik,it) =squeeze( sind(Seg(iss).azimuth)'.*Sec(iss).u(:,ik,it)  ...
             - cosd(Seg(iss).azimuth)'.*Sec(iss).v(:,ik,it));
        Sec(iss).u_t(:,ik,it) = -cosd(Seg(iss).azimuth)'.*Sec(iss).u(:,ik,it)  ...
             - sind(Seg(iss).azimuth)'.*Sec(iss).v(:,ik,it);
    end
end

fprintf('\n ..saving \n')

out_file = sprintf('%s_transect_ocean_vars_%s_monthly.mat', ...
                   Trans_label, num2str(yyyy));
save(out_file,'-v7.3','Seg','Sec','timeR'); 

% rmpath(genpath('/home/grindylow/sdurski/matlab_tools/ROMS_general_tools'));


% function make_bndy_fromROMSoutput_sin
% ==========================================================================
% build boundary fields for a nested roms grid 
% from data in a larger roms grid.
% Data file could be history or average file.
%
% Algorithm: 
% Get vertical distribution of a variable for a given grid cell,
% (j,i) nested grid cell.
% (1) find nearest four points in larger domain
% (2) calculate weight using distance
% (3) vertical interpolation at four points
% (4) horizontal interpolation base on wights in (2)
% BJ Choi, sept-15-2005
%
% infile      = larger domain roms data file (his.nc or avg.nc)
% analysis_day = time of infile (in days)
% out_file     = boundary file for the nested domain (init.nc)
%
% USE: nc_create_roms_init.m
%      write_roms_init.m
%      grd.m
% ==========================================================================
% version 3 (Oct-07-2005)
% 
% (1) u and v are not true eastward and northward velocities. They are ROMS
% variables. Interpolate u and v on rho points and rotate velocity vectors
% to true eastward and northward.
%
% (2) volume conservation across open boundaries. 
% Because bottom depths are different in larger domain 
% and the nested domain, current speed across the boundary (ubar, vbar) should be 
% multiplied by depth ratio, i.e., U_nested = U_large * h_large / h_nested 
% Here, h_large / h_nested = 1 + (h_l - h_n) / h_n ~= 1 + alpha * (h_l - h_n) / h_n 
%       alpha = 0.30 or 1.0 
% Calculate amount of volume transport difference between large domain data and 
% nested domain estimated value, and add a constant speed to the nested domain 
% estimated speed for the compensation of total volume transport difference
%
% ==========================================================================
clear all; clc

disp(' read grid information of larger domain and the nested smaller domain')

if exist('gl')~=1
   gl = grd('auto');         % (1) Get Larger grid information
end

if exist('gn')~=1
%   gn = grd('yw_n10');
%   gn = grd('nwps10tanh'); 
    gn = grd('HF');          % (2) Get Nested grid information
end

% (3) roms data file from a larger domain
% infile='/home/server/project/bjchoi/ccs2000/ocean_avg_0002.nc';
head='G:\ROMS\OUTPUT\roms auto output\';
filedir = dir(head); filedir(1:2) = []; filedir(end) = [];
foot='.nc';

% sourcestr = [ 'From 1/4 deg. : to 10km resolution '];
% check file number   ex) avg_1606.nc ~ avg_1666.nc
% start_file = 0050;  %% use//  file_type = 'sequence_number';
start_file = 1155;   %% use//  file_type = 'year_mon_number';
end_file = 1155;

file_type = 'sequence_number'; %% sequence_number // 0001.nc
% file_type = 'year_mon_number'; %% year_mon_number // YYYY_MM.nc
ref_year = 2013 ;  %% Model data is 1993, then input 1992

% (5) output file, boundary file for the nested grid
% out_file = 'roms_yw_init1996_layer20.nc';
% mkdir(out_head);
out_head = './';

% (4) set time: time from the base_date in days.
%  analysis_day= 0 ; % Jan 1, 1996 0 0 0 = 203  86400*4
% for iyear=1992:2002
% for iyear=1992:1992
%year = (end_file-start_file+1)/12;
year = 1;

out_file = [out_head,'roms_bndy_HF_jh_20140228',foot];

disp([' create an empty boundary file = ' out_file])
noclobber = 0;
base_date = [ref_year+1 1 1 0 0 0];
time_variable = 'ocean_time';
cycle_length = 360*year ;
time_variable_units = basedate2str(base_date);
roms.grd = gn;
grd_file = gn.grd_file;
details = [ 'Quick boundary file from East Asia Seas 1/4 deg ' ...
            'by script ' which(mfilename) ];
donuts = 0;
nc_create_roms_bndy_nest  % create an nc file, write variables and close it.
disp([' creating an empty boundary file done ..... '])
disp('  ')
% ================= End of Input Parameters =================================

fm=0;
for f=start_file:end_file
    fm=fm+1;

if (file_type == 'sequence_number')
    %infile=[head, filedir(f - (start_file-1) + 59).name, '\', 'avg_',num2char(f,4),foot]
    infile=[head, '2014022800\', 'avg_',num2char(f,4),foot]
    %infile=[head,num2char(f,4),foot];
elseif (file_type == 'year_mon_number')
    conv_mon = mod(f,12);   
    if conv_mon == 0
        conv_mon = 12;
    elseif conv_mon == 1
        ref_year = ref_year +1 ;
    end
    infile=[head,num2str(ref_year),'_',num2char(conv_mon,2),foot]; 
end


% out_file = ['roms_yw_bndy_',num2str(fm),'.nc'];
% Information for the boundary conditions file
% and create an empty boundary file

% read data from larger domain
disp([' read data from the larger domain roms file = ' infile])
disp([' wait ..... '])
nc=netcdf(infile);
temp=nc{'temp'}(:);
salt=nc{'salt'}(:);
zeta=nc{'zeta'}(:);
ubar_dump=nc{'ubar'}(:);
vbar_dump=nc{'vbar'}(:);
u_dump=nc{'u'}(:);
v_dump=nc{'v'}(:);
close(nc)
disp([' reading done ..... '])
disp('  ')

%(1)interpolate ubar_dump and vbar_dump on rho-points
% rho    points 514x510 
% ubar   points 514x509
% vbar   points 513x510

[M N]=size(ubar_dump);
ubar =ones(M,N+1)*NaN;
ubar(:,2:N) = ( ubar_dump(:,1:N-1)+ubar_dump(:,2:N) ) * 0.5;
ubar(:,1)   = ubar_dump(:,1);
ubar(:,N+1) = ubar_dump(:,N);

[M N]=size(vbar_dump);
vbar =ones(M+1,N)*NaN;
vbar(2:M,:) = ( vbar_dump(1:M-1,:)+vbar_dump(2:M,:) ) * 0.5;
vbar(1,:)   = vbar_dump(1,:);
vbar(M+1,:) = vbar_dump(M,:);


[L M N]=size(u_dump);
u =ones(L,M,N+1)*NaN;
u(:,:,2:N) = ( u_dump(:,:,1:N-1)+u_dump(:,:,2:N) ) * 0.5;
u(:,:,1)   = u_dump(:,:,1);
u(:,:,N+1) = u_dump(:,:,N);


[L M N]=size(v_dump);
v =ones(L,M+1,N)*NaN;
v(:,2:M,:) = ( v_dump(:,1:M-1,:)+v_dump(:,2:M,:) ) * 0.5;
v(:,1,:)   = v_dump(:,1,:);
v(:,M+1,:) = v_dump(:,M,:);

%(2)roate them to get true eastward and northward velocities.
%   unit of g.angle is radian ( 0.74 = 42 degree )
%
%  | true_u | = | cos(angle) -sin(angle) | | u |
%  | true_v |   | sin(angle)  cos(angle) | | v |
%  where (u,v)' is roms space vector

true_ubar=cos(gl.angle).*ubar - sin(gl.angle).*vbar;
true_vbar=sin(gl.angle).*ubar + cos(gl.angle).*vbar;

cos_angle3D=repmat( cos(gl.angle) ,[1 1 L ]);
cos_angle3D=permute(cos_angle3D, [3 1 2]);
sin_angle3D=repmat( sin(gl.angle) ,[1 1 L ]);
sin_angle3D=permute(sin_angle3D, [3 1 2]);

true_u=cos_angle3D.*u - sin_angle3D.*v;
true_v=sin_angle3D.*u + cos_angle3D.*v;


% size of grids
[r,c] = size ( gl.lon_rho );
   nl = gl.N;  
[M N] = size ( gn.lon_rho );
   nn = gn.N;

% find deepest depth
maxdepth=max([max(max(gl.h)) max(max(gn.h))])+500;

% extraplolate data (variables) horizonally
% into the land. 
% three land grid points next to the coast will have data.
disp([' horizontal extrapolation of original data '])

mask=gl.mask_rho;
mask_temp=mask;
for numofextrapol=1:3
 Iland=find(  mask_temp == 0 );
 num_land_grid=length(Iland);
 for i=1:num_land_grid
   
   ind = Iland(i);
   row_index = mod ( ind - 1, r ) + 1;
   col_index = floor( (ind - 1) / r ) + 1;
   extflag=0;

   if(     (col_index > 2) && (mask(row_index,col_index-1) == 1) )
     oj=row_index; oi=col_index-1; extflag=1;
   elseif( (col_index < c) && (mask(row_index,col_index+1) == 1) )
     oj=row_index; oi=col_index+1; extflag=1;
   elseif( (row_index > 2) && (mask(row_index-1,col_index) == 1) )
     oj=row_index-1; oi=col_index; extflag=1;
   elseif( (row_index < r) && (mask(row_index+1,col_index) == 1) )
     oj=row_index+1; oi=col_index; extflag=1;
   end

   if( extflag )
     % 2D variables
     zeta(row_index,col_index)       = zeta(oj,oi);
     true_ubar(row_index,col_index)  = true_ubar(oj,oi);
     true_vbar(row_index,col_index)  = true_vbar(oj,oi);
     % 3D variables
     temp(:,row_index,col_index)   = temp(:,oj,oi);
     salt(:,row_index,col_index)   = salt(:,oj,oi);
     true_u(:,row_index,col_index) = true_u(:,oj,oi);
     true_v(:,row_index,col_index) = true_v(:,oj,oi);
     % reset mask value
     mask_temp(row_index,col_index)=1; 
   end

 end % of for i=1:num_land_grid
 mask=mask_temp; 
end  % of for numofextrapol=1:2


% find land mask from gl grid
ocean=ones(r,c);
land =ones(r,c)*1.e20;
Isea=find( mask > 0);
land(Isea)=ocean(Isea);    % 1 for ocean and 1.e20 for land
clear ocean Isea

% extrapolate data in vertical direction
disp([' vertical extrapolation of original data '])

extsalt(1,:,:)=salt(1,:,:);         % add bottom ( at -maxdepth)
extsalt(2:nl+1,:,:)=salt(1:nl,:,:); % data
extsalt(nl+2,:,:)=salt(nl,:,:);     % add top    ( 20 m above sea level)

exttemp(1,:,:)=temp(1,:,:);         % add bottom ( at -maxdepth)
exttemp(2:nl+1,:,:)=temp(1:nl,:,:); % data
exttemp(nl+2,:,:)=temp(nl,:,:);     % add top    ( 20 m above sea level)

extu(1,:,:)=true_u(1,:,:);         % add bottom ( at -maxdepth)
extu(2:nl+1,:,:)=true_u(1:nl,:,:); % data
extu(nl+2,:,:)=true_u(nl,:,:);     % add top    ( 20 m above sea level)

extv(1,:,:)=true_v(1,:,:);         % add bottom ( at -maxdepth)
extv(2:nl+1,:,:)=true_v(1:nl,:,:); % data
extv(nl+2,:,:)=true_v(nl,:,:);     % add top    ( 20 m above sea level)


% initiailize boundary data file
disp([' initiailize roms structure (boundary data file) '])
% east west south north

% d4=end_file-start_file+1;
% roms.time = (fm-1)*30 + 15 ;
roms.temp = zeros([gn.N size(gn.lon_rho)]);
roms.salt = zeros([gn.N size(gn.lon_rho)]);
roms.zeta = zeros(size(gn.h));
roms.u = zeros([gn.N size(gn.lon_u)]);
roms.v = zeros([gn.N size(gn.lon_v)]);
roms.vbar = zeros(size(gn.lon_v));
roms.ubar = zeros(size(gn.lon_u));

ntrue_ubar = zeros(size(gn.h));
ntrue_vbar = zeros(size(gn.h));
ntrue_u = zeros([gn.N size(gn.lon_rho)]);
ntrue_v = zeros([gn.N size(gn.lon_rho)]);

% write_roms_bndy(out_file,roms) % append zeros to an existing empty boundary file
                               % and close it.
% write_roms_init(out_file,roms)    
% write_roms_init_nest(out_file,roms,fm,d4)
% write_roms_init_nest(out_file,roms,fm)

% % nc = netcdf(out_file,'write');
% % % append to an existing boundary file
% % time_variable_name = nc{'temp'}.time(:)
% % nc_tindex = 1;
% % nc_tindex = d4;
% % nc{'ocean_time'}(nc_tindex) = roms.time;
% % 
% % for varlist = { 'temp','salt','u','v'}
% %   varname = char(varlist);
% %   data = getfield(roms,varname);
% %   nc{varname}(fm,:,:,:) = data;
% % end
% % 
% % for varlist = { 'zeta','ubar','vbar'}
% %   varname = char(varlist);
% %   data = getfield(roms,varname);
% % %   nc{varname}(nc_tindex,:,:) = data;
% %   nc{varname}(fm,:,:) = data;
% % end
% % close(nc)


disp([' appending default values to boundary file done ..... '])
disp('  ')

% =======================================================================
% vertical and horizonatal interpolation of variables 
% such as temp, salt, zeta, true_u, true_v, true_ubar and true_vbar
% from larger domain to the nested domain.
% =======================================================================

disp([' ================================================ '])
disp([' interpolating temp and salt on the nested domain '])
disp([' wait .....                              '])
disp(['                                         '])

% for j=1:M
for i=1:N        % grid point in the nested (smaller) domain
for j=1:M

 if ( gn.mask_rho(j,i) > 0 ) % sea; we works on a cell under water

   % find 4 nearest points
   % ind --> index of the 4 points
   % Assume the projection is ok to do this.
   d = sqrt ( (gl.lon_rho - gn.lon_rho(j,i)).^2 + (gl.lat_rho - gn.lat_rho(j,i)).^2 ); 
   d = d.*land;
   d_temp = d;
   ind=[];
   while length( ind ) < 4
      ind_temp = find( d == min(d_temp(:)) );
      ind = [ind ind_temp(1)];   
      d_temp( ind_temp(1) ) = 1.e20; 
   end

   % closest points row and column indice
   row_index = mod ( ind - 1, r ) + 1;
   col_index = floor( (ind - 1) / r ) + 1;

   % calculate linear weights based on distance between points
   xx0=gn.lon_rho(j,i); 
   yy0=gn.lat_rho(j,i); 
   for kk=1:4
    jj=row_index(kk);
    ii=col_index(kk);
    xx=gl.lon_rho(jj,ii);
    yy=gl.lat_rho(jj,ii);
    dis(kk)=m_lldist([xx0  xx],[yy0 yy]);
   end
   sum_dis=sum( dis(1:4) );
   weight(1:4) = dis(1:4)./sum_dis;

   % transformation from s-coordinate to z-coordinate
   %z0r = (grid.sc_r-grid.Cs_r).*grid.hc + grid.Cs_r.*grid.h;
   %zzr = z0r + squeeze(zeta).*(1.0 + z0r./grid.h);

   % vertical interpolation and extrapolation 
   % interpolate zeta horizontally
   izeta=0;              % interpolated sea surface, zeta
   ihl=0;                % interpolated depth of water, h
   for kk=1:4  
    jj=row_index(kk);
    ii=col_index(kk);
    z0r=(gl.sc_r-gl.Cs_r).*gl.hc + gl.Cs_r.*gl.h(jj,ii);
    zzr(1:nl,kk)=z0r+zeta(jj,ii).*(1.0 + z0r./gl.h(jj,ii));
    izeta=izeta+zeta(jj,ii).*weight(kk);
    ihl  =ihl  +gl.h(jj,ii).*weight(kk);
    ntrue_ubar(j,i)=ntrue_ubar(j,i)+true_ubar(jj,ii).*weight(kk);
    ntrue_vbar(j,i)=ntrue_vbar(j,i)+true_vbar(jj,ii).*weight(kk);
   end

   % apply volume flux conservation across open boundary (vertical factor)
   % vfactor = 1 if ihl = gn.h(j,i)
   vfactor=(ihl+izeta)/(gn.h(j,i)+izeta);    
   ntrue_ubar(j,i)=ntrue_ubar(j,i) * vfactor ;
   ntrue_vbar(j,i)=ntrue_vbar(j,i) * vfactor ;

   iz0r=(gn.sc_r-gn.Cs_r).*gn.hc + gn.Cs_r.*gn.h(j,i);
   izzr(1:nn)=iz0r+izeta.*(1.0 + iz0r./gn.h(j,i));

   % add extra top level at 20 m above sea level and bottom level at maxdepth.
   extzzr=ones(nl+2,4)*NaN;
   extzzr(1,1:4)=-maxdepth;                          % add bottom
   extzzr(2:nl+1,1:4)=zzr(1:nl,1:4);
   extzzr(nl+2,1:4)=20;                              % add top

   % vertical interpolation of variable at larger domain grid and
   % horizontal interpolation to the nested grid
   for kk=1:4
    jj=row_index(kk);
    ii=col_index(kk);
    itempdata=interp1(extzzr(1:nl+2,kk),exttemp(1:nl+2,jj,ii),izzr(1:nn),'linear');
    isaltdata=interp1(extzzr(1:nl+2,kk),extsalt(1:nl+2,jj,ii),izzr(1:nn),'linear');
    iudata=interp1(extzzr(1:nl+2,kk),extu(1:nl+2,jj,ii),izzr(1:nn),'linear');
    ivdata=interp1(extzzr(1:nl+2,kk),extv(1:nl+2,jj,ii),izzr(1:nn),'linear');
    roms.temp(1:nn,j,i)=roms.temp(1:nn,j,i)+(itempdata.*weight(kk))';
    roms.salt(1:nn,j,i)=roms.salt(1:nn,j,i)+(isaltdata.*weight(kk))';
    ntrue_u(1:nn,j,i)=ntrue_u(1:nn,j,i)+(iudata.*weight(kk))';
    ntrue_v(1:nn,j,i)=ntrue_v(1:nn,j,i)+(ivdata.*weight(kk))';
   end

   % post-processing for NaN values
   Ip=find(  isfinite(squeeze(roms.salt(:,j,i))) );
   Iq=find( ~isfinite(squeeze(roms.salt(:,j,i))) ); 
   
   if ( length(Ip) < 1)
    error(['error at f = ',num2str(f),'    i = ' num2str(i) ' no data!'])
   elseif( length(Iq) > 1)
    error(['fix NaN value at f = ',num2str(f),'     j=' num2str(j) ' ,  i = ' num2str(i)])
   end
   
 roms.zeta(j,i)=izeta; % updata zeta values
 end  % of if ( gn.mask_rho(j,i) > 0 ) ; sea - we works on a cell under water



end % of j 
            disp(['done at f = ',num2str(f),'    i = ' num2str(i) ',    j = ' num2str(j)])
end % of i  grid point in the nested (smaller) domain


%(3)roate true eastward and northward velocities to roms u and v
%
%   unit of g.angle is radian ( 0.74 = 42 degree )
%
%  | true_u | = | cos(angle) -sin(angle) | | u |
%  | true_v |   | sin(angle)  cos(angle) | | v |
%  where (u,v)' is roms space vector
%
%  | u | = |  cos(angle) +sin(angle) | | true_u |
%  | v |   | -sin(angle)  cos(angle) | | true_v |

nubar= cos(gn.angle).*ntrue_ubar + sin(gn.angle).*ntrue_vbar;
nvbar=-sin(gn.angle).*ntrue_ubar + cos(gn.angle).*ntrue_vbar;

clear cos_angle3D sin_angle3D

cos_angle3D=repmat( cos(gn.angle) ,[1 1 nn ]);
cos_angle3D=permute(cos_angle3D, [3 1 2]);
sin_angle3D=repmat( sin(gn.angle) ,[1 1 nn ]);
sin_angle3D=permute(sin_angle3D, [3 1 2]);

nu= cos_angle3D.*ntrue_u + sin_angle3D.*ntrue_v;
nv=-sin_angle3D.*ntrue_u + cos_angle3D.*ntrue_v;
% roms.u= cos_angle3D.*ntrue_u + sin_angle3D.*ntrue_v;
% roms.v=-sin_angle3D.*ntrue_u + cos_angle3D.*ntrue_v;

 clear ubar vbar u v

[M N]=size(nubar);
roms.ubar = ( nubar(:,1:N-1)+nubar(:,2:N) ) * 0.5;
roms.vbar = ( nvbar(1:M-1,:)+nvbar(2:M,:) ) * 0.5;
roms.u = ( nu(:,:,1:N-1)+nu(:,:,2:N) ) * 0.5;
roms.v = ( nv(:,1:M-1,:)+nv(:,2:M,:) ) * 0.5;

% plotsalt=0; % Do you want to plot temp/salt at top and bottom level? yes=1 no=0
% write_roms_init(out_file,roms) % append data to an existing zeros boundary file and close it.

% write_roms_init_nest(out_file,roms)
% function write_roms_bndy(bndy_file,roms,tind)

%     if fm<10
%         out_file = [out_head,'0',num2str(fm),foot];
%     else
%         out_file = [out_head,num2str(fm),foot];
%     end

roms.time = (fm-1)*30 + 15 ;
nc = netcdf(out_file,'write');
% append to an existing boundary file
% time_variable_name = nc{'temp'}.time(:)
% nc_tindex = 1;
% nc{'ocean_time'}(nc_tindex) = roms.time;

nc{'ocean_time'}(fm) = roms.time;
for varlist = { 'temp','salt','u','v'}
  varname = char(varlist);
  data = getfield(roms,varname);
  nc{[varname '_west']}(fm,:,:,:) = data(:,:,1);
  nc{[varname '_east']}(fm,:,:,:) = data(:,:,end);
  nc{[varname '_north']}(fm,:,:,:) = data(:,end,:);
  nc{[varname '_south']}(fm,:,:,:) = data(:,1,:);
end

for varlist = { 'zeta','ubar','vbar'}
  varname = char(varlist);
  data = getfield(roms,varname);
  nc{[varname '_west']}(fm,:,:) = data(:,1);
  nc{[varname '_east']}(fm,:,:) = data(:,end);
  nc{[varname '_north']}(fm,:,:) = data(end,:);
  nc{[varname '_south']}(fm,:,:) = data(1,:);
end
clear data
close(nc)

end  % loop_day

fnum=fm
disp([' appending data to boundary file done ..... '])
disp([' Finished ' which(mfilename) ])
disp('  ')

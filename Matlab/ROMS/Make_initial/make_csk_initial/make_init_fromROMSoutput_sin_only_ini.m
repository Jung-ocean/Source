% function make_inti_fromROMSoutput_sin(gl_name,gn_name,in_file,out_file,ini_time)
% function  make_inti_fromROMSoutput_sin
% =========================================================================
% Edit : Chang-Sin Kim ( Feb. 2006 )
% mailto : longius@hanmail.net
% =========================================================================
close all;
clear all;
clc;
disp(' read grid information of larger domain and the nested smaller domain')
sourcestr = [ 'From yellow 1/36 : 3km resolution '];
% ================= End of Input Parameters =================================
%    gl = grd(gl_name);    % (1) Get Larger grid information
%    gn = grd(gn_name);    % (2) Get Nested grid information
gl = grd('kimyy');   % (1) Get Larger grid information
%    gn = grd('yw_e5c_edyz3'); % (2) Get Nested grid information
%    gl = grd('yw_e5c_edyz3');   % (1) Get Larger grid information
%    gn = grd('yw_e5c_edyz3_30'); % (2) Get Nested grid information
%    gn = grd('yw_e5c_edyz3_40'); % (2) Get Nested grid information
%    gn = grd('yw_e5c_edyz3'); % (2) Get Nested grid information
gn = grd('YECS');

% Information for the initial conditions file
% and create an empty initial file

% in_file  =  'G:\ROMS\z_yw10c_0305\daily\his_Ryw10c_0127.nc' ;
in_file  =  'test06_monthly_1983_01.nc';
out_file =  'roms_ini_YECS_NWPtest06.nc' ;
% out_file =  'ini_yw10c_2003_7_30l.nc' ;
% out_file =  'ini_2003_7_40l.nc' ;


disp([' create an empty intial file = ' out_file])
title = 'ROMS initial from ROMS output';
noclobber = 0;
base_date = [1983 01 01 0 0 0];
time_variable = 'ocean_time';
roms.grd = gn;
grd_file = gn.grd_file;
grd.theta_s = gn.theta_s;
grd.theta_b = gn.theta_b;
grd.Tcline  = gn.Tcline ;
grd.hc      = gn.hc     ;
grd.sc_r    = gn.sc_r   ;
grd.sc_w    = gn.sc_w   ;
grd.Cs_r    = gn.Cs_r   ;
grd.Cs_w    = gn.Cs_w   ;

details = [ 'Quick initial file from ECS 1/4 ' ...
    'by script ' which(mfilename) ];
donuts = 0;
create_inifile_J(out_file,gn.grd_file,title,gn.theta_s,gn.theta_b,gn.hc,gn.N,0,'clobber',2)  % create an nc file, write variables and close it.
disp([' creating an empty initial file done ..... '])
disp('  ')
clearvars title

% read data from larger domain
disp([' read data from the larger domain roms file = ' in_file])
disp([' wait ..... '])
nc=netcdf(in_file,'read');

mask_rho = nc{'mask_rho'}(:);
mask_u = nc{'mask_u'}(:);
mask_v = nc{'mask_v'}(:);

ocean_time = nc{'ocean_time'}(:);

if length(ocean_time) == 1
    
    temp=nc{'temp'}(:);
    salt=nc{'salt'}(:);
    zeta=nc{'zeta'}(:);
    ubar_dump=nc{'ubar'}(:);
    vbar_dump=nc{'vbar'}(:);
    u_dump=nc{'u'}(:);
    v_dump=nc{'v'}(:);
    
elseif length(ocean_time) == 2
    
    index = find(ocean_time == 0);
    temp=nc{'temp'}(index,:,:,:);
    salt=nc{'salt'}(index,:,:,:);
    zeta=nc{'zeta'}(index,:,:);
    ubar_dump=nc{'ubar'}(index,:,:);
    vbar_dump=nc{'vbar'}(index,:,:);
    u_dump=nc{'u'}(index,:,:,:);
    v_dump=nc{'v'}(index,:,:,:);
    
end

close(nc)

zeta(:,:) = zeta(:,:).*mask_rho;
ubar_dump(:,:) = ubar_dump(:,:).*mask_u;
vbar_dump(:,:) = vbar_dump(:,:).*mask_v;
for i = 1:gl.N
    temp(i,:,:) = squeeze(temp(i,:,:)).*mask_rho;
    salt(i,:,:) = squeeze(salt(i,:,:)).*mask_rho;
    u_dump(i,:,:) = squeeze(u_dump(i,:,:)).*mask_u;
    v_dump(i,:,:) = squeeze(v_dump(i,:,:)).*mask_v;
end

disp([' reading done ..... '])
disp('  ')

%(1)interpolate ubar_dump and vbar_dump on rho-points
% rho    points 162x194
% ubar   points 162x193
% vbar   points 161x194

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


% initailize inital data file
disp([' initailize roms structure (inital data file) '])

roms.time = 0 ; % edit sin
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

disp([' appending default values to initial file done ..... '])
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

for i=1:N        % grid point in the nested (smaller) domain
    for j=1:M
        
        izeta=0;              % interpolated sea surface, zeta
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
                error(['error at j=' num2str(j) ' ,  i = ' num2str(i) ' no data!'])
            elseif( length(Iq) > 1)
                error(['fix NaN value at j=' num2str(j) ' ,  i = ' num2str(i)])
            end
            
        end  % of if ( gn.mask_rho(j,i) > 0 ) ; sea - we works on a cell under water
        roms.zeta(j,i)=izeta; % updata zeta values
        
    end % of j
    disp(['done at  i = ' num2str(i) ',    j = ' num2str(j)])
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

%(4)interpolate nubar and nvbar on rho-points to ubar and vbar on velocity points
% rho    points 82x42
% ubar   points 82x41
% vbar   points 81x42

clear ubar vbar u v

[M N]=size(nubar);
roms.ubar = ( nubar(:,1:N-1)+nubar(:,2:N) ) * 0.5;
roms.vbar = ( nvbar(1:M-1,:)+nvbar(2:M,:) ) * 0.5;
roms.u = ( nu(:,:,1:N-1)+nu(:,:,2:N) ) * 0.5;
roms.v = ( nv(:,1:M-1,:)+nv(:,2:M,:) ) * 0.5;

maxtemp = max(max(max(roms.temp)));
mintemp = min(min(min(roms.temp(roms.temp>0))));
maxsalt = max(max(max(roms.salt)));
minsalt = min(min(min(roms.salt(roms.salt>0))));
disp(['================================================================'])
disp([' max. temp = ' num2str(maxtemp) ' min. temp = ' num2str(mintemp)])
disp([' max. salt = ' num2str(maxsalt) ' min. salt = ' num2str(minsalt)])

maxubar = max(max(roms.ubar));
minubar = min(min(roms.ubar));
maxvbar = max(max(roms.vbar));
minvbar = min(min(roms.vbar));
disp(['================================================================'])
disp([' max. ubar = ' num2str(maxubar) ' min. ubar = ' num2str(minubar)])
disp([' max. vbar = ' num2str(maxvbar) ' min. vbar = ' num2str(minvbar)])

maxu = max(max(max(roms.u)));
minu = min(min(min(roms.u)));
maxv = max(max(max(roms.v)));
minv = min(min(min(roms.v)));
disp(['================================================================'])
disp([' max. u = ' num2str(maxu) ' min. u = ' num2str(minu)])
disp([' max. v = ' num2str(maxv) ' min. v = ' num2str(minv)])

% check if any NaN salt value in data

%repmat Replicate and tile an array
%B = repmat(A,M,N) creates a large matrix B consisting
%of an M-by-N tiling of copies of A.

indexNaN1 = find( ~isfinite(roms.salt) );
rho_mask3D= repmat(gn.mask_rho,[1,1,nn]);
rho_mask3D= permute(rho_mask3D,[3,1,2]);
indexNaN2 = find( rho_mask3D(indexNaN1) == 1);
if ( length(indexNaN2) > 1 )
    beep;
    disp(' there are NaN salt values in data ')
    beep;
    error(' error! ')
end

plotsalt=1; % Do you want to plot temp/salt at top and bottom level? yes=1 no=0
if (plotsalt)
    figure
    subplot(2,2,1)
    pcolor( gn.lon_rho, gn.lat_rho, squeeze(roms.temp(nn,:,:)) )
    shading flat
    title(' temp at top level ')
    caxis([mintemp maxtemp])
    colorbar
    subplot(2,2,2)
    pcolor( gn.lon_rho, gn.lat_rho, squeeze(roms.temp(1,:,:)) )
    shading flat
    title(' temp at bottom level ')
    caxis([mintemp maxtemp])
    colorbar
    subplot(2,2,3)
    pcolor( gn.lon_rho, gn.lat_rho, squeeze(roms.salt(nn,:,:)) )
    shading flat
    title(' salt at top level ')
    caxis([minsalt maxsalt])
    colorbar
    subplot(2,2,4)
    pcolor( gn.lon_rho, gn.lat_rho, squeeze(roms.salt(1,:,:)) )
    shading flat
    title(' salt at bottom level ')
    caxis([minsalt maxsalt])
    colorbar
end


% check if any NaN u value in data

%repmat Replicate and tile an array
%B = repmat(A,M,N) creates a large matrix B consisting
%of an M-by-N tiling of copies of A.

indexNaN1 = find( ~isfinite(roms.u) );
u_mask3D= repmat(gn.mask_u,[1,1,nn]);
u_mask3D= permute(u_mask3D,[3,1,2]);
indexNaN2 = find( u_mask3D(indexNaN1) == 1);
if ( length(indexNaN2) > 1 )
    beep;
    disp(' there are NaN u values in data ')
    beep;
    error(' error! ')
end


% check if any NaN v value in data

%repmat Replicate and tile an array
%B = repmat(A,M,N) creates a large matrix B consisting
%of an M-by-N tiling of copies of A.

indexNaN1 = find( ~isfinite(roms.v) );
v_mask3D= repmat(gn.mask_v,[1,1,nn]);
v_mask3D= permute(v_mask3D,[3,1,2]);
indexNaN2 = find( v_mask3D(indexNaN1) == 1);
if ( length(indexNaN2) > 1 )
    beep;
    disp(' there are NaN v values in data ')
    beep;
    error(' error! ')
end

ncout = netcdf(out_file, 'w');
ncout{'temp'}(:) = roms.temp;
ncout{'salt'}(:) = roms.salt;
ncout{'zeta'}(:) = roms.zeta;
ncout{'u'}(:) = roms.u;
ncout{'v'}(:) = roms.v;
ncout{'ubar'}(:) = roms.ubar;
ncout{'vbar'}(:) = roms.vbar;
close(ncout)

disp([' appending data to initial file done ..... '])
disp([' Finished ' which(mfilename) ])
disp('  ')



plotcompare=0;     % compare large and nested domains data
if (plotcompare)
    figure
    roms_zview(out_file,'temp',1,-10,gn,3,1,'k')
    ax=axis;
    colorbar
    cax=caxis;
    title('temp: nested domain interpolated data at 10 m')
    figure
    roms_zview(in_file,'temp',1,-10,gl,6,1,'k')
    axis(ax);
    caxis(cax);
    colorbar
    title('temp: larger domain original data at 10 m')
    
    figure
    roms_zview(out_file,'salt',1,-50,gn,3,1.0,'k')
    ax=axis;
    colorbar
    cax=caxis;
    title('salt: nested domain interpolated data at 50 m')
    figure
    roms_zview(in_file,'salt',1,-50,gl,6,1.0,'k')
    axis(ax);
    caxis(cax);
    colorbar
    title('salt: larger domain original data at 50 m')
    
    figure
    roms_zview(out_file,'temp',1,-250,gn,3,1,'k')
    ax=axis;
    colorbar
    cax=caxis;
    title('temp: nested domain interpolated data at 250 m')
    figure
    roms_zview(in_file,'temp',1,-250,gl,6,1,'k')
    axis(ax);
    caxis(cax);
    colorbar
    title('temp: larger domain original data at 250 m')
    
    figure
    roms_zview(out_file,'salt',1,-400,gn,3,1,'k')
    ax=axis;
    colorbar
    cax=caxis;
    title('salt: nested domain interpolated data at 400 m')
    figure
    roms_zview(in_file,'salt',1,-400,gl,6,1,'k')
    axis(ax);
    caxis(cax);
    colorbar
    title('salt: larger domain original data at 400 m')
    
end


% return

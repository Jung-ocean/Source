% function [total_volume,total_salt,total_fresh] = xy_transport_onefile(filename,g,selectdepth);
% ====================================================================
% [total_volume,total_salt,total_fresh]= xy_transport_onefile(filename,g,selectdepth);
% calculate transports of  volume(in Sv, 10^6 m^3/sec)
%                          heat  (in PW, 10^15 W)
%                          salt  (in 10^9 kg)
%
% across a line segment (slice along a constant I or J)
%
% 'filename'       = history or average file name
% 'grid_nick_name' = grid information such as 'eas' 'hudson' 'latte'
% 'selectdepth' = surface to which depth (m) such as 100, 500, 50000
%
% keep in mind that
% vertical coordinate changes in time = h + zeta(t) in ROMS
%
% USE: xy_transport_function.m
%
% ====================================================================
% onefile   for single   input file  and single segment.
% BJ Choi, Marhch07, 2006.

clear; clc;
tic; warning off
%   if( nargin < 1)
%     filename='./../avg_his/avg_eRTD_0002.nc';

temp_limit = 40;

filename_trans = 'transport';
filename_heat = ['heat_transport_', num2str(temp_limit)];

foot = '.nc';
year_start = 2010;
year_end   = 2019;
mon_start  = 1;
mon_end    = 12;

g = grd('EYECS');
selectdepth = 5000; % Should be deeper than maximum depth

% s_max = 32.76; % maximum salinity for the calculation of
% % tempwater flux - Hudson River, NY Bight.
% s_max = 34.00; % maximum salinity for the calculation of
% % tempwater flux - Hudson River, NY Bight.
% s_max = 34.5586083395882 ; % real ~ 103
s_max = 34.573;
% *************************************************************
%
%   END OF USER DEFINED VARIABLES
%
% *************************************************************

% size of grids
[r,c] = size ( g.lon_rho );
mask3d_rho=repmat(g.mask_rho,[1 1 g.N]);
mask3d_rho=permute(mask3d_rho,[3 1 2]);

[r1,c1] = size ( g.lon_u );
mask3d_u=repmat(g.mask_u,[1 1 g.N]);
mask3d_u=permute(mask3d_u,[3 1 2]);

[r2,c2] = size ( g.lon_v );
mask3d_v=repmat(g.mask_v,[1 1 g.N]);
mask3d_v=permute(mask3d_v,[3 1 2]);

% transport from surface to which depth (m)

if ( selectdepth > 0 )
    selectdepth = selectdepth*-1;
end

% t_point=  1;
% point_name={'Jeju'};
% kts = [126.734498 34.521141 126.634498 33.515753];

t_point=  3;
point_name={'Jeju', 'NECS', 'SYS'};
kts = [126.734498 34.521141 126.634498 33.515753 ...
    120 33 126.63 33.3 ...
    119 34.5 126.63 34.8];

%depth = 100;
sn=0;

for st=1:t_point
    
    %disp([char(point_name(st)),' Depth to ',num2str(depth)])
    endpt_lon(1) = kts(sn+1);
    endpt_lat(1) = kts(sn+2);
    endpt_lon(2) = kts(sn+3);
    endpt_lat(2) = kts(sn+4);
    sn=sn+4;
    
    for cpts=1:2 % corner points
        dist = sqrt(  ( g.lon_rho - endpt_lon(cpts) ).*( g.lon_rho - endpt_lon(cpts) ) + ...
            ( g.lat_rho - endpt_lat(cpts) ).*( g.lat_rho - endpt_lat(cpts) ) );
        ind=find( min( dist(:) ) == dist );
        % closest points row and column indice
        row_index = mod ( ind - 1, r ) + 1;
        col_index = floor( (ind - 1) / r ) + 1;
        corner_endpt_col(cpts)=col_index(1);
        corner_endpt_row(cpts)=row_index(1);
    end
    
    
    % my xy_transport_onefile works only if corner_endpt_row(2) < corner_endpt_row(1).
    if( corner_endpt_row(2) > corner_endpt_row(1)  )
        tmp_col=corner_endpt_col(2);
        tmp_row=corner_endpt_row(2);
        corner_endpt_col(2)=corner_endpt_col(1);
        corner_endpt_row(2)=corner_endpt_row(1);
        corner_endpt_col(1)=tmp_col;
        corner_endpt_row(1)=tmp_row;
        beep
        disp(' === switching two end points === ')
    end
    
    % longitude and latitude coordinate.
    
    for i=1:length(endpt_lat)
        xx(i)=g.lon_rho(corner_endpt_row(i),corner_endpt_col(i));
        yy(i)=g.lat_rho(corner_endpt_row(i),corner_endpt_col(i));
    end
    distance_r = m_lldist ( xx, yy );
    
    %     figure(f)
    %     hold on
    %     plot(xx,yy,'x-k','LineWidth',2)
    %     colorbar
    %     title('bottom topography (m)')
    
    %  transect information
    
    % delj = j increasment
    if( corner_endpt_col(2) >= corner_endpt_col(1) )
        delj=1;
        west2east_transect=1; % previously zonaltransect
    else
        delj=-1;
        west2east_transect=0; % previously meridionaltransect
    end
    
    % deli = i increasment
    if( corner_endpt_row(2) > corner_endpt_row(1) )
        deli=1;
    else
        deli=-1;
    end
    
    xzero=g.lon_rho( corner_endpt_row(1), corner_endpt_col(1) );
    yzero=g.lat_rho( corner_endpt_row(1), corner_endpt_col(1) );
    xone=g.lon_rho( corner_endpt_row(2), corner_endpt_col(2) );
    yone=g.lat_rho( corner_endpt_row(2), corner_endpt_col(2) );
    slope=( yone-yzero) / (xone - xzero);
    % A x + B y + C = 0;
    A=slope;
    B=-1;
    C=-slope*xzero+yzero;
    D=sqrt( A*A + B*B );
    % distance = abs( A x + B y + C ) / D
    
    %   grid information
    
    %N  is the number of vertical levels
    %hz is thickness  of each level
    N = g.N;
    [M L]=size(g.h);
    hz=g.z_w(2:N+1,:,:)-g.z_w(1:N,:,:); % z_w: [31x142x254]
    dx = 1./g.pm;
    dy = 1./g.pn;
    dx_v=0.5*(dx(1:M-1,:)+dx(2:M,:));
    dy_u=0.5*(dy(:,1:L-1)+dy(:,2:L));
    g_h_v=0.5*(g.h(1:M-1,:)+g.h(2:M,:));
    g_h_u=0.5*(g.h(:,1:L-1)+g.h(:,2:L));
    
    avgdxdy = mean([ mean( mean( dx ) ), mean( mean( dy ) ) ]);
    
    ynum = 0; mnum=0;
    for yy = year_start : year_end
        ynum=ynum+1;
        for mm =  mon_start : mon_end
            mnum = mnum+1;
            ystr = num2char(yy,4);
            if yy == 9999; ystr = 'avg'; end
            mts = num2char(mm,2);
            %filepath = ['G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\', yts, '\'];
            %if yy == 1980
            %    filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\old_1980\1980_ver38\output_14\'];
            %end
            %filepath = ['G:\내 드라이브\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\', ystr, '\'];
            %cd(filepath)
                        
            filename = ['monthly_', ystr, mts, foot];
            nc = netcdf(filename);
            zeta = nc{'zeta'}(:);
            u = nc{'u'}(:);
            temp = nc{'temp'}(:);
%             salt = nc{'salt'}(:);
            v = nc{'v'}(:);
            close(nc);
            
%             temp(temp > temp_limit) = 0;
            
            u = u.*mask3d_u;
            v = v.*mask3d_v;
            temp = temp.*mask3d_rho; % zero for land, ** very important **
%             salt = salt.*mask3d_rho; % zero for land, ** very important **
            
            % szero = ones(size(temp)).*s_max;
            % fresh = ( szero - salt ) ./ szero; % freshwater fraction
            % fresh = fresh.*mask3d_rho; % zero for land, ** very important **
            
            %   vertical coordinate changes in time
            %   because sea surface height changes in time.
            %   thickness of each layer changes propotional to total water thicknes.
            
            h_total = g.h + zeta;       %total water thickness
            for level=1:N               %thickness of each layer
                Hz(level,:,:)=squeeze(hz(level,:,:)).*(h_total./g.h);
            end
            
            % average Hz to  Arakawa-C u points
            
            Hz_u=0.5*(Hz(:,:,1:L-1)+Hz(:,:,2:L)); % each layer thickness
            z_u(1,:,:)=-g_h_u(:,:);             % z @ bottom of each layer
            for k=2:+1:N
                z_u(k,:,:)=z_u(k-1,:,:)+Hz_u(k-1,:,:);
            end
            
            temp_u=0.5*(temp(:,:,1:L-1)+temp(:,:,2:L)); % each layer temp at u point
%             salt_u=0.5*(salt(:,:,1:L-1)+salt(:,:,2:L)); % each layer salt at u point
            %             fresh_u=0.5*(fresh(:,:,1:L-1)+fresh(:,:,2:L)); % each layer freshwater at u point
            
            % average Hz to  Arakawa-C v points
            
            Hz_v=0.5*(Hz(:,1:M-1,:)+Hz(:,2:M,:)); % each layer thickness
            z_v(1,:,:)=-g_h_v(:,:);             % z @ bottom of each layer
            for k=2:+1:N
                z_v(k,:,:)=z_v(k-1,:,:)+Hz_v(k-1,:,:);
            end
            temp_v=0.5*(temp(:,1:M-1,:)+temp(:,2:M,:)); % each layer temp at u point
%             salt_v=0.5*(salt(:,1:M-1,:)+salt(:,2:M,:)); % each layer salt at u point
            %             fresh_v=0.5*(fresh(:,1:M-1,:)+fresh(:,2:M,:)); % each layer freshwater at u point
            
            %   ====================================================================================
            %   find path from corner_endpt(1) to corner_endpt(2)
            
            icount=1;
            col_index(icount)=corner_endpt_col(1);
            row_index(icount)=corner_endpt_row(1);
            on_vpoint(icount)=0;
            vpoint=0;
            xpoint=g.lon_u( row_index(icount), col_index(icount) );
            ypoint=g.lat_u( row_index(icount), col_index(icount) );
            
            signline(icount)=(ypoint - yzero) - slope*(xpoint -xzero);
            dist(icount)= abs( A*xpoint + B*ypoint + C ) / D;
            tmp_dist=dist(icount);
            dist2endpoint(icount) = m_lldist([xpoint xone],[ypoint yone])*1000;
            flag_approach = 1;
            
            if (west2east_transect)
                
                while ( dist2endpoint(icount) > avgdxdy  &&  flag_approach )
                    
                    icount=icount+1;
                    
                    if ( vpoint == 1 )
                        
                        col_index(icount)=col_index(icount-1)+delj;
                        if ( on_vpoint(icount-1) == 1)
                            row_index(icount)=row_index(icount-1);
                        else
                            row_index(icount)=row_index(icount-1)+deli;
                        end
                        xpoint=g.lon_v( row_index(icount), col_index(icount) );
                        ypoint=g.lat_v( row_index(icount), col_index(icount) );
                        signline(icount)=(ypoint - yzero) - slope*(xpoint -xzero);
                        dist(icount)= abs( A*xpoint + B*ypoint + C ) / D;
                        
                        if ( signline(icount)*signline(icount-1) < 0  ...
                                ||   dist(icount) <= dist(icount-1)       ...
                                ||   dist(icount) <= tmp_dist                  )
                            tmp_dist=0;
                            on_vpoint(icount)=1;
                            plot(  xpoint,  ypoint , 'ro')
                            dist2endpoint(icount) = m_lldist([xpoint xone],[ypoint yone])*1000;
                        else
                            tmp_dist=dist(icount);
                            vpoint=0;
                            icount=icount-1;
                            plot(  xpoint,  ypoint , 'gx')
                        end
                        
                    else % on upoint
                        
                        col_index(icount)=col_index(icount-1);
                        if ( on_vpoint(icount-1) == 0)
                            row_index(icount)=row_index(icount-1)+deli;
                        else
                            row_index(icount)=row_index(icount-1);
                        end
                        xpoint=g.lon_u( row_index(icount), col_index(icount) );
                        ypoint=g.lat_u( row_index(icount), col_index(icount) );
                        signline(icount)=(ypoint - yzero) - slope*(xpoint -xzero);
                        dist(icount)= abs( A*xpoint + B*ypoint + C ) / D;
                        
                        if (      signline(icount)*signline(icount-1) < 0 ...
                                ||   dist(icount) <= dist(icount-1)   ...
                                ||   dist(icount) <= tmp_dist                       )
                            tmp_dist=0;
                            on_vpoint(icount)=0;
                            plot(  xpoint,  ypoint , 'ro')
                            dist2endpoint(icount) = m_lldist([xpoint xone],[ypoint yone])*1000;
                        else
                            tmp_dist=dist(icount);
                            vpoint=1;
                            icount=icount-1;
                            plot(  xpoint,  ypoint , 'gx')
                        end
                        
                    end % if ( on_vpoint == 1 )
                    
                    if( icount > 3 &&  dist2endpoint(icount) > dist2endpoint(icount-3) )
                        flag_approach = 0;
                    end
                    
                end % while
                
            else % if (west2east_transect)
                
                while ( dist2endpoint(icount) > avgdxdy  &&  flag_approach )
                    
                    icount=icount+1;
                    
                    if ( vpoint == 1 )
                        
                        if ( on_vpoint(icount-1) == 1)
                            col_index(icount)=col_index(icount-1)+delj;
                            row_index(icount)=row_index(icount-1);
                        else
                            col_index(icount)=col_index(icount-1);
                            row_index(icount)=row_index(icount-1)+deli;
                        end
                        
                        xpoint=g.lon_v( row_index(icount), col_index(icount) );
                        ypoint=g.lat_v( row_index(icount), col_index(icount) );
                        signline(icount)=(ypoint - yzero) - slope*(xpoint -xzero);
                        dist(icount)= abs( A*xpoint + B*ypoint + C ) / D;
                        
                        if ( signline(icount)*signline(icount-1) < 0  ...
                                ||   dist(icount) <= dist(icount-1)       ...
                                ||   dist(icount) <= tmp_dist                  )
                            tmp_dist=0;
                            on_vpoint(icount)=1;
                            plot(  xpoint,  ypoint , 'ro')
                            dist2endpoint(icount) = m_lldist([xpoint xone],[ypoint yone])*1000;
                        else
                            tmp_dist=dist(icount);
                            vpoint=0;
                            icount=icount-1;
                            plot(  xpoint,  ypoint , 'gx')
                        end
                        
                    else % on upoint
                        
                        if ( on_vpoint(icount-1) == 0)
                            col_index(icount)=col_index(icount-1);
                            row_index(icount)=row_index(icount-1)+deli;
                        else
                            col_index(icount)=col_index(icount-1)+delj;
                            row_index(icount)=row_index(icount-1);
                        end
                        
                        
                        xpoint=g.lon_u( row_index(icount), col_index(icount) );
                        ypoint=g.lat_u( row_index(icount), col_index(icount) );
                        signline(icount)=(ypoint - yzero) - slope*(xpoint -xzero);
                        dist(icount)= abs( A*xpoint + B*ypoint + C ) / D;
                        
                        if (      signline(icount)*signline(icount-1) < 0 ...
                                ||   dist(icount) <= dist(icount-1)   ...
                                ||   dist(icount) <= tmp_dist                       )
                            tmp_dist=0;
                            on_vpoint(icount)=0;
                            plot(  xpoint,  ypoint , 'ro')
                            dist2endpoint(icount) = m_lldist([xpoint xone],[ypoint yone])*1000;
                        else
                            tmp_dist=dist(icount);
                            vpoint=1;
                            icount=icount-1;
                            plot(  xpoint,  ypoint , 'gx')
                        end
                        
                    end % if ( on_vpoint == 1 )
                    
                    if( icount > 3 &&  dist2endpoint(icount) > dist2endpoint(icount-3) )
                        flag_approach = 0;
                    end
                end % while
                
            end % if (west2east_transect)
            
            total_temp=0;
            total_volume=0;
%             total_salt=0;
            %             total_fresh=0;
            
            for index=1:icount
                
                vpoint=on_vpoint(index);
                xy_heat_transport_function
                
                if( west2east_transect == 0 && vpoint == 1 )
                    total_volume = total_volume - sum_segment;
%                     total_salt   = total_salt   - sum_segment_salt;
                    total_temp  = total_temp  - sum_segment_temp;
                    %                     total_fresh  = total_fresh  - sum_segment_fresh;
                    %                     freshtransect(index)=-sum_segment_fresh;
                    voltransect(index)=-sum_segment;
                else
                    total_volume = total_volume + sum_segment;
%                     total_salt   = total_salt   + sum_segment_salt;
                    total_temp  = total_temp  + sum_segment_temp;
                    %                     total_fresh  = total_fresh  + sum_segment_fresh;
                    %                     freshtransect(index)=sum_segment_fresh;
                    voltransect(index)=sum_segment;
                end
                
                
            end
            disp(['YY/MM = ',num2str(yy),'/',num2char(mm,2),' transport ',char(point_name(st)),': ',num2str(total_volume/1e+6)])
            disp(['YY/MM = ',num2str(yy),'/',num2char(mm,2),' heat transport ',char(point_name(st)),': ',num2str(total_temp*(4.1*10^6)/1e+15)])
            
            trans(mnum,st) = total_volume/1e+6;
%             salt_tr(mnum,st)  = total_salt*1.025/1e+6;
            temp_tr(mnum,st)  = total_temp*(4.1*1000*1000)/1e+12; % 1000 kg/m^3(density) x 4.1*1000(kJ -> J)~~ Isobe_etal_2002_JGR
        end   % for mm
    end %% for yy
end  % for st=1:t_point

% salt = salt_tr ./ trans ;
% outfile = [filename_trans, '_', tys,'.txt'];
% fid = fopen(outfile,'w+');
% fprintf(fid,'%% Straits transport\n');
% fprintf(fid,'%8.3f \n', trans);
% fclose(fid);

outfile = [filename_heat, '_', ystr,'.txt'];
fid = fopen(outfile,'w+');
fprintf(fid,'%% Straits heat transport\n');
fprintf(fid,'%8.3f %8.3f %8.3f \n', [trans' temp_tr']);
fclose(fid);

% temp_tr(:,7)=temp_tr(:,7)*(-1);
% outfile = ['roms_temp_transport_monthly_',num2str(yy),'.txt'];
% fid = fopen(outfile,'w+');
% fprintf(fid,'%%korea ruku Taiwan kuroshio tsugaru soya onshore \n');
% fprintf(fid,'%8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %9.3f %9.3f\n', temp_tr');
% fclose(fid);

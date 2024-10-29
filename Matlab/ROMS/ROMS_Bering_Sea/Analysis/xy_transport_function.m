% function [sum_segment,sum_segment_salt,sum_segment_fresh] = xy_transport_function(filename,g,selectdepth);
% ====================================================================
% [volume,heat,salinity] = ij_transport_onefile(filename,g,selectdepth);
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
% ====================================================================
% version 1 for single   input file  and single segment.
% version 2 for multiple input files and single segment.
% onefile   for single   input file  and single segment.

% *******************************************************************
% FOR FIXED I (or longitude)
% *******************************************************************

% *******************************************************************
% FOR FIXED J (or latitude)
% *******************************************************************

if ( vpoint ==  1 )
    
    % along a latitude
    %    _ __
    %     |
    %     | v  Hz(k+1,jj,i)
    %    _|__
    %     |
    %     | v  Hz(k  ,jj,i)
    %    _|__
    
    jj=row_index(index);
    i1=col_index(index);
    i2=col_index(index);
    
    % actual calculation of transport
    
    sum_segment=0;
    sum_segment_salt=0;
    sum_segment_temp=0;
    
    for i=i1:i2
        Ip=find( z_v(:,jj,i) > selectdepth );
        lastlevel=min([N; min(Ip)]);
        sum=0;
        sum_salt=0;
        sum_fresh=0;
        sum_temp=0;
        for k=N:-1:lastlevel         % whole cell transport
            sum=sum+v(k,jj,i)*Hz_v(k,jj,i);
            sum_salt=sum_salt+v(k,jj,i)*Hz_v(k,jj,i)*salt_v(k,jj,i);
            %           sum_temp=sum_temp+v(k,jj,i)*Hz_v(k,jj,i)*temp_v(k,jj,i);
        end
        if (lastlevel == N)          % partial cell transport
            partialH=zeta(jj,i)-selectdepth;
            sum=sum+v(N,jj,i)*partialH;
            sum_salt=sum_salt+v(N,jj,i)*partialH*salt_v(N,jj,i);
            %           sum_temp=sum_temp+v(N,jj,i)*partialH*temp_v(N,jj,i);
        elseif (lastlevel ~= 1)
            partialH=z_v(k,jj,i)-selectdepth;
            sum=sum+v(k-1,jj,i)*partialH;
            sum_salt=sum_salt+v(k-1,jj,i)*partialH*salt_v(k-1,jj,i);
            %           sum_temp=sum_temp+v(k-1,jj,i)*partialH*temp_v(k-1,jj,i);
        end
        sum_segment=sum_segment+sum*dx_v(jj,i);
        sum_segment_salt=sum_segment_salt+sum_salt*dx_v(jj,i);
        %       sum_segment_temp=sum_segment_temp+sum_temp*dx_v(jj,i);
    end
    
    
elseif  ( vpoint == 0 )
    
    % along a longitude
    %    _ __
    %     |
    %     | u  Hz(k+1,j,ii)
    %    _|__
    %     |
    %     | u  Hz(k  ,j,ii)
    %    _|__
    
    ii=col_index(index);
    j1=row_index(index);
    j2=row_index(index);
    
    % actual calculation of transport
    
    sum_segment=0;
    sum_segment_salt=0;
    sum_segment_fresh=0;
    sum_segment_temp=0;
    for j=j1:j2
        Ip=find( z_u(:,j,ii) > selectdepth );
        lastlevel=min([N; min(Ip)]);
        sum=0;
        sum_salt=0;
        sum_temp=0;
        sum_fresh=0;
        for k=N:-1:lastlevel         % whole cell transport
            sum=sum+u(k,j,ii)*Hz_u(k,j,ii);
            sum_salt=sum_salt+u(k,j,ii)*Hz_u(k,j,ii)*salt_u(k,j,ii);
            %           sum_temp=sum_temp+u(k,j,ii)*Hz_u(k,j,ii)*temp_u(k,j,ii);
        end
        if (lastlevel == N)          % partial cell transport
            partialH=zeta(j,ii)-selectdepth;
            sum=sum+u(N,j,ii)*partialH;
            sum_salt =sum_salt +u(N,j,ii)*partialH*salt_u(N,j,ii);
            %            sum_temp=sum_temp+u(N,j,ii)*partialH*temp_u(N,j,ii);
        elseif (lastlevel ~= 1)
            partialH=z_u(k,j,ii)-selectdepth;
            sum=sum+u(k-1,j,ii)*partialH;
            sum_salt =sum_salt +u(k-1,j,ii)*partialH*salt_u(k-1,j,ii);
            %           sum_temp=sum_temp+u(k-1,j,ii)*partialH*temp_u(k-1,j,ii);
        end
        sum_segment=sum_segment+sum*dy_u(j,ii);
        sum_segment_salt =sum_segment_salt +sum_salt*dy_u(j,ii);
        %       sum_segment_temp=sum_segment_temp+sum_temp*dy_u(j,ii);
    end
     
end
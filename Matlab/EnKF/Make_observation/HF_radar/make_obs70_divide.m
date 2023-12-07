% 
%  Create Gunsan_OBS_data
% 

close all
clear all

%path1='./time_series_detide/';
%foot1='_uv_detide.dat';

% path1 = 'D:\Data\Ocean\HFobservation(JEJU)\';
% foot1 = '.tuv.int';

path1 = 'G:\HF_smoothed\';
foot1 = '.dat';

path2='./observation_did2/';
!mkdir observation_did2;

%head2='gs_obs_';
head2 = 'jj_obs_';
foot2='.nc';

end_num = 720; %check ens step
dayi = 29;
timei = 23;

% index=zeros(1,60);
% index(1,1:30)=4;
% index(1,31:60)=5;
% ixt=1:60; ixt=ixt';
% ndata=60;
% depth(1,1:60)=0;

% ng=netcdf('c:\roms_tools\make_grid\Build_grid\roms_grd_gs_msl1.nc');
% lonu=ng{'lon_u'}(:);
% latu=ng{'lat_u'}(:);
% lonv=ng{'lon_v'}(:);
% latv=ng{'lat_v'}(:);
% 
% masku=ng{'mask_u'}(:);
% maskv=ng{'mask_v'}(:);
% 
% warning off
% masku=masku./masku;
% maskv=maskv./maskv;
% warning on
fid=fopen('kalman_loof.par','w+');
fprintf(fid,'total time roof\n');

file = ([path1,'TOTL_JEJU_2014_05_01_1000_smoothed',foot1]);
data = load(file);
lon = data(:,1);
lat = data(:,2);

%==========================================================================
lon_ceil = ceil(lon*100)/100; lat_ceil = ceil(lat*100)/100;
lon_uni = unique(lon_ceil); lat_uni = unique(lat_ceil);
lon_sort = sort(lon_uni); lat_sort = sort(lat_uni);
lon_six = lon_sort(6:3:end-4); lat_five = lat_sort(6:3:end-2);

index_sel = [];
for i = 1:length(lon_six)
    for ii = 1:length(lat_five)
        lon_index = lon_ceil == lon_six(i);
        lat_index = lat_ceil == lat_five(ii);
        sel_index = find(lon_index == 1 & lat_index == 1);
        index_sel = [index_sel; sel_index];
    end
end
data = data(index_sel, :);
%==========================================================================

lon = data(:,1);
lat = data(:,2);

plon = lon;
plat = lat;

ll1 = length(plon);
ll2 = length(lon);

clear data; clear file; 

% data1=load('make_obs_point70.dat');
% plon=data1(:,1);
% plat=data1(:,2); clear data1;
% ll1=length(plon);

% file=([path1,'0001',foot1]);
% data1=load(file); clear file;
% lon=data1(:,1);
% lat=data1(:,2); clear data1;
% ll2=length(lon);

for i=1:ll1
    for j=1:ll2
        rng(j) = distance(plon(i),plat(i),lon(j),lat(j));
    end
    mdis(i)=find(rng==min(rng));
end

%for t=1:end_num
for t = 1:dayi
for tt = 1:timei+1
    
    %nn=num2char(t+1,4);
    %nn = [num2char(t,2),'_',num2char((tt-1),2)];
    nn = datestr(datenum(2014,05,01,09, 0, 0) + (24*(t-1) + tt )/24, 'dd_HH');
    nn2=num2char((t-1)*24+(tt),4);
    
    file1=[path1,'TOTL_JEJU_2014_05_',nn,'00_smoothed',foot1];
    data1=load(file1);
    
    data1=data1(index_sel,:);
        
    %u=data1(:,7);
    %v=data1(:,8); 
    
    u = data1(:,3);
    v = data1(:,4);
    
    clear data1
    for i=1:ll1
        olon(i)=lon(mdis(i));
        olat(i)=lat(mdis(i));
        us(i)=u(mdis(i));
        vs(i)=v(mdis(i));
        if us(i) == 0
            us(i) = NaN;
            vs(i) = NaN;
        end
    end
        
    ind0=find(isnan(us)==0);    
    len=length(ind0);
    for i=1:len
        uu(i)= us(ind0(i))/100;
        vv(i)= vs(ind0(i))/100;
        slon(i)=olon(ind0(i));
        slat(i)=olat(ind0(i));
    end

    if len == 0
        ed = 0;
    else
        ed = 2;
        uum=nanmean(uu);
        vvm=nanmean(vv);
    end
    fprintf(fid,'%5d\n',ed);
    
%     uu=griddata(lon,lat,u,lonu,latu);
%     uu=uu.*masku;
%     vv=griddata(lon,lat,v,lonv,latv);
%     vv=vv.*maskv;
    if ed == 2
        for i=1:ed
            mm=num2char(i,4);
            file2=[path2,head2,nn2,'_',mm,foot2];

            nc_data_obs2(file2,len);
            nc=netcdf(file2,'write');
            if i==1
                index(1,1:len)=4; 
            else
                index(1,1:len)=5;
            end
            nc{'dindex'}(1,1:len)=index; clear index;
            nc{'ixt'}(:)=1:len;
            nc{'ndata'}(:)=len;
            nc{'rdepth'}(:)=zeros(1,len);
        
            if i == 1
                nc{'rlon'}(1,1:len)=slon(1,1:len);
                nc{'rlat'}(1,1:len)=slat(1,1:len);
                nc{'obsdata'}(1,1:len)=uu(1,1:len); 
                nc{'obserr'}(1,1:len)= abs(uu(1,1:len))*0.1; %(uu(1,1:len)-uum)*0.05; 
                nc{'time'}(:)=(str2num(nn2)-1)/24.;
            else
                nc{'rlon'}(1,1:len)=slon(1,1:len);
                nc{'rlat'}(1,1:len)=slat(1,1:len);
                nc{'obsdata'}(1,1:len)=vv(1,1:len); 
                nc{'obserr'}(1,1:len)= abs(vv(1,1:len))*0.1; %(vv(1,1:len)-vvm)*0.05;
                nc{'time'}(:)=(str2num(nn2)-1)/24.;            
            end
            
            disp([' time : ',nn2,'    number : ', mm,'   ens_t : ',nn])
            close(nc)
        end
        clear slon; clear slat;  clear uu;  clear vv;
    else
        disp([' time : ',[t, tt],'    number : ', mm,'   ens_t : ',nn])
        disp([' This time step did not have OBS.'])
        clear index; clear uu; clear vv; clear slon; clear slat;
    end
end    
end

fclose(fid);




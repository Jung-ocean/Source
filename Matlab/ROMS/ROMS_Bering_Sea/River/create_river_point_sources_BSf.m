% This is a script to add the major Bering Sea rivers as precipitation input.

% Baed on data from the NCAR EOL database, from a Zhang and Woodgate paper (2010?) 
% The three major rivers are the Yukon, Kukokswim and Anadyr
% The numbers from there are ...
mean_flow=[371 1289 42; 331 1068 31; 306 892 25; 439 923 26; 2295 7906 284;  ...
       2303 18278 4981; 1910 12950 3008; 2131 11335 1587;1927 9351 1298; ...
       1289 5639 452; 623 2289 117; 439 1465 65];
% These are monthly values for the Anadyr, Yukon and Kukokswim respectively in m^3/s

% Let's collect all our historical monthly flow information from the GRDC
% data base.
Rname = '/data/sdurski/ROMS_Setups/Forcing/Rivers/Source_data/GRDC_Kamchatka.nc';
[Riv(1)] = read_grdc_river(Rname, 'Kamchatka',2); % the second record is farther downstream.
Rname = '/data/sdurski/ROMS_Setups/Forcing/Rivers/Source_data/GRDC_Anadyr.nc';
[Riv(2)] = read_grdc_river(Rname, 'Anadyr',1); 
Rname = '/data/sdurski/ROMS_Setups/Forcing/Rivers/Source_data/GRDC_Yukon.nc';
[Riv(3)] = read_grdc_river(Rname, 'Yukon',1); 
Rname = '/data/sdurski/ROMS_Setups/Forcing/Rivers/Source_data/GRDC_Kuskokwim_reg.nc';
[Riv(4)] = read_grdc_river(Rname, 'Kuskokwim',1); % riv#1 in this file corresponds to Kusk
[Riv(5)] = read_grdc_river(Rname, 'Nushagak',5); % riv# 5 in this file corresponds to Nush



% This is a revision of my routine that added rivers as precipitation
% sources.  Here we add rivers as point sources somewhat distributed along
% the coastlines

% I want to distribute this water over the near coastal region,.  I will linearly interpolate between the 
% Let me form a semicircle of a chosen radius around the approximate mouth
% of each river and add the river inflow over this area evenly distributed.
% To do this I need to determine how many unmasked grid cells are contained
% in the semicircle and divide the mean flow by the number of cells.

% In this iteration I am including rivers from the entire Bering Sea
% region.
% So far the Rivers I plan to include are the Yukon,Anadyr,Kuskokwim,
% Kamchatka, Nushagak....    For some of these I have rather current monthly data,
% for others I only have historical data. 

filename='/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BS_HYC20180701_D_init.nc';
Gname='/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_D_grid.nc';
%Grid=grid_arrays_new_2(filename,Gname);
load /data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_D_grid.mat

% The locations of the rivers are Kamchatka, Anadyr, Yukon, Kuskokwim,
% Nushagak 
lon_riv=[-197.5 -182.3 -165 -162.3 -158.67];
lat_riv=[56.2    64.6 62.65 60.0   58.8 ];

% Find all grid points within a radius x of the river mouth
% Given the flow and topography around each lets make the radius of interest small
% for the Kukokswim and Anadyr, but large, and delta-like for the Yukon.
% These radii will kind of set the pressure head associated with the
% outflow. It remains to be determined how few grid points we should
% distribute the transport over.
del_lat=[0.15 0.21 0.3 0.15 0.1];

for ir=1:length(lon_riv);  
  % by multiplying by the mask we find the relevant grid points that are
  % unmasked.
  distlon = distance([lat_riv(ir) lon_riv(ir)],[lat_riv(ir) lon_riv(ir)+1], ...
                     almanac('earth', 'ellipsoid', 'km'));
  distlat = distance([lat_riv(ir) lon_riv(ir)],[lat_riv(ir)+1 lon_riv(ir)], ...
                     almanac('earth', 'ellipsoid', 'km'));
  dist_ratio = distlon/distlat;
  dist=sqrt(((Grid.ln_r.*Grid.mask_r-lon_riv(ir)).*dist_ratio).^2 + ...
             (Grid.lt_r.*Grid.mask_r-lat_riv(ir)).^2);
  riv(ir).ind=find(dist<=del_lat(ir));    
end


% Now I am not interested in the semicircle but only the cells on that
% semicircle which are masked on one or more sides.
% Search through each grid cell in riv(ir).ind, and identify cells adjacent
% to a masked point...determine on which side that masked point is and
% identify the u or v face index and the direction (sign) of outflow.

% First just identify the points
for ir=1:length(lon_riv),
    ipc=0;
    for ip=1:length(riv(ir).ind),
        [ii,ij]=ind2sub([Grid.L Grid.M],riv(ir).ind(ip));
        if (Grid.mask_r(ii,ij-1)==0 || Grid.mask_r(ii,ij+1)==0 ||...
            Grid.mask_r(ii-1,ij)==0 || Grid.mask_r(ii+1,ij)==0)
          ipc=ipc+1;
          riv(ir).indp(ipc)=riv(ir).ind(ip);
        end
    end
end

% Let's identify the points that aren't cornered by two other
% masked points as true point source boundary points.

for ir=1:length(lon_riv),
    ipc=0;
    for ip=1:length(riv(ir).indp),
        [ii,ij]=ind2sub([Grid.L Grid.M],riv(ir).indp(ip));
        [irp,jrp]=ind2sub([Grid.L Grid.M],setdiff(riv(ir).indp,riv(ir).indp(ip)));
        if ~(sum(irp==ii-1 & jrp==ij)     ...
                *sum(irp==ii   & jrp==ij-1) | ...
                sum(irp==ii-1 & jrp==ij)     ...
                *sum(irp==ii   & jrp==ij+1) | ...
                sum(irp==ii+1 & jrp==ij)     ...
                *sum(irp==ii   & jrp==ij-1) | ...
                sum(irp==ii+1 & jrp==ij)     ...
                *sum(irp==ii   & jrp==ij+1  ))
            ipc=ipc+1;
            riv(ir).indpt(ipc)=riv(ir).indp(ip);
        end
    end
end

maskN= Grid.mask_r;maskN(Grid.mask_r==0)=NaN;
figure(7);
pcolor(Grid.ln_r,Grid.lt_r,-Grid.h.*maskN); set(gca,'CLim',[-400 0]);shading flat;
for ir = 1:length(Riv)
    hlr(ir).h = line(Grid.ln_r(riv(ir).ind),Grid.lt_r(riv(ir).ind));
    set(hlr(ir).h,'LineStyle','none','Marker','o','color',[1 0 0]);
    hlr(ir).hp =line(Grid.ln_r(riv(ir).indpt),Grid.lt_r(riv(ir).indpt));
    set(hlr(ir).hp,'LineStyle','none','Marker','p','color',[0 0.8 0]);
end


% We have now identified our point sources.  Next we determine the
% direction of outflow from that point source u or v.  and the magnitude
% and sign of the outflow at that point.  
for ir=1:length(lon_riv),
    ipc=0;
    for ip=1:length(riv(ir).indpt),
        [ii,ij]=ind2sub([Grid.L Grid.M],riv(ir).indpt(ip));
        if Grid.mask_r(ii-1,ij)==0
            riv(ir).uv(ip)=0;
            riv(ir).Xp(ip)=ii;
            riv(ir).Yp(ip)=ij;
            riv(ir).sign(ip)=1.0;
        elseif Grid.mask_r(ii,ij-1)==0
            riv(ir).uv(ip)=1;
            riv(ir).Xp(ip)=ii;
            riv(ir).Yp(ip)=ij;
            riv(ir).sign(ip)=1.0;
        elseif Grid.mask_r(ii+1,ij)==0   
            riv(ir).uv(ip)=0;
            riv(ir).Xp(ip)=ii+1;
            riv(ir).Yp(ip)=ij;
            riv(ir).sign(ip)=-1.0;
        else
            riv(ir).uv(ip)=1;
            riv(ir).Xp(ip)=ii;
            riv(ir).Yp(ip)=ij+1;
            riv(ir).sign(ip)=-1.0;  
        end
    end
end



% Assume the monthly transport is associated with the 15th of each month, 
% assign a value to the first of each month and one additional at the last
% minute of the year.

mf_2=zeros([13 length(Riv)]);
for ir =1: length(Riv)
mf_2(1:12,ir)=Riv(ir).transp_clima;
end
mf_2(13,:)=mf_2(1,:);
mf_3=zeros([13 length(Riv)]);
mf_3(1:12,:)=0.5.*(mf_2(2:end,:)+mf_2(1:end-1,:));
mf_3(13,:)=mf_3(1,:);
for im=1:12
    mf_time(im)=datenum(0,im,0);
end
mf_time(13)=datenum(0,12,31.99);

%for each
% forcing record linearly interpolate between to the chosen time to
% determine the fresh water volume.  
Fname='/data/sdurski/ROMS_Setups/Forcing/Rivers/BS_5rivers_201819_2.nc';
% Although this is a cyclical climatology, let's create a file of times
% from May 1st, 2009 through August 1 2010, with daily records.
times=datenum(2018,6,1):1:datenum(2019,8,1);
times_r=times-datenum(1968,5,23);
% NOTE: need to create netcdf file and input proper number of point source
% locations into it 
Np=length(riv(1).indpt) + length(riv(2).indpt) + length(riv(3).indpt);
% Write out point source positions and directions
ipp=0;
riv_ind = [];
psource_Vshape=zeros([Grid.N Np]);
for ir=1:length(riv)
    for ip=1:length(riv(ir).indpt)
        ipp=ipp+1;
        riv_ind(ipp)=ir;
        psource_rid(ipp)=ir;
        psource_dir(ipp)=riv(ir).uv(ip);
        psource_Xp(ipp)=riv(ir).Xp(ip)-1;  % subtract one from both the i-
        psource_Yp(ipp)=riv(ir).Yp(ip)-1;  % and j- position to start rho index at 1.
        psource_Vshape(:,ipp)=ones([Grid.N 1])./Grid.N;
     end
end

ncwrite(Fname,'river',psource_rid);
ncwrite(Fname,'river_Xposition',psource_Xp);
ncwrite(Fname,'river_Eposition',psource_Yp);
ncwrite(Fname,'river_direction',psource_dir);
ncwrite(Fname,'river_Vshape',psource_Vshape');
% Write out the time 
timeR=times_r;
ncwrite(Fname,'river_time',timeR);

transp=zeros([Np length(times)]);
for it=1:length(times),
    % convert the time to a 0th year time.
    year=str2num(datestr(times(it),'yyyy'));
    time0=times(it)-datenum(year,0,0);
    ipp=0;
    for ir=1:length(riv)
        mf0=interp1(mf_time,mf_3(:,ir),time0);  % determine the freshwater flow at the given time.
        mfi=mf0./length(riv(ir).indpt);  
        for ip=1:length(riv(ir).indpt),
            ipp=ipp+1;
            transp(ipp,it)=mfi.*riv(ir).sign(ip);
        end
    end
end
ncwrite(Fname,'river_transport',transp);


% Finally we need to write out the river temperature and the river
% salinity.
% Let's read in a time record from our simulation near the mouth of each
% river to specify the river temperature and set the river salinity in all
% cases to zero.  
% Set the minimum temperature of the water to zero...this should make the
% mouths of these estuaries ideal places for frazil ice formation...

%collect data at 3 stations....

% Load temperature time series from a previous run for the river mouths.
% Append a summer run with a fall-winter-spring run.
load /home/jaguar/data6/sdurski/ROMS/Output/Bering_Sea/Winter/Ice_Improve/MAT_files/River_mouth_Stations_2009_Summer.mat
% 
Sta_sum=Sta;
timeSum=timeR;
load /home/jaguar/data6/sdurski/ROMS/Output/Bering_Sea/Winter/Ice_Improve/MAT_files/River_mouth_Stations_2009_2010.mat
Sta_win=Sta;
timeW=timeR;

% wrap around plus one day...
timeSta=[timeSum(1:41) timeW(10:254)];
% shift this array a bit such that we have and annual cycle in just year
% day.
timeSta_c=([timeSta(134:end)-365 timeSta(2:135)])-datenum(2009,1,1);
% Shift the temperature time series at the three rivers in the same way.
TempS_c=zeros([Grid.N length(timeSta_c) 3]);
for ir=1:3,
    TempS=[Sta_sum(ir).temp(:,1:41) Sta_win(ir).temp(:,10:254)];
    TempS_c(:,:,ir)=[TempS(:,134:end) TempS(:,2:135)]; 
end
TempS_c=max(TempS_c,0.0);
% For each river interpolate the temperature to the times in 
T_river=zeros([Np Grid.N length(times)]);

% We now have 5 rivers so let's say the Kamchatka and E.. are jst like the
% Kuskokwim
TempS_c5 = zeros([45 length(timeSta_c) 5]);
TempS_c5(:,:,1) = TempS_c(:,:,3);
TempS_c5(:,:,5) = TempS_c(:,:,3);
TempS_c5(:,:,2:4) = TempS_c(:,:,1:3);
for it=1:length(times),
    % convert the time to a 0th year time.
    year=str2num(datestr(times(it),'yyyy'));
    time0=times(it)-datenum(year,0,0);
    ipp=0;
    for ir=1:length(riv)
        for ip=1:length(riv(ir).indpt),
            ipp=ipp+1;
            for ik=1:Grid.N,
               T_river(ipp,ik,it)=interp1(timeSta_c,TempS_c5(ik,:,ir),time0);  % Specify the temperature of the freshwater inflow.
            end
        end
    end
    it
end

% Set the salinity to zero for all points of all rivers.
S_river=zeros(size(T_river));

% and write out the river temperatures and salinities.
ncwrite(Fname,'river_temp',T_river);
ncwrite(Fname,'river_salt',S_river);



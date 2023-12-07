clc;clear all;close all

%% cad에서 빼온 자료 transform
% fid=fopen('depth.dat');
% depth=textscan(fid,'%f %f %f');
% fclose(fid);
% Xk=depth{1};Yk=depth{2};z=depth{3};
% X1=252600; X2=252700;
% x1=129.420758841;x2=129.421867453;
% Y1=281400; Y2=281500;
% y1=36.0313560354;y2=36.0322077689;
% lat=((y2-y1)/(100)).*(Yk-Y1)+y1;
% lon=((x2-x1)/(X2-X1)).*(Xk-X1)+x1;
% data=[lon,lat,z];
% fid=fopen('depth_ll.dat','w');
% fprintf(fid,'%13.9f  %13.9f  %f  \r\n',data');
% fclose(fid);

%% 과거 자료에서 새로 매립된 곳 추가하여 수심 변경
%data=load('new_dep.dat');
%lon=data(:,1);lat=data(:,2);z=data(:,3);

load grid.mat
lon = lon_rho(1,:); lat = lat_rho(:,1);
z = -10*ones(100,50);

Xi=[min(lon)-0.05:0.05:max(lon)+0.05];
Yi=[min(lat)-0.05:0.05:max(lat)+0.05];
[X,Y]=meshgrid(Xi,Yi);
Z=griddata(lon,lat,z,X,Y);
Z=-Z;
Z(isnan(Z)==1)=0;
pcolor(X,Y,Z);shading flat;

nw=netcdf('depth_test.nc','clobber');

nw('lon') = length(Xi);
nw('lat') = length(Yi);
nw('one') = 1;

nw{'lon'} = ncfloat('lon');
nw{'lon'}.long_name = ncchar('Longitude');
nw{'lon'}.units = ncchar('degree_east');
nw{'lon'}(:)=Xi;

nw{'lat'} = ncfloat('lat');
nw{'lat'}.long_name = ncchar('Latitude');
nw{'lat'}.units = ncchar('degree_north');
nw{'lat'}(:)=Yi;

nw{'z'} = ncfloat('lat','lon');
nw{'z'}.long_name = ncchar('z');
nw{'z'}.units = ncchar('meter');
nw{'z'}(:)=Z;

close(nw);
function [dx,dy]=lonlat2dxdy(lon,lat);

R = earthRadius('m');
lon1=lon(:,1);
lat1=lat(1,:);
dlon=diff(lon1);
dlat=diff(lat1);
dlon=0.5*(dlon(1:end-1)+dlon(2:end));
dlat=0.5*(dlat(1:end-1)+dlat(2:end));
dlon=[dlon(1);dlon;dlon(end)];
dlat=[dlat(1) dlat dlat(end)];

[dlat,dlon]=meshgrid(dlat,dlon);

dy=R*dlat*pi/180;
dx=R*dlon*pi/180.*cos(dlat*pi/180);

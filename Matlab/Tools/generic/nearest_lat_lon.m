function [I,J]=nearest_lat_lon(lat,lon,reflat,reflon)
% From YS
%lat = latitude matrix
%lon= longitude matrix
%reflat= lat to be found as the closest to
%reflon = lon to be found as the closest to
dist2=sum(bsxfun(@minus, cat(3,lat,lon), cat(3,reflat,reflon)).^2,3);
[I,J]=find(dist2==min(dist2(:)));

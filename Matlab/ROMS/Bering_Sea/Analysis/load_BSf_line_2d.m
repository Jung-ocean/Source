function [x, data] = load_BSf_line_2d(g, vari_str, datenum_target, domaxis)

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4/'];
filenum = datenum_target - datenum(2018,7,1) + 1;
fstr = num2str(filenum, '%04i');
filename = ['Dsm4_avg_', fstr, '.nc'];
file = [filepath, filename];

zeta = ncread(file, 'zeta');
depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);

if strcmp(vari_str, 'str_n')
    wgs84 = wgs84Ellipsoid("km");
    angle_section = azimuth(domaxis(3),domaxis(1),domaxis(4),domaxis(2),wgs84);
    angle_section = angle_section - 90; % To make East 0

    skip = 1;
    npts = [0 0 0 0];

    u = ncread(file, 'sustr');
    v = ncread(file, 'svstr');

    [u_rho,v_rho,lonred,latred,maskred] = ...
        uv_vec2rho_J(u,v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

    cosa = cosd(angle_section);
    sina = sind(angle_section);
    u_t = u_rho.*cosa - v_rho.*sina;
    v_n = v_rho.*cosa + u_rho.*sina;

    vari = v_n;

elseif strcmp(vari_str, 'v_n')
    wgs84 = wgs84Ellipsoid("km");
    angle_section = azimuth(domaxis(3),domaxis(1),domaxis(4),domaxis(2),wgs84);
    angle_section = angle_section - 90; % To make East 0

    skip = 1;
    npts = [0 0 0 0];

    u = ncread(file, 'u', [1 1 g.N 1], [Inf Inf 1 Inf]);
    v = ncread(file, 'v', [1 1 g.N 1], [Inf Inf 1 Inf]);

    [u_rho,v_rho,lonred,latred,maskred] = ...
        uv_vec2rho_J(u,v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

    cosa = cosd(angle_section);
    sina = sind(angle_section);
    u_t = u_rho.*cosa - v_rho.*sina;
    v_n = v_rho.*cosa + u_rho.*sina;

    vari = v_n;

elseif strcmp(vari_str, 'SSS')
    vari = squeeze(ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf]));
else
    vari = squeeze(ncread(file, vari_str));
end


lon = g.lon_rho;
lat = g.lat_rho;

dist=sqrt((lon-domaxis(1)).^2+(lat-domaxis(3)).^2);
min_dist=min(min(dist));
dist2=sqrt((lon-domaxis(2)).^2+(lat-domaxis(4)).^2);
min_dist2=min(min(dist2));
[x1,y1]=find(dist==min_dist);
[x2,y2]=find(dist2==min_dist2);
lat1=lat(x1(1),y1(1));lon1=lon(x1(1),y1(1));
lat2=lat(x2(1),y2(1));lon2=lon(x2(1),y2(1));

if (lon2-lon1) >= (lat2-lat1)+.1
    lon_line=[min(lon1,lon2):0.05:max(lon1,lon2)];
    lat_line=(lon_line-lon1)/((lon2-lon1)/(lat2-lat1))+lat1;
    x=lon_line';
    x_label='Longitude (^oE)';
else
    lat_line=[min(lat1,lat2):0.05:max(lat1,lat2)];
    lon_line=(lat_line-lat1)*((lon2-lon1)/(lat2-lat1))+lon1;
    x=lat_line';
    x_label='Latitude (^oN)';
end

lon_range=lon(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
lat_range=lat(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));

data_range=squeeze(vari(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
data = griddata(lon_range,lat_range,data_range,lon_line,lat_line);

% pcolor(x,Yi,data); shading flat;

end
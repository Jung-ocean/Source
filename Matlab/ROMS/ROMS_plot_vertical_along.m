%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS vertical section along line
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yyyy = 2013; tys = num2str(yyyy);

casename = 'NWP';
g = grd(casename);
masku2 = g.mask_u./g.mask_u;
maskv2 = g.mask_v./g.mask_v;

theta_s = g.theta_s; theta_b = g.theta_b;
hc = g.hc; h = g.h; N = g.N;

depth_target = 15;

[lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, [126 128.5], [33.8 35]);

h_target = g.h(lat_ind, lon_ind);

index_lat = [];
index_lon = [];
for i = 1:length(lon_ind)
    h_tmp = h_target(:,i);
    dist = (h_tmp - depth_target).^2;
    index = find(dist == min(dist));
    
    [lat, lon] = find(g.h == h_tmp(index));
    index_lat = [index_lat; lat];
    index_lon = [index_lon; lon];
end

lon_ind = index_lon;
lat_ind = index_lat;

figure; hold on;
pcolor(g.h.*g.mask_rho./g.mask_rho)
plot(lon_ind, lat_ind ,'ro')

var_str = 'temp';
switch var_str
    case 'temp'
        colormapname = 'parula';
        clim = [0 30];
        %clim = [0 20];
        contourinterval = [clim(1):2:clim(2)];
        colorbarname = 'Temperature (deg C)';
    case 'salt'
        colormapname = 'parula';
        clim = [30 35];
        contourinterval = [clim(1):1:clim(2)];
        colorbarname = 'Salinity';
    case 'u'
        colormapname = 'jet';
        clim = [-1.0 1.0];
        contourinterval = [clim(1):0.1:clim(2)];
        colorbarname = 'Zonal velocity (m/s)';
    case 'v'
        colormapname = 'jet';
        clim = [-0.5 0.5];
        contourinterval = [clim(1):0.1:clim(2)];
        colorbarname = 'Meridional velocity (m/s)';
    case 'density'
        colormapname = 'parula';
        clim = [15 28];
        contourinterval = [clim(1):1:clim(2)];
        colorbarname = 'Density (\sigma_\theta)';
end

datenum_ref = datenum(yyyy,1,1);

filenumber = 182:243;
fns = num2char(filenumber, 4);
filedate = datestr(filenumber + datenum_ref -1, 'mmdd');

for fi = 1:length(filenumber)
    %mm = mi;     tms = num2char(mm,2);
    %filename = ['monthly_', tys, tms, '.nc']; ncload(filename)
    
    filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\2013\daily\'];
    filename = ['avg_', fns(fi,:), '.nc']; 
    file = [filepath, filename];
    ncload(file)
    
    depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
    depth(depth > 1000) = NaN;
    
    pdens = zeros(size(depth));
    for si = 1:g.N
        pres = sw_pres(squeeze(depth(si,:,:)), g.lat_rho);
        pdens(si,:,:) = sw_pden_ROMS(squeeze(salt(si,:,:)), squeeze(temp(si,:,:)), pres, 0);
    end
    
    density = pdens - 1000;
    var = eval(var_str);
    
    if strcmp(var_str,'u') || strcmp(var_str,'v')
        skip = 1; npts = [0 0 0 0];
        for di = 1:g.N
            u_2d = squeeze(u(di,:,:));
            v_2d = squeeze(v(di,:,:));
            [u_rho(di,:,:),v_rho(di,:,:),lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        end
        var = eval([var_str, '_rho']);
    end
    
    Yi = zeros(N, length(lon_ind));
    data = zeros(N, length(lon_ind));
    Xi = zeros(1,length(lon_ind));
    for pi = 1:length(lon_ind)
        Yi(:,pi) = squeeze(depth(:,lat_ind(pi),lon_ind(pi)));
        data(:,pi) = squeeze(eval(['var(:,lat_ind(pi),lon_ind(pi))']));
        Xi(:,pi) = g.lon_rho(lat_ind(pi), lon_ind(pi));
    end
    Xi=repmat(Xi,g.N,1);
    
    figure; hold on
    pcolor(Xi,Yi,data); shading interp; colormap(colormapname)
    [cs, h] = contour(Xi, Yi, data, contourinterval, 'k');
    clabel(cs,h,'LabelSpacing',144, 'FontSize', 15)
    caxis(clim);
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    
    set(gca, 'FontSize', 15)
    ylabel('Depth(m)', 'FontSize', 15)
    xlabel('Longitude(^oE)', 'FontSize', 15)
        
    title([filedate(fi,:)], 'fontsize', 25)
    saveas(gcf, [var_str, '_diagonal_', filedate(fi,:), '.png'])
end
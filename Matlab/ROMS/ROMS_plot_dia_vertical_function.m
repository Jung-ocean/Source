function [x, Yi, data] = ROMS_plot_dia_vertical_function(g, depth, var_str, var, domaxis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS vertical section
%       casename = model domain casename
%       var_str = variable name string
%       var = variable
%       section = 'lon' or 'lat'
%       location = constant longitude or latitude
%       range = section range [a b]
%
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lon = g.lon_rho;
lat = g.lat_rho;

if sum(strcmp(var_str, {'v_cor', 'v_prsgrd', 'v_barot', 'v_baroc', 'v_geo', 'v_vvisc', 'v_adv', 'v_accel'}))
    scale_factor = 1e-6; clim = [-50 50]; contourinterval = [-50 -30 -8 -4 0 4 8 30 50]; colorbarname = 'x 10^-^6 m/s^2'; clim_ = 10;
else
    scale_factor = 1e-6; clim = [-50 50]; contourinterval = [-50 -30 -8 -4 0 4 8 30 50]; colorbarname = 'x 10^-^6 m/s^2'; clim_ = 1;
end

colormapname = 'redblue2';

dist=sqrt((lon-domaxis(3)).^2+(lat-domaxis(1)).^2);
min_dist=min(min(dist));
dist2=sqrt((lon-domaxis(4)).^2+(lat-domaxis(2)).^2);
min_dist2=min(min(dist2));
[x1,y1]=find(dist==min_dist);
[x2,y2]=find(dist2==min_dist2);
lat1=lat(x1(1),y1(1));lon1=lon(x1(1),y1(1));
lat2=lat(x2(1),y2(1));lon2=lon(x2(1),y2(1));

if (lon2-lon1) >= (lat2-lat1)
    lon_line=[lon1:0.05:lon2];
    lat_line=(lon_line-lon1)/((lon2-lon1)/(lat2-lat1))+lat1;
    x=repmat(lon_line,g.N,1);
    x_label='Longitude (^oE)';
    domaxis=[domaxis(3) domaxis(4) domaxis(5) domaxis(6) domaxis(5) domaxis(6)];
else
    lat_line=[min(lat1,lat2):0.05:max(lat1,lat2)];
    lon_line=(lat_line-lat1)*((lon2-lon1)/(lat2-lat1))+lon1;
    x=repmat(lat_line,g.N,1);
    x_label='Latitude (^oN)';
end

data=zeros(g.N,length(lat_line));
for k=1:1:g.N
    lon_range=lon(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
    lat_range=lat(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
    data_range=squeeze(var(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
    depth_range=squeeze(depth(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
    
    if size(lon_range,2) == 1 || size(lat_range,2) == 1
        data(k,:) = data_range;
        Yi(k,:) = depth_range;
    else
        data(k,:) = griddata(lon_range,lat_range,data_range,lon_line,lat_line);
        Yi(k,:) = griddata(lon_range,lat_range,depth_range,lon_line,lat_line);
    end
   
end

data = data./(scale_factor);

figure; hold on
% make land
datasize = size(Yi);
index = find(Yi(1,:) == min(Yi(1,:)));
Yi2 = repmat(Yi(:,index), [1, datasize(2)]);
land = -1000*ones(size(Yi2));
pcolor(x,Yi2,land); shading interp

data(data < clim(1)) = clim(1);
pcolor(x,Yi,data); shading interp;

cm = colormap(colormapname);
cm = [[.9 .9 .9]; cm];
cm2 = colormap(cm);
clim2 = [clim(1)-clim_ clim(2)+clim_];

[cs, h] = contour(x, Yi, data, contourinterval, 'k');
h.LineWidth = 2;
clabel(cs,h,'LabelSpacing',400, 'FontSize', 20);%, 'FontWeight', 'bold')
caxis(clim2);
%c.Label.String = colorbarname; c.Label.FontSize = 25;
% if sum(strcmp(var_str, {'u_vvisc', 'v_vvisc', 'u_accel', 'v_accel'}))
    c = colorbar; c.FontSize = 20;
    c.Ticks = [-50 -25 0 25 50];
    c.TickLabels = {'-50', '-25', '0', '25', '50'};
        
    c.Limits = clim;
    c.Title.String = colorbarname; c.Title.FontSize = 15;
    %setposition('vertical')
    
% else
    %setposition('vertical')
    %set(gca, 'Position', [ 0.3258    0.2055    0.5960    0.7195])
% end

set(gca, 'FontSize', 20)

ylabel('Depth (m)', 'FontSize', 20)
yticks([-120 -80 -40 0])
xlh = xlabel(x_label, 'FontSize', 20);
%xlh.Position(2) = xlh.Position(2) + abs(xlh.Position(2) * 0.12);

% if ~sum(strcmp(var_str, {'u_prsgrd', 'v_prsgrd', 'u_accel', 'v_accel'}))
% set(gca,'YTickLabel',[]);
% ylabel('');
% end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
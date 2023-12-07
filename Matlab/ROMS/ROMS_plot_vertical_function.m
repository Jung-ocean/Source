function [x, Yi, data] = ROMS_plot_vertical_function(g, depth, var_str, var, domaxis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS vertical section
%       casename = model domain casename
%       var_str = variable name string
%       var = variable
%       section = 'lon' or 'lat'
%       location = constant longitude or latitude
%       range = section range [a b]
%       vec = 'on' or 'off'
%
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS_colorbar = 16;
FS_contour = 20;

switch var_str
    case 'temp'
        colormapname = 'parula';
        clim = [10 30];
        %clim = [0 20];
        contourinterval = [clim(1):1:clim(2)];
        colorbarname = '^oC';
        
        lon = g.lon_rho;
        lat = g.lat_rho;
        
    case 'salt'
        colormapname = 'jet';
        clim = [30 35];
        contourinterval = [clim(1):.5:clim(2)];
        colorbarname = 'g/kg';
        
        lon = g.lon_rho;
        lat = g.lat_rho;
        
    case {'u', 'u_rho'}
        var = var*100; % m/s -> cm/s
        
        colormapname = 'redblue2';
        clim = [-80 80];
        contourinterval = [clim(1):20:clim(2)];
        colorbarname = 'cm/s';
        yticks_vec = [-4000 -3000 -2000 -1000 0];
        
        if strcmp(var_str, 'u')
            lon = g.lon_u;
            lat = g.lat_u;
        elseif strcmp(var_str, 'u_rho')
            lon = g.lon_rho;
            lat = g.lat_rho;
        end
        
    case {'v', 'v_rho'}
        var = var*100; % m/s -> cm/s
        
        colormapname = 'redblue2';
        clim = [-40 40];
        contourinterval = [clim(1):10:clim(2)];
        colorbarname = 'cm/s';
        yticks_vec = [-4000 -3000 -2000 -1000 0];
        
        if strcmp(var_str, 'v')
            lon = g.lon_v;
            lat = g.lat_v;
        elseif strcmp(var_str, 'v_rho')
            lon = g.lon_rho;
            lat = g.lat_rho;
        end
        
    case 'density'
        colormapname = 'parula';
        clim = [18 28];
        contourinterval = [clim(1):1:clim(2)];
        colorbarname = '\sigma_\theta';
        
        lon = g.lon_rho;
        lat = g.lat_rho;
        
    case 'w'
        g.N = g.N + 1;
        scale_factor = 1e-4;
        var = var/scale_factor;
        colormapname = 'parula';
        clim = [-2 2];
        contourinterval = [clim(1):.4:clim(2)];
        colorbarname = 'x10^-^4 m/s';
        
        lon = g.lon_rho;
        lat = g.lat_rho;
        
        %     case {'dye_01', 'dye_02', 'dye_03'}
        %         scale_factor = 1;
        %         var = var/scale_factor;
        %         colormapname = 'parula';
        %         clim = [0 30]; clim_ = 2;
        %         %contourinterval = [clim(1):2:clim(2)];
        %         contourinterval = [10 10];
        %         %colorbarname = 'Dye concentration (%)';
        %         colorbarname = '%';
        %
        %         lon = g.lon_rho;
        %         lat = g.lat_rho;
        
    case {'dye_01', 'dye_02', 'dye_03'}
        scale_factor = 1;
        var = var/scale_factor;
        
        colormapname = flipud(parula);
        %clim = [-6 2]; clim_ = 2;
        %clim = [0 1]; clim_ = .01; contourinterval = [clim(1):1:clim(2)];
        %clim = [0 1]; clim_ = .01; contourinterval = [clim(1):1:clim(2)];
        %colorbarname = 'Dye concentration (log, %)';
        clim = [0 100]; contourinterval = [10:20:100];
        colorbarname = '%';
        yticks_vec = [-4000 -3000 -2000 -1000 0];
        
        lon = g.lon_rho;
        lat = g.lat_rho;
        
end

dist=sqrt((lon-domaxis(3)).^2+(lat-domaxis(1)).^2);
min_dist=min(min(dist));
dist2=sqrt((lon-domaxis(4)).^2+(lat-domaxis(2)).^2);
min_dist2=min(min(dist2));
[x1,y1]=find(dist==min_dist);
[x2,y2]=find(dist2==min_dist2);
lat1=lat(x1(1),y1(1));lon1=lon(x1(1),y1(1));
lat2=lat(x2(1),y2(1));lon2=lon(x2(1),y2(1));

if (lon2-lon1) >= (lat2-lat1)+.1
    lon_line=[min(lon1,lon2):0.05:max(lon1,lon2)];
    lat_line=(lon_line-lon1)/((lon2-lon1)/(lat2-lat1))+lat1;
    x=repmat(lon_line,g.N,1);
    x_label='Longitude (^oE)';
    %domaxis=[domaxis(3) domaxis(4) domaxis(5) domaxis(6) domaxis(5) domaxis(6)];
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
    %if size(lon_range,2) == 1 || size(lat_range,2) == 1
    %    data(k,:)=data_range;
    %    Yi(k,:)=depth_range;
    if length(unique(lon_range)) == 1
        data(k,:)=interp1(lat_range,data_range,lat_line);
        Yi(k,:)=interp1(lat_range,depth_range,lat_line);
    elseif length(unique(lat_range)) == 1
        data(k,:)=interp1(lon_range,data_range,lon_line);
        Yi(k,:)=interp1(lon_range,depth_range,lon_line);
    else
        data(k,:)=griddata(lon_range,lat_range,data_range,lon_line,lat_line);
        Yi(k,:)=griddata(lon_range,lat_range,depth_range,lon_line,lat_line);
    end
end

figure; hold on
% make land
datasize = size(Yi);

mindepth = min(min(Yi));
Yi2_surf = Yi(1,:) - 0.1;
for i = 1:datasize(2)
    Yi2(:,i) = linspace(mindepth, Yi2_surf(i),datasize(1));
end
land = 1000*ones(size(Yi2));
pcolor(x,Yi2,land); shading interp

% switch var_str
%     case {'dye_01', 'dye_02', 'dye_03'}
%         data(data < 1e-4) = NaN;
%     otherwise
%         data(data < clim(1)) = clim(1);
% end

pcolor(x,Yi,data); shading interp;

cm = colormap(colormapname);
cm = [cm; [.7 .7 .7]; [.7 .7 .7]];
cm2 = colormap(cm);
if strcmp(colormapname, 'redblue2')
    clim_ = 5;
    cm = [cm(1,:); cm(1,:); cm;];
    cm2 = colormap(cm);
else
    clim_ = 0;
end
clim2 = [clim(1)-clim_ clim(2)+clim_];

[cs, h] = contour(x, Yi, data, contourinterval, 'k');
h.LineWidth = 1;
%[cs24, h24] = contour(x, Yi, data, [24 24], 'k');
%h24.LineWidth = 3;
clabel(cs,h,'LabelSpacing',200, 'FontSize', FS_contour, 'FontWeight', 'bold')
%clabel(cs24,h24,'LabelSpacing',200, 'FontSize', 25, 'FontWeight', 'bold')

caxis(clim2);
c = colorbar; c.FontSize = FS_colorbar;
c.Limits = clim;
c.Title.String = colorbarname; c.Title.FontSize = FS_colorbar;
%c.Label.String = colorbarname; c.Label.FontSize = 22;

%switch var_str
%    case {'dye_01', 'dye_02', 'dye_03'}
%c.TickLabels = {'10^{-8}' '10^{-6}' '10^{-4}' '10^{-2}' '10^{0}' '10^{2}'} ;
%        c.TickLabels = {'10^{-6}' '10^{-4}' '10^{-2}' '10^{0}' '10^{2}'} ;
%end

set(gca, 'FontSize', 20)

ylabel('Depth (m)', 'FontSize', 20)
%yticks(yticks_vec)
xlabel(x_label, 'FontSize', 20)

% if sum(strcmp(var_str, {'u'}))
%     set(gca,'YTickLabel',[]);
%     ylabel('');
% end

end
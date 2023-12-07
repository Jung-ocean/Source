clear; clc; close all

varistr = 'salt';
line = 'YS_325';

switch varistr
    case 'temp'
        filestr = 't';
        clim = [10 30];
        contour_interval = [clim(1):2:clim(2)];
        unit = '^oC';
        colormapname = 'parula';
    case 'salt'
        filestr = 's';
        clim = [30 35];
        contour_interval = [clim(1):.5:clim(2)];
        unit = 'g/kg';
        colormapname = 'jet';
end

for mi = 6:8
    mm = mi; mstr = num2char(mm,2);
    filename = ['eas_decav_', filestr, mstr, '_10.nc'];
    
    nc = netcdf(filename);
    lon1 = nc{'lon'}(:);
    lat1 = nc{'lat'}(:);
    dep = nc{'depth'}(:);
    vari = nc{[filestr, '_an']}(:);
    close(nc)
    
    [lon, lat] = meshgrid(lon1, lat1);
    
    vari(abs(vari) > 100) = NaN;
    depth = repmat(dep, [1, size(lat)]);
    
    switch line
        case 'KS_N'
            domaxis=[35.4 33.4 129 130.5 -150 0]; % Korea Strait N
        case 'KS_S'
            domaxis=[35 33.2 128.5 129.8 -150 0]; % Korea Strait S
        case '208'
            domaxis = [35.475 35.185 129.455 129.8783 -150 0];
        case {'YS_325', 'YS_330', 'YS_335', 'YS_340', 'YS_345', 'YS_350', 'YS_355', 'YS_360'}
            lat_target = str2num(line(4:6))/10;
            domaxis = [lat_target lat_target 119 126.63 -90 0];
    end
    
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
        x=repmat(lon_line,length(dep),1);
        x_label='Longitude(^oE)';
        domaxis=[domaxis(3) domaxis(4) domaxis(5) domaxis(6) domaxis(5) domaxis(6)];
    else
        lat_line=[min(lat1,lat2):0.05:max(lat1,lat2)];
        lon_line=(lat_line-lat1)*((lon2-lon1)/(lat2-lat1))+lon1;
        x=repmat(lat_line,length(dep),1);
        x_label='Latitude(^oN)';
    end
    
    data=zeros(length(dep),length(lat_line));
    for k=1:1:length(dep)
        lon_range=lon(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
        lat_range=lat(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
        data_range=squeeze(vari(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
        depth_range=squeeze(depth(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
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
    %set(gca,'Position',[0.2 0.15 0.73 0.75]);
    
    pcolor(x,-Yi,data); shading flat;
    
    colormap(colormapname); caxis(clim)
    axis([domaxis(1) domaxis(2) domaxis(5) domaxis(6)]);
    
    [cs,h] = contour(x,-Yi,data,contour_interval,'k','linewidth',1);
    clabel(cs,h,'FontSize',20,'Color','k','labelspacing',100000,'Rotation',0,'fontweight','bold');
    
    ylabel('Depth (m)')
    xlabel('Longitude (^oE)')
    title([varistr, ' ', mstr])
    
    set(gca, 'FontSize', 20)
    
    bar = colorbar('fontsize', 16);
    bar.Limits = clim;
    set(get(bar,'title'),'string',unit,'FontSize',16)
    
    saveas(gcf, [varistr, '_vertical_',line, '_', mstr, '.png'])
    
end
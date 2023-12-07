clear; clc; close all

yyyy = 2007; ystr = num2str(yyyy);
varistr = 'salt';

switch varistr
    case 'temp'
        clim = [0 30];
        contour_interval = [clim(1):5:clim(2)];
        unit = '^oC';
    case 'salt'
        clim = [33 35];
        contour_interval = [clim(1):.1:clim(2)];
        unit = ' ';
end

for mi = 1:12
    mm = mi; mstr = num2char(mm,2);
    filename = ['HYCOM_' ,ystr, mstr, '.nc'];
    
    nc = netcdf(filename);
    lon = nc{'longitude'}(:);
    lat = nc{'latitude'}(:);
    dep = nc{'depth'}(:);
    vari = nc{varistr}(:);
    close(nc)
    
    vari(abs(vari) > 100) = NaN;
    depth = repmat(dep, [1, size(lat)]);
    
    data = vari;
    
    domaxis=[29.0047 27.5218 125.9953 128.2412 -1500 0]; % PN-line
    
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
    
    Temp=zeros(length(dep),length(lat_line));
    for k=1:1:length(dep)
        lon_range=lon(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
        lat_range=lat(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
        data_range=squeeze(data(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
        depth_range=squeeze(depth(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
        Temp(k,:)=griddata(lon_range,lat_range,data_range,lon_line,lat_line);
        Yi(k,:)=griddata(lon_range,lat_range,depth_range,lon_line,lat_line);
    end
    data=Temp;
    
    figure('position',[400 100 550 550],'PaperUnits','inches','PaperPosition',[0 0 5.7 5.8]); hold on
    set(gca,'Position',[0.2 0.15 0.73 0.75]);
    
    pcolor(x,-Yi,data); shading flat;
    colormap('jet'); caxis(clim)
    axis([domaxis(1) domaxis(2) domaxis(5) domaxis(6)]);
    
    [cs,h] = contour(x,-Yi,data,contour_interval,'k','linewidth',1);
    clabel(cs,h,'FontSize',15,'Color','k','labelspacing',100000,'Rotation',0,'fontweight','bold');
    
    ylabel('Depth (m)')
    xlabel('Longitude (^oE)')
    
    set(gca, 'FontSize', 15)
    
    bar = colorbar('fontsize',17,'fontweight','bold');
    set(get(bar,'title'),'string',unit,'FontSize',17,'fontweight','bold')
    
    saveas(gcf, [varistr, '_vertical_PN_HYCOM_', ystr, mstr, '.png'])
    
end
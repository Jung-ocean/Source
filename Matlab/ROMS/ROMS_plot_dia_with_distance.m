clear; clc; close all

yyyy = 2013; ystr = num2str(yyyy);
month_all = 7:8; month_title = {'July', 'August'};

fig_str = '206';
switch fig_str
    case '205'
        domaxis = [33.6217 34.4167 128.1533 127.6667 -120 0]; % KODC 205 line
    case 'cross'
        domaxis = [33.6217 34.4167 128.1533 127.8667 -120 0];
    case '206'
        domaxis = [34.3733 34.6333 128.8283 128.4167 -120 0]; % KODC 206 line
end
        
directions = {'ubar', 'vbar'};
varis = {'prsgrd', 'cor', 'sstr', 'bstr', 'hadv', 'hvisc', 'accel'};

casename = 'EYECS_20190904';
g = grd(casename);

lon = g.lon_rho;
lat = g.lat_rho;

dist=sqrt((lon-domaxis(3)).^2+(lat-domaxis(1)).^2);
min_dist=min(min(dist));
dist2=sqrt((lon-domaxis(4)).^2+(lat-domaxis(2)).^2);
min_dist2=min(min(dist2));
[x1,y1]=find(dist==min_dist);
[x2,y2]=find(dist2==min_dist2);
lat1=lat(x1(1),y1(1));lon1=lon(x1(1),y1(1));
lat2=lat(x2(1),y2(1));lon2=lon(x2(1),y2(1));

if (lon2-lon1) >= (lat2-lat1)
    lon_line=[lon1:0.1:lon2];
    lat_line=(lon_line-lon1)/((lon2-lon1)/(lat2-lat1))+lat1;
    x_label='Longitude(^oE)';
    domaxis=[domaxis(3) domaxis(4) domaxis(5) domaxis(6) domaxis(5) domaxis(6)];
else
    lat_line=[min(lat1,lat2):0.1:max(lat1,lat2)];
    lon_line=(lat_line-lat1)*((lon2-lon1)/(lat2-lat1))+lon1;
    x_label='Latitude(^oN)';
end

for li = 1:length(lat_line)
    dist=sqrt((lon-lon_line(li)).^2+(lat-lat_line(li)).^2);
    min_dist=min(min(dist));
    [x,y]=find(dist==min_dist);
    xall(li) = x;
    yall(li) = y;
end

ubar = [];
vbar = [];
for di = 1:length(directions)
    direction = directions{di};
    
    for mi = 1:length(month_all)
        
        month = month_all(mi); mstr = num2char(month,2);
        
        filename = ['.\monthly_dia_', ystr, mstr, '.nc'];
        nc = netcdf(filename);
        
        for vi = 1:length(varis)
            var_str = [direction, '_', varis{vi}];
            
            for li = 1:length(xall)
                var = nc{var_str}(:,xall(li),yall(li));
                
                eval([direction, '(vi,li,mi) = var;'])
                
            end
            
        end % vi
    end % mi
end % di

figure;
for mi = 1:length(month_all)
    subplot(1,2,mi); hold on; grid on
    for vi = 1:length(varis)+1
        var = ubar;
        
        if vi == 8
            plot(lat_line, squeeze(var(2,:,mi))+squeeze(var(1,:,mi)), 'k--', 'LineWidth', 2)
        else
            plot(lat_line, squeeze(var(vi,:,mi)), 'LineWidth', 2)
            
        end
        xlabel('Latitude (^oN)')
        ylabel('(m/s^2)')
    end
    
    ylim([-10e-6 10e-6])
    yticks([-10e-6:2e-6:10e-6])
    h = legend([varis, 'ageo'], 'Location', 'SouthEast', 'Orientation', 'Vertical');
    h.FontSize = 12;
    title(month_title{mi})
    set(gca, 'FontSize', 15)
    set(gcf, 'Position', [ -1 337 1846 571])
    
end

saveas(gcf, 'Zonal(alongshore).png')

figure;
for mi = 1:length(month_all)
    subplot(1,2,mi); hold on; grid on
    for vi = 1:length(varis)+1
        var = vbar;
        
        if vi == 8
            plot(lat_line, squeeze(var(2,:,mi))+squeeze(var(1,:,mi)), 'k--', 'LineWidth', 2)
        else
            plot(lat_line, squeeze(var(vi,:,mi)), 'LineWidth', 2)
            
        end
        xlabel('Latitude (^oN)')
        ylabel('(m/s^2)')
    end
    
    ylim([-10e-5 10e-5])
    yticks([-10e-5:2e-5:10e-5])
    h = legend([varis, 'ageo'], 'Location', 'SouthEast', 'Orientation', 'Vertical');
    h.FontSize = 12;
    title(month_title{mi})
    set(gcf, 'Position', [ -1 337 1846 571])
    set(gca, 'FontSize', 15)
    
end

saveas(gcf, 'Meridional(crossshore).png')
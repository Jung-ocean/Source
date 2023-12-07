clear; clc; close all

fig_str = '205';
domaxis = [33.6217 34.4167 128.1533 127.6667 -120 0]; % KODC 205 line

location = load('G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\2013\location_205.mat');
lat_line = location.lat_line;
lon_line = location.lon_line;

year_mean = 2006:2015;
year_target = 2013;

month_all = 7:8;

domain_case = 'KODC_small';
colorbarname = 'Sea Level Anomaly (m)';

for mi = 1:length(month_all)
        
    month = month_all(mi); mstr = num2char(month,2);
    
    for yi = 1:length(year_mean)
        year = year_mean(yi); ystr = num2str(year);
        
        filepath = '.\';
        filename = ['AVISO_daily_', ystr, '.nc'];
        file = [filepath, filename];
        
        nc = netcdf(file);
        sla = nc{'sla'}(:); sla_sf = nc{'sla'}.scale_factor(:);
        sla = sla.*sla_sf;
        time = nc{'time'}(:);
        lon_raw = nc{'longitude'}(:);
        lat_raw = nc{'latitude'}(:);
        close(nc);
        
        [lon, lat] = meshgrid(lon_raw, lat_raw);
        
        time_vec = datevec(time + datenum(1950,1,1));
        index = find(time_vec(:,1) == year & time_vec(:,2) == month);
        
        sla_mean = squeeze(mean(sla(index,:,:)));
        sla_mean(sla_mean < -1000) = NaN;
        
        sla_all(yi,:,:) = sla_mean;
        
        if year == year_target
            sla_target = sla_mean;
        end
        
    end
    
    sla_climate = squeeze(mean(sla_all));
    
    subplot(1,2,mi); hold on; grid on;
    for i = 1:2
        
        if i == 1
            var = sla_climate;
        else
            var = sla_target;
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
            lon_line=[lon1:0.15:lon2];
            lat_line=(lon_line-lon1)/((lon2-lon1)/(lat2-lat1))+lat1;
            x_label='Longitude(^oE)';
            domaxis=[domaxis(3) domaxis(4) domaxis(5) domaxis(6) domaxis(5) domaxis(6)];
        else
            lat_line=[min(lat1,lat2):0.15:max(lat1,lat2)];
            lon_line=(lat_line-lat1)*((lon2-lon1)/(lat2-lat1))+lon1;
            x_label='Latitude(^oN)';
        end
        
        for li = 1:length(lat_line)
            dist=sqrt((lon-lon_line(li)).^2+(lat-lat_line(li)).^2);
            min_dist=min(min(dist));
            [x,y]=find(dist==min_dist);
            xall(li) = x;
            yall(li) = y;
            data(li) = var(x,y);
        end
    
        plot(lat_line, data, '-o', 'linewidth', 2)
        
        ylim([-0.1 0.3])
        
        xlabel('Latitude(^oN)')
        ylabel('Sea level anomaly (m)')
        
    end
        set(gca, 'FontSize', 15)
        h = legend('mean(2006-2015)', '2013');
        h.FontSize = 15;
    
end

set(gcf, 'Position', [289 242 1392 565])
saveas(gcf, ['sla_AVISO_', fig_str, '.png'])
    
 
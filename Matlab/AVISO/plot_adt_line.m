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
        adt = nc{'adt'}(:); adt_sf = nc{'adt'}.scale_factor(:);
        adt = adt.*adt_sf;
        time = nc{'time'}(:);
        lon_raw = nc{'longitude'}(:);
        lat_raw = nc{'latitude'}(:);
        close(nc);
        
        [lon, lat] = meshgrid(lon_raw, lat_raw);
        
        time_vec = datevec(time + datenum(1950,1,1));
        index = find(time_vec(:,1) == year & time_vec(:,2) == month);
        
        adt_mean = squeeze(mean(adt(index,:,:)));
        adt_mean(adt_mean < -1000) = NaN;
        
        adt_all(yi,:,:) = adt_mean;
        
        if year == year_target
            adt_target = adt_mean;
        end
        
    end
    
    adt_climate = squeeze(mean(adt_all));
    
    subplot(1,2,mi); hold on; grid on;
    for i = 1:2
        
        if i == 1
            var = adt_climate;
        else
            var = adt_target;
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
        data_all(i,mi,:) = data;
        
        plot(lat_line, data, '-o', 'linewidth', 2)
                
        ylim([0.6 1.2])
        
        xlabel('Latitude(^oN)')
        ylabel('Absolute dynamic topography (m)')
        
    end
    set(gca, 'FontSize', 15)
    h = legend('mean(2006-2015)', '2013');
    h.FontSize = 15;
    
end

set(gcf, 'Position', [289 242 1392 565])
%saveas(gcf, ['adt_AVISO_', fig_str, '.png'])

figure; hold on; grid on
Aug_July_mean = squeeze(data_all(1,2,:) - data_all(1,1,:));
Aug_July_2013 = squeeze(data_all(2,2,:) - data_all(2,1,:));
plot(lat_line, Aug_July_mean, '-o', 'linewidth', 2)
plot(lat_line, Aug_July_2013, '-o', 'linewidth', 2)
%ylim([0. 0.2])
xlabel('Latitude(^oN)')
ylabel('Absolute dynamic topography (m)')
        
set(gca, 'FontSize', 15)
h = legend('mean(2006-2015)', '2013');
h.FontSize = 15;
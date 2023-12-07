clear; clc; close all

load('G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\2013\upwellingindex\location.mat')

day_all = 182:243;

fs = 20;
period_movmean = 14;
linewidth_movmean = 3;
color_daily = [.5 .5 .5];

year_target = 2013;

for yi = 1:length(year_target)
    year = year_target(yi); ystr = num2str(year);
    
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
    
end
var = adt;

for di = 1:length(day_all)
    dayind = day_all(di);
    
    for li = 1:length(lat_coastal)
        dist_coastal=sqrt((lon-lon_coastal(li)).^2+(lat-lat_coastal(li)).^2);
        dist_offshore=sqrt((lon-lon_offshore(li)).^2+(lat-lat_offshore(li)).^2);
        
        min_dist_coastal=min(min(dist_coastal));
        min_dist_offshore=min(min(dist_offshore));
        
        [x,y]=find(dist_coastal==min_dist_coastal);
        xall(li) = x;
        yall(li) = y;
        data_coastal(li) = adt(dayind,x,y);
        
        [x,y]=find(dist_offshore==min_dist_offshore);
        xall(li) = x;
        yall(li) = y;
        data_offshore(li) = adt(dayind,x,y);
        
    end
    
    sealeveldiff(di) = mean(data_offshore - data_coastal);
end

figure; hold on; grid on
plot(day_all+1,movmean(sealeveldiff,period_movmean, 'Endpoints', 'fill'), 'linewidth', linewidth_movmean);
plot(day_all+1,sealeveldiff, 'linewidth', 1, 'Color', color_daily);
xticks([day_all(1)+1 day_all(32)+1 day_all(end)+1])
datetick('x', 'mmdd', 'keepticks')
xticklabels({'1 July', '1 August', '31 August'});
%ylim([0.05 0.25])
ylim([0 0.2])
ylabel('m')
title('Sea level diff. (offshore - coastal)')
set(gca, 'FontSize', fs)
box on; set(gca, 'LineWidth', 2)

set(gcf, 'Position', [14 694 1078 260])

saveas(gcf, 'ADTdiff_2013daily.png')
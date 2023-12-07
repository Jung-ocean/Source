%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot OSTIA daily temperature on the map
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

load('G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\2013\upwellingindex\location.mat')

day_all = 182:243;

fs = 20;
period_movmean = 14;
linewidth_movmean = 3;
color_daily = [.5 .5 .5];

[lon_lim, lat_lim] = domain_J('KODC_small');

%% Setting
% Target date from start to end
start_year = 2013;
start_month = 7;
start_day = 1;
start_datenum = datenum(start_year, start_month, start_day,0,0,0) - datenum(start_year, 01, 01,0,0,0) + 1;

end_month = 8;
end_day = 31;
end_datenum = datenum(start_year, end_month, end_day,0,0,0) - datenum(start_year, 01, 01,0,0,0) + 1;

% Filepath (related with start_year)
path = ['D:\Data\Satellite\OSTIA\', num2char(start_year,4), '\'];

%% Loop start
for i = start_datenum:end_datenum
    
    filedate = datestr(datenum(start_year,01,01,0,0,0) + i - 1, 'yyyymmdd')
    filepath = [path, num2char(i,3), '\'];
    filename = [filedate, '-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc.bz2'];
    [status, result] = unzip7([filepath, filename], filepath);
    file = [filepath, filename(1:end-4)];
    
    % Read data from netcdf file
    nc = netcdf(file);
    temp = nc{'analysed_sst'}(:);
    scale_factor = nc{'analysed_sst'}.scale_factor(:);
    add_offset = nc{'analysed_sst'}.add_offset(:);
    Lat = nc{'lat'}(:);
    Lon = nc{'lon'}(:);
    mask = nc{'mask'}(:);
    close(nc)
    
    % Convert raw temperature -> Kelvin -> Celsius (with mask)
    temp_Kelvin = temp*scale_factor + add_offset;
    temp_Celsius = temp_Kelvin - add_offset;
    mask(mask ~= 1) = nan;
    temp_mask = temp_Celsius.*mask;
    
    % Set the map and data limit
    lon_ind = find(Lon > lon_lim(1) & Lon < lon_lim(2));
    lat_ind = find(Lat > lat_lim(1) & Lat < lat_lim(2));
    
    Lon_selected = Lon(lon_ind);
    Lat_selected = Lat(lat_ind);
    temp_selected = temp_mask(lat_ind, lon_ind);
    
    [lon,lat] = meshgrid(Lon_selected, Lat_selected);
    
    for li = 1:length(lat_coastal)
        dist_coastal=sqrt((lon-lon_coastal(li)).^2+(lat-lat_coastal(li)).^2);
        dist_offshore=sqrt((lon-lon_offshore(li)).^2+(lat-lat_offshore(li)).^2);
        
        min_dist_coastal=min(min(dist_coastal));
        min_dist_offshore=min(min(dist_offshore));
        
        [x,y]=find(dist_coastal==min_dist_coastal);
        xall(li) = x;
        yall(li) = y;
        data_coastal(li) = temp_selected(x,y);
        
        [x,y]=find(dist_offshore==min_dist_offshore);
        xall(li) = x;
        yall(li) = y;
        data_offshore(li) = temp_selected(x,y);
        
    end
    
    data_offshore_all(i) = mean(data_offshore);
    data_coastal_all(i) = mean(data_coastal);
    SSTdiff(i) = mean(data_offshore - data_coastal);
end

SSTdiff(SSTdiff == 0) = [];
day_all = 182:243;

figure; hold on; grid on
plot(day_all+1,movmean(SSTdiff,period_movmean, 'Endpoints', 'fill'), 'linewidth', linewidth_movmean);
plot(day_all+1,SSTdiff, 'linewidth', 1, 'Color', color_daily);
xticks([day_all(1)+1 day_all(32)+1 day_all(end)+1])
datetick('x', 'mmdd', 'keepticks')
xticklabels({'1 July', '1 August', '31 August'});
ylim([0 5])
ylabel('^oC')
title('SST diff. (offshore - coastal)')
set(gca, 'FontSize', fs)
box on; set(gca, 'LineWidth', 2)

set(gcf, 'Position', [14 694 1078 260])

%saveas(gcf, 'SSTdiff_2013daily.png')
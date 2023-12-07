%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ECMWF monthly wind field on the map
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

average = 1;

filepath = 'D:\Data\Atmosphere\ECMWF_interim\monthly\mat\';
casename = 'YECS_large';

year_mean = 1980:2015;
month_mean = 1:2;

year_figure = 2013;
month_figure = 1:2;

t2m_avg = zeros;

for yi = 1:length(year_mean)
    year_target = year_mean(yi); yts = num2str(year_target);
    
    filename = ['t2m_', yts, '_monthly.mat'];
    file = [filepath, filename];
    
    t2m = load(file);
    
    for mi = 1:length(month_mean)
        month_target = month_mean(mi); mts = num2char(month_target,2);
        
        t2m_avg = t2m_avg + eval(['t2m.t2m_', yts, mts, ';']);
        
    end
end
t2m_avg = t2m_avg/length(year_mean);
t2m_avg = t2m_avg/length(month_mean);
t2m_avg_degC = t2m_avg - 273.15;

lon = t2m.longitude; lat = t2m.latitude;

% Plot t2m field

t2m_target = zeros;
for yii = 1:length(year_figure)
    for mii = 1:length(month_figure)
        
        yts = num2str(year_figure(yii));
        mts = num2char(month_figure(mii), 2);
        
        filename = ['t2m_', yts, '_monthly.mat'];
        file = [filepath, filename];
        
        t2m = load(file);
        
        month_target = month_mean(mi); mts = num2char(month_target,2);
        
        t2m_target = t2m_target + eval(['t2m.t2m_', yts, mts, ';']);
        
    end
end
t2m_target = t2m_target/length(month_mean);
t2m_target_degC = t2m_target - 273.15;

% Calculate wind speed in the plot area
[lon_lim, lat_lim] = domain_J('airT_YSBCW');
lat_ind = find(lat_lim(1)-.5 < lat & lat < lat_lim(2)+.5);
lon_ind = find(lon_lim(1)-.5 < lon & lon < lon_lim(2));


lon_area = lon(lon_ind);
lat_area = lat(lat_ind);

[xx, yy] = meshgrid(lon_area, lat_area);

figure
map_J(casename)

if average
    t2m_figure = t2m_target_degC - t2m_avg_degC;
end


t2m_area = t2m_figure(lat_ind, lon_ind);

m_pcolor(xx,yy,t2m_area); shading interp
colormap('redblue');
caxis([-2 2])

% Box
[line_lon, line_lat] = domain_J('airT_YSBCW');
plot_line_map([line_lon(1)-0.1 line_lon(2)-0.15], [line_lat(1)-0.1 line_lat(2)+0.1], [0.4706 0.6706 0.1882], '-')

c = colorbar;
c.Label.String = 'Air temperature (deg C)';
c.FontSize = 15;
c.Label.FontSize = 15;

fc = [.95 .95 .95 ];
m_gshhs_i('patch',fc )

%        l = legend([h_mean, h_target], 'Mean (1980-2015)', [yts], 'Location', 'SouthEast');

%title(['ECMWF monthly wind ', yts, mts], 'fontsize', 15)

saveas(gcf, '2013_winter_airT_map.png')

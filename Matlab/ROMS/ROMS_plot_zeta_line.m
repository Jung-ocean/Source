clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
year_all = [9999, 2013];
month_all = 7:8;

var_str = 'zeta';
fig_str = '205';

switch var_str
    case 'zeta'
        y_label = 'zeta (m)';
        ylimit = [0 0.6];
    case 'sla'
        y_label = 'Sea level anomaly (m)';
        ylimit = [-0.1 0.3];
end

casename = 'EYECS_20190904';
g = grd(casename);
lon = g.lon_rho;
lat = g.lat_rho;

if strcmp(fig_str, '400')
    domaxis = [34.0767 34.6 128.5 128.0833 -120 0]; % KODC 400 line
elseif strcmp(fig_str, '204')
    domaxis = [33.5967 34.3 127.0533 127.533 -120 0]; % KODC 204 line
elseif strcmp(fig_str, '205')
    domaxis = [33.6217 34.4167 128.1533 127.6667 -120 0]; % KODC 205 line
elseif strcmp(fig_str, '206')
    domaxis = [34.3733 34.6333 128.8283 128.4167 -120 0]; % KODC 206 line
end

for mi = 1:length(month_all)
    month = month_all(mi); mstr = num2char(month,2);
    
    for yi = 1:length(year_all)
        subplot(1,2,yi); hold on; grid on;
        year = year_all(yi); ystr = num2str(year);
        if year == 9999; ystr = 'avg'; end
        
        filepath = ['G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\', ystr, '\'];
        filename = ['monthly_', ystr, mstr, '.nc'];
        file = [filepath, filename];
        
        switch var_str
            case 'zeta'
                var = get_hslice_J(file,g,'zeta',0,'r');
            case 'sla'
                mdtfile = 'G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\avg\yearly.nc';
                mnc = netcdf(mdtfile);
                mdt = mnc{'zeta'}(:);
                close(mnc)
                zeta = get_hslice_J(file,g,'zeta',0,'r');
                
                var = zeta - mdt;
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
            data(li) = var(x,y);
        end
        
        plot(lat_line, data, '-o', 'linewidth', 2)
        data_all(yi,mi,:) = data;
        ylim(ylimit)
        
        xlabel(x_label)
        ylabel(y_label)
        
        set(gca, 'FontSize', 15)
        h = legend('mean(2006-2015)', '2013');
        h.FontSize = 15;
        
    end
end

set(gcf, 'Position', [289 242 1392 565])
saveas(gcf, [var_str,'_', fig_str, '.png'])


figure; hold on; grid on
Aug_July_mean = squeeze(data_all(1,2,:) - data_all(1,1,:));
Aug_July_2013 = squeeze(data_all(2,2,:) - data_all(2,1,:));
plot(lat_line, Aug_July_mean, '-o', 'linewidth', 2)
plot(lat_line, Aug_July_2013, '-o', 'linewidth', 2)
ylim([0. 0.2])
xlabel(x_label)
ylabel(y_label)
        
set(gca, 'FontSize', 15)
h = legend('mean(2006-2015)', '2013');
h.FontSize = 15;
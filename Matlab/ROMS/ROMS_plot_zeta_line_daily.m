clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yyyy = 2019;

%filenumber = [156 174];
filenumber = [234 245];

refdatenum = datenum(yyyy,1,1);
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');
titlestr = datestr(refdatenum + filenumber -1, 'dd-mmm-yyyy');

var_str = 'zeta';
fig_str = '205';

switch var_str
    case 'zeta'
        y_label = 'zeta (cm)';
        ylimit = [5 30];
    case 'sla'
        y_label = 'Sea level anomaly (m)';
        ylimit = [-0.1 0.3];
end

casename = 'EYECS_20220110';
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

for fi = 1:length(filenumber)
    fns = num2char(filenumber(fi), 4);
    savename = filedate(fi,:);
    filename = ['avg_', fns, '.nc'];
    
    switch var_str
        case 'zeta'
            var = get_hslice_J(filename,g,'zeta',0,'r');
            var = var*100;
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
    
    figure; hold on; grid on
    p1 = plot(lat_line, data, '-k', 'linewidth', 2);
    plot([34.2936], interp1(lat_line,data, 34.2936), '.r', 'MarkerSize', 35);
    data_all(fi,:) = data;
    if fi == 2
        p2 = plot(lat_line, data_all(1,:), '--', 'linewidth', 2, 'Color', [.5 .5 .5]);
        l = legend([p1, p2], titlestr(2,:), titlestr(1,:));
        l.FontSize = 20;
    end
    
    xlim([33.6173 34.4323])
    ylim(ylimit)
    
    xlabel(x_label)
    ylabel(y_label)
    
    set(gca, 'FontSize', 15)

    title([titlestr(fi,:)], 'fontsize', 25)
    
    set(gcf, 'Position', [89   319   560   420])
    set(gca, 'Position', [0.1838    0.2077    0.5895    0.6712])

    saveas(gcf, [var_str,'_', fig_str, '_', filedate(fi,:), '.png'])
end
% set(gcf, 'Position', [289 242 1392 565])


% 
% figure; hold on; grid on
% Aug_July_mean = squeeze(data_all(1,2,:) - data_all(1,1,:));
% Aug_July_2013 = squeeze(data_all(2,2,:) - data_all(2,1,:));
% plot(lat_line, Aug_July_mean, '-o', 'linewidth', 2)
% plot(lat_line, Aug_July_2013, '-o', 'linewidth', 2)
% ylim([0. 0.2])
% xlabel(x_label)
% ylabel(y_label)
% 
% set(gca, 'FontSize', 15)
% h = legend('mean(2006-2015)', '2013');
% h.FontSize = 15;
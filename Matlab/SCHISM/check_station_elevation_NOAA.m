%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check SCHISM elevation location at the NOAA tidal stations
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2018; ystr = num2str(yyyy);
mm = 7; mstr = num2str(mm,'%02i');

% SCHISM
rundays = 30;
Mobj.time = (datetime(yyyy,mm,1,1,0,0):hours(1):datetime(yyyy,mm,31,0,0,0))';
Mobj.rundays = days(Mobj.time(end)-Mobj.time(1));
Mobj.dt = 150;
Mobj.coord = 'geographic';

hgrid_file = '../hgrid.gr3';
%vgrid_file = '/data/jungjih/Models/SCHISM/test_schism/vgrid.in';
Mobj = read_schism_hgrid(Mobj, hgrid_file);
%Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

stations.name = {'Adak Island', 'Unalakleet', 'Atka', ...
    'Unalaska', 'Nikolski', 'King Cove', ...
    'Village Cove, St Paul Island', 'Sand Point', ...
    'Nome, Norton Sound'};

stations.id = {'9461380', '9468333', '9461710', ...
    '9462620', '9462450', '9459881', ...
    '9464212', '9459450', ...
    '9468756'};

stations.indices = [499501, 489972, 500090, ...
    529254, 531990, 495277, ...
    803, 827040, ...
    489003]+1; % +1 because these indices are from python

stations.lon = [183.36242676, 199.21200562, 185.82749939, ...
    193.45968628, 191.12869263, 197.67388916, ...
    189.71479797, 199.4956665, ...
    194.56036377];

stations.lat = [51.86064148, 63.875, 52.23194122, ...
    53.87918854, 52.94060898, 55.05989075, ...
    57.12530136, 55.33171844, ...
    64.49461365];

figure; hold on;
set(gcf, 'Position', [1 1 1200 900])
tiledlayout(3,3);

for si = 1:length(stations.name)

    nexttile

    disp_schism_hgrid(Mobj, [1 1])
    caxis([-10 0])

    lon = stations.lon(si);
    lat = stations.lat(si);
    xlim([lon-0.03 lon+0.03])
    ylim([lat-0.03 lat+0.03])
    p1 = plot(lon, lat, '.k', 'MarkerSize', 15);
    p2 = plot(Mobj.lon(stations.indices(si)), Mobj.lat(stations.indices(si)), 'xk', 'MarkerSize', 12, 'LineWidth', 4);
    
    schism_depth = Mobj.depth(stations.indices(si));

    l = legend([p1, p2], 'COOPS', ['SCHISM (' num2str(schism_depth, '%.3f'), ' m)']);
    l.Location = 'NorthWest';

    title([stations.id{si}, ' (', stations.name{si}, ')'])
end

print('check_station' ,'-dpng')
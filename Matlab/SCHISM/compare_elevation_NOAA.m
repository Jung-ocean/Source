%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare SCHISM elevation with NOAA tide predictions
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% NOAA tide predictions
filepath = '/data/jungjih/Observations/NOAA_tide_predictions/';
station = 'CLARKS POINT, NUSHAGAK BAY';
switch station
    case 'CLARKS POINT, NUSHAGAK BAY'
        stationid = 9465261;
        lat = 58 + 50.9/60;
        lon = 158 + 33.1/60;
        lon = abs(lon - 360);
        savename = 'Clarks_Point_Nushagak_Bay';
end
file = [filepath, num2str(stationid), '.txt'];
data_all = importdata(file);
yyyymmdd = data_all.textdata(14:end,1);
HH = data_all.textdata(14:end,3);
datenum_NOAA = datenum([cell2mat(yyyymmdd), cell2mat(HH)], 'yyyy/mm/ddHH:MM');
elevation_NOAA = data_all.data;

% SCHISM
Mobj.time = (datetime(2018,6,1,6,0,0):hours(1):datetime(2018,6,3,5,0,0))';
Mobj.rundays = days(Mobj.time(end)-Mobj.time(1));
Mobj.dt = 150;
Mobj.coord = 'geographic';

hgrid_file = '/data/jungjih/Models/SCHISM/test_schism/hgrid.gr3';
vgrid_file = '/data/jungjih/Models/SCHISM/test_schism/vgrid.in';

Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

figure('Color', 'w');
tiledlayout(2,1);
nexttile(1); hold on
disp_schism_hgrid(Mobj, [1 0], 'EdgeColor', 'none')
set(gcf, 'Position', [1 300 900 900])
colormap(parula(25))

wgs84 = wgs84Ellipsoid("km");
dist = distance(Mobj.lat, Mobj.lon, lat, lon, wgs84);
index = find(dist == min(dist));

plot(lon, lat, '.k', 'MarkerSize', 10);
plot(Mobj.lon(index), Mobj.lat(index), 'xr', 'MarkerSize', 10);

ei = 1;
for oi = 1:2
    oistr = num2str(oi);
    file_output = ['outputs/out2d_', oistr, '.nc'];
    for ti = 1:24
        elevation = ncread(file_output, 'elevation', [1 ti], [Inf 1]);
        elevation_SCHISM(ei) = elevation(index);
        ei = ei+1;
    end
end

nexttile(2); hold on; grid on
plot(datenum_NOAA, elevation_NOAA, '-k');
plot(datenum(Mobj.time), elevation_SCHISM, '-r');

xlim([datenum(2018,6,1) datenum(2018,6,4)]);
datetick('x', 'mmm-dd HH:MM', 'keepticks', 'keeplimits');
ylabel('m');

l = legend('NOAA tide predictions', 'SCHISM');

title(station)

print(['compare_elevation_', savename], '-dpng')
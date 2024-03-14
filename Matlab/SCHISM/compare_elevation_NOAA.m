%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare SCHISM elevation with NOAA tide predictions
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

% NOAA tide predictions
filepath = '/data/jungjih/Observations/NOAA_tide_predictions/';
station_all = { ...
    'CLARKS POINT, NUSHAGAK BAY', ...
    'Nome, Norton Sound', ...
    'Unalakleet', ...
    'Village Cove, St Paul Island', ...
    'Atka', ...
    'Unalaska'};
station_colors = {'r', 'g','b','m','0.4941 0.1843 0.5569', '0.9294 0.6941 0.1255'};

elevation_NOAA = zeros(length(station_all), 24*eomday(yyyy,mm));
elevation_SCHISM = zeros(length(station_all), rundays*24);
for si = 1:length(station_all)
    station = station_all{si};

switch station
    case 'CLARKS POINT, NUSHAGAK BAY'
        filetype = 1;
        stationid = 9465261;
        lat = 58 + 50.9/60;
        lon = 158 + 33.1/60;
        lon = abs(lon - 360);
        savename = 'Clarks_Point_Nushagak_Bay';
    case 'Nome, Norton Sound'
        filetype = 0;
        stationid = 9468756;
        lat = 64 + 29.7/60;
        lon = 165 + 26.4/60;
        lon = abs(lon - 360);
        savename = 'Nome_Norton_Sound';
    case 'Unalakleet'
        filetype = 0;
        stationid = 9468333;
        lat = 63 + 52.3/60;
        lon = 160 + 47.1/60;
        lon = abs(lon - 360);
        savename = 'Unalakleet';
    case 'Village Cove, St Paul Island'
        filetype = 0;
        stationid = 9464212;
        lat = 57 + 7.5/60;
        lon = 170 + 17.1/60;
        lon = abs(lon - 360);
        savename = 'Village_Cove_St_Paul_Island';
    case 'Atka'
        filetype = 0;
        stationid = 9461710;
        lat = 52 + 13.9/60;
        lon = 174 + 10.4/60;
        lon = abs(lon - 360);
        savename = 'Atka';
    case 'Unalaska'
        filetype = 0;
        stationid = 9462620;
        lat = 53 + 52.8/60;
        lon = 166 + 32.4/60;
        lon = abs(lon - 360);
        savename = 'Unalaska';
end

if filetype == 1
    file = [filepath, num2str(stationid), '_', ystr, mstr, '.txt'];
    data_all = importdata(file);
    yyyymmdd = data_all.textdata(14:end,1);
    HH = data_all.textdata(14:end,3);
    datenum_NOAA = datenum([cell2mat(yyyymmdd), cell2mat(HH)], 'yyyy/mm/ddHH:MM');
    elevation_NOAA(si,:) = data_all.data;
else
    file = [filepath, 'CO-OPS_', num2str(stationid), '_met_', ystr, mstr, '.csv'];
    data_all = readtable(file);
    yyyymmdd = table2cell(data_all(:,1));
    HH = table2cell(data_all(:,2));
    datenum_NOAA = datenum([cell2mat(yyyymmdd), cell2mat(HH)], 'yyyy/mm/ddHH:MM');
    elevation_NOAA(si,:) = table2array(data_all(:,5));
end

figure(1); hold on;
set(gcf, 'Position', [1 300 1000 500])
if si == 1
    disp_schism_hgrid(Mobj, [1 0], 'EdgeColor', 'none')
    caxis([-200 0])
    colormap(parula)
end
wgs84 = wgs84Ellipsoid("km");
dist = distance(Mobj.lat, Mobj.lon, lat, lon, wgs84);
index = find(dist == min(dist));

plot(lon, lat, '.k', 'MarkerSize', 30);
plot(Mobj.lon(index), Mobj.lat(index), 'x', 'MarkerSize', 10, 'LineWidth', 4, 'Color', station_colors{si});

timenum_all = [];
ei = 1;
for oi = 1:rundays
    oistr = num2str(oi);
    file_output = ['outputs/out2d_', oistr, '.nc'];
    timenum = ncread(file_output, 'time')/60/60/24 + datenum(yyyy,mm,1,0,0,0);
    for ti = 1:24
        elevation = ncread(file_output, 'elevation', [1 ti], [Inf 1]);
        elevation_SCHISM(si,ei) = elevation(index);
        ei = ei+1;
    end
    timenum_all = [timenum_all; timenum];
end

end
print('map_elevation_station', '-dpng')

figure; hold on;
set(gcf, 'Position', [1 300 1000 900])
tiledlayout(length(station_all), 1);
for si = 1:length(station_all)
    nexttile(si); hold on; grid on

    p1 = plot(datenum_NOAA, elevation_NOAA(si,:), '-k', 'LineWidth', 2);
    plot(timenum_all, elevation_SCHISM(si,:), '-', 'Color', station_colors{si},'LineWidth', 2);

    xlim([datenum(yyyy,mm,1) datenum(yyyy,mm,eomday(yyyy,mm))]);
    datetick('x', 'mmm-dd HH:MM', 'keepticks', 'keeplimits');
    ylabel('m');

    if si == 1
        title([station_all{si}, ' (NOAA predicted)'])
    else
        title([station_all{si}, ' (NOAA observed)'])
    end
end

print('compare_elevation', '-dpng')
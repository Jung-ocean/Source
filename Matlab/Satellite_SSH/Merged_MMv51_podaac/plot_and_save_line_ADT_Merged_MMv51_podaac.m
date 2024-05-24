%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ADT along the specific line using the Merged_MMv5.1_podaac data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% Line numbers
direction = 'a';
if strcmp(direction, 'p')
    lines = 1:16; % pline
else
    lines = 1:29; % aline
end

isfilter = 0;
filter_window = 8; % 1 ~ 5.75 km

% User defined variables
filepath = '/data/sdurski/Observations/SSH/Merged_MMv5.1_podaac/';
filenum_all = 949:1087;
lon_range = [-205.9832 -156.8640]; lat_range = [49.1090 66.3040]; % Bering Sea

% DTU15 data
DTU15 = load('/data/jungjih/Observations/Satellite_SSH/DTU15/DTU15_1min_Bering_Sea.mat');
lon_DTU15 = DTU15.lon_DTU15_Bering_Sea;
lat_DTU15 = DTU15.lat_DTU15_Bering_Sea;
mss_DTU15 = DTU15.mss_DTU15_Bering_Sea;
mdt_DTU15 = DTU15.mdt_DTU15_Bering_Sea;
geoid_DTU15 = DTU15.geoid_DTU15_Bering_Sea;

% Load grid information
g = grd('BSf');

h1 = figure; hold on;
set(gcf, 'Position', [1 1 1800 500])
t = tiledlayout(1,2);

for li = 1:length(lines)

    lstr = num2str(li, '%02i');
    [lon_target, lat_target] = indices_lines_Bering_Sea_slope(direction, li);
    
    timenum_all = [];
    ADT_all = [];
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
    file_target = dir([filepath, '*', fstr, '*.nc']);
    filename = file_target.name;
    file = [filepath, filename];

    time = ncread(file, 'time');

    lat = ncread(file, 'lat');
    lon = ncread(file, 'lon') - 360;

    index_lon = find(lon > lon_range(1) -1 & lon < lon_range(2) + 1);
    index_lat = find(lat > lat_range(1) -1 & lat < lat_range(2) + 1);
    [val,pos] = intersect(index_lon, index_lat);
    lat = lat(val);
    lon = lon(val);
    time = time(val)/60/60/24 + datenum(1992,1,1);
    timevec = datevec(time);

    index_lines = find(ismember(lon, lon_target) == 1 & ismember(lat, lat_target) == 1);

    %mssh = ncread(file, 'mssh').*1e-3; % units = mm to m
    %mssh = mssh(val);
    %geoid = geoidheight(lat,lon); % units = m, EGM96 Geopotential Model
    %mdt = mssh - geoid;
    
%   mdt = griddata(lon_DTU15, lat_DTU15, mdt_DTU15, lon, lat);
    load(['mdt_', num2str(length(lon)), '.mat']);
    
    ssha = ncread(file, 'ssha').*1e-3; % units = mm to m
    ssha = ssha(val);
    nanind = find(isnan(ssha) == 1);
    
    if isfilter == 1
        ssha = smoothdata(ssha, 'gaussian', filter_window);
        ssha(nanind) = NaN;
    end
    adt = mdt + ssha;
    adt_line = adt(index_lines);
    
    time_line = time(index_lines);
    lat_line = lat(index_lines);
    lon_line = lon(index_lines);
    
    timenum_all = [timenum_all; time_line(1)];

    if fi == 1
        nexttile(1)
        if li == 1
            plot_map('Bering', 'mercator', 'l');
            [C,h] = contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'Color', [.7 .7 .7]);
%             cl = clabelm(C,h); set(cl, 'BackgroundColor', 'none');
            p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
        else
            delete(p)
            p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
        end
    end

    ADT_all = [ADT_all; adt_line'];
end % fi

lon_plot = lon_line+360;

nexttile(2); cla; hold on; grid on
%pcolor(lon_mid, timenum_all, geostrophic_all*100); shading interp
pcolor(lon_plot, timenum_all, ADT_all*100); shading interp
ax = gca;
colormap(ax, 'parula')

%xlim([lon_plot(1)-0.1 lon_plot(end)+0.1])
xlim([154 203])
ylim([timenum_all(1)-10 timenum_all(end)+10])
datetick('y', 'mmm dd, yyyy', 'keeplimits')

caxis([20 60])
c = colorbar;
c.Title.String = 'cm';

xlabel('Longitude')

title([direction, 'line ', num2str(li, '%02i')])

t.TileSpacing = 'compact';
t.Padding = 'compact';

pause(1)
saveas(gcf, [direction, 'line_', lstr, '_ADT_Merged_MMv5.1_podaac.png']);

% Make gif
gifname = [direction, 'line_ADT_Merged_MMv5.1_podaac.gif'];

frame = getframe(h1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
if li == 1
    imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
else
    imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
end

save(['ADT_', direction, 'line_', lstr, '.mat'], 'lon_line', 'lat_line', 'timenum_all', 'ADT_all')

end % li
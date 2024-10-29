%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ADT along specific line using the Merged_MMv5.1_podaac data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

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
mask = g.mask_rho./g.mask_rho;

% Line indices perpendiculart to the Bering Sea slope from the north
indices_pline_Bering_Sea_slope = {9440:9498;
    13330:13685;
    3680:4145;
    7810:8255;
    11820:12270;
    2200:2630;
    6310:6680;
    10360:10690;
    770:1070;
    4910:5190;
    8930:9200;
    12960:13210;
    3410:3645};

%

h1 = figure; hold on;
set(gcf, 'Position', [1 1 1800 500])
t = tiledlayout(1,2);

for li = 1:length(indices_pline_Bering_Sea_slope)
    index_pline = indices_pline_Bering_Sea_slope{li};
    
    timevec_line = [];
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

    %mssh = ncread(file, 'mssh').*1e-3; % units = mm to m
    %mssh = mssh(val);
    %geoid = geoidheight(lat,lon); % units = m, EGM96 Geopotential Model
    %mdt = mssh - geoid;
    if li == 1 && fi == 1
        mdt = griddata(lon_DTU15, lat_DTU15, mdt_DTU15, lon, lat);
    end
    if length(mdt) ~= length(lon)
        mdt = griddata(lon_DTU15, lat_DTU15, mdt_DTU15, lon, lat);
    end
    ssha = ncread(file, 'ssha').*1e-3; % units = mm to m
    ssha = ssha(val);
    adt = mdt + ssha;
    
    timevec_line = [timevec_line; timevec(index_pline,:)];
    lat_line = lat(index_pline);
    lon_line = lon(index_pline);
    adt_line = adt(index_pline);

    if fi == 1
        nexttile(1)
        if li == 1
            plot_map('Bering', 'mercator', 'l');
            [C,h] = contourm(g.lat_rho, g.lon_rho, g.h.*mask, [200 200], 'Color', [.7 .7 .7]);
            cl = clabelm(C,h); set(cl, 'BackgroundColor', 'none');
            p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
        else
            delete(p)
            p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
        end
        nexttile(2); cla; hold on; grid on
    end

    plot(lon_line, adt_line, '-');
    ylim([-0.5 1])
    ylabel('ADT (m)')

end
    % Make gif
    gifname = ['Line_all_ADT_Merged_MMv5.1_podaac.gif'];

    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if li == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end
end
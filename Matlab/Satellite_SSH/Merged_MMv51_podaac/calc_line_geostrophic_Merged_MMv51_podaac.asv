%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate geostrophic currents along the specific line 
% using the Merged_MMv5.1_podaac data
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
    
    timenum_all = [];
    geostrophic_all = [];
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
    adt_line = adt(index_pline);
    
    timenum_all = [timenum_all; time(1)];
    lat_line = lat(index_pline);
    lon_line = lon(index_pline);
    
    lat_mid = (lat_line(1:end-1)+lat_line(2:end))./2;
    lon_mid = (lon_line(1:end-1)+lon_line(2:end))./2;

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
    end
    
    wgs84 = wgs84Ellipsoid("m");
    dx = distance(lat_line(1:end-1),lon_line(1:end-1),lat_line(2:end),lon_line(2:end),wgs84);
    
    % Spatial low-pass filter
%     fs = 1./mean(dx);
%     cut_off_wavelength = 80000; % m
%     extra_index = ceil(cut_off_wavelength./mean(dx));
% 
%     adt_line_extra = [adt_line(1:extra_index); adt_line; adt_line(end-extra_index+1:end)];
%     nanind = find(isnan(adt_line_extra) == 1);
%     adt_line_fill = fillmissing(adt_line_extra, 'linear');
%     if sum(isnan(adt_line_fill)) ~= length(adt_line_fill)
%         adt_line_filter_extra = lowpass(adt_line_fill,1./cut_off_wavelength,fs);
%         adt_line_filter_extra(nanind) = NaN;
% 
%         adt_line_filter = adt_line_filter_extra;
%         adt_line_filter(1:extra_index) = []; adt_line_filter(end-extra_index+1:end) = [];
%         dadt = diff(adt_line_filter);
        gconst = 9.8; % m/s^2
%         f = 2*(7.2921e-5)*sind(lat_mid); % /s
%         geostrophic = (gconst./f).*(dadt./dx);
%     else
%         geostrophic = nan(size(lat_mid));
%     end

    % Subsample
    interval = 4;
    adt_line_sub = adt_line(1:interval:end);
    lat_line_sub = lat_line(1:interval:end);
    lon_line_sub = lon_line(1:interval:end);

    lat_mid_sub = (lat_line_sub(1:end-1)+lat_line_sub(2:end))./2;
    lon_mid_sub = (lon_line_sub(1:end-1)+lon_line_sub(2:end))./2;
    dx_sub = distance(lat_line_sub(1:end-1),lon_line_sub(1:end-1),lat_line_sub(2:end),lon_line_sub(2:end),wgs84);

    f_sub = 2*(7.2921e-5)*sind(lat_mid_sub); % /s

    dadt_sub = diff(adt_line_sub);
    geostrophic = (gconst./f_sub).*(dadt_sub./dx_sub);
    
    geostrophic_all = [geostrophic_all; geostrophic'];
end % fi

nexttile(2); cla; hold on; grid on
%pcolor(lon_mid, timenum_all, geostrophic_all*100); shading interp
pcolor(lon_mid_sub, timenum_all, geostrophic_all*100); shading interp
ax = gca;
colormap(ax, 'redblue')

xlim([lon_mid(1)-0.1 lon_mid(end)+0.1])
ylim([timenum_all(1)-10 timenum_all(end)+10])
datetick('y', 'mmm dd, yyyy', 'keeplimits')

caxis([-70 70])
c = colorbar;
c.Title.String = 'cm/s';

% Make gif
gifname = ['Line_geostrophic_Merged_MMv5.1_podaac.gif'];

frame = getframe(h1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
if li == 1
    imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
else
    imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
end

end % li
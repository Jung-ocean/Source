%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SSS through area-averaged to Argo and Satellite monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy_all = 2020:2020;
mm_all = 1:5;
layer = 45;
num_sat = 3;

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

ind_plotpoly = 1;

if exist('polygon_SSS.mat')
    load polygon_SSS.mat
else
figure; hold on; grid on;
set(gcf, 'Position', [1 200, 800 500])
load interp_SSS_Argo_SMAP_winter.mat
pcolor(g.lon_rho, g.lat_rho, vari_sat_interp); shading interp
pcolor(g.lon_rho, g.lat_rho, vari_Argo_interp); shading interp
contour(g.lon_rho, g.lat_rho, g.h, [50 200 500], 'k');
caxis([31.5 33.5])
p = drawpolygon;
polygon(:,1) = p.Position(:,1);
polygon(:,2) = p.Position(:,2);
polygon(end+1,:) = polygon(1,:);
end
% lon_lim = [-193 -188];
% lat_lim = [57.5 59.5];
% lon_lim = [-193 -187];
% lat_lim = [57.3 59.3];
% polygon = [;
%     lon_lim(1)   lat_lim(1)
%     lon_lim(2)   lat_lim(1)
%     lon_lim(2)   lat_lim(2)
%     lon_lim(1)   lat_lim(2)
%     lon_lim(1)   lat_lim(1)
%     ];

[in, on] = inpolygon(g.lon_rho, g.lat_rho, polygon(:,1), polygon(:,2));
mask_target = in./in;
area_target = area.*mask_target;
close all

if ind_plotpoly == 1
    figure; hold on; grid on;
    set(gcf, 'Position', [1 200, 800 500])
    plot_map('Bering', 'mercator', 'l')

    contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');
    plotm(polygon(:,2), polygon(:,1), '--r', 'LineWidth', 2);

    print('map_SSS_area_avg', '-dpng')
end

switch vari_str
    case 'salt'
        ylimit = [32 35.2];
        unit = 'g/kg';
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/monthly/'];

timenum_all = NaN(length(yyyy_all)*12,1);
vari_control_all = NaN(length(yyyy_all)*12,1);
vari_sat_all = NaN(num_sat, length(yyyy_all)*12);
vari_Argo_all = NaN(length(yyyy_all)*12,1);
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Satellite SSS
    % RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/monthly/', ystr, '/'];
    % OISSS L4 v2.0 (https://podaac.jpl.nasa.gov/dataset/OISSS_L4_multimission_7day_v2)
    filepath_OISSS = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/monthly/'];
    % CEC SMOS v9.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/monthly/'];
    
    filepaths_sat = {filepath_RSS_70, filepath_OISSS, filepath_CEC, };

    lons_sat = {'lon', 'longitude', 'lon'};
    lons_360ind = [360, 180, 180];
    lats_sat = {'lat', 'latitude', 'lat'};
    varis_sat = {'sss_smap', 'sss', 'SSS'};
    titles_sat = {'RSS SMAP L3 SSS v5.3 (70 km)', 'ESR OISSS L4 v2.0', 'CEC SMOS L3 SSS v9.0'};

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
        filename_control = dir(filepattern_control);
        if ~isempty(filename_control)
            file_control = [filepath_control, filename_control.name];
            vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
            vari_control_all(12*(yi-1) + mi) = sum(vari_control(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');
        else
            vari_control = NaN;
            vari_control_all(12*(yi-1) + mi) = NaN;
        end

        timenum = datenum(yyyy,mm,15);
        time_title = datestr(timenum, 'mmm, yyyy');
        timenum_all(12*(yi-1) + mi) = timenum;

        % Argo
        filepath_Argo = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];
        filepattern_Argo = fullfile(filepath_Argo, (['*', ystr, '_', mstr, '*.mat']));
        filename_Argo = dir(filepattern_Argo);

        file_Argo = [filepath_Argo, filename_Argo.name];
        Argo = load(file_Argo);

        lon_Argo = Argo.lon'-360;
        lat_Argo = Argo.lat';
        vari_Argo = Argo.salt(:,:,1)';
        
        vari_Argo_interp = interp2(lon_Argo, lat_Argo, vari_Argo, lon, lat);
        mask_Argo = ~isnan(vari_Argo_interp);
        mask_Argo_model = (mask_Argo./mask_Argo).*mask_target;
        area_Argo = area_target.*mask_Argo_model;
        vari_Argo_all(12*(yi-1) + mi) = sum(vari_Argo_interp(:).*area_Argo(:), 'omitnan')./sum(area_Argo(:), 'omitnan');

        % Satellite
        for si = 1:num_sat
            filepath_sat = filepaths_sat{si};
            filepattern1_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
            filepattern2_sat = fullfile(filepath_sat, (['*', ystr, '_', mstr, '*.nc']));

            filename_sat = dir(filepattern1_sat);
            if isempty(filename_sat)
                filename_sat = dir(filepattern2_sat);
            end

            if isempty(filename_sat)
                vari_sat_all(si,12*(yi-1) + mi) = NaN;
                vari_sat_interp = NaN;
            else
                file_sat = [filepath_sat, filename_sat.name];
                lon_sat = double(ncread(file_sat,lons_sat{si}));
                lat_sat = double(ncread(file_sat,lats_sat{si}));
                vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');
                if si == 2 || si == 3
                    index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
                    vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
                end
                lon_sat = lon_sat - lons_360ind(si);

                index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
                index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

                vari_sat_part = vari_sat(index_lat,index_lon);

                [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

                vari_sat_interp = interp2(lon_sat2, lat_sat2, vari_sat_part, lon, lat);
                mask_sat = ~isnan(vari_sat_interp);
                mask_sat_model = (mask_sat./mask_sat).*mask_target;
                area_sat = area_target.*mask_sat_model;
                vari_sat_all(si,12*(yi-1) + mi) = sum(vari_sat_interp(:).*area_sat(:), 'omitnan')./sum(area_sat(:), 'omitnan');
            end
        end
        disp([ystr, mstr, '...'])
    end % mi
end % yi
timevec = datevec(timenum_all);

% Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = figure; hold on; grid on;
% set(gcf, 'Position', [1 1 1800 600])
set(gcf, 'Position', [1 200 1300 500])

T1p1 = plot(timenum_all, vari_control_all, '-ok', 'LineWidth', 2);
for si = 1:2%num_sat
    T1ps(si) = plot(timenum_all, vari_sat_all(si,:), '-o', 'LineWidth', 2);
end
T1pa = plot(timenum_all, vari_Argo_all, '-o', 'LineWidth', 2);

% xticks(timenum_all);
xticks(datenum(yyyy_all, 1, 15));
xlim([timenum_all(1)-1 timenum_all(end)+1])
datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
% ylim(ylimit);
ylabel(unit)
title(['Area averaged SSS (monthly)'])
l = legend([T1p1, T1ps T1pa], ['ROMS', titles_sat(1:2), 'Argo BOA'], 'Interpreter', 'none');
l.Location = 'Northwest';
l.FontSize = 12;

set(gca, 'FontSize', 12)

print('cmp_area_avg_SSS_ROMS_to_Argo_sat_monthly', '-dpng')
asdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = figure; hold on;
set(gcf, 'Position', [1 200 1500 750])
t = tiledlayout(2,2);

tindex = 1:12;

nexttile(1); hold on; grid on;
p(1) = plot(1:12, vari_control_all(tindex), 'LineWidth', 2);
p(2) = plot(1:12, vari_control_all(tindex+12), 'LineWidth', 2);
p(3) = plot(1:12, vari_control_all(tindex+24), 'LineWidth', 2);
p(4) = plot(1:12, vari_control_all(tindex+36), 'LineWidth', 2);
% plot(1:12, vari_control_shelf_mean, 'k');
xticks(1:12);
xlim([0 13])
xlabel('Month')
% ylim([32.4 32.7]);
ylabel(unit)

l = legend(p, num2str(timevec(1:12:end,1)));
l.Location = 'NorthWest';
l.Orientation = 'Horizontal';
l.FontSize = 8;

title('ROMS', 'Interpreter', 'None')

for si = 1:2%num_sat
    nexttile(1+si); hold on; grid on
    plot(1:12, vari_sat_all(si,tindex), 'LineWidth', 2);
    plot(1:12, vari_sat_all(si,tindex+12), 'LineWidth', 2);
    plot(1:12, vari_sat_all(si,tindex+24), 'LineWidth', 2);
    plot(1:12, vari_sat_all(si,tindex+36), 'LineWidth', 2);
%     plot(1:12, vari_sat_shelf_mean(si,:), 'k');
    xticks(1:12);
    xlim([0 13])
    xlabel('Month')
%     ylim([32.4 32.7]);
    ylabel(unit)

    title(titles_sat{si}, 'Interpreter', 'None')
end

nexttile(4); hold on; grid on;
p(1) = plot(1:12, vari_Argo_all(tindex), 'LineWidth', 2);
p(2) = plot(1:12, vari_Argo_all(tindex+12), 'LineWidth', 2);
p(3) = plot(1:12, vari_Argo_all(tindex+24), 'LineWidth', 2);
p(4) = plot(1:12, vari_Argo_all(tindex+36), 'LineWidth', 2);
xticks(1:12);
xlim([0 13])
xlabel('Month')
% ylim([32.5 33.5]);
ylabel(unit)

title('Argo BOA', 'Interpreter', 'None')

t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t, ['Area averaged SSS'])

pause(1)
% 
% savename = ['compare_area_averaged_', vari_str, '_with_Satellite_interannual_shelf'];
% print(savename, '-dpng');
% savefig([savename, '.fig'])
clear; clc

yyyy_all = 1993:2022;
mm_all = 1:12;

filepath = '/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly/';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        filename = ['dt_global_allsat_phy_l4_', ystr, mstr, '.nc'];
        file = [filepath, filename];
        
        lon = ncread(file, 'longitude');
        lat = ncread(file, 'latitude');
        adt = ncread(file, 'adt')';

        index1 = find(lon < 0);
        index2 = find(lon > 0);
        lon = [lon(index2); lon(index1)+360];
        adt = [adt(:,index2) adt(:,index1)];

        wgs84 = wgs84Ellipsoid("m");
        diff_lon = diff(lon);
        diff_lat = diff(lat);
        dx_deg = diff_lon(1); % degree
        dy_deg = diff_lat(1); % degree
        dy = dy_deg*111*1000; % m

        dx = distance(lat,zeros(size(lat)),lat,zeros(size(lat))+dx_deg,wgs84);
        area_1d = dx.*dy;
        area = repmat(area_1d, [1, size(lon,1)]);

        lon_shelf = [185.4112 194.1194 199.2915 190.9528 185.4112];
        lat_shelf = [61.4757 55.1954 57.2418 62.5341 61.4757];

        lon_basin = [176.6503 171.4782 168.3116 165.5144 169.3671 ...
            174.3281 180.3447 188.7890 176.6503];
        lat_basin = [60.6289 58.3003 59.2176 57.0654 54.7367 ...
            53.3255 52.4081 54.3134 60.6289];
        
        lon_Pacific = [164.0924 172.0966 182.4177 161.7755 154.4032 164.0924];
        lat_Pacific = [54.2721 51.8200 50.6990 44.6738 47.1960 54.2721];

        lon_GoA = [196.1089 213.1703 216.9617 199.4791 196.1089];
        lat_GoA = [54.4823 60.2973 59.7368 53.8517 54.4823];

        [lon2, lat2] = meshgrid(lon,lat);

        in = inpolygon(lon2, lat2, lon_shelf, lat_shelf);
        mask_shelf = in./in;
        area_shelf = area.*mask_shelf;
        adt_shelf = adt.*mask_shelf;
        adt_shelf_all(yi,mi) = sum(adt_shelf(:).*area_shelf(:), 'omitnan')./sum(area_shelf(:), 'omitnan');

        in = inpolygon(lon2, lat2, lon_basin, lat_basin);
        mask_basin = in./in;
        area_basin = area.*mask_basin;
        adt_basin = adt.*mask_basin;
        adt_basin_all(yi,mi) = sum(adt_basin(:).*area_basin(:), 'omitnan')./sum(area_basin(:), 'omitnan');

        in = inpolygon(lon2, lat2, lon_Pacific, lat_Pacific);
        mask_Pacific = in./in;
        area_Pacific = area.*mask_Pacific;
        adt_Pacific = adt.*mask_Pacific;
        adt_Pacific_all(yi,mi) = sum(adt_Pacific(:).*area_Pacific(:), 'omitnan')./sum(area_Pacific(:), 'omitnan');

        in = inpolygon(lon2, lat2, lon_GoA, lat_GoA);
        mask_GoA = in./in;
        area_GoA = area.*mask_GoA;
        adt_GoA = adt.*mask_GoA;
        adt_GoA_all(yi,mi) = sum(adt_GoA(:).*area_GoA(:), 'omitnan')./sum(area_GoA(:), 'omitnan');
    end
    disp([ystr, ' / ', num2str(yyyy_all(end)), ' ...'])
end

figure; hold on; grid on
for yi = 1:length(yyyy_all)
    p1 = plot(1:12, adt_shelf_all(yi,:), 'Color', [0 0.4471 0.7412]);
    p2 = plot(1:12, adt_basin_all(yi,:), 'Color', [0.8510 0.3255 0.0980]);
    p3 = plot(1:12, adt_Pacific_all(yi,:), 'Color', [0.4941 0.1843 0.5569]);
    p4 = plot(1:12, adt_GoA_all(yi,:), 'Color', [0.4667 0.6745 0.1882]);
end

index = find(yyyy_all == 2019);
plot(1:12, adt_shelf_all(index,:), 'Color', 'k', 'LineWidth', 2);
plot(1:12, adt_basin_all(index,:), 'Color', 'k', 'LineWidth', 2);

xlim([0 13])
ylim([-0.1 0.9])
xticks([1:12])

xlabel('Month')
ylabel('ADT (m)')

l = legend([p1 ,p2, p3, p4], 'Shelf', 'Basin', 'Pacific', 'Gulf of Alaska');
l.Location = 'NorthWest';
title('Area-averaged monthly mean ADT (1993-2022)')

print('area_averaged_adt_all', '-dpng')

adt_shelf_mean = mean(adt_shelf_all, 1);
adt_shelf_std = std(adt_shelf_all, 1);
adt_basin_mean = mean(adt_basin_all, 1);
adt_basin_std = std(adt_basin_all, 1);
adt_Pacific_mean = mean(adt_Pacific_all, 1);
adt_Pacific_std = std(adt_Pacific_all, 1);
adt_GoA_mean = mean(adt_GoA_all, 1);
adt_GoA_std = std(adt_GoA_all, 1);

figure; hold on; grid on
e1 = errorbar(1:12, adt_shelf_mean, adt_shelf_std, 'Color', [0 0.4471 0.7412]);
e2 = errorbar(1:12, adt_basin_mean, adt_basin_std, 'Color', [0.8510 0.3255 0.0980]);
e3 = errorbar(1:12, adt_Pacific_mean, adt_Pacific_std, 'Color', [0.4941 0.1843 0.5569]);
e4 = errorbar(1:12, adt_GoA_mean, adt_GoA_std, 'Color', [0.4667 0.6745 0.1882]);

xlim([0 13])
ylim([-0.1 0.9])
xticks([1:12])

xlabel('Month')
ylabel('ADT (m)')

l = legend([e1 ,e2, e3, e4], 'Shelf', 'Basin', 'Pacific', 'Gulf of Alaska');
l.Location = 'NorthWest';
title('Area-averaged monthly mean ADT (1993-2022)')

% pcolor
adt_shelf_all_pcolor = adt_shelf_all;
adt_shelf_all_pcolor(:,end+1) = 100;
adt_shelf_all_pcolor(end+1,:) = 100;
adt_basin_all_pcolor = adt_basin_all;
adt_basin_all_pcolor(:,end+1) = 100;
adt_basin_all_pcolor(end+1,:) = 100;
% adt_Pacific_all_pcolor = adt_Pacific_all;
% adt_Pacific_all_pcolor(:,end+1) = 100;
% adt_Pacific_all_pcolor(end+1,:) = 100;

adt_shelf_anomaly_pcolor = adt_shelf_all - adt_shelf_mean;
adt_shelf_anomaly_pcolor(:,end+1) = 100;
adt_shelf_anomaly_pcolor(end+1,:) = 100;
adt_basin_anomaly_pcolor = adt_basin_all - adt_basin_mean;
adt_basin_anomaly_pcolor(:,end+1) = 100;
adt_basin_anomaly_pcolor(end+1,:) = 100;
%
figure; hold on;
pcolor(1:13,[yyyy_all 2023], adt_shelf_all_pcolor)
xlim([1 13])
ylim([1993 2023])
xticks(1.5:12.5);
xticklabels(1:12);
xlabel('Month')
yticks(1993.5:2022.5);
yticklabels(1993:2022);
ylabel('Year')
c = colorbar;
c.Title.String = 'm';
caxis([0.4 0.6])
title('Shelf, monthly mean ADT')
set(gcf, 'Position', [1 1 800 900])

print('month_year_diagram_shelf_adt', '-dpng')
%
figure; hold on;
pcolor(1:13,[yyyy_all 2023], adt_shelf_anomaly_pcolor)
colormap redblue
xlim([1 13])
ylim([1993 2023])
xticks(1.5:12.5);
xticklabels(1:12);
xlabel('Month')
yticks(1993.5:2022.5);
yticklabels(1993:2022);
ylabel('Year')
c = colorbar;
c.Title.String = 'm';
caxis([-0.2 0.2])
title('Shelf, monthly mean ADT anomaly')
set(gcf, 'Position', [1 1 800 900])

print('month_year_diagram_shelf_adt_anomaly', '-dpng')
%
figure; hold on;
pcolor(1:13,[yyyy_all 2023], adt_basin_all_pcolor)
xlim([1 13])
ylim([1993 2023])
xticks(1.5:12.5);
xticklabels(1:12);
xlabel('Month')
yticks(1993.5:2022.5);
yticklabels(1993:2022);
ylabel('Year')
c = colorbar;
c.Title.String = 'm';
caxis([0.15 0.35])
title('Basin, monthly mean ADT')
set(gcf, 'Position', [1 1 800 900])

print('month_year_diagram_basin_adt', '-dpng')
%
figure; hold on;
pcolor(1:13,[yyyy_all 2023], adt_basin_anomaly_pcolor)
colormap redblue
xlim([1 13])
ylim([1993 2023])
xticks(1.5:12.5);
xticklabels(1:12);
xlabel('Month')
yticks(1993.5:2022.5);
yticklabels(1993:2022);
ylabel('Year')
c = colorbar;
c.Title.String = 'm';
caxis([-0.2 0.2])
title('Basin, monthly mean ADT anomaly')
set(gcf, 'Position', [1 1 800 900])

print('month_year_diagram_basin_adt_anomaly', '-dpng')

%
figure; hold on;
pcolor(1:13,[yyyy_all 2023], adt_shelf_all_pcolor - adt_basin_all_pcolor)
colormap redblue
xlim([1 13])
ylim([1993 2023])
xticks(1.5:12.5);
xticklabels(1:12);
xlabel('Month')
yticks(1993.5:2022.5);
yticklabels(1993:2022);
ylabel('Year')
c = colorbar;
c.Title.String = 'm';
caxis([0 0.5])
title('Difference (Shelf-Basin), monthly mean ADT')
set(gcf, 'Position', [1 1 800 900])

print('month_year_diagram_adt_diff', '-dpng')

%
figure; hold on;
pcolor(1:13,[yyyy_all 2023], adt_shelf_anomaly_pcolor - adt_basin_anomaly_pcolor)
colormap redblue
xlim([1 13])
ylim([1993 2023])
xticks(1.5:12.5);
xticklabels(1:12);
xlabel('Month')
yticks(1993.5:2022.5);
yticklabels(1993:2022);
ylabel('Year')
c = colorbar;
c.Title.String = 'm';
caxis([-.2 0.2])
title('Anomaly difference (Shelf-Basin), monthly mean ADT')
set(gcf, 'Position', [1 1 800 900])

print('month_year_diagram_adt_anomaly_diff', '-dpng')
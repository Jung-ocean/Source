clear; clc; close all

yyyy_all = 2004:2025;
timenum_M2 = datenum(yyyy_all,1,1);
NAA = [1.21; 1.03; 0.10; 0.70; 0.42; 1.55; 0.71; 1.89; -0.52; -0.39; -0.85;
    0.06; -1.89; -1.30; -0.26; -0.51; 0.99; -0.23; -1.05; 0.03; -0.10; -1.57];

% SIC
filepath = '/data/jungjih/Project/Beaufort/';
filename = ['SIC_NSIDC_v4.nc'];
file = [filepath, filename];
timenum = ncread(file, 'time') + datenum(2000,1,1);
timevec = datevec(timenum);
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');
SIC = ncread(file, 'SIC');
lon(lon<0) = lon(lon<0) + 360;

index = 78028; % maximum corr
lon_target = lon(index);
lat_target = lat(index);

dist = sqrt((lon - lon_target).^2 + (lat - lat_target).^2);
mindex = find(dist == min(dist(:)));

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
plot(timenum_M2, NAA, '-ok', 'LineWidth', 2)
xticks(timenum_M2)
xlim([timenum_M2(1)-1 timenum_M2(end)+1])
ylim([-3 3])
datetick('x', 'yy', 'keepticks', 'keeplimits')
xlabel('time [year - 2000]')
ylabel('M2 NAA')
set(gca, 'FontSize', 15)

SIC_tmp = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    index = find(timevec(:,1) == yyyy);
    vari = squeeze(mean(SIC(:,:,index),3));
    SIC_tmp(yi) = vari(mindex);
end

% Remove the mean
SIC_demean = SIC_tmp - mean(SIC_tmp, 'omitnan');

% Scale to unit variance
SIC_norm = SIC_demean ./ std(SIC_tmp, 0, 'omitnan');

yyaxis right; hold on;
set(gca, 'YColor', 'b')
set(gcf, 'Position', [1 200 1300 500])
plot(timenum_M2, SIC_norm, '-ob', 'LineWidth', 2)
ylim([-3 3])
ylabel('Normalized SIC')

[r, p] = corrcoef(NAA, SIC_norm);

title(['Time series at the location of maximum r (', num2str(r(1,2), '%.2f'), ')'], 'FontSize', 20)

% Map
fig = gcf;
figPos = get(fig, 'Position');
h = 0.35;
w = h * figPos(4) / figPos(3);
pos = [0.15 0.15 w h];
axInset = axes('Parent', fig, 'Units', 'normalized', 'Position', pos);
plot_arctic_map(axInset);
p = plotm(lat_target, lon_target, '.r', 'MarkerSize', 15);

asdf
print('timeseries_M2_SIC_max_r', '-dpng')
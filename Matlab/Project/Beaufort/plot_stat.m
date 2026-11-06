clear; clc; close all

% M2 NAA
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

SIC_yearly = NaN(size(SIC,1), size(SIC,2), length(yyyy_all));
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    index = find(timevec(:,1) == yyyy);
    SIC_yearly(:,:,yi) = mean(SIC(:,:,index),3);
end
index = find(SIC_yearly < 0.001);
SIC_yearly(index) = NaN;

SIC_mean = mean(SIC_yearly, 3);
SIC_std = std(SIC_yearly, 0, 3);

% Remove the mean
SIC_yearly_demean = SIC_yearly - SIC_mean;
% Scale to unit variance
SIC_yearly_norm = SIC_yearly_demean ./ SIC_std;

corr_map = NaN(size(SIC,1), size(SIC,2));
p_map = NaN(size(SIC,1), size(SIC,2));
for i = 1:size(corr_map,1)
    for j = 1:size(corr_map,2)
        vari_tmp = SIC_yearly_norm(i,j,:);
        [r,p] = corrcoef(NAA, SIC_yearly_norm(i,j,:));
        corr_map(i,j) = r(1,2);
        p_map(i,j) = p(1,2);
    end
end

figure;
t = tiledlayout(2,2);
t.Padding = 'compact';
t.TileSpacing = 'tight';
set(gcf, 'Position', [1 200 900 800])

% Mean
ax1 = nexttile(1); hold on; grid on;
plot_arctic_map
p = pcolorm(lat, lon, SIC_mean);
color = 'jet(10)';
colormap(ax1, color)
caxis([0 100])
uistack(p, 'bottom')
c = colorbar;
c.Title.String = '%';
title('Multi-year mean sea ice concentration')

% Std
ax2 = nexttile(2); hold on; grid on;
plot_arctic_map
p = pcolorm(lat, lon, SIC_std);
color = 'jet(10)';
colormap(ax2, color)
caxis([0 25])
uistack(p, 'bottom')
c = colorbar;
c.Title.String = '%';
title('Standard deviation')

% Correlation
ax3 = nexttile(3); hold on; grid on
plot_arctic_map
p = pcolorm(lat, lon, corr_map);
[color, contour_interval] = get_color('redblue', [-1 1], 0.2);
colormap(ax3, color)
caxis([-1 1])
uistack(p, 'bottom')
c = colorbar;
title('r (Beaufort M2 NAA vs normalized SIC)')

% P-value
ax4 = nexttile(4); hold on; grid on
plot_arctic_map
p = pcolorm(lat, lon, p_map);
colormap(ax4, jet(10))
caxis([0 0.05])
uistack(p, 'bottom')
c = colorbar;
title('P-value')

print('stat', '-dpng')
clear; clc; close all

region = 'Bering';
vari_str = 'msl';

[lon_limit, lat_limit] = load_domain(region);

yyyy_all = 1996:2025;
mm_all = 3:5;

PDO = [];
AO = [];
SLP = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    PDO_tmp = load_PDO(yyyy,mm_all);
    PDO(yi) = mean(PDO_tmp);
    AO_tmp = load_AO(yyyy,mm_all);
    AO(yi) = mean(AO_tmp);
    
    vari_tmp = [];
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        [lon, lat, vari_tmp(:,:,mi)] = load_ERA5_monthly(yyyy, mm, vari_str, lon_limit, lat_limit);
    end
    SLP(:,:,yi) = mean(vari_tmp,3)/100; % Pa to hPa
end

[lat2, lon2] = meshgrid(lat, lon);

% Regression onto PDO
for i = 1:size(SLP,1)
    for j = 1:size(SLP,2)
        y = squeeze(SLP(i,j,:));
        
        mdl = fitlm(PDO, y);
        beta_PDO(i,j) = mdl.Coefficients.Estimate(2); % slope
        pval_PDO(i,j) = mdl.Coefficients.pValue(2); % p-value
    end
end
sig_level = 0.1;  % 90% confidence
index_PDO = find(pval_PDO < sig_level);

% Regression onto AO
for i = 1:size(SLP,1)
    for j = 1:size(SLP,2)
        y = squeeze(SLP(i,j,:));
        
        mdl = fitlm(AO, y);
        beta_AO(i,j) = mdl.Coefficients.Estimate(2); % slope
        pval_AO(i,j) = mdl.Coefficients.pValue(2); % p-value
    end
end
sig_level = 0.1;  % 90% confidence
index_AO = find(pval_AO < sig_level);

figure;
set(gcf, 'Position', [1 200 1800 600])
t = tiledlayout(1,2);
t.Padding = 'compact';
t.TileSpacing = 'tight';

climit = [-3 3];
interval = .3;

nexttile(1);
[color, contour_interval] = get_color('redblue', climit, interval);
plot_map('Bering', 'mercator', 'l')
pcolorm(lat2, lon2, beta_PDO);
caxis(climit);
plotm(lat2(index_PDO), lon2(index_PDO), '.k', 'MarkerSize', 2)
plot_map('Bering', 'mercator', 'l')
% c = colorbar;
% c.Title.String = 'hPa';
plabel('FontSize', 10)
mlabel('FontSize', 10)
title('Regression map of SLP (MAM) onto PDO (MAM)', 'FontSize', 20);

nexttile(2);
plot_map('Bering', 'mercator', 'l')
pcolorm(lat2, lon2, beta_AO);
caxis(climit)
colormap(color);
plotm(lat2(index_AO), lon2(index_AO), '.k', 'MarkerSize', 2)
plot_map('Bering', 'mercator', 'l')
c = colorbar;
c.Title.String = 'hPa';
c.FontSize = 12;
c.Ticks = contour_interval;
plabel('off')
mlabel('FontSize', 10)
title('Regression map of SLP (MAM) onto AO (MAM)', 'FontSize', 20);

print('regression_SLP', '-dpng')
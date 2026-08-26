clear; clc

domain = 'Oregon_1km_large';
g = grd(domain);
filepath = ['/data/jungjih/Project/NOPP_Carbon/', domain, '/Setups/Nudgcoef/'];
% filename = ['nudgcoef_', domain, '.nc'];
filename = 'nudgcoef_Oregon_1km_large_1day_deeper_than_1000m.nc';
file = [filepath, filename];

nudgcoef = ncread(file, 'temp_NudgeCoef', [1 1 g.N], [Inf Inf 1]);

% Plot
figure;
pcolor(g.lon_rho, g.lat_rho, nudgcoef.*g.mask_rho./g.mask_rho); shading flat
title('Nudging coefficient')
colorbar;
set(gcf, 'Position', [1 200 500 800])
asdf
print('nudgcoef', '-dpng')
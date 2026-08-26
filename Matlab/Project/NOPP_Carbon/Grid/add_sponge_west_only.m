clear; clc

roms_matlab = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/roms_matlab';
addpath(genpath(roms_matlab));

filename_org = 'grid_Oregon_1km_large_3.nc';
filename = 'grid_Oregon_1km_large_sponge.nc';
copyfile(filename_org, filename);

factor = 3;
% Nfilter = 25;
Nfilter = 95;
Lplot = 1;
Lwrite = 0;

S = sponge(filename, factor, Nfilter, Lplot, Lwrite);

% Minus 1 to make interior diffusivity/viscosity 0
% factor = factor-1;
% S.diff_factor = S.diff_factor-1;
% S.visc_factor = S.visc_factor-1;

% For viscosity only
% factor_visc = 3 + 1-(8/15);
% Sv = sponge(filename, factor_visc, Nfilter, Lplot, Lwrite);
% S.visc_factor = Sv.visc_factor-(1-(8/15));

% Plot
G = get_roms_grid(filename);

dist = 100;
mask = G.mask_rho;
visc_factor = ones(size(mask));
factor_1d = linspace(factor, 1, dist);
for j = 1:size(visc_factor,2)
    visc_factor(1:dist, j) = factor_1d;
end
diff_factor = visc_factor;

S.visc_factor = visc_factor;
S.diff_factor = diff_factor;

figure;
% contourf(G.lon_rho, G.lat_rho, nanland(S.diff_factor,G));
pcolorjw(G.lon_rho, G.lat_rho, nanland(S.diff_factor,G));
title('Sponge Diffusivity/Viscosity Factor')
colorbar;
set(gcf, 'Position', [1 200 500 800])

% print('sponge', '-dpng')

% Write
add_sponge(filename, S.visc_factor, S.diff_factor)
sponge_info = [datestr(now,1) ' created with ' which(mfilename)       ...
    ': factor = ', num2str(factor)                         ...
    ', Nfilter = ', num2str(Nfilter)];
status = nc_attadd(filename, 'sponge', sponge_info);

rmpath(genpath(roms_matlab));
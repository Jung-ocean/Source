clear; clc

start_date = datetime(2018,7,1);
Mobj.rundays = 153;
Mobj.time = (start_date:hours(1):start_date + Mobj.rundays)';
Mobj.dt = 120;
Mobj.coord = 'geographic';

hgrid_file = './hgrid.gr3';
vgrid_file = '../vgrid.in';

bMobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

% Horizontal grids
figure;
disp_schism_hgrid(Mobj, [1 0])
%axis image
% set(gcf, 'Position', [50 300 1800 900])  
% colormap(gray(25))
set(gcf, 'Position', [1 1 1800 900])  
asdf
% print('grid_info','-dpng');

% Vertical grids
% check the quality of vertical grids
% draw a line on the map and press ENTER
figure('Color', 'w')
disp_schism_hgrid(Mobj, [1 0], 'EdgeAlpha', 0.05, 'LineWidth', 0.5);
sect_info = def_schism_transect(Mobj, -1, 0.01);
 
disp_schism_vgrid(Mobj, sect_info)

% check the invese CFL constraints
figure('Color', 'w')
%set(gcf, 'Position', [1 1 1500 600])  
set(gcf, 'Position', [1 1 1800 900])  

check_schism_metrics(Mobj);

print('grid_check','-dpng')
tt
% display the Max. acceptable resolutions as a function of water depth 
calc_schism_CFL(Mobj)

% check the hydrostatic assumption
check_schism_hydrostatic(Mobj);


% grid_depth_resolution
figure; hold on;
set(gcf, 'Position', [1 1 1800 500])  
subplot(121)
disp_schism_hgrid(Mobj, [1 0], 'EdgeColor', 'None')
caxis([-500 0])
title('Depth')

% resolution
CFL_limit = 0.4;
g = 9.80665;
ua = 0;
h = abs(Mobj.depth);
R = calc_schism_cradius(Mobj);      % use the circumradius
dx = R(:);

subplot(122)
disp_schism_var(Mobj, dx/1000)
caxis([0 3])
title('Actual grid resolutions (km)')

print('grid_depth_resolution', '-dpng')
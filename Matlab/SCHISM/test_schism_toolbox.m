clear; clc

start_date = datetime(2018,7,1);
Mobj.rundays = 153;
Mobj.time = (start_date:hours(1):start_date + Mobj.rundays)';
Mobj.dt = 120;
Mobj.coord = 'geographic';

hgrid_file = './hgrid.gr3';
vgrid_file = './vgrid.in';

Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

% Horizontal grids
figure('Color', 'w')
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

% Plot
figure;
p = disp_schism_var(Mobj, temp_surf, 'EdgeColor', 'none');
figure;
p = disp_schism_var(Mobj, temp_bot, 'EdgeColor', 'none');

% %
% h1 = figure('Color', 'w');
% set(gcf, 'Position', [1 300 900 600])
% for oi = 1:2
%     oistr = num2str(oi);
%     file_output = ['outputs/out2d_', oistr, '.nc'];
%     for ti = 1:24
%         elevation = ncread(file_output, 'elevation', [1 ti], [Inf 1]);
%         
%         if oi == 1 && ti == 1
%             p = disp_schism_var(Mobj, elevation, 'EdgeColor', 'none');
%             caxis([-2 2])
%         else
%             p.FaceVertexCData = elevation;
%         end
% 
%         % Make gif
%         gifname = ['test_schism_elevation.gif'];
% 
%         frame = getframe(h1);
%         im = frame2im(frame);
%         [imind,cm] = rgb2ind(im,256);
%         if oi == 1 && ti == 1
%             imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
%         else
%             imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
%         end
%     end
% end
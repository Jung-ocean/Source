clear; clc

Mobj.dt = 120;
Mobj.coord = 'geographic';
hgrid_file = './hgrid.gr3';
Mobj = read_schism_hgrid(Mobj, hgrid_file);

% Horizontal grids
figure('Color', 'w')
disp_schism_hgrid(Mobj, [1 1])

set(gcf, 'Position', [1 1 1200 600])

hp = drawpolygon;

num = 200;
lon = linspace(hp.Position(1,1),hp.Position(2,1),num);
lat = linspace(hp.Position(1,2),hp.Position(2,2),num);

output = 'transect.bp';

fileID = fopen(output,'w');
fprintf(fileID, '%s\n', output)
fprintf(fileID, '%i\n', length(lon))
for li = 1:length(lon)
    fprintf(fileID,'%i %10.6f %10.6f %10.6f\n',[li, lon(li), lat(li), 1]);
end
fclose(fileID);

% print('transect', '-dpng')
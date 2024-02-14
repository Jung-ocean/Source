function plot_map(casename, projection, resolution)

[lon, lat] = load_domain(casename);

filepath = '/home/grindylow/sdurski/matlab_tools/datasets/gshhs_matlab/';

shapepathE = fullfile(filepath,['gshhs_', resolution, '_East_Bering_Sea']);
shapepathW = fullfile(filepath,['gshhs_', resolution, '_West_Bering_Sea']);
east_bering_sea=shaperead(shapepathE,'UseGeoCoords',true);
west_bering_sea=shaperead(shapepathW,'UseGeoCoords',true);
% projection = mercator, lambert, miller ...
ax1m = axesm(projection, 'MapLatLimit', [lat], 'MapLonLimit', [lon], 'MLabelParallel', 'South');
geoshow(east_bering_sea, 'FaceColor', [0.55 0.55 0.55])
geoshow(west_bering_sea, 'FaceColor', [0.55 0.55 0.55])
setm(gca,'MLabelLocation',10)
setm(gca,'PLabelLocation',5)
tightmap

%setm(gca,'mlabelparallel',50)
mlabel('FontSize', 8);
plabel('FontSize', 8);
gridm('MlineLocation',2.5,'PLineLocation',2.5);

%set(gcf,'position',[30 100 700 800]);
%set(gcf,'PaperSize',[8.5 11],'PaperPosition',[0.25 0.25 6 6]);

end

function [lon, lat] = load_domain(casename)

switch casename
    case 'US_west'
        lon = [-140 -110]; lat = [28 55];
    case 'Bering_Arctic'
        lon = [-185 -155]; lat = [45 85];
    case 'Bering'
        lon = [-205.9832 -156.8640]; lat = [49.1090 66.3040];
    case 'Eastern_Bering'
        lon = [-185 -156.8640]; lat = [49.1090 66.3040];
end

end % function load_domain




function plot_map(casename, projection, resolution)

[lon, lat] = load_domain(casename);

if min(lat) < 49
    filepath = ['/data/jungjih/Coastline/GSHHS_shp/', resolution, '/'];
    shapepath = fullfile(filepath,['GSHHS_', resolution, '_L1']);
    coastline=shaperead(shapepath,'UseGeoCoords',true);
    % projection = mercator, lambert, miller ...
    ax1m = axesm(projection, 'MapLatLimit', [lat], 'MapLonLimit', [lon], 'MLabelParallel', 'South');
    geoshow(coastline, 'FaceColor', [0.55 0.55 0.55])
else
    filepath = '/home/grindylow/sdurski/matlab_tools/datasets/gshhs_matlab/';
    shapepathE = fullfile(filepath,['gshhs_', resolution, '_East_Bering_Sea']);
    shapepathW = fullfile(filepath,['gshhs_', resolution, '_West_Bering_Sea']);
    east_bering_sea=shaperead(shapepathE,'UseGeoCoords',true);
    west_bering_sea=shaperead(shapepathW,'UseGeoCoords',true);
    % projection = mercator, lambert, miller ...
    ax1m = axesm(projection, 'MapLatLimit', [lat], 'MapLonLimit', [lon], 'MLabelParallel', 'South');
    geoshow(east_bering_sea, 'FaceColor', [0.55 0.55 0.55])
    geoshow(west_bering_sea, 'FaceColor', [0.55 0.55 0.55])
end
setm(gca,'MLabelLocation',10)
setm(gca,'PLabelLocation',5)
tightmap

%setm(gca,'mlabelparallel',50)
mlabel('FontSize', 8);
plabel('FontSize', 8);
if strcmp(casename, 'US_west') | strcmp(casename, 'US_west_HFR')
    setm(gca,'MLabelLocation',3)
    setm(gca,'PLabelLocation',3)
    gridm('MlineLocation',1,'PLineLocation',1);
    mlabel('FontSize', 10);
    plabel('FontSize', 10);
else
    gridm('MlineLocation',2.5,'PLineLocation',2.5);
end

%set(gcf,'position',[30 100 700 800]);
%set(gcf,'PaperSize',[8.5 11],'PaperPosition',[0.25 0.25 6 6]);

end
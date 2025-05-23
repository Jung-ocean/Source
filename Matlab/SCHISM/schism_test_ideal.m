clear; clc

rlx = 400000;
rly = 200000;

Mobj.time = (datetime(2000,1,1):hours(1):datetime(2000,1,2))';
Mobj.rundays = days(Mobj.time(end)-Mobj.time(1));
Mobj.dt = 60;
Mobj.coord = 'geographic';

hgrid_file = './hgrid.gr3';
vgrid_file = './vgrid.in';

Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

lon = Mobj.lon;
Mobj.lon = lon.*rlx/180/2 + rlx/2;
lat = Mobj.lat;
Mobj.lat = lat.*rly/5/2 + rly/2;

% Horizontal grids
figure('Color', 'w')
disp_schism_hgrid(Mobj, [1 1])
xlabel('m');
ylabel('m');
%axis image
% set(gcf, 'Position', [50 300 1800 900])  
set(gcf, 'Position', [1 300 1500 600])
% colormap(gray(25))
%print('grid_info','-dpng');
%close all

% Initial elevation
% elev_ic_data = importdata('elev.ic');
% elev_ic = elev_ic_data.data(3:2:4101,2);
% h1 = figure('Color', 'w');
% set(gcf, 'Position', [1 300 1000 400])
% %p = disp_schism_var(Mobj, elev_ic, 'EdgeColor', 'k');
% scatter(Mobj.lon, Mobj.lat, 10, elev_ic)
% caxis([0 1])

% check the invese CFL constraints
% figure('Color', 'w')
% set(gcf, 'Position', [1 1 1500 600])  
% check_schism_metrics(Mobj);
% print('grid_check','-dpng')

% display the Max. acceptable resolutions as a function of water depth 
% calc_schism_CFL(Mobj)

% check the hydrostatic assumption
% check_schism_hydrostatic(Mobj);

%
scale = 5e4;
skip = 1;
SZ = 30;

close all
h1 = figure('Color', 'w'); hold on
set(gcf, 'Position', [1 300 1500 600])
ei = 1;
for oi = 1:10
    oistr = num2str(oi);
    file_output = ['outputs/out2d_', oistr, '.nc'];
    for ti = 1:24
        elevation = ncread(file_output, 'elevation', [1 ti], [Inf 1]);
        ubar = ncread(file_output, 'depthAverageVelX', [1 ti], [Inf 1]);
        vbar = ncread(file_output, 'depthAverageVelY', [1 ti], [Inf 1]);

        index = find(Mobj.lon == 100e3);
        elevation_line(ei,:) = elevation(index);
        ubar_line(ei,:) = ubar(index);

        index1 = find(Mobj.lon == 100e3 & Mobj.lat == 10e3);
        index2 = find(Mobj.lon == 100e3 & Mobj.lat == 100e3);
        ubar_points(ei,1) = ubar(index1);
        ubar_points(ei,2) = ubar(index2);
        ei = ei+1;

        if oi == 1 && ti == 1
            p = disp_schism_var(Mobj, elevation, 'EdgeColor', 'none');
%             s = scatter(Mobj.lon, Mobj.lat, SZ, elevation, 'filled');
            caxis([-1 1])            
            c = colorbar;
            c.Title.String = 'm';
            
            q = quiver(Mobj.lon(1:skip:end), Mobj.lat(1:skip:end), ubar(1:skip:end).*scale, vbar(1:skip:end).*scale, 0, 'k');
            
            qs = quiver(0+2*rlx/100, rly+rly/100, 0.1.*scale, 0.*scale, 0, 'r');
            qs.LineWidth = 2;
            qs.MaxHeadSize = 1;
            text(0+6*rlx/100, rly+rly/100, '0.1 m/s', 'Color', 'r');
        else
            p.FaceVertexCData = elevation;
%             delete(s)
%             s = scatter(Mobj.lon, Mobj.lat, SZ, elevation, 'filled');
            delete(q)
            q = quiver(Mobj.lon(1:skip:end), Mobj.lat(1:skip:end), ubar(1:skip:end).*scale, vbar(1:skip:end).*scale, 0, 'k');
        end

        colormap(parula)

        xlim([0-rlx/100 rlx]);
        ylim([0-rlx/100 rly+rlx/100]);

        xlabel('m')
        ylabel('m')

        % Make gif
        gifname = ['test_ideal_elevation.gif'];

        frame = getframe(h1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if oi == 1 && ti == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end
end
dfdf

figure; hold on; grid on
pcolor(elevation_line); shading interp
caxis([-1.5 1.5])

figure; hold on; grid on
plot(elevation_line(30,:))
plot(elevation_line(60,:))
plot(elevation_line(90,:))
plot(elevation_line(120,:))
plot(elevation_line(end,:))

figure; hold on; grid on
pcolor(ubar_line); shading interp
caxis([-0.3 0.3])

figure; hold on; grid on
plot(ubar_points(:,1))
plot(ubar_points(:,2))
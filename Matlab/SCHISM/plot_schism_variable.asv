clear; clc; close all

yyyy = 2018; ystr = num2str(yyyy);
mm = 7; mstr = num2str(mm,'%02i');
time_ref = datenum(2018,7,1,0,0,0);

vari_str = 'elevation';
filenum_all = 7:7;
domain = 'Bristol_Bay';

[lon, lat] = load_domain(domain);

% SCHISM
rundays = 30;
Mobj.time = (datetime(yyyy,mm,1,1,0,0):hours(1):datetime(yyyy,mm,31,0,0,0))';
Mobj.rundays = days(Mobj.time(end)-Mobj.time(1));
Mobj.dt = 150;
Mobj.coord = 'geographic';

hgrid_file = './hgrid.gr3';
%vgrid_file = '/data/jungjih/Models/SCHISM/test_schism/vgrid.in';
Mobj = read_schism_hgrid(Mobj, hgrid_file);
%Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

h1 = figure('Color', 'w'); hold on
set(gcf, 'Position', [1 300 1000 500])
% plot_map(domain, 'mercator', 'l')
for oi = 1:length(filenum_all)
    filenum = filenum_all(oi);
    oistr = num2str(filenum);
    file_output = ['outputs/out2d_', oistr, '.nc'];
    for ti = 1:24
        vari = ncread(file_output, vari_str, [1 ti], [Inf 1]);
        time = ncread(file_output, 'time', [ti], [1])/60/60/24;
        title_str = datestr(time_ref + time, 'HH:MM mmm-dd, yyyy');

        if oi == 1 && ti == 1
            p = disp_schism_var(Mobj, vari, 'EdgeColor', 'none');
            caxis([-1 1])
            c = colorbar;
            c.Title.String = 'm';
            colormap(parula)
            xlim([lon]+360)
            ylim([lat])
        else
            p.FaceVertexCData = vari;
        end
        
        title(title_str)

%         asdfasdf
%         hold on;
%         lat = 58 + 50.9/60;
%         lon = 158 + 33.1/60;
%         lon = abs(lon - 360);
%         plot(lon, lat, 'rx', 'MarkerSize', 10, 'LineWidth', 2)
%         caxis([-2 2])
%         print('elevation_Bristol_Bay_snapshot','-dpng')

        % Make gif
        gifname = [vari_str, '_', domain, '.gif'];

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
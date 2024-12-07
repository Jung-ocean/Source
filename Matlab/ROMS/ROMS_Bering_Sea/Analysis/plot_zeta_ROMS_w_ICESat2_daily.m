%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS zeta with ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
yyyy = 2022;
ystr = num2str(yyyy);
mm = 4;
mstr = num2str(mm, '%02i');
startdate = datenum(2018,7,1);

ispng = 1;
isgif = 1;

filepath_con = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];
% filepath_con = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng_awdrag/ncks/';

filepath_ICESat2 = ['/data/jungjih/Observations/Sea_ice/ICESat2/SSHA/'];
filename_ICESat2 = ['ADT_ICESat2_', ystr, '.mat'];
file_ICESat2 = [filepath_ICESat2, filename_ICESat2];
load(file_ICESat2)

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;

% Figure properties
interval = 5;
climit = [-40 20];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = ['cm'];

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 800])
plot_map('Gulf_of_Anadyr', 'mercator', 'l');


for di = 1:eomday(yyyy,mm)
    dd = di; dstr = num2str(dd, '%02i');

    timenum = datenum(yyyy,mm,dd);

    filenum = datenum(yyyy,mm,dd) - startdate + 1;
    fstr = num2str(filenum, '%04i');
    filename = [exp, '_avg_', fstr, '.nc'];
    %         filename = ['zeta_', fstr, '.nc'];
    file_con = [filepath_con, filename];
    vari = 100*ncread(file_con, 'zeta')';

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(end)) = climit(end);
    [cs, p] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(p,'bottom')
    plot_map('Gulf_of_Anadyr', 'mercator', 'l')

    if di == 1
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = contour_interval;
    end

    dindex = datenum(yyyy,mm,dd) - datenum(yyyy,1,1)+1;
    lat_ADT = data_ICESat2(dindex).lat_ADT;
    lon_ADT = data_ICESat2(dindex).lon_ADT;
    ADT = 100*data_ICESat2(dindex).ADT;

    s = scatterm(lat_ADT, lon_ADT, 70, ADT, 'filled', 'MarkerEdgeColor', 'k');

    set(gca, 'FontSize', 15)

    title(['Sea level (', datestr(timenum, 'mmm dd, yyyy'), ')'])

    if ispng == 1
        print(['plot_zeta_ROMS_w_ICESat2_daily_', ystr, mstr, dstr], '-dpng')
    end

    if isgif == 1
        % Make gif
        gifname = ['plot_zeta_ROMS_w_ICESat2_daily_', ystr, mstr, '.gif'];

        frame = getframe(h1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if di == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end
    delete(p)
    delete(s)
end % di
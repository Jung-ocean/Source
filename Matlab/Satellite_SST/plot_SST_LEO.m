%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot LEO SST daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm, '%02i');

filepath_all = '/data/jungjih/Observations/Satellite_SST/LEO/daily/';

g = grd('BSf');

climit = [4 14];
interval = .5;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = '^oC';

f1 = figure;
set(gcf, 'Position', [1 200 800 500])
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath = [filepath_all, ystr, '/'];

    timenum_start = datenum(yyyy,mm,1);
    timenum_end = datenum(yyyy,mm,eomday(yyyy,mm));
    timenum_all = timenum_start:timenum_end;

    filenum_all = timenum_all - datenum(yyyy,1,1) + 1;

    for fi = 1:length(filenum_all)
        timenum = timenum_all(fi);
        filenum = filenum_all(fi);
        fstr = num2str(filenum, '%03i');
        filename = dir([filepath, fstr, '/*.nc']);
        file = [filename.folder, '/', filename.name];

        lat_sat = double(ncread(file, 'lat'));
        lon_sat = double(ncread(file, 'lon'));
        vari_sat = double(ncread(file, 'sea_surface_temperature')') - 273.15;

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];

        lon_sat = lon_sat - 180;

        latind = find(55 < lat_sat & lat_sat < 68);
        lonind = find(-200 < lon_sat & lon_sat < -150);
        lat_sat = lat_sat(latind);
        lon_sat = lon_sat(lonind);
        vari_sat = vari_sat(latind,lonind);
        [lon2, lat2] = meshgrid(lon_sat, lat_sat);

        p = pcolorm(lat_sat, lon_sat, vari_sat);
        colormap(color)
        caxis(climit)
        c = colorbar;
        c.Title.String = unit;
        uistack(p, 'bottom')

        title(['LEO L3S SST (', datestr(timenum, 'mmm dd, yyyy'), ')'])

        % Make gif
        gifname = ['SST_LEO_', ystr, mstr, '.gif'];

        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if fi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
        delete(p)

    end
end
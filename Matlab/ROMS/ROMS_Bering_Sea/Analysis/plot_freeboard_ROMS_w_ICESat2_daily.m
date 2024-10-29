%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS freeboard with ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2022;
ystr = num2str(yyyy);
mm_all = 1:2;
startdate = datenum(2018,7,1);

ispng = 0;
isgif = 1;

filepath_con = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';

filepath_ICESat2 = ['/data/jungjih/Observations/Sea_ice/ICESat2/Freeboard/'];
filename_ICESat2 = ['freeboard_ICESat2_', ystr, '.mat'];
file_ICESat2 = [filepath_ICESat2, filename_ICESat2];
load(file_ICESat2)

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Gulf_of_Anadyr', 'mercator', 'l');

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        timenum = datenum(yyyy,mm,dd);
        
        filenum = datenum(yyyy,mm,dd) - startdate + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['Dsm2_spng_avg_', fstr, '.nc'];
        file_con = [filepath_con, filename];
        hice = ncread(file_con, 'hice')';
        aice = ncread(file_con, 'aice')';
        hice(aice < 0.05) = NaN;
        vari = hice.*0.1;

        p = pcolorm(g.lat_rho, g.lon_rho, vari.*g.mask_rho./g.mask_rho);
        uistack(p, 'bottom')
        colormap parula
        caxis([0 0.5])
        c = colorbar;
        c.Title.String = 'm';

        dindex = datenum(yyyy,mm,dd) - datenum(yyyy,1,1)+1;
        lat_freeboard = data_ICESat2(dindex).lat_freeboard;
        lon_freeboard = data_ICESat2(dindex).lon_freeboard;
        freeboard = data_ICESat2(dindex).freeboard;

        s = scatterm(lat_freeboard, lon_freeboard, 70, freeboard, 'filled', 'MarkerEdgeColor', 'k');
        
        title(['Freeboard (', datestr(timenum, 'mmm dd, yyyy'), ')'])

        if ispng == 1
            print(['plot_freeboard_ROMS_w_ICESat2_daily_', ystr, mstr, dstr], '-dpng')
        end

        if isgif == 1
            % Make gif
            gifname = ['plot_freeboard_ROMS_w_ICESat2_daily_', ystr, '.gif'];

            frame = getframe(h1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if mi == 1 && di == 1
                imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
            else
                imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
            end
        end
        delete(p)
        delete(s)
    end % di
end % mi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS zeta with ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2020;
ystr = num2str(yyyy);
mm_all = 1:2;
startdate = datenum(2018,7,1);

ispng = 0;
isgif = 1;

% filepath_con = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';
filepath_con = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng_awdrag/ncks/';

filepath_ICESat2 = ['/data/jungjih/Observations/Sea_ice/ICESat2/SSHA/'];
filename_ICESat2 = ['ADT_ICESat2_', ystr, '.mat'];
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
%         filename = ['Dsm2_spng_avg_', fstr, '.nc'];
        filename = ['zeta_', fstr, '.nc'];
        file_con = [filepath_con, filename];
        vari = ncread(file_con, 'zeta')';

        p = pcolorm(g.lat_rho, g.lon_rho, vari.*g.mask_rho./g.mask_rho);
        uistack(p, 'bottom')
        colormap redblue
        caxis([-1 1])
        c = colorbar;
        c.Title.String = 'm';

        dindex = datenum(yyyy,mm,dd) - datenum(yyyy,1,1)+1;
        lat_ADT = data_ICESat2(dindex).lat_ADT;
        lon_ADT = data_ICESat2(dindex).lon_ADT;
        ADT = data_ICESat2(dindex).ADT;

        s = scatterm(lat_ADT, lon_ADT, 70, ADT, 'filled', 'MarkerEdgeColor', 'k');
        
        title(['zeta (', datestr(timenum, 'mmm dd, yyyy'), ')'])

        if ispng == 1
            print(['plot_zeta_ROMS_w_ICESat2_daily_', ystr, mstr, dstr], '-dpng')
        end

        if isgif == 1
            % Make gif
            gifname = ['plot_zeta_ROMS_w_ICESat2_daily_', ystr, '.gif'];

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
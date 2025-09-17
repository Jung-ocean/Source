%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged ROMS aice daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Koryak_coast';

exp = 'Dsm4';
vari_str = 'aice';
yyyy_all = 2018:2023;
mm_all = 1:12;

% Load grid information
g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
dxdy = dx.*dy;
[mask, area] = mask_and_area(region, g);

% figure; hold on;
% set(gcf, 'Position', [1 200 800 500])
% plot_map('Bering', 'mercator', 'l')
% contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k')
% pcolorm(g.lat_rho, g.lon_rho, mask);
% print(['region_', region], '-dpng')

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, exp, '/'];

aice = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');
            timenum = [timenum; datenum(yyyy,mm,dd)];
            filenum = datenum(yyyy,mm,dd) - datenum(2018,7,1) + 1;
            fstr = num2str(filenum, '%04i');

            filepattern_control = fullfile(filepath_control,(['*',exp, '_avg_', fstr,'*.nc']));
            filename_control = dir(filepattern_control);
            if ~isempty(filename_control)
                file_control = [filepath_control, filename_control.name];
                if filenum == 0119
                    file_control = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/Dsm4_rhZop05/Sum_2018_Dsm4_rhZop05_avg_0119.nc';
                elseif filenum == 1640
                    file_control = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2022/Dsm4_nKC/SumFal_2022_Dsm4_nKC_avg_1640.nc';
                elseif filenum == 1826
                    file_control = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
                end

                vari = ncread(file_control,'aice');
                if isempty(vari) == 1
                    aice = [aice; NaN];
                else
                    aice_tmp = sum(vari(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
                    aice = [aice; aice_tmp];
                end
            else
                aice = [aice; NaN];
            end

            disp([ystr, mstr, dstr, '...'])
        end % di
    end % mi
end % yi

output_filename = ['aice_ROMS_', region, '_daily.mat'];

figure; hold on; grid on
set(gcf, 'Position', [1 200 1300 500])
plot(timenum, aice, '-k', 'LineWidth', 2);
xticks([datenum(yyyy_all,1,1)]);
xlim([datenum(yyyy_all(1),1,0) datenum(yyyy_all(end)+1,1,1)])
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
set(gca, 'FontSize', 15)

box on
save(output_filename, 'timenum', 'aice')
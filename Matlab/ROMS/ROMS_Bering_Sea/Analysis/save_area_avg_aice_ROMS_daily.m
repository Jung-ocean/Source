%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged ROMS aice daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; %close all

region = 'M5_50km';

exp = 'Dsm4';
vari_str = 'aice';
yyyy_all = 2019:2023;
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

figure; hold on; grid on
plot(timenum, aice, '-');
xticks([datenum(yyyy_all,6,1)]);
xlim([datenum(yyyy_all(1),1,0) datenum(yyyy_all(end)+1,1,1)])
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

output_filename = ['aice_ROMS_', region, '_daily.mat'];

save(output_filename, 'timenum', 'aice')
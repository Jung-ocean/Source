%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged ROMS aice monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'aice';
yyyy_all = 2019:2022;
mm_all = 1:7;

% Load grid information
g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
dxdy = dx.*dy;
[mask, area] = mask_and_area(region, g);

figure; hold on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k')
pcolorm(g.lat_rho, g.lon_rho, mask);
print(['region_', region], '-dpng')

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, exp, '/monthly/'];

aice = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');
        timenum = [timenum; datenum(yyyy,mm,15)];

        filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
        filename_control = dir(filepattern_control);
        if ~isempty(filename_control)
            file_control = [filepath_control, filename_control.name];
            vari = ncread(file_control,'aice')';

            aice_tmp = sum(vari(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');

            aice = [aice; aice_tmp];
        else
            aice = [aice; NaN];
        continue
        end

        disp([ystr, mstr, '...'])
    end % mi
end % yi

figure; hold on; grid on
plot(timenum, aice, '-o');
xticks(datenum(yyyy_all,1,15));
xlim([datenum(yyyy_all(1),1,1) datenum(yyyy_all(end)+1,1,1)])
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

if length(mm_all) == 1
    output_filename = ['aice_ROMS_', region, '_', num2str(mm_all, '%02i'), '.mat'];
else
    output_filename = ['aice_ROMS_', region, '.mat'];
end
save(output_filename, 'timenum', 'aice')
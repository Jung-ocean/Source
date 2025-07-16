%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot area-averaged ROMS SSS with sea ice concentration monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy_all = 2019:2022;
mm_all = 1:12;
layer = 45;

region = 'Smidshelf';

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

[mask, area] = mask_and_area(region, g);

ind_plotpoly = 1;
if ind_plotpoly == 1
    figure; hold on; grid on;
    set(gcf, 'Position', [1 200, 800 500])
    plot_map('Bering', 'mercator', 'l')

    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');
    pcolorm(g.lat_rho, g.lon_rho, mask);

    print(['region_', region], '-dpng')
end

switch vari_str
    case 'salt'
        ylimit = [28 33];
        unit = 'psu';
end

% Model
case_control = 'Dsm4';
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, case_control, '/monthly/'];

timenum_all = NaN(length(yyyy_all)*12,1);
vari_all = NaN(length(yyyy_all)*12,1);
aice_all = NaN(length(yyyy_all)*12,1);
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
   
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
        filename_control = dir(filepattern_control);
        if ~isempty(filename_control)
            file_control = [filepath_control, filename_control.name];
            vari = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
            vari_all(12*(yi-1) + mi) = sum(vari(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');

            aice = ncread(file_control,'aice')';
            aice_all(12*(yi-1) + mi) = sum(aice(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
        else
            vari = NaN;
            vari_all(12*(yi-1) + mi) = NaN;
            aice_all(12*(yi-1) + mi) = NaN;
        end

        timenum = datenum(yyyy,mm,15);
        time_title = datestr(timenum, 'mmm, yyyy');
        timenum_all(12*(yi-1) + mi) = timenum;

        disp([ystr, mstr, '...'])
    end % mi
end % yi
timevec = datevec(timenum_all);

% Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
plot(timenum_all, aice_all, '-ok');
ylim([0 1])
ylabel('Sea ice concentration')

yyaxis right
plot(timenum_all, vari_all, '-or');
ylim(ylimit)
ylabel('Salinity (psu)')

ax = gca;
set(ax, 'YColor', 'r')

xticks([datenum(yyyy_all,7,15)])
datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')

set(gca, 'FontSize', 15)
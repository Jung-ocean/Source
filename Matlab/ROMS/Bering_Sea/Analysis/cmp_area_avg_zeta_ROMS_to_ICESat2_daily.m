%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS area averaged zeta to ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2021;
mm_all = 1:6;
startdate = datenum(2018,7,1);

exp = 'Dsm4';
region = 'Gulf_of_Anadyr';
filepath_con = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

ystr = num2str(yyyy);

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

filenum_start = datenum(yyyy,mm_all(1),1) - startdate + 1;
fileum_end = datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end))) - startdate + 1;

filenum_all = filenum_start:fileum_end;
timenum_all = [startdate + filenum_all]-1;

[mask_target, area_target] = mask_and_area(region, g);

ylimit = [-1 1];

vari_con = [];
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
    filename = [exp, '_avg_', fstr, '.nc'];

    file_con = [filepath_con, filename];
    vari = ncread(file_con, 'zeta')';
    vari_con(fi) = sum(vari(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');

    disp(datestr(timenum_all(fi), 'yyyymmdd'))
end

load(['/data/jungjih/Observations/Sea_ice/ICESat2/SSHA/ADT_ICESat2_', region, '_', ystr, '.mat'])

num = length(vari_con);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1200 300])

pc = plot(timenum_all, vari_con, '-k', 'LineWidth', 2);
psat = plot(timenum_all, ADT_ICESat2(1:num), '.r', 'MarkerSize', 15);
xticks(datenum(yyyy, 1:12,1))
xlim([timenum_all(1)-1 timenum_all(end)+1])
ylim(ylimit)

datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
ylabel('m')

l = legend([pc, psat], 'ROMS', 'ICESat2');
l.Location = 'NorthEast';
l.FontSize = 15;

set(gca, 'FontSize', 12)

title(['Area averaged ADT (', region, ')'], 'Interpreter', 'none');

print(['cmp_area_avg_zeta_ROMS_to_ICESat2_daily_',region, '_', ystr], '-dpng')
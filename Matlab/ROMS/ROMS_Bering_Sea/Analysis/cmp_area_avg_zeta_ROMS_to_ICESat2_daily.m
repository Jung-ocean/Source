%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS area averaged zeta to ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2019;
mm_all = 1:6;
startdate = datenum(2018,7,1);

region = 'Gulf_of_Anadyr';
filepath_con = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';

ystr = num2str(yyyy);

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

filenum_start = datenum(yyyy,mm_all(1),1) - startdate + 1;
fileum_end = datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end))) - startdate + 1;

filenum_all = filenum_start:fileum_end;
timenum_all = [startdate + filenum_all]-1;

if strcmp(region, 'Gulf_of_Anadyr')
    polygon = [;
        -181.1407   62.6194
        -173.5578   64.6246
        -180.0089   66.2790
        -184.7623   64.8251
        -181.1407   62.6194
        ];

    ylimit = [-.7 .7];
elseif strcmp(region, 'Norton_Sound')
    polygon = [;
        -166.3047   64.6603
        -164.0475   62.6674
        -160.0348   63.6554
        -160.7155   65.0351
        -166.3047   64.6603
        ];

    ylimit = [-1.7 1.7];
end

[in, on] = inpolygon(g.lon_rho, g.lat_rho, polygon(:,1), polygon(:,2));
mask_target = in./in;
area_target = area.*mask_target;

vari_con = [];
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
    filename = ['Dsm2_spng_avg_', fstr, '.nc'];

    file_con = [filepath_con, filename];
    vari = ncread(file_con, 'zeta')';
    vari_con(fi) = sum(vari(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');

    disp(datestr(timenum_all(fi), 'yyyymmdd'))
end

load(['/data/jungjih/Observations/Sea_ice/ICESat2/ADT_ICESat2_', region, '_', ystr, '.mat'])

num = length(vari_con);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1200 300])

pc = plot(timenum_all, vari_con, '-r');
psat = plot(timenum_all, ADT_ICESat2(1:num), 'bo');
xticks(datenum(yyyy, 1:12,1))
xlim([timenum_all(1)-1 timenum_all(end)+1])
ylim(ylimit)

datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
ylabel('m')

l = legend([pc, psat], 'Control', 'ICESat2');
l.Location = 'NorthWest';

title(['Area averaged SSH (', region, ')'], 'Interpreter', 'none');

print(['cmp_area_avg_zeta_ROMS_to_ICESat2_daily_',region, '_', ystr], '-dpng')
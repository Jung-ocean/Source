%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS point zeta to ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2021;
mm_all = 1:6;

exp = 'Dsm4';
region = 'Gulf_of_Anadyr';
startdate = datenum(2018,7,1);
filepath_con = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

ystr = num2str(yyyy);

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

[mask_target, area_target] = mask_and_area(region, g);

polygon = [;
    -180.9180   62.3790
    -172.9734   64.3531
    -178.7092   66.7637
    -184.1599   64.8934
    -180.9180   62.3790
    ];

load(['/data/jungjih/Observations/Sea_ice/ICESat2/SSHA/ADT_ICESat2_2021']);
for di = 1:length(data_ICESat2)
    timenum_tmp = data_ICESat2(di).timenum;
    timenum(di) = timenum_tmp;
    lat_tmp = data_ICESat2(di).lat_ADT;
    lon_tmp = data_ICESat2(di).lon_ADT;
    ADT_tmp = data_ICESat2(di).ADT;

    [in, on] = inpolygon(lon_tmp, lat_tmp, polygon(:,1), polygon(:,2));

    if sum(in) > 0
        lat_target = lat_tmp(in);
        lon_target = lon_tmp(in);
        ADT_target = ADT_tmp(in);

        filenum = timenum_tmp - startdate + 1;
        fstr = num2str(filenum, '%04i');
        filename = [exp, '_avg_', fstr, '.nc'];
        file = [filepath_con, filename];
        vari = ncread(file, 'zeta')';
        vari_point = interp2(g.lon_rho, g.lat_rho, vari, lon_target, lat_target);

        ADT_sat(di) = mean(ADT_target);
        ADT_model(di) = mean(vari_point);
    else
        ADT_sat(di) = NaN;
        ADT_model(di) = NaN;
    end

    disp(datestr(timenum_tmp, 'yyyymmdd'))
end

ddd


figure; hold on; grid on;
plot(timenum, ADT_sat, '-o')
plot(timenum, ADT_model, '-o')

for ti = timenum_start:timenum_end
    



end


filenum_start = datenum(yyyy,mm_all(1),1) - startdate + 1;
fileum_end = datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end))) - startdate + 1;

filenum_all = filenum_start:fileum_end;
timenum_all = [startdate + filenum_all]-1;


ylimit = [-1 1];





vari_con = [];
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
    
    vari_con(fi) = sum(vari(:).*area_target(:), 'omitnan')./sum(area_target(:), 'omitnan');

    disp(datestr(timenum_all(fi), 'yyyymmdd'))
end


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

print(['cmp_point_zeta_ROMS_to_ICESat2_daily_',region, '_', ystr], '-dpng')
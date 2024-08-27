%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS zeta to ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2022;
ystr = num2str(yyyy);
mm_all = 1:6;
startdate = datenum(2018,7,1);

filepath_con = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';

filepath_ICESat2 = ['/data/jungjih/Observations/Sea_ice/ICESat2/'];
filename_ICESat2 = ['uv_ICESat2_', ystr, '.mat'];
file_ICESat2 = [filepath_ICESat2, filename_ICESat2];
load(file_ICESat2)

g = grd('BSf');
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;

ADT_all = [];
vari_interp_all = [];

figure; hold on; grid on;
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');
        dindex = datenum(yyyy,mm,dd) - datenum(yyyy,1,1)+1;

        num_ADT = data_ICESat2(dindex).num_ADT;
        timenum = data_ICESat2(dindex).timenum;

        if isnan(sum(num_ADT)) == 1

        else
            filenum = datenum(yyyy,mm,dd) - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = ['Dsm2_spng_avg_', fstr, '.nc'];
            file_con = [filepath_con, filename];
            vari = ncread(file_con, 'zeta')';
%             ot = ncread(file_con, 'ocean_time');
%             HH = datestr(datenum(1968,5,23) + ot/60/60/24, 'HH');
%             if strcmp(HH, '00')
%                 fstr = num2str(filenum-1, '%04i');
%                 filename = ['Dsm2_spng_avg_', fstr, '.nc'];
%                 file_con = [filepath_con, filename];
%                 vari_tmp = ncread(file_con, 'zeta')';
% 
%                 vari = (vari + vari_tmp)/2;
%             end

            indices = unique([0; cumsum(num_ADT)]);
            for ni = 1:length(indices)-1
                index = indices(ni)+1:indices(ni+1);

                lat_ADT = data_ICESat2(dindex).lat_ADT(index);
                lon_ADT = data_ICESat2(dindex).lon_ADT(index);
                ADT = data_ICESat2(dindex).ADT(index);

                vari_interp = interp2(g.lon_rho, g.lat_rho, vari, lon_ADT, lat_ADT);

                figure; hold on; grid on;
                psat = plot(lat_ADT,ADT, '-o');
                proms = plot(lat_ADT,vari_interp, '-o');
                xlabel('Latitude (^oN)');
                ylabel('ADT or zeta (m)');
                ylim([-.7 .7])
             
                l = legend([psat proms], 'ICESat2', 'ROMS');
                l.Location = 'SouthWest';
                l.FontSize = 15;

                title(datestr(timenum, 'mmm dd, yyyy'))
            end
        end
        disp(datestr(timenum, 'yyyymmdd'))
    end % di
end % mi

df

print(['cmp_zeta_ROMS_to_ICESat2_', datestr(timenum, 'yyyymmdd')], '-dpng')


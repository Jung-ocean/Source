%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS zeta to ICESat2 and NOAA daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

g = grd('BSf');
startdate = datenum(2018,7,1);

yyyy = 2019;
mm_all = 1:6;
region = 'Norton_Sound';

filepath_con = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';
filepath_sta = '/data/jungjih/Observations/NOAA_stations/';

station_name = {'Nome, Norton Sound, AK', 'Unalakleet, AK'};
station_ID = [9468756 9468333];
station_lat = [64.4950 63.8717];
station_lon = [-165.4400 -160.7850];

vari_con = [];
vari_sta = [];
timenum_all = [];
dataindex = 1;
for si = 1:1%length(station_name)
    lat_sta = station_lat(si);
    lon_sta = station_lon(si);
    id_sta = station_ID(si); idstr = num2str(id_sta);

    dist = sqrt((g.lon_rho - lon_sta).^2 + abs(g.lat_rho - lat_sta).^2);
    [latind, lonind] = find(dist == min(dist(:)));

    if si == 1
        latind = latind - 1;
    elseif si == 2
        latind = latind - 1;
        lonind = lonind - 1;
    end

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');
            timenum = datenum(yyyy,mm,dd);
            filenum = timenum - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = ['Dsm2_spng_avg_', fstr, '.nc'];

            file_con = [filepath_con, filename];
            vari_con(si,dataindex) = ncread(file_con, 'zeta', [lonind, latind, 1], [1, 1, Inf]);

            yyyymmdd = datestr(startdate + filenum - 1, 'yyyymmdd');
            ystr = yyyymmdd(1:4); yyyy = str2num(ystr);
            mstr = yyyymmdd(5:6); mm = str2num(mstr);
            dstr = yyyymmdd(7:8); dd = str2num(dstr);

            file_sta = [filepath_sta, 'CO-OPS_', idstr, '_met_', ystr, '.csv'];
            data = readtable(file_sta);
            timevec_sta = datevec(datenum([cell2mat(table2array(data(:,1))) cell2mat(table2array(data(:,2)))], 'yyyy/mm/ddHH:MM'));
            vari_sta_1h = table2array(data(:,5));
            vari_sta_pre_1h = table2array(data(:,3));

            index = find(timevec_sta(:,1) == yyyy & timevec_sta(:,2) == mm & timevec_sta(:,3) == dd);
            vari_raw = vari_sta_1h(index);

            if yyyy == 2019
                ERA5 = ['/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/BSf_ERA5_', ystr, '_', mstr, '_ni2_a_frc.nc'];
                ERA5_lon = ncread(ERA5, 'lon')';
                ERA5_lat = ncread(ERA5, 'lat')';
                ERA5_dist = sqrt((ERA5_lon - lon_sta).^2 + abs(ERA5_lat - lat_sta).^2);
                [ERA5_latind, ERA5_lonind] = find(ERA5_dist == min(ERA5_dist(:)));

                ERA5_timenum = ncread(ERA5, 'sfrc_time') + datenum(1968,5,23);
                ERA5_timevec = datevec(ncread(ERA5, 'sfrc_time') + datenum(1968,5,23));
                ERA5_Pair = squeeze(ncread(ERA5, 'Pair', [ERA5_lonind, ERA5_latind 1], [1 1 Inf]));

                ERA5_index = find(ERA5_timevec(:,1) == yyyy & ERA5_timevec(:,2) == mm & ERA5_timevec(:,3) == dd);
                try
                    ERA5_timenum_target = ERA5_timenum([ERA5_index; ERA5_index(end)+1]);
                    ERA5_Pair_target = ERA5_Pair([ERA5_index; ERA5_index(end)+1]);
                catch
                    ERA5_tmp = ['/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/BSf_ERA5_', ystr, '_', num2str(str2num(mstr)+1, '%02i'), '_ni2_a_frc.nc'];
                    time_tmp = ncread(ERA5_tmp, 'sfrc_time', [1], [1]) + datenum(1968,5,23);
                    Pair_tmp = squeeze(ncread(ERA5, 'Pair', [ERA5_lonind, ERA5_latind 1], [1 1 1]));

                    ERA5_timenum_target = [ERA5_timenum(ERA5_index); time_tmp];
                    ERA5_Pair_target = [ERA5_Pair(ERA5_index); Pair_tmp];
                end
                ERA5_time_interp = [datenum(yyyy,mm,dd):1/24:datenum(yyyy,mm,dd+1)-1/24];

                vari_baro = interp1(ERA5_timenum_target, ERA5_Pair_target, ERA5_time_interp)';
            else
                file_sta_atm = [filepath_sta, 'CO-OPS_', idstr, '_met_atm_', ystr, '.csv'];
                data_atm = readtable(file_sta_atm);
                vari_baro_1h = table2array(data_atm(:,7));
                    
                vari_baro_tmp = vari_baro_1h(index);
                if iscell(vari_baro_tmp) == 1
                    vari_baro = NaN(size(vari_baro_tmp));
                    for i = 1:length(vari_baro_tmp)
                        try
                            vari_baro(i) = str2num(cell2mat(vari_baro_tmp(i)));
                        catch
                            vari_baro(i) = NaN;
                        end
                    end
                else
                    vari_baro = vari_baro_tmp;
                end

            end

            gconst = 9.8; % m/s^2
            rho0 = 1027; % kg/m^3
            pref = 1010.06; % 3 year mean from the Nome station
            vari_ib = -100*(vari_baro - pref)/(gconst*rho0);
            vari_correct = vari_raw - vari_ib;

            vari_sta(si,dataindex) = mean(vari_correct);
            vari_sta_pre(si,dataindex) = mean(vari_sta_pre_1h(index));

            timenum_all = [timenum_all; timenum];
            dataindex = dataindex+1;
            disp([yyyymmdd])
        end
    end
end

load(['/data/jungjih/Observations/Sea_ice/ICESat2/ADT_ICESat2_', region, '_', ystr, '.mat'])

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1200 300])
ps = plot(timenum_all, vari_sta, 'k');
pc = plot(timenum_all, vari_con, 'r');
psat = plot(timenum_all, ADT_ICESat2, 'ob');

xticks([datenum(yyyy,1:12,1)])

xlim([timenum_all(1)-1 timenum_all(end)+1])
ylim([-1.7 1.7]);

datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
ylabel('m');

if yyyy == 2019
    l = legend([ps, pc, psat], 'NOAA station (correction using ERA5 pressure)', 'Control', 'ICESat2 (area averaged)');
    l.Location = 'SouthWest';
else
    l = legend([ps, pc, psat], 'NOAA station', 'Control', 'ICESat2 (area averaged)');
    l.Location = 'NorthWest';
end

title([station_name{si}, ' (', ystr, ')'])

print(['cmp_zeta_ROMS_to_ICESat2_and_NOAA_daily_',region, '_', ystr], '-dpng')

save(['cmp_zeta_', region, '_', ystr, '.mat'] , 'vari_sta', 'vari_con', 'ADT_ICESat2');

df
%
ADT_ICESat2_all = [];
vari_con_all = [];
vari_sta_all = [];
for yyyy = 2019:2022
    load(['cmp_zeta_Norton_Sound_', num2str(yyyy), '.mat'])
    ADT_ICESat2_all = [ADT_ICESat2_all; ADT_ICESat2];
    vari_sta_all = [vari_sta_all; vari_sta'];
    vari_con_all = [vari_con_all; vari_con'];
end

index = find(isnan(ADT_ICESat2_all) ~= 1 & isnan(vari_sta_all) ~= 1);
ADT_ICESat2_data = ADT_ICESat2_all(index);
vari_sta_data = vari_sta_all(index);

figure; hold on; grid on;
plot(ADT_ICESat2_data, vari_sta_data, 'o');

yyyy_all = 2019:2022;
colors = {'r', 'g', 'b', 'k'};
for i = 1:length(yyyy_all)
    yyyy = yyyy_all(i);
    load(['cmp_zeta_Norton_Sound_', num2str(yyyy), '.mat'])
    pt(i) = plot(double(ADT_ICESat2), vari_sta', 'o', 'Color', colors{i});
end
l = legend(pt, {'2019', '2020', '2021', '2022'});
l.Location = 'SouthWest';
l.FontSize = 15;

xlim([-1 1])
ylim([-1 1])

xlabel('ICESat2 (m, area averaged)')
ylabel('NOAA station (m)')

[p, S] = polyfit(ADT_ICESat2_data, vari_sta_data, 1);
text(-0.9, 0.8, ['y = ', num2str(p(1), '%.2f'), 'x', num2str(p(2), '%.2f')], 'FontSize', 15)
[R, P] = corrcoef(ADT_ICESat2_data, vari_sta_data);
text(-0.9, 0.6, ['R = ', num2str(R(1,2), '%.2f')], 'FontSize', 15)

set(gca, 'FontSize', 12)

title([region, ' (2019 - 2022)'], 'interpreter', 'none')

print('ICESat2_vs_NOAA', '-dpng')
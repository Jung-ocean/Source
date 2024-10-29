%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS zeta to ROMS and NOAA daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

g = grd('BSf');
startdate = datenum(2018,7,1);

filenum_all = 517:729;
timenum_all = [startdate + filenum_all]-1;

filepath_con = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/ncks/';
filepath_exp = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng_awdrag/ncks/';

filepath_sta = '/data/jungjih/Observations/NOAA_stations/';

station_name = {'Nome, Norton Sound, AK', 'Unalakleet, AK'};
station_ID = [9468756 9468333];
station_lat = [64.4950 63.8717];
station_lon = [-165.4400 -160.7850];

vari_con = [];
vari_exp = [];
vari_sta = [];
for si = 1:length(station_name)
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

    for fi = 1:length(filenum_all)
        filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
        filename = ['zeta_', fstr, '.nc'];

        file_con = [filepath_con, filename];
        vari_con(si,fi) = ncread(file_con, 'zeta', [lonind, latind, 1], [1, 1, Inf]);

        file_exp = [filepath_exp, filename];
        vari_exp(si,fi) = ncread(file_exp, 'zeta', [lonind, latind, 1], [1, 1, Inf]);

        yyyymmdd = datestr(startdate + filenum - 1, 'yyyymmdd');
        ystr = yyyymmdd(1:4); yyyy = str2num(ystr);
        mstr = yyyymmdd(5:6); mm = str2num(mstr);
        dstr = yyyymmdd(7:8); dd = str2num(dstr);

        file_sta = [filepath_sta, 'CO-OPS_', idstr, '_met_', ystr, '.csv'];
        data = readtable(file_sta);
        timevec_sta = datevec(datenum([cell2mat(table2array(data(:,1))) cell2mat(table2array(data(:,2)))], 'yyyy/mm/ddHH:MM'));
        vari_sta_1h = table2array(data(:,5));
        vari_sta_pre_1h = table2array(data(:,3));

        file_sta_atm = [filepath_sta, 'CO-OPS_', idstr, '_met_atm_', ystr, '.csv'];
        data_atm = readtable(file_sta_atm);
        vari_baro_1h = table2array(data_atm(:,7));
        
        index = find(timevec_sta(:,1) == yyyy & timevec_sta(:,2) == mm & timevec_sta(:,3) == dd);
        
        vari_raw = vari_sta_1h(index);
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

        gconst = 9.8; % m/s^2
        rho0 = 1027; % kg/m^3
        pref = 1010.06; % 3 year mean from the Nome station
        vari_ib = -100*(vari_baro - pref)/(gconst*rho0);
        vari_correct = vari_raw - vari_ib;

        vari_sta(si,fi) = mean(vari_correct);
        vari_sta_pre(si,fi) = mean(vari_sta_pre_1h(index));

        disp([num2str(si), '/', num2str(length(station_name)), ' ', yyyymmdd])
    end
end

figure; hold on; grid on;
plot_map('Eastern_Bering', 'mercator', 'l')
for si = 1:length(station_name)
    plotm(station_lat(si), station_lon(si), '.r', 'MarkerSize', 15)
end
print('map_stations', '-dpng')

% map_station = geopoint(station_lat, station_lon);
% map_station.Name = station_name;
% kmlwrite('map_station.kml', map_station)

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1200 600])
t = tiledlayout(2,1);
for si = 1:length(station_name)
    nexttile(si); hold on; grid on
    ps = plot(timenum_all, vari_sta(si,:), 'k');
    pc = plot(timenum_all, vari_con(si,:), 'r');
    pe = plot(timenum_all, vari_exp(si,:), 'b');
  
    xticks([datenum(2019,1:12,1) datenum(2020,1:12,1)])

    xlim([timenum_all(1)-1 timenum_all(end)+1])
    ylim([-1.7 1.7]);

    datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
    ylabel('m');
    
    if si == 1
        l = legend([ps, pc, pe], 'NOAA station', 'Control', 'Wind drag only');
        l.Location = 'NorthWest';
    end
    
    title(station_name(si))
end

t.TileSpacing = 'compact';
t.Padding = 'compact';

print(['cmp_zeta_ROMS_to_ROMS_and_NOAA_daily'], '-dpng')
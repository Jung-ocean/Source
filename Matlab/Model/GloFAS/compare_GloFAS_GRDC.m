%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare GloFAS with GRDC
% You will need a mapping package (M-Map)
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
GRDC_filepath = '/data/sdurski/ROMS_Setups/Forcing/Rivers/Source_data/';
GloFAS_filepath = '/data/jungjih/Model/GloFAS/';
%

GRDC_filenames = dir([GRDC_filepath, '*nc']);
GRDC_time_ref = datenum(1700,1,1);

for fi_GRDC = 1:length(GRDC_filenames)
    f = figure; hold on

    GRDC_filename = GRDC_filenames(fi_GRDC).name;
    GRDC_file = [GRDC_filepath, GRDC_filename];

    time_GRDC = double(ncread(GRDC_file, 'time'));
    timenum_GRDC = GRDC_time_ref + time_GRDC;
    timevec_GRDC = datevec(timenum_GRDC);

    station_name = ncread(GRDC_file, 'station_name');
    river_name = ncread(GRDC_file, 'river_name');
    river_name = replace(river_name, "'", '');
    lon_GRDC = ncread(GRDC_file, 'geo_x');
    lat_GRDC = ncread(GRDC_file, 'geo_y');
    dis_GRDC = ncread(GRDC_file, 'runoff_mean');
    
    rivind = 0;
    if strcmp(river_name(1),'KAMCHATKA')
        rivind = 2;
    elseif strcmp(river_name(1),'KUSKOKWIM RIVER')
        rivind = 1;
    end

    if rivind~=0
        river_name = river_name(rivind);
        station_name = station_name(rivind);
        lon_GRDC = lon_GRDC(rivind);
        lat_GRDC = lat_GRDC(rivind);
        dis_GRDC = dis_GRDC(rivind,:);
    end

    sgtitle(strcat(river_name, ' (', station_name, ')'), 'FontSize', 25)

    subplot(2,2,1); hold on
    try
        plot_map('Bering'); hold on
        m_plot(lon_GRDC,lat_GRDC,'.r', 'MarkerSize', 15)
        m_plot(lon_GRDC+360,lat_GRDC,'.r', 'MarkerSize', 15)
    catch
        plot(lon_GRDC,lat_GRDC,'.r', 'MarkerSize', 15)
    end

    yyyy_all = unique(timevec_GRDC(:,1));
    yearnums = [0; cumsum(yeardays(yyyy_all))];
    dis_GloFAS_total = zeros(yearnums(end),1);
    dis_GloFAS_monthly_total = zeros(12*length(yyyy_all),1);
    timenum_total = zeros(yearnums(end),1);
    timenum_monthly = zeros(12*length(yyyy_all),1);
    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi); ystr = num2str(yyyy);
        GloFAS_filenames = dir([GloFAS_filepath, ystr, '/*.nc']);
        if isempty(GloFAS_filenames)
            continue
        end
        
        GloFAS_file = [GloFAS_filepath, ystr, '/', GloFAS_filenames(1).name];
        lon_GloFAS = ncread(GloFAS_file,'lon');
        lat_GloFAS = ncread(GloFAS_file,'lat');
        [lon2,lat2] = meshgrid(lon_GloFAS,lat_GloFAS);

        dist = distance(lat_GRDC, lon_GRDC, lat2, lon2);
        [I,J] = find(dist == min(dist,[],'all'));

        daynums = [0, cumsum(eomday(yyyy,1:12))];
        dis_GloFAS_yyyy = zeros(yeardays(yyyy), 1);
        dis_GloFAS_monthly_yyyy = zeros(length(GloFAS_filenames),1);
        timenum_yyyy = zeros(yeardays(yyyy),1);
        for fi_GloFAS = 1:length(GloFAS_filenames)
            GloFAS_filename = GloFAS_filenames(fi_GloFAS).name;
            GloFAS_file = [GloFAS_filepath, ystr, '/', GloFAS_filename];
            mm_str = GloFAS_filename(17:18);
            GloFAS_time_ref = datenum(yyyy,str2num(mm_str),1);
            time_GloFAS = ncread(GloFAS_file,'time');
            timenum_GloFAS = GloFAS_time_ref + time_GloFAS/24;
            timevec_GloFAS = datevec(timenum_GloFAS);
            dis_GloFAS_around = ncread(GloFAS_file,'dis24',[J-1 I-1 1], [3 3 Inf]);
            dis_GloFAS_around = permute(dis_GloFAS_around, [3 2 1]);
            dis_GloFAS_around_sum = squeeze(sum(dis_GloFAS_around,1));
            [II,JJ] = find(dis_GloFAS_around_sum==max(dis_GloFAS_around_sum,[],'all'));
            if length(II) > 1
                II = II(1); JJ = JJ(1);
            end
            dis_GloFAS = squeeze(dis_GloFAS_around(:,II,JJ));
            
            daynum = (daynums(fi_GloFAS)+1):daynums(fi_GloFAS+1);
            dis_GloFAS_yyyy(daynum) = dis_GloFAS;
            dis_GloFAS_monthly_yyyy(fi_GloFAS) = mean(dis_GloFAS);
            timenum_yyyy(daynum) = timenum_GloFAS;
        end % fi_GloFAS
        yearnum = (yearnums(yi)+1):yearnums(yi+1);
        dis_GloFAS_total(yearnum) = dis_GloFAS_yyyy;
        dis_GloFAS_monthly_total(12*yi-11:12*yi) = dis_GloFAS_monthly_yyyy;
        timenum_total(yearnum) = timenum_yyyy;
        timenum_monthly(12*yi-11:12*yi) = datenum(yyyy,1:12,1);
        disp(strcat(river_name, {' '} ,ystr, '/', num2str(yyyy_all(end)), '...'))
    end % yi

    subplot(2,2,3:4); hold on; grid on
    p1 = plot(timenum_total, dis_GloFAS_total, 'b');
    p2 = plot(timenum_monthly, dis_GloFAS_monthly_total, 'ob');
    p3 = plot(timenum_GRDC, dis_GRDC, 'or');
    
    index = find(timenum_monthly ~= 0);
    timevec_tick = datevec(timenum_monthly(index));
    yyyy_tick = unique(timevec_tick(:,1));
    xtick_list = datenum([yyyy_tick; yyyy_tick(end)+1],1,1);
    xticks(xtick_list);
    xlim([xtick_list(1) xtick_list(end)])
    datetick('x', 'yyyy', 'keepticks');
    
    ylabel('River discharge (m^3/s)');
    ylim([0 max(dis_GloFAS_total) + 1000]);
    
    l = legend([p1, p2, p3], 'GloFAS daily', 'GloFAS monthly', 'GFDC monthly');
    l.Location = 'NorthWest';

    set(gca, 'Position', [0.1300 0.1066 0.7750 0.3306])

    % Climate plot
    timevec_GRDC = datevec(timenum_GRDC);
    yyyy_climate_GRDC = unique(timevec_GRDC(:,1));
    timevec_monthly = datevec(timenum_monthly);
    yyyy_climate_GloFAS = unique(timevec_monthly(:,1));
    yyyy_climate_GloFAS(yyyy_climate_GloFAS==0) = [];
    
    for i = 1:12
        index_GRDC = find(timevec_GRDC(:,2) == i);
        dis_climate_GRDC(i) = nanmean(dis_GRDC(index_GRDC));

        index_GloFAS = find(timevec_monthly(:,2) == i);
        dis_climate_GloFAS(i) = nanmean(dis_GloFAS_monthly_total(index_GloFAS));
    end
    
    subplot(2,2,2); hold on; grid on;
    p1 = plot(1:12, dis_climate_GloFAS, 'b', 'LineWidth', 2);
    p2 = plot(1:12, dis_climate_GRDC, '--r', 'LineWidth', 2);

    xticks([1:12]);
    xlim([0 13]);
    ylim([0 max(dis_climate_GloFAS)+1200])
    
    xlabel('Month')
    ylabel('River discharge (m^3/s)');
    set(gca, 'FontSize', 12)

    l = legend([p1, p2], ...
        ['GloFAS (', num2str(yyyy_climate_GloFAS(1)), '-', num2str(yyyy_climate_GloFAS(end)),')'], ...
        ['GRDC (',  num2str(yyyy_climate_GRDC(1)), '-', num2str(yyyy_climate_GRDC(end)),')']);
    l.Location = 'NorthWest';
    
    title('Climate')

    set(gcf, 'Position', [0 0 1800 900]);
    set(gcf, 'PaperPosition', [-4.9635 0.6979 18.4271 9.6042])
    set(gcf, 'PaperSize', [8.5000 11.0000])
    set(gcf, 'PaperPositionMode', 'auto');
    pause(3)
    print(strcat('Compare_GloFAS_GRDC_', river_name),'-dpng');
end % fi_GRDC
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare GloFAS to SAEM
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
yyyy_all = [2019:2022]';

SAEM_filepath = '/data/jungjih/Observations/SAEM/';
SAEM_filename = 'dis_2901201.mat';
GloFAS_filepath = '/data/jungjih/Models/GloFAS/daily/';
station_name = 'Snezhnoye';
river_name = 'Anadyr';
%

f = figure; hold on
set(gcf, 'Position', [1 200 1300 900])
t = tiledlayout(2,2);

SAEM_file = [SAEM_filepath, SAEM_filename];
SAEM = load(SAEM_file);

timenum_SAEM = SAEM.timenum;
timevec_SAEM = datevec(timenum_SAEM);
index = find(ismember(timevec_SAEM(:,1), yyyy_all) == 1);
timenum_SAEM = SAEM.timenum(index);
timevec_SAEM = datevec(timenum_SAEM);

lon_SAEM = SAEM.lon;
lat_SAEM = SAEM.lat;
dis_SAEM = SAEM.dis(index);

nexttile(1); hold on
plot_map('Gulf_of_Anadyr_west', 'mercator', 'l');
plotm(lat_SAEM, lon_SAEM,'xr', 'LineWidth', 4, 'MarkerSize', 15)
plabel('FontSize', 12)
mlabel('FontSize', 12)
title(['(a) Station location (', station_name, ')'], 'FontSize', 15)

yearnums = [0; cumsum(yeardays(yyyy_all))];
dis_GloFAS_total = zeros(yearnums(end),1);
timenum_total = zeros(yearnums(end),1);
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    GloFAS_filenames = dir([GloFAS_filepath, ystr, '/*.nc']);
    if isempty(GloFAS_filenames)
        continue
    end

    GloFAS_file = [GloFAS_filepath, ystr, '/', GloFAS_filenames(1).name];
    lon_GloFAS = ncread(GloFAS_file,'lon');
    lat_GloFAS = ncread(GloFAS_file,'lat');
    [lat2,lon2] = meshgrid(lat_GloFAS,lon_GloFAS);

    dist = distance(lat_SAEM, lon_SAEM, lat2, lon2);
    [I,J] = find(dist == min(dist,[],'all'));

    daynums = [0, cumsum(eomday(yyyy,1:12))];
    dis_GloFAS_yyyy = zeros(yeardays(yyyy), 1);
    timenum_yyyy = zeros(yeardays(yyyy),1);
    for fi_GloFAS = 1:length(GloFAS_filenames)
        GloFAS_filename = GloFAS_filenames(fi_GloFAS).name;
        GloFAS_file = [GloFAS_filepath, ystr, '/', GloFAS_filename];
        mm_str = GloFAS_filename(17:18);
        GloFAS_time_ref = datenum(yyyy,str2num(mm_str),1);
        time_GloFAS = ncread(GloFAS_file,'time');
        timenum_GloFAS = GloFAS_time_ref + time_GloFAS/24;
        timevec_GloFAS = datevec(timenum_GloFAS);
        dis_GloFAS_around = ncread(GloFAS_file,'dis24',[I-1 J-1 1], [3 3 Inf]);
        dis_GloFAS_around_sum = squeeze(sum(dis_GloFAS_around,3));
        [II,JJ] = find(dis_GloFAS_around_sum==max(dis_GloFAS_around_sum,[],'all'));
        if length(II) > 1
            II = II(1); JJ = JJ(1);
        end
        dis_GloFAS = squeeze(dis_GloFAS_around(II,JJ,:));

        daynum = (daynums(fi_GloFAS)+1):daynums(fi_GloFAS+1);
        dis_GloFAS_yyyy(daynum) = dis_GloFAS;
        timenum_yyyy(daynum) = timenum_GloFAS;
    end % fi_GloFAS
    yearnum = (yearnums(yi)+1):yearnums(yi+1);
    dis_GloFAS_total(yearnum) = dis_GloFAS_yyyy;
    timenum_total(yearnum) = timenum_yyyy;
    disp([river_name, ' ' ,ystr, '/', num2str(yyyy_all(end)), '...'])
end % yi

nexttile(3, [1 2]); hold on; grid on
p1 = plot(timenum_total, dis_GloFAS_total, '-k', 'LineWidth', 2);
p2 = plot(timenum_SAEM, dis_SAEM, 'or', 'LineWidth', 2);

xticks(datenum(2019:2022,1,1));
xlim([datenum(2019,1,1)-1 datenum(2022,12,31)+1])
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits');
xlabel('Date')
ylabel('m^3/s');
ylim([0 1e4]);

l = legend([p1, p2], 'GloFAS daily', 'SAEM daily');
l.Location = 'NorthEast';
l.FontSize = 12;

set(gca, 'FontSize', 12)
title('(c) Comparison of daily river discharge', 'FontSize', 15)

% Seasonal variability
nexttile(2); hold on; grid on
timevec_GloFAS = datevec(timenum_total);

dis_climate = NaN(12,1);
dis_std = NaN(12,1);
for mi = 1:12
    mm = mi;
    index = find(timevec_GloFAS(:,2) == mm);
    dis_climate(mi) = mean(dis_GloFAS_total(index));
    dis_std(mi) = std(dis_GloFAS_total(index));
end
plot(1:12, dis_climate, '-ko', 'LineWidth', 2);
xlim([0.5 12.5])
ylim([0 6000])
xticks(1:12)
xlabel('Month')
ylabel('m^3/s')
set(gca, 'FontSize', 12)
title('(b) Four-year mean GloFAS monthly discharge', 'FontSize', 15)

t.Padding = 'compact';
t.TileSpacing = 'compact';
dfdf

index = find(isnan(dis_SAEM) == 0);
vari_diff = dis_GloFAS_total(index) - dis_SAEM(index);
bias = mean(vari_diff);
rmse = sqrt( mean( vari_diff.^2 ) );
[R,P] = corrcoef(dis_GloFAS_total(index),dis_SAEM(index));

print(strcat('Compare_GloFAS_SAEM_', river_name),'-dpng');
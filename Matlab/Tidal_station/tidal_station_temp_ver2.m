%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot tidal station temperature
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all
%% File
filepath = '.\';
filename = ['sample_temp_ver2.txt'];
file = [filepath, filename];

%% Set the target year
year_list = [2013:2013];

%% Read all data
[num, yyyymmdd, hh, temp] = textread(file, '%d %s %s %f', 'headerlines', 6);
yyyymmdd = cell2mat(yyyymmdd);
yyyy = yyyymmdd(:, 1:4);
mm = yyyymmdd(:,6:7);
dd = yyyymmdd(:, 9:10);

%% Calculate entire daily mean (_e means entire)
mmdd_e = str2num([mm, dd]);
data_e = [mmdd_e, temp];
datenum_e = datenum(2012, str2num(mm), str2num(dd));

mmdd_e_u = unique(mmdd_e); % _u means unique
data_e_mean = [];
for i = 1:length(mmdd_e_u)
    ind = find(mmdd_e == mmdd_e_u(i));
    data_e_mean = [data_e_mean; mean(datenum_e(ind)) mean(data_e(ind, 2))];
end

%% Calculate target year daily mean (_t means target)
for yi = 1:length(year_list)
    
    yi_t = find(str2num(yyyy) == year_list(yi));
    yyyy_t = yyyy(yi_t, :);
    mm_t = mm(yi_t, :);
    dd_t = dd(yi_t, :);
    temp_t = temp(yi_t, :);
    
    mmdd_t = str2num([mm_t, dd_t]);
    data_t = [mmdd_t, temp_t];
    datenum_t = datenum(2012, str2num(mm_t), str2num(dd_t));
    
    mmdd_t_u = unique(mmdd_t);
    data_t_mean = [];
    
    for ii = 1:length(mmdd_t_u)
        ind2 = find(mmdd_t == mmdd_t_u(ii));
        data_t_mean = [data_t_mean; mean(datenum_t(ind2)) mean(data_t(ind2, 2))];
    end

    %% Plot
    figure; hold on;
    plot(data_e_mean(:,1), data_e_mean(:,2), '.k', 'MarkerSize', 15)
    plot(data_t_mean(:,1), data_t_mean(:,2), '.r', 'MarkerSize', 15)
    
    datetick('x', 'mm')
    xlabel('Month'); ylabel('Temperature')
    set(gca, 'fontsize', 15)
    ylim([0 30])
    legend([yyyy(1,:), '-', yyyy(end,:)], yyyy_t(1,:), 'location', 'NorthWest')
    
end
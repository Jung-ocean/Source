clear; clc; close all

%targetline = '205';
%targetpoint = {'00', '05'};
targetline = '400';
targetpoint = {'00', '13'};

year_all = [2006:2015];
month_all = [8];

fpath = 'D:\Data\Ocean\KODC\excel\';
figpath = 'D:\Data\Ocean\KODC\KODC_';
titletype = [''];

% Temp
variindex = 12;
vari = 'temp';
colorbarname = '^oC';
colormap_style = 'parula';

for yi = 1:length(year_all)
    year = year_all(yi); ystr = num2str(year);
    fname = [fpath, 'KODC_', ystr, '.xls'];
    
    [num, raw, txt] = xlsread(fname);
    
    obsline = txt(3:end,2); obspoint = txt(3:end,3);
    lat = txt(3:end, 5); lon = txt(3:end, 6);
    date = datenum(txt(3:end, 7));
    dep = txt(3:end, 8);
    temp = txt(3:end, 9);
    salt = txt(3:end, 11);
    
    data_cell = [obsline obspoint lat lon dep temp salt];
    datasize = size(data_cell);
    
    clearvars data
    for i = 1:datasize(1)
        for j = 1:datasize(2)
            if isempty(cell2mat(data_cell(i,j))) == 1
                data(i,j) = NaN;
            else
                data(i,j) = str2num(cell2mat(data_cell(i,j)));
            end
        end
    end
    
    data_all = [datevec(date) data];
    
    for mi = 1:length(month_all)
        month = month_all(mi); mstr = num2char(month,2);
        
        coastalindex = find(strcmp(obsline, targetline) == 1 & strcmp(obspoint,targetpoint{1}) == 1 & data_all(:,2) == month);
        offshoreindex = find(strcmp(obsline, targetline) == 1 & strcmp(obspoint,targetpoint{2}) == 1 & data_all(:,2) == month);
        
        if isempty(coastalindex)
            coastalindex = find(strcmp(obsline, targetline) == 1 & strcmp(obspoint,targetpoint{1}) == 1 & data_all(:,2) == month+1);
        end
        
        if isempty(offshoreindex)
            offshoreindex = find(strcmp(obsline, targetline) == 1 & strcmp(obspoint,targetpoint{2}) == 1 & data_all(:,2) == month+1);
        end
        
        coastal_data = data_all(coastalindex,:);
        offshore_data = data_all(offshoreindex,:);
        
        coastal_surf_ind = find(coastal_data(:,11) == min(coastal_data(:,11)));
        coastal_bot_ind = find(coastal_data(:,11) == max(coastal_data(:,11)));
        
        offshore_surf_ind = find(offshore_data(:,11) == min(offshore_data(:,11)));
        
        coastal_surf_temp = coastal_data(coastal_surf_ind(1),variindex);
        coastal_bot_temp = coastal_data(coastal_bot_ind(1),variindex);
        offshore_surf_temp = offshore_data(offshore_surf_ind(1),variindex);
        
        UI(yi) = (offshore_surf_temp - coastal_surf_temp) / (offshore_surf_temp - coastal_bot_temp);
        SST_diff(yi) = (offshore_surf_temp - coastal_surf_temp);
    end
    
end

figure; hold on; grid on
plot(year_all, SST_diff, '-o', 'LineWidth', 2)
xlim([2005 2016])
xticks([2007:2:2015])
ylabel('^oC');
xlabel('Year');
title('SST diff. in August (Offshore - Coastal)')
set(gca, 'FontSize', 15)
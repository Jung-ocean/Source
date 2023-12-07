clear; clc; close all

year_all = [1980:2020];
month_all = [2:2:12];
depth_all = [0];

point_all = [30910, 20505, 10411];
title_all = {'황해', '남해', '동해'};

fpath = 'D:\Data\Ocean\KODC\excel\';
%figpath = 'D:\Data\Ocean\KODC\KODC_';
figpath = fpath;
titletype = [''];

for ts = 1:1
    if ts == 1
        variindex = 12;
        clim = [10 30];
        contour_interval = [clim(1):2:clim(2)];
        vari = 'temp';
        colorbarname = '^oC';
        colormap_style = 'parula';
    elseif ts == 2
        variindex = 13;
        clim = [30 35];
        contour_interval = [clim(1):.5:clim(2)];
        vari = 'salt';
        colorbarname = 'g/kg';
        colormap_style = 'jet';
    elseif ts == 3
        clim = [18 28];
        contour_interval = [clim(1):1:clim(2)];
        vari = 'density';
        colorbarname = '\sigma_t';
        colormap_style = 'parula';
    end
    
    data_point = [];
    for yi = 1:length(year_all)
        year = year_all(yi); ystr = num2str(year)
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
            
            for di = 1:length(depth_all)
                depth = depth_all(di);
                if depth > 99; charnum = 3; else; charnum = 2; end
                dstr = num2char(depth, charnum);
                
                index1 = find(data_all(:,2) == month & data_all(:,11) == depth);
                index2 = find(data_all(:,2) == month+1 & data_all(:,11) == depth);
                
                index = sort([index1; index2]);
                
                data_target = data_all(index,:);
                
                nanind = find(isnan(mean(data_target,2)) == 1);
                data_target(nanind,:) = [];
           
                for pi = 1:length(point_all)
                    point = point_all(pi);
                    index = find(data_target(:,7) == floor(point/100) & data_target(:,8) == point - 100*floor(point/100));
                    
                    data_point = [data_point; data_target(index,:)];
                end
            end
        end
        %close all
    end
end

for pi = 1:length(point_all)
    point = point_all(pi); pstr = num2str(point);
    index = find(data_point(:,7) == floor(point/100) & data_point(:,8) == point - 100*floor(point/100));
    
    data_point_specific = data_point(index,:);
        
    year_all = data_point_specific(:,1);
    datenum_zero = [0*data_point_specific(:,1) data_point_specific(:,2:3)];
    datenum_Julian = datenum(datenum_zero);
    
    temp_all = data_point_specific(:,12);
    
    temp_monthly = [];
    for mi = 1:length(month_all)
        month = month_all(mi);
        index = find(data_point_specific(:,2) == month | data_point_specific(:,2) == month+1);
        temp_monthly(mi) = mean(data_point_specific(index,12));
    end
    datenum_monthly = datenum(0,2:2:12,15);

    figure; hold on; grid on
    h = plot(datenum_monthly, temp_monthly, '-', 'Color', [.7 .7 .7], 'LineWidth', 5);
    scatter(datenum_Julian, temp_all, 20, year_all, 'filled');
    
    set(gca, 'Xtick', datenum_monthly)
    datetick('x', 'mm', 'keepticks')
    xlim([1 395])
    ylim([0 40])
    
    ylabel('표층 수온 (^oC)')
    xlabel('월')
    
    title([title_all{pi}, '(', pstr(1:3), ' - ', pstr(4:5), ')'])
    
    set(gca, 'FontSize', 20)
    
    l = legend(h, '기간 평균(1980 - 2020) 표층 수온');
    l.Location = 'NorthWest';
    l.FontSize = 15;
    
    colormap('jet')
    c = colorbar;
    c.Title.String = '년도';
    c.FontSize = 15;
    
    saveas(gcf, [pstr, '.png'])
        
end

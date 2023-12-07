clear; clc; close all

%load bfreq.mat
%year_all = yyyy_wstrati;

year_all = [1970:2019];

month_all = [8];
%depth_all = [0 10 20 30 50 75 100 125 150];
depth_all = [0];

fpath = 'D:\Data\Ocean\KODC\excel\';
figpath = 'D:\Data\Ocean\KODC\KODC_';

data_all = [];
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
    
    data_year = [datevec(date) data];
    data_all = [data_all; data_year];
    
end

index = find(isnan(mean(data_all,2)) == 1);
data_all(index,:) = [];

line_all = data_all(:,7)*100 + data_all(:,8);
line_list = unique(line_all);

data_avg = [];
for di = 1:length(depth_all)
    depth = depth_all(di);
    for li = 1:length(line_list)
        line = line_list(li);
        for  mi = 1:length(month_all)
            month = month_all(mi);
            index1 = find(data_all(:,2) == month & data_all(:,11) == depth & line_all == line);
            index2 = find(data_all(:,2) == month+1 & data_all(:,11) == depth & line_all == line);
            index = [index1; index2];
            
            data_tmp = nanmean(data_all(index,:),1);
            data_tmp(:,2) = month;
            
            if isnan(sum(sum(data_tmp))) == 1
            else
                data_avg = [data_avg; data_tmp];
            end
                        
        end
    end
end

%save data_avg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot tidal station temperature
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all
%% File
filepath = 'D:\Data\Ocean\조위관측소\수온\';
filename = '여수_2013-01_2013-12.txt';
file = [filepath, filename];

%% Read all data as string
[num, yyyymmdd, hhhh, temp, salt] = textread(file, '%s %s %s %s %s', 'headerlines', 6);
data1 = [num, yyyymmdd, hhhh, temp, salt];

%% Set file date
yyyymmdd = cell2mat(data1(:,2));
yyyy = str2num(yyyymmdd(:,1:4)); 
mm = str2num(yyyymmdd(:,6:7));
dd = str2num(yyyymmdd(:,9:10));

hhhh = cell2mat(data1(:,3));
hh = str2num(hhhh(:,1:2));

date = datenum(yyyy,mm,dd,hh,0,0); % File date

%% Set file temperature
temp_cell = data1(:,4);
for i = 1:length(data1)
    if strcmp(temp_cell(i), '-') % If temperature is '-', replace it as 'NaN'
        temp_num(i,:) = NaN;
    else
        temp_num(i,:) = str2num(cell2mat(temp_cell(i)));
    end
end

temperature = temp_num; % Temperature

%% Plot
plot(date, temperature, '.k')
datetick('x', 'mm')
xlabel('Month', 'fontsize', 15); ylabel('Temperature', 'fontsize', 15);
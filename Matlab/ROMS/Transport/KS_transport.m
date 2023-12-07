clear; clc

ty = 2001; % target year
tm = 1:12; % target month

data = load('D:\Data\Ocean\Transport\ADCP\obs_tsushima_200407_201512_ORIGIN.DAT');

trans = data(:,4);
yyyy = data(:,5);
mm = data(:,6);

trans_monthly = zeros;
for mi = 1:length(tm)
    ind = find(yyyy == ty & mm == tm(mi));
    trans_monthly(:,mi) = mean(trans(ind));
end
clear; clc

nline = 10300;
depth = 0;
month = 4;

prefile = ['D:\Data\Ocean\KODC\KODC1980~2012.txt'];
pre = load(prefile);

pre_st = pre(:,1);
pre_depth = pre(:,6);
pre_index = find(pre(:,1) == nline & pre(:,6) == depth);
pre_temp = pre(pre_index,7);
pre_mean = mean(pre_temp)

aftfile = ['D:\Data\Ocean\KODC\KODC1961-2015.txt'];
aft = load(aftfile);

aft_st = aft(:,1);
aft_depth = aft(:,5);
aft_date = aft(:,2);
aft_date_str = num2str(aft_date);
aft_month = str2num(aft_date_str(:,5:6));
aft_index = find(aft_st == nline & aft_depth >= depth & aft_depth < depth+10 & aft_month == month);
aft_temp = aft(aft_index,6);
aft_mean = mean(aft_temp)
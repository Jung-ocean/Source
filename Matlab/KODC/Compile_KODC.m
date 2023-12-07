clear; clc

Data_all = [];

file_61to11 = ['D:\Data\Ocean\KODC\용엽쓰\KODC\kodc_hydro.dat'];
data_61to11 = load(file_61to11);
st_61to11 = data_61to11(:,4)*100 + data_61to11(:,5);
datenum_61to11 = datenum(data_61to11(:,1), data_61to11(:,2), data_61to11(:,3));
date_61to11 = str2num(datestr(datenum_61to11, 'yyyymmdd'));
Lon_61to11 = data_61to11(:,7);
Lat_61to11 = data_61to11(:,6);
depth_61to11 = data_61to11(:,8);
temp_61to11 = data_61to11(:,9);
salt_61to11 = data_61to11(:,10);

Data_all = [Data_all; st_61to11 date_61to11 Lon_61to11 Lat_61to11 depth_61to11 temp_61to11 salt_61to11];

file_12 = ['D:\Data\Ocean\KODC\1980~2012\KODC2012.txt'];
data_12 = load(file_12);
st_12 = data_12(:,1);
date_12 = data_12(:,2);
Lon_12 = data_12(:,4);
Lat_12 = data_12(:,5);
depth_12 = data_12(:,6);
temp_12 = data_12(:,7);
salt_12 = data_12(:,8);

Data_all = [Data_all; st_12 date_12 Lon_12 Lat_12 depth_12 temp_12 salt_12];

file_13 = ['G:\Research\여름철 수온 저온화현상\result data\KODC2013.txt'];
data_13 = load(file_13);

Data_all = [Data_all; data_13];

file_14 = ['G:\Research\여름철 수온 저온화현상\result data\KODC2014.txt'];
data_14 = load(file_14);

Data_all = [Data_all; data_14];

file_15 = ['G:\Research\여름철 수온 저온화현상\result data\KODC2015.txt'];
data_15 = load(file_15);

Data_all = [Data_all; data_15];

fid = fopen(['KODC1961-2015.txt'],'w');
fprintf(fid,'%s', '% ST  yyyymmdd    LON         LAT    DEP  Temp       Salt ');
fprintf(fid,'\n');
 for j = 1:length(Data_all)
     fprintf(fid, '%d %d %10f %10f %3d %10f %10f',Data_all(j,:));
     fprintf(fid,'\n');
 end
 fclose(fid);

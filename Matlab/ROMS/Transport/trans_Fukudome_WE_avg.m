[num, raw] = xlsread('D:\Data\Ocean\Transport\ADCP\obs_tsushima_197001_201209_ORIGIN.xls');

yyyy_F1 = num(:,1);
mm_F1 = num(:,2);

trans_west1 = num(:,3);
trans_east1 = num(:,4);
trans_total1 = num(:,5);

data = load('D:\Data\Ocean\Transport\ADCP\obs_tsushima_200407_201512_ORIGIN.DAT');

trans_west2 = data(:,2);
trans_east2 = data(:,3);
trans_total2 = data(:,4);
yyyy_F2 = data(:,5);
mm_F2 = data(:,6);

for i = 1:12
    index1 = find(mm_F1 == i);
    index2 = find(mm_F2 == i);
    trans_west12 = [trans_west1(index1); trans_west2(index2)];
    trans_east12 = [trans_east1(index1); trans_east2(index2)];
    trans_total12 = [trans_total1(index1); trans_total2(index2)];
    
    trans_FW(i) = nanmean(trans_west12);
    trans_FE(i) = nanmean(trans_east12);
    trans_FT(i) = nanmean(trans_total12);
end
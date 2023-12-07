data1 = load('D:\Data\Ocean\Transport\transport_Fukudome.txt');

trans1 = data1(:,3);
yyyy_F1 = data1(:,1);
mm_F1 = data1(:,2);

data2 = load('D:\Data\Ocean\Transport\ADCP\obs_tsushima_200407_201512_ORIGIN.DAT');

trans2 = data2(:,4);
yyyy_F2 = data2(:,5);
mm_F2 = data2(:,6);

for i = 1:12
    index1 = find(mm_F1 == i);
    index2 = find(mm_F2 == i);
    trans12 = [trans1(index1); trans2(index2)];
    trans_F(i) = nanmean(trans12);
end
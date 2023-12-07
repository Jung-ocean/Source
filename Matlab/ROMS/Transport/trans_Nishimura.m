data = load('D:\Data\Ocean\Transport\transport_Nishimura.dat');

trans = data(:,2);
yyyy_N = data(:,1);

ind = find(yyyy_N == ty);
trans_N = trans(ind);

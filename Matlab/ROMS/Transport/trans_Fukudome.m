if ty <= 2006
    data = load('D:\Data\Ocean\Transport\transport_Fukudome.txt');
    
    trans = data(:,3);
    yyyy_F = data(:,1);
    
    ind = find(yyyy_F == ty);
    trans_F = trans(ind);
    
elseif ty > 2006
    
    data = load('D:\Data\Ocean\Transport\ADCP\obs_tsushima_200407_201512_ORIGIN.DAT');
    
    trans = data(:,4);
    yyyy_F = data(:,5);
    mm = data(:,6);
    
    ind = find(yyyy_F == ty);
    
    mm = mm(ind);
    trans_yyyy = trans(ind);
    
    for i = 1:12
        monthly = find(mm == i);
        trans_F(i) = mean(trans_yyyy(monthly));
    end
    trans_F = trans_F';
    
end
if ty <= 2006
    [num, raw] = xlsread('D:\Data\Ocean\Transport\ADCP\obs_tsushima_197001_201209_ORIGIN.xls');
    
    trans_west = num(:,3);
    trans_east = num(:,4);
    trans_total = num(:,5);
    
    yyyy_F = num(:,1);
    
    ind = find(yyyy_F == ty);
    trans_FW = trans_west(ind);
    trans_FE = trans_east(ind);
    trans_FT = trans_total(ind);
    
elseif ty > 2006
    
    data = load('D:\Data\Ocean\Transport\ADCP\obs_tsushima_200407_201512_ORIGIN.DAT');
    
    trans_west = data(:,2);
    trans_east = data(:,3);
    trans_total = data(:,4);
    yyyy_F = data(:,5);
    mm = data(:,6);
    
    ind = find(yyyy_F == ty);
    
    mm = mm(ind);
    
    trans_FWyyyy = trans_west(ind);
    trans_FEyyyy = trans_east(ind);
    trans_FTyyyy = trans_total(ind);
    
    for i = 1:12
        monthly = find(mm == i);
        
        trans_FW(i) = mean(trans_FWyyyy(monthly));
        trans_FE(i) = mean(trans_FEyyyy(monthly));
        trans_FT(i) = mean(trans_FTyyyy(monthly));
    end
    trans_FW = trans_FW';
    trans_FE = trans_FE';
    trans_FT = trans_FT';
    
end
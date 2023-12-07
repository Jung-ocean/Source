clear; clc; warning off

fpath = 'D:\Data\Ocean\KODC\re_position\';
filename = dir(fullfile(fpath,'*.txt'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
year = [1980:2015];
Depth_all = [100]; % depth setting
Month_all = [10 12]; % month setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for di = 1:length(Depth_all)
    depth = Depth_all(di);
    if depth > 99
        charnum = 3;
    else
        charnum = 2;
    end
    
for mi = 1:length(Month_all)
    month = Month_all(mi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(filename)

    [ST, Date, LON, LAT, Dep, Temp, Salt] = textread([fpath, filename(i).name], '%d %d %f %f %d %f %f');
    Data_all = [ST, Date, LON, LAT, Dep, Temp, Salt];
    chk_index = find(LON == 0);
    Data_all(chk_index,:) = [];
        
    ST = Data_all(:,1); Date = Data_all(:,2); LON = Data_all(:,3);
    LAT = Data_all(:,4); Dep = Data_all(:,5); Temp = Data_all(:,6); Salt = Data_all(:,7);
    
    Temp(Temp == 0) = NaN;
    Temp(Temp > 45) = NaN;
    
    index = find(depth <= Dep & Dep < depth + 10);
        
    date = Date(index);
    temp = Temp(index);
    salt = Salt(index);
    
    for ii = 1:length(year)
        
        year_index = find(date > year(ii)*10000+month*100 & date < year(ii)*10000+(month+1)*100);
        
        try
            temp_re(ii) = temp(year_index);
            salt_re(ii) = salt(year_index);
        catch
            temp_re(ii) = NaN;
            salt_re(ii) = NaN;
        end         
    end
        
    try 
       st(i) = ST(1);
       avg_temp(i) = nanmean(temp_re);
       avg_salt(i) = nanmean(salt_re);
    catch
       st(i) = NaN;
       avg_temp(i) = NaN;
       avg_salt(i) = NaN;
    end
         
end

temp_index1 = find(avg_temp == 0);
temp_index2 = find(isnan(avg_temp) == 1);
temp_index = sort([temp_index1,temp_index2]);

salt_index1 = find(avg_salt == 0);
salt_index2 = find(isnan(avg_salt) == 1);
salt_index = sort([salt_index1, salt_index2]);
ts_index = unique([temp_index salt_index]);

st(ts_index) = []; avg_temp(ts_index) = []; avg_salt(ts_index) = [];

[ST_ LAT_ LON_] = textread('NSOposition.txt','%s %f %f','headerlines',1);
ST_ = str2mat(ST_); ST_ = str2num(ST_(:,[1:3,5:6]));
for i = 1:length(st)
    index = find(st(i) == ST_);
    lon(i) = LON_(index); lat(i) = LAT_(index);
end

fid = fopen([num2char(depth,charnum),'m_',num2char(month,2),'_mean.txt'],'w');
for i = 1:length(st)
    fprintf(fid, '%d %f %f %f %f',st(i), lon(i), lat(i), avg_temp(i), avg_salt(i));
    fprintf(fid,'\n');
end
fclose(fid);

fprintf('%s', ['complete',num2char(depth,charnum), 'm_',num2char(month,2)])
fprintf('\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
end
clear; clc
warning off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Year_all = [2001:2015];
Depth_all = [0 50 100]; % depth setting
Month_all = [2:2:12]; % month setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fpath = ['D:\Data\Ocean\KODC\'];
fname = ['KODC1961-2015.txt'];

Data_all = load([fpath, fname]);

ST = Data_all(:,1); Date = Data_all(:,2);
LON = Data_all(:,3); LAT = Data_all(:,4);
Dep = Data_all(:,5); Temp = Data_all(:,6); Salt = Data_all(:,7);

for yi = 1:length(Year_all)
    year = Year_all(yi);
    folder = ['KODC_',num2char(year,4)];
    %mkdir(folder)
for di = 1:length(Depth_all)
    depth = Depth_all(di);
    if depth > 99
        charnum = 3;
    else
        charnum = 2;
    end
    
    dind = find(depth <= Dep & Dep < depth + 10); % specific depth
    st = ST(dind); date = Date(dind); lon = LON(dind); lat = LAT(dind);
    dep = Dep(dind); temp = Temp(dind); salt = Salt(dind);
    
    for mi = 1:length(Month_all)
        month = Month_all(mi);
        
        year_index = find(date>year*10000+month*100 & date<year*10000+(month+1)*100);
        
        st_ = st(year_index); date_ = date(year_index); lon_ = lon(year_index); 
        lat_ = lat(year_index); dep_ = dep(year_index); temp_ = temp(year_index); salt_ = salt(year_index);
        
        fid = fopen([fpath, folder,'\',num2char(depth,charnum),'m_',num2char(month,2),'_',num2char(year,4),'.txt'],'w');
        for j = 1:length(st_)
        fprintf(fid, '%d %f %f %f %f',st_(j), lon_(j), lat_(j), temp_(j), salt_(j));
        fprintf(fid,'\n');
        end
        fclose(fid);
    end
    
end
end
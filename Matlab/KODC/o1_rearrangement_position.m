clear; clc

re_posit_path = ['G:\Research\여름철 수온 저온화현상\result data\re_position\'];
fpath = ['G:\Research\여름철 수온 저온화현상\result data\'];
fname = ['KODC1961-2015.txt'];

Data_all = load([fpath, fname]);

ST = Data_all(:,1); Date = Data_all(:,2);
LON = Data_all(:,3); LAT = Data_all(:,4);
Dep = Data_all(:,5); Temp = Data_all(:,6); Salt = Data_all(:,7);

[ST_info] = textread('NSOposition.txt','%s %*[^\n]','headerlines',1);
ST_info = str2mat(ST_info); ST_info = ST_info(:,[1:3,5:6]);
ST_info = str2num(ST_info);

for i = 1:length(ST_info)
    fprintf('%s %d %s','processing',ST_info(i),'...')
    fprintf('\n')
    
    try
    
        index = find(ST == ST_info(i));
        ST_re = ST(index);
        Date_re = Date(index);
        LON_re = LON(index);
        LAT_re = LAT(index);
        Dep_re = Dep(index);
        Temp_re = Temp(index);
        Salt_re = Salt(index);
        
        rearrange = [ST_re Date_re LON_re LAT_re Dep_re Temp_re Salt_re];
        
        fid = fopen([re_posit_path, num2char(ST_info(i),5),'_re.txt'],'w');
        for j = 1:length(ST_re)
        fprintf(fid, '%d %d %f %f %d %f %f',rearrange(j,:));
        fprintf(fid,'\n');
        end
        fclose(fid);
        
    catch
    end
end
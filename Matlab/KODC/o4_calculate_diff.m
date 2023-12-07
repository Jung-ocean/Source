clear; clc

Year_all = [1980:2015];

path_mean = 'D:\Data\Ocean\KODC\avg_ts(1980_2015)\';
fname_mean = dir(fullfile(path_mean, '*.txt'));

for yi = 1:length(Year_all)
    path = ['D:\Data\Ocean\KODC\KODC_', num2char(Year_all(yi), 4),'\'];
    fname = dir(fullfile(path, '*.txt'));
    
for i = 1:length(fname)

    [ST_mean LON_mean LAT_mean Temp_mean Salt_mean] = textread([path_mean, fname_mean(i).name],'%d %f %f %f %f');
    [ST LAT LON Temp Salt] = textread([path, fname(i).name],'%d %f %f %f %f');
    
    for ii = 1:length(ST)
        index = find(ST(ii) == ST_mean);
        if ~isempty(index)
            Temp_diff(ii) = Temp(ii) - Temp_mean(index);
            Salt_diff(ii) = Salt(ii) - Salt_mean(index);
        else
            Temp_diff(ii) = NaN;
            Salt_diff(ii) = NaN;
        end
    end
    
    folder_name = ['TS_diff_', num2char(Year_all(yi),4)];
    mkdir(folder_name)
    fid_part = fname(i).name;
    fid = fopen([folder_name, '\', fid_part(1:end-4),'_diff.txt'],'w');
    for iii = 1:length(Temp_diff)
        fprintf(fid, '%d %f %f %f %f', ST(iii), LAT(iii), LON(iii), Temp_diff(iii), Salt_diff(iii));
        fprintf(fid, '\n');
    end
    fclose(fid);
    clear Temp_diff Salt_diff
end

end
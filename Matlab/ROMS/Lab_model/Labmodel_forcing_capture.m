clear; clc

year_all = 2012:2016;

for yi = 1:length(year_all)
    target_year = year_all(yi); ystr = num2str(target_year);
    yd = yeardays(target_year);
    
    rootpath = ['G:\backup', ystr, '\'];
    
    for i = 150:250
        daynum = datenum(target_year, 1, 1, 0, 0, 0) + i - 1;
        daystr = datestr(daynum, 'yyyymmddhh');
        fpath = [rootpath, daystr, '/'];
        fname = 'UM_yw3km_Uwind.nc';
        fname2 = 'UM_yw3km_Vwind.nc';
        %  fname3 = 'UM_yw3km_Tair.nc';
        %  fname4 = 'UM_yw3km_swrad.nc';
        target_file = [fpath, fname];
        target_file2 = [fpath, fname2];
        %  target_file3 = [fpath, fname3];
        %  target_file4 = [fpath, fname4];
        
        mkdir(daystr);
        
        try
            copyfile(target_file, ['./',daystr])
            copyfile(target_file2, ['./',daystr])
            %   copyfile(target_file3, ['./',daystr])
            %   copyfile(target_file4, ['./',daystr])
        catch
            disp(['No file on ', daystr])
        end
        
        
    end
end
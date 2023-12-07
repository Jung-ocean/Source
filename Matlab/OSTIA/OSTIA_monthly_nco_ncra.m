%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       OSTIA monthly mean temperature using nco_ncra
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

% Filepath
filepath = 'D:\Data\Satellite\OSTIA\';

yyyy_all = 2020;
mm_all = 1:12;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02.f');
        
        ddd = (datenum(yyyy,mm,1):datenum(yyyy,mm,eomday(yyyy,mm))) - datenum(yyyy,1,0);
        
        % Turn time into a record dimension (_time.nc files)
        for di = 1:length(ddd)
            File = dir([filepath, ystr, '\', num2str(ddd(di), '%03.f'), '\*.nc']);
            nco_ncks_time([File.folder, '\', File.name]);
        end
        
        % Delete .tmp files
        for di = 1:length(ddd)
            File = dir([filepath, ystr, '\', num2str(ddd(di), '%03.f'), '\*.tmp']);
            delete([File.folder, '\', File.name])
        end
        
        % NCRA
        Filelist = [];
        for di = 1:length(ddd)
            File = dir([filepath, ystr, '\', num2str(ddd(di), '%03.f'), '\*time*']);
            Filelists(di,:) = [File.folder, '\', File.name];
        end
        nco_ncra(Filelists, ['OSTIA_monthly_', ystr, mstr, '.nc'])
        
        % Delete _time.nc files
        for di = 1:length(ddd)
            File = dir([filepath, ystr, '\', num2str(ddd(di), '%03.f'), '\*time*']);
            delete([File.folder, '\', File.name])
        end
    end
end
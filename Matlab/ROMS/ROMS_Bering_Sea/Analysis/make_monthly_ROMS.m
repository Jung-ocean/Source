%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make ROMS monthly outputs using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2020:2020; % some missing 201906, 202011
month_avg = [11:11];
year_start = 2018;
month_start = 7;
filename_header = 'Dsm_1rnoff_';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath_daily = ['/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm1_rnoff/'];
    datenum_ref = datenum(1968,05,23);

    eomdays = eomday(yyyy,1:12);
    
    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        filenumbers = [datenum(yyyy,mm,1):datenum(yyyy,mm+1,1)-1] - datenum(year_start,month_start,1) + 1;
        for fi = 1:length(filenumbers)
            filenumber = filenumbers(fi); fstr = num2str(filenumber, '%04i');
            filename = dir([filepath_daily, '*avg*', fstr, '*']);
            if ~isempty(filename)
                command = ['ln -s ', filepath_daily, filename.name, ' ./'];
                system(command)
            end
        end
        
        command = ['ls *avg* | wc -l'];
        [status, nfile] = system(command);
        if str2num(nfile) == eomdays(mi)
            command = ['ncra *avg* ', filename_header, ystr, mstr, '.nc'];
            system(command)
        end
        
        command = ['rm -f *avg*'];
        system(command)

        disp([ystr, mstr, '...'])
    end
end
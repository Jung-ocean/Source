%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make ROMS monthly outputs using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2024:2024;
month_avg = [1:12];
refdate = datenum(2024,1,1);

filepath_daily = '/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Output/daily/';
filepath_monthly = '/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Output/monthly/';
cd(filepath_monthly);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        
        eomdays = eomday(yyyy,mm);
        filenumbers = [datenum(yyyy,mm,1):datenum(yyyy,mm+1,1)-1] - refdate + 1;
        for fi = 1:length(filenumbers)
            filenumber = filenumbers(fi);
            fstr = num2str(filenumber, '%04i');
            filename = ['ocean_avg_', fstr, '.nc'];
            file = [filepath_daily, filename];

            if ~isempty(file)
                command = ['ln -s ', file, ' ./'];
                system(command);
            end
        end
        
        command = ['ls *avg* | wc -l'];
        [status, nfile] = system(command);
        if str2num(nfile) == eomdays
            command = ['ncra *avg* ', 'monthly_', ystr, mstr, '.nc'];
            system(command)
        end
        
        command = ['rm -f *avg*'];
        system(command)

        disp([ystr, mstr, '...'])
    end
end
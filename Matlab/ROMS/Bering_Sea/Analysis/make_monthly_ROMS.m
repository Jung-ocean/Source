%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make ROMS monthly outputs using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2023:2023;
month_avg = [12:12];
year_start = 2018;
month_start = 7;
exp = 'Dsm4_mk2';
filename_header = 'Dsm4_mk2';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        
        eomdays = eomday(yyyy,mm);
        filenumbers = [datenum(yyyy,mm,1):datenum(yyyy,mm+1,1)-1] - datenum(year_start,month_start,1) + 1;
        for fi = 1:length(filenumbers)
            filenumber = filenumbers(fi);
            try
                file = get_ncfilename(exp, 'avg', filenumber);
            catch
                file = [];
            end

            if ~isempty(file)
                command = ['ln -s ', file, ' ./'];
                system(command);
                ot = ncread(file, 'ocean_time');
                if isempty(ot)
                    index = find(ismember(file, '/'));
                    filename = file(index(end)+1:end);
                    command = ['rm -f ', filename];
                    system(command);
                end
            end
        end
        
        command = ['ls *avg* | wc -l'];
        [status, nfile] = system(command);
        if str2num(nfile) == eomdays
            command = ['ncra *avg* ', filename_header, '_', ystr, mstr, '.nc'];
            system(command)
        end
        
        command = ['rm -f *avg*'];
        system(command)

        disp([ystr, mstr, '...'])
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make ROMS monthly outputs using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2018:2019;
month_avg = [1:12];
year_start = 2018;
month_start = 7;
exp = 'Dsm4_rh';
filename_header = 'Dsm4_phi3m1';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

%     filepath_daily = ['/data/sdurski/ROMS_BSf/Output/Ice/Winter_2018/', exp, '/Output/'];
    filepath_daily = ['/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/', exp, '/Output/'];
    datenum_ref = datenum(1968,05,23);

    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        eomdays = eomday(yyyy,mm);
        filenumbers = [datenum(yyyy,mm,1):datenum(yyyy,mm+1,1)-1] - datenum(year_start,month_start,1) + 1;
        for fi = 1:length(filenumbers)
            filenumber = filenumbers(fi); fstr = num2str(filenumber, '%04i');
            filename = dir([filepath_daily, '*', exp, '_avg*', fstr, '*']);
            if ~isempty(filename)
                command = ['ln -s ', filepath_daily, filename.name, ' ./', filename_header, '_', filename.name(end-10:end)];
                system(command)
            end
        end

        disp([ystr, mstr, '...'])
    end
end
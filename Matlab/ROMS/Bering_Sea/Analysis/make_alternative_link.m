function make_alternative_link(filepath, filename, filename_link)

fstr = filename(end-6:end-3);
fnum = str2num(fstr);
timenum = fnum + datenum(2018,7,1);
timevec = datevec(timenum);
yyyy = timevec(:,1);
ystr_m1 = num2str(yyyy-1);
ystr = num2str(yyyy);
ystr_p1 = num2str(yyyy+1);

if strcmp(filename(1:6), 'SumFal')
    filepath_new = replace(filepath, {'NoIce', 'SumFal', ystr}, {'Ice', 'Winter', ystr_m1});
    filename_new = replace(filename, {'SumFal', ystr}, {'Winter', ystr_m1});
else
    filepath_new = replace(filepath, {'Ice', 'Winter', ystr}, {'NoIce', 'SumFal', ystr});
    filename_new = replace(filepath, {'Winter', ystr}, {'SumFal', ystr});
end

file = dir([filepath_new, '/*', filename_new]);
command = (['ln -s ', filepath_new, '/', file.name, ' ./', filename_link]);
system(command);

disp(['from ', filename_new, ' to ', filename_link]);
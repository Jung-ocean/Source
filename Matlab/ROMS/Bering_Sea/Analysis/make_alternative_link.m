function make_alternative_link(filepath, filename, filename_link)

command = ['ls -ltrh ', filepath, filename];
[status, output] = system(command);
index1 = ismember(output, '/');
index2 = find(index1 == 1);
filename_origin = output(index2(end)+1:end);
filenum = str2num(filename_origin(end-7:end-3));
timenum = datenum(2018,7,1) + filenum;
timevec = datevec(timenum);
yyyy = timevec(1);
yyyy_m1 = yyyy-1;
yyyy_p1 = yyyy+1;
mm = timevec(2);
season = filename_origin(1:6);

if mm < 10 & strcmp(season, 'Winter')
    ystr = num2str(yyyy_p1);
elseif mm > 10 & strcmp(season, 'Winter')
    ystr = num2str(yyyy);
elseif mm < 10 & strcmp(season, 'SumFal')
    ystr = num2str(yyyy_m1);
elseif mm > 10 & strcmp(season, 'SumFal')    
    ystr = num2str(yyyy);
end

file_search = filename_origin(end-11:end-1);

if strcmp(season, 'Winter')
    filepath_alternative = ['/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_', ystr, '/'];
else
    filepath_alternative = ['/data/sdurski/ROMS_BSf/Output/Ice/Winter_', ystr, '/'];
end
command = ['find ', filepath_alternative, ' -name *', file_search];
[status, output] = system(command);
index1 = ismember(output, '/');
index2 = find(index1 == 1);
filename_new = output(index2(end)+1:end);
command = (['ln -s ', output(1:end-1), ' ./', filename_link]);
system(command);

disp(['from ', filename_origin, ' to ', filename_new]);
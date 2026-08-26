clear; clc

yyyy = 2024;

for di = 1:yeardays(yyyy)
    dstr = num2str(di, '%04i');
    timenum = datenum(yyyy,1,1) + di -1;
    yyyymmdd = datestr(timenum, 'yyyy.mm.dd');
    filename = ['ocean_avg_', dstr, '.nc'];

    link = ['https://s3.kopah.uw.edu/pm-share/jung2024/f', yyyymmdd, '/ocean_avg_0001.nc'];
    command = ['wget -O ', filename, ' ', link];
    [status, result] = system(command);
end
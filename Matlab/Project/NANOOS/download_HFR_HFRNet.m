clear; clc

yyyy = 2024;
ystr = num2str(yyyy);
timenum_start = datenum(yyyy,1,1);
timenum_end = datenum(yyyy,12,31);

for ti = timenum_start:timenum_end
    timenum = ti;
    yyyymm = datestr(timenum, 'yyyymm');
    yyyymmdd = datestr(timenum, 'yyyymmdd');

    link = ['https://www.ncei.noaa.gov/data/oceans/ioos/hfradar/rtv/', ystr, '/', yyyymm, '/USWC/', yyyymmdd, '1200_hfr_uswc_6km_rtv_uwls_25hr_average_SIO.nc'];
    command = ['wget ', link];
    system(command);
end
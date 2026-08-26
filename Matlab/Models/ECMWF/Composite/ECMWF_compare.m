clear; clc

filenum = '2';
vari = 'tp';
nc2017 = netcdf('ECMWF_Interim_tp_2017.nc');
time_2017 = nc2017{'time'}(:);
vari_2017 = nc2017{vari}(:);
vari_2017_scale_factor = nc2017{vari}.scale_factor(:);
vari_2017_add_offset = nc2017{vari}.add_offset(:);
vari_2017_unpacked = vari_2017.*vari_2017_scale_factor + vari_2017_add_offset;
close(nc2017)
vari_2017_unpacked_mean = mean(mean(vari_2017_unpacked,2),3);

time_re = zeros(length(time_2017),1);
vari_re = zeros(length(time_2017),1);
for mi = 1:12
    
    month = mi; tms = num2char(month,2);
    disp(['month = ', tms])
    
    filepath = 'D:\Data\Atmosphere\ECMWF_interim\2017\';
    filename = [tms, '-', filenum, '.nc'];
    file = [filepath, filename];
    
    nc = netcdf(file);
    vari_time = nc{'time'}(:);
    vari_raw = nc{vari}(:);
    vari_scale_factor = nc{vari}.scale_factor(:);
    vari_add_offset = nc{vari}.add_offset(:);
    close(nc)
    
    vari_unpacked = vari_raw.*vari_scale_factor + vari_add_offset;
    vari_unpacked_mean = mean(mean(vari_unpacked,2),3);
    
    for ti = 1:length(vari_time)
        tindex = find(vari_time(ti) == time_2017);
        time_re(tindex) = vari_time(ti);
        vari_re(tindex) = vari_unpacked_mean(ti);
    end
end

figure; hold on
plot(time_2017, vari_2017_unpacked_mean, '-k')
plot(time_re, vari_re, '--r')
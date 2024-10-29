clear; clc

yyyy_all = 2019:2022;
mm_all = 1:6;

filepath_all = ['/data/smithj28/Obersvations/Thin_ice/'];
bath_file = 'bathy_reg_BER.nc';
lon = ncread(bath_file, 'TLON');
lat = ncread(bath_file, 'TLAT');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath = [filepath_all, ystr, '/'];
    filename = [num2str(yyyy-1), '_', ystr, '_combined_thickness.mat'];
    file = [filepath, filename];
    data = load(file);

    timenum = datenum(data.thin_ice_data.dates);
    timevec = datevec(timenum);

    hice_thin_tmp = data.thin_ice_data.thickness.rect_lon_lat;

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        index = find(timevec(:,1) == yyyy & timevec(:,2) == mm);
        hice_thin = mean(hice_thin_tmp(:,:,index),3, 'omitnan');

        save(['hice_thin_', ystr, mstr, '.mat'], 'lon', 'lat', 'hice_thin')

        disp([ystr, mstr, '...'])
    end
end


    

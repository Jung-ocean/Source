clear; clc;

yyyy = 2016;
mm = 10;
dd = 2:8;

target_date = datenum(yyyy,mm,dd) - datenum(yyyy,1,1) + 1;

[target_lon, target_lat] = read_point_2017('2017');
num_data = length(target_lon);

nod = 1; % number of observation file at each DA step

filepath = 'D:\Data\Satellite\OSTIA\2016\001\';
filename = ['20160101-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc.bz2'];
[status, result] = unzip7([filepath, filename], filepath);
file = [filepath, filename(1:end-4)];

nc = netcdf(file);
Lat = nc{'lat'}(:);
Lon = nc{'lon'}(:);
close(nc); delete(file)
[lon2, lat2] = meshgrid(Lon, Lat);

for i=1:num_data
    
    Distance = dist([target_lon(i)' target_lat(i)'], [lon2(:)'; lat2(:)']);
    
    Dindex = find(Distance == min(Distance));
    ind_lon_tmp = find(Lon == lon2(Dindex));
    ind_lon(i) = ind_lon_tmp;
    ind_lat_tmp = find(Lat == lat2(Dindex));
    ind_lat(i) = ind_lat_tmp;
end

fid=fopen('kalman_loof.par','w+');
fprintf(fid,'total time roof\n');
filenum = 1;
for t = target_date(1):target_date(end)
    
    filepath = ['D:\Data\Satellite\OSTIA\2016\', num2char(t,3), '\'];
    filename = dir([filepath, '*.bz2']); filename = filename.name;
    [status, result] = unzip7([filepath, filename], filepath);
    file = [filepath, filename(1:end-4)];
    
    nc = netcdf(file);
    temp = nc{'analysed_sst'}(:);
    scale_factor = nc{'analysed_sst'}.scale_factor(:);
    add_offset = nc{'analysed_sst'}.add_offset(:);
    mask = nc{'mask'}(:);
    close(nc); delete(file)
    
    % Convert raw temperature -> Kelvin -> Celsius (with mask)
    temp_Kelvin = temp*scale_factor + add_offset;
    temp_Celsius = temp_Kelvin - add_offset;
    mask(mask ~= 1) = nan;
    temp_mask = temp_Celsius.*mask;
        
    for i = 1:num_data
        olon(i) = Lon(ind_lon(i));
        olat(i) = Lat(ind_lat(i));
        otemp(i) = temp_mask(ind_lat(i), ind_lon(i));
    end
    
    fprintf(fid,'%5d\n', nod);
    
    obsfile = ['obs_temp_', num2char(filenum, 4), '_', num2char(nod, 4), '.nc'];
    filenum = filenum + 1;
    
    nc_data_obs(obsfile,num_data);
    
    nc = netcdf(obsfile,'w');
    nc{'dindex'}(1,1:num_data) = 2;
    nc{'ixt'}(:) = 1:num_data;
    nc{'ndata'}(:) = num_data;
    nc{'rdepth'}(:) = zeros(1,num_data);
    nc{'rlon'}(1,1:num_data) = olon(1,1:num_data);
    nc{'rlat'}(1,1:num_data) = olat(1,1:num_data);
    nc{'obsdata'}(1,1:num_data) = otemp(1,1:num_data);
    nc{'obserr'}(1,1:num_data) = 0.1;
    close(nc)
end
fclose(fid);
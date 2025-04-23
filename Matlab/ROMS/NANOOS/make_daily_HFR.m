%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make daily averaged HF radar netcdf file
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2023:2024;
filepath = '/data/serofeev/RTDAOW2/Data/HFR/';

timenum_all = datenum(yyyy_all(1),1,1):datenum(yyyy_all(end),12,31);

lon_all = [];
lat_all = [];
for ti = 1:length(timenum_all)
    timenum = timenum_all(ti);
        
    filename = ['Q1W.', datestr(timenum, 'yyyy.mm.dd')];
    file = [filepath, filename];
    try
        data_tmp = importdata(file);
        data = data_tmp.data;

        lon = data(:,1);
        lat = data(:,2);
        u = data(:,4);
        v = data(:,5);

        lon_all = [lon_all; lon];
        lat_all = [lat_all; lat];
    catch

    end
end
coordinate = lon_all + i*lat_all;
coordinate_unique = unique(coordinate);
lon = real(coordinate_unique);
lat = imag(coordinate_unique);

mySchema.Name = '/';
mySchema.Format = 'classic';
mySchema.Dimensions(1).Name = 'time';
mySchema.Dimensions(1).Length = Inf;
mySchema.Dimensions(2).Name = 'data';
mySchema.Dimensions(2).Length = length(lon);

for ti = 1:length(timenum_all)
    timenum = timenum_all(ti);
        
    filename = ['Q1W.', datestr(timenum, 'yyyy.mm.dd')];
    file = [filepath, filename];
    
    u = NaN(length(coordinate_unique),1);
    v = NaN(length(coordinate_unique),1);
    try
        data_tmp = importdata(file);
        data = data_tmp.data;

        lon_tmp = data(:,1);
        lat_tmp = data(:,2);
        u_tmp = data(:,4);
        v_tmp = data(:,5);

        ll_complex = lon_tmp + i*lat_tmp;
        [Lia, Locb] = ismember(ll_complex, coordinate_unique); 
        
        u(Locb) = u_tmp;
        v(Locb) = v_tmp;

        ncfile = ['HFR_', datestr(timenum,'yyyymmdd'), '.nc'];
        ncwriteschema(ncfile ,mySchema)
        nccreate(ncfile, 'u', 'Dimensions', {'data'});
        ncwriteatt(ncfile,'u','description','Zonal velocity')
        ncwriteatt(ncfile,'u','unit','cm/s')
        nccreate(ncfile, 'v', 'Dimensions', {'data'});
        ncwriteatt(ncfile,'v','description','Meridional velocity')
        ncwriteatt(ncfile,'v','unit','cm/s')
        nccreate(ncfile, 'lon', 'Dimensions', {'data'});
        nccreate(ncfile, 'lat', 'Dimensions', {'data'});
        nccreate(ncfile, 'time', 'Dimensions', {'time'});
        ncwriteatt(ncfile,'time','description','Days since Jan 0, 0000')
        ncwriteatt(ncfile,'time','unit','days')

        ncwrite(ncfile, 'u', u);
        ncwrite(ncfile, 'v', v);
        ncwrite(ncfile, 'lon', lon);
        ncwrite(ncfile, 'lat', lat);
        ncwrite(ncfile, 'time', timenum);
    catch

    end
end

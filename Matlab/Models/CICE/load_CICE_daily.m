function [g, vari] = load_CICE_daily(vari_str, datenum_target)

% Load grid information
file = '/data/smithj28/CICE_output/Data/4km_data/seasons/2018_2019/2018-11-02-00000.nc';
aice = ncread(file, 'aice');
mask = aice;
mask(isnan(mask) == 0) = 1;
lon = ncread(file, 'TLON');
for i = 1:size(lon,1)
    lon(i,:) = mean(lon(i,:), 'omitnan');
end
lat = ncread(file, 'TLAT');
for j = 1:size(lat,2)
    lat(:,j) = mean(lat(:,j), 'omitnan');
end

area = ncread(file, 'tarea');
dy = mask.*4000;
pn = 1./dy;
dx = area./dy;
pm = 1./dx;

hfile = '/home/server/pi/homes/smithj28/Regional_CICE_setup/Grids/half_resolution_nomask/bathy_reg_BER.nc';
h = ncread(hfile, 'Bathymetry');

g.lon_rho = lon - 360;
g.lat_rho = lat;
g.pm = pm.*mask;
g.pn = pn.*mask;
g.mask_rho = mask;
g.h = h.*mask;

% Load variable
filepath_all = ['/data/smithj28/CICE_output/Data/4km_data/seasons/'];
timenum = datenum_target;
yyyy = str2num(datestr(timenum, 'yyyy'));
ystr = num2str(yyyy);
mm = str2num(datestr(timenum, 'mm'));
mstr = num2str(mm);
dd = str2num(datestr(timenum, 'dd'));
dstr = num2str(dd);
yyyymmdd = datestr(timenum, 'yyyy-mm-dd');

if mm < 11
    filepath_control = [filepath_all, num2str(yyyy-1), '_', ystr, '/'];
else
    filepath_control = [filepath_all, ystr, '_', num2str(yyyy+1), '/'];
end

filepattern_control = fullfile(filepath_control,(['*',yyyymmdd,'*.nc']));
filename_control = dir(filepattern_control);
if ~isempty(filename_control)
    file_control = [filepath_control, filename_control.name];
    vari = ncread(file_control, vari_str);
else
    vari = NaN.*g.mask_rho;
end

disp(['Loading CICE ', vari_str, ' ', yyyymmdd, '...'])

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Save OSTIA daily mean temperature as .mat file
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

casename = 'NWP';

% Map limit
[lon_lim, lat_lim] = domain_J(casename);
lim = [lon_lim lat_lim];


%% Setting
% Filepath
rootpath = 'D:\Data\Satellite\OSTIA\';

% Target date
target_year = 2016;
%target_month = 1;

%% Calculate mean temperature
% Find target path
targetpath = [rootpath, num2str(target_year), '\'];

dirlist = dir(targetpath);
dirlist(1:2) = [];

for di = 1:length(dirlist)
    
    filepath = [targetpath, num2char(di,3), '\'];
    filelist = dir(fullfile(filepath, '*.bz2'));
    filename = filelist.name;
    [status, result] = unzip7([filepath, filename], filepath);
    file = [filepath, filename(1:end-4)];
    
    % Read data from netcdf file
    nc = netcdf(file);
    temp = nc{'analysed_sst'}(:);
    scale_factor = nc{'analysed_sst'}.scale_factor(:);
    add_offset = nc{'analysed_sst'}.add_offset(:);
    Lat = nc{'lat'}(:);
    Lon = nc{'lon'}(:);
    mask = nc{'mask'}(:);
    close(nc)
    
    % Convert raw temperature -> Kelvin -> Celsius (with mask)
    temp_Kelvin = temp*scale_factor + add_offset;
    temp_Celsius = temp_Kelvin - add_offset;
    mask(mask ~= 1) = nan;
    temp_mask = temp_Celsius.*mask;
    
    lon_ind = find(Lon > lon_lim(1) -5 & Lon < lon_lim(2) + 5);
    lat_ind = find(Lat > lat_lim(1) -5  & Lat < lat_lim(2) + 5);
    
    Lon_selected = Lon(lon_ind);
    Lat_selected = Lat(lat_ind);
    temp_selected = temp_mask(lat_ind, lon_ind);
    
    
    temp_daily(di,:,:) = temp_selected;
    
    disp([num2char(di,3), ' ', file])
    delete(file)
end
   
%% Save as .mat file
save(['OSTIA_daily_', num2str(target_year), '.mat'], 'temp_daily', 'Lat_selected', 'Lon_selected');
disp([' End calculation ', num2char(target_year, 4)])
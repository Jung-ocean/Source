%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Save OSTIA monthly mean temperature as .mat file
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear; clc
%% Setting
% Filepath
rootpath = 'D:\Data\Satellite\OSTIA\';

% Target date
%target_year = 2013;
%target_month = 1;

%% Calculate mean temperature
% Make empty matrix
err_sum = zeros;

% Set the date
start_datenum = datenum(target_year, target_month,1) - datenum(target_year,1,1) + 1;
end_datenum = datenum(target_year, target_month+1, 1) - datenum(target_year,1,1);
if target_month == 12
   end_datenum = datenum(target_year+1, 1, 1) - datenum(target_year,1,1);
end
datelength = end_datenum - start_datenum + 1;

% Find target path
targetpath = [rootpath, num2str(target_year), '\'];

% Sum of data
for di = start_datenum:end_datenum
    
    filepath = [targetpath, num2char(di,3), '\'];
    filelist = dir(fullfile(filepath, '*.bz2'));
    filename = filelist.name;
    [status, result] = unzip7([filepath, filename], filepath);
    file = [filepath, filename(1:end-4)];
    
    % Read data from netcdf file
    nc = netcdf(file);
    err_raw = nc{'analysis_error'}(:);
    scale_factor = nc{'analysis_error'}.scale_factor(:);
    add_offset = nc{'analysis_error'}.add_offset(:);
    Lat = nc{'lat'}(:);
    Lon = nc{'lon'}(:);
    mask = nc{'mask'}(:);
    close(nc)
    
    % Convert raw temperature -> Kelvin -> Celsius (with mask)
    err = err_raw*scale_factor + add_offset;
    mask(mask ~= 1) = nan;
    err_mask = err.*mask;
    
    err_sum = err_sum + err_mask;
    
    disp([num2char(di,3), ' ', file])
    delete(file)
end
% Average
err_mean = err_sum/datelength;
   
%% Save as .mat file
save(['OSTIA_err_monthly_', num2str(target_year), num2char(target_month,2), '.mat'], 'err_mean', 'Lat', 'Lon', 'mask');
disp([' End calculation ', num2char(target_year, 4), num2char(target_month, 2)])
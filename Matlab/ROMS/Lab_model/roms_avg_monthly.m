%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS Lab model output avgerage file variables (Monthly)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

target_year = 2012;
ystr = num2char(target_year,4); % target_year_str
fpath_all = ['G:\backup', ystr,'\'];

for k = 1:12

target_month = k;
mstr = num2char(target_month,2); % target_month_str

varis = {'temp', 'salt', 'u', 'v', 'zeta'};

fpath_list = dir(fullfile(fpath_all, [ystr, mstr, '*']));

temp_sum = zeros; salt_sum = zeros; u_sum = zeros; v_sum = zeros; zeta_sum = zeros;
for i = 1:length(fpath_list)
    fpath = fpath_list(i).name;
    fdatenum = datenum(fpath, 'yyyymmddHH');
    fnum = datenum(fdatenum) - datenum(2011,01,01,0,0,0) + 1;
    fname = ['avg_', num2char(fnum,4), '.nc'];
    file = [fpath_all, fpath, '\', fname]
    
    nc = netcdf(file);
    if length(nc) == 0
    close(nc);
    fpath = fpath_list(i-1).name;
    file = [fpath_all, fpath, '\', fname]
    nc = netcdf(file);
    end

    temp = nc{'temp'}(:); salt = nc{'salt'}(:);
    u = nc{'u'}(:); v = nc{'v'}(:);
    zeta = nc{'zeta'}(:);
    close(nc);
    
    for ii = 1:length(varis)
        vari = cell2mat(varis(ii));
        eval([vari, '_sum = ', vari, '_sum + ', vari, ';'])
    end
       
end
temp_monthly = temp_sum/length(fpath_list);
salt_monthly = salt_sum/length(fpath_list);
u_monthly = u_sum/length(fpath_list);
v_monthly = v_sum/length(fpath_list);
zeta_monthly = zeta_sum/length(fpath_list);

clear nc

nc_name = ['monthly_', ystr, mstr, '.nc'];
size_2d = size(zeta_monthly); size_3d = size(temp_monthly);

nccreate(nc_name, 'temp', 'Dimensions', {'xi_rho', size_3d(3), 'eta_rho', size_3d(2), 's_rho', size_3d(1)}, 'format', 'classic');
nccreate(nc_name, 'salt', 'Dimensions', {'xi_rho', size_3d(3), 'eta_rho', size_3d(2), 's_rho', size_3d(1)}, 'format', 'classic');
nccreate(nc_name, 'u', 'Dimensions', {'xi_u', size_3d(3)-1, 'eta_u', size_3d(2), 's_rho', size_3d(1)}, 'format', 'classic');
nccreate(nc_name, 'v', 'Dimensions', {'xi_v', size_3d(3), 'eta_v', size_3d(2)-1, 's_rho', size_3d(1)}, 'format', 'classic');
nccreate(nc_name, 'zeta', 'Dimensions', {'xi_rho', size_3d(3), 'eta_rho', size_3d(2)}, 'format', 'classic');

ncwrite(nc_name,'temp', permute(temp_monthly, [3 2 1]));
ncwrite(nc_name,'salt', permute(salt_monthly, [3 2 1]));
ncwrite(nc_name,'u', permute(u_monthly, [3 2 1]));
ncwrite(nc_name,'v', permute(v_monthly, [3 2 1]));
ncwrite(nc_name,'zeta', zeta_monthly');

end

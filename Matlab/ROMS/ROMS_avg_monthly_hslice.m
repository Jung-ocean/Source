%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Save ROMS model monthly horizontal section into .mat file
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

target_year = 2012;
tys = num2char(target_year,4); % target_year_str
fpath_all = 'G:\MEPL_backup\auto_backup\auto_output\backup2012\';
gfile = 'D:\roms_grd.nc';

for k = 10:12

target_month = k;
tms = num2char(target_month,2); % target_month_str

varis = {'temp', 'salt', 'u', 'v'};
depth = 50;

fpath_list = dir(fullfile(fpath_all, [tys, tms, '*']));

temp_sum = zeros; salt_sum = zeros; u_sum = zeros; v_sum = zeros;
for i = 1:length(fpath_list)
    fpath = fpath_list(i).name;
    fdatenum = datenum(fpath, 'yyyymmddHH');
    fnum = datenum(fdatenum) - datenum(2011,01,01,0,0,0) + 1;
    fname = ['avg_', num2char(fnum,4), '.nc'];
    file = [fpath_all, fpath, '/', fname]
    
    nc = netcdf(file);
    if length(nc) == 0
    close(nc);
    fpath = fpath_list(i-1).name;
    file = [fpath_all, fpath, '/', fname]
    nc = netcdf(file);
    end

    lon_rho = nc{'lon_rho'}(:); lat_rho = nc{'lat_rho'}(:);
    lon_u = nc{'lon_u'}(:); lat_u = nc{'lat_u'}(:);
    lon_v = nc{'lon_v'}(:); lat_v = nc{'lat_v'}(:);
    angle = nc{'angle'}(:); ocean_time = nc{'ocean_time'}(:);
    temp = nc{'temp'}(:); salt = nc{'salt'}(:);
    mask_rho = nc{'mask_rho'}(:); mask_u = nc{'mask_u'}(:); mask_v = nc{'mask_v'}(:);
    u = nc{'u'}(:); v = nc{'v'}(:);
    close(nc);
    
    mask2 = mask_rho./mask_rho;
    masku2 = mask_u./mask_u;
    maskv2 = mask_v./mask_v;
    
    ftime = datestr(datenum(2011, 01, 01, 00, 00, 00) + ocean_time/60/60/24, 'yyyy-mm-dd');
    
    for ii = 1:4
    	if ii == 3
		type = 'u';
	elseif ii == 4
		type = 'v';
	else
		type = 'r';
	end
        vari = varis{ii};
	var = get_hslice(file, gfile, vari, 1, -depth, type);
        eval([vari, '_sum = ', vari, '_sum + var;'])
    end
       
end
temp_monthly = temp_sum/length(fpath_list);
salt_monthly = salt_sum/length(fpath_list);
u_monthly = u_sum/length(fpath_list);
v_monthly = v_sum/length(fpath_list);

clear nc
save(['monthly_', tys, tms, '_', num2char(depth,2), 'm.mat'], '*')

end

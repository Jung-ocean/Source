clear; clc

exp = 'Dsm4';
startdate = datenum(2018,7,1);
g = grd('BSf');
dx = 1./g.pm;
dy = 1./g.pn;
load mask_shelf_basin.mat

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

filenum_start = datenum(2019,1,1) - startdate + 1;
filenum_end = datenum(2022,12,31) - startdate + 1;
filenum_all = filenum_start:filenum_end;

salt_trans = NaN([length(filenum_all), 1]);
timenum = NaN([length(filenum_all), 1]);
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi);
    fstr = num2str(filenum ,'%04i');
    timenum(fi) = filenum - 1 + startdate;

filename = [exp, '_avg_', fstr, '.nc'];
file = [filepath, filename];

if exist(file)
    salt_trans_sum = zeros;

zeta = ncread(file, 'zeta')';
z_r = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.Tcline,g.N,'r',2);
z_w = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.Tcline,g.N,'w',2);
dz = z_w(2:end,:,:) - z_w(1:end-1,:,:);
salt = ncread(file, 'salt');
salt = permute(salt, [3 2 1]);
temp = ncread(file, 'temp');
temp = permute(temp, [3 2 1]);

u = ncread(file, 'u');
u = permute(u, [3 2 1]);
v = ncread(file, 'v');
v = permute(v, [3 2 1]);

for i = 1:size(mask_shelf, 1)
    for j = 1:size(mask_shelf, 2)

        point = mask_shelf(i,j);
        if point == 1

            if i == size(g.mask_rho, 1)
                point_N = 0;
            else
                point_N = mask_basin(i+1,j);
            end
            if point_N == 1
                salt_N = (salt(:,i,j) + salt(:,i+1,j))/2; % g/kg
                temp_N = (temp(:,i,j) + temp(:,i+1,j))/2;
                dz_N = (dz(:,i,j) + dz(:,i+1,j))/2; % m
                z_N = (z_r(:,i,j) + z_r(:,i+1,j))/2;
                lat_N = (g.lat_rho(i,j) + g.lat_rho(i+1,j))/2;
                pres = sw_pres(abs(z_N), lat_N);
                pden_N = sw_pden_ROMS(salt_N, temp_N, pres, 0); % kg/m^3
                dx_tmp = (dx(i,j) + dx(i+1,j))/2;
                dx_N = repmat(dx_tmp, [1,g.N])'; % m
                v_N = v(:,i,j); % m

                salt_trans_1d = pden_N.*salt_N.*1e-3.*dz_N.*dx_N.*v_N; % kg/s
                salt_trans_sum = salt_trans_sum + sum(salt_trans_1d);
            end

            if j == size(g.mask_rho, 2)
                point_E = 0;
            else
                point_E = mask_basin(i,j+1);
            end
            if point_E == 1
                salt_E = (salt(:,i,j) + salt(:,i,j+1))/2; % g/kg
                temp_E = (temp(:,i,j) + temp(:,i,j+1))/2;
                dz_E = (dz(:,i,j) + dz(:,i,j+1))/2; % m
                z_E = (z_r(:,i,j) + z_r(:,i,j+1))/2;
                lat_E = (g.lat_rho(i,j) + g.lat_rho(i,j+1))/2;
                pres = sw_pres(abs(z_E), lat_E);
                pden_E = sw_pden_ROMS(salt_E, temp_E, pres, 0); % kg/m^3
                dy_tmp = (dy(i,j) + dy(i,j+1))/2;
                dy_E = repmat(dy_tmp, [1,g.N])'; % m
                u_E = u(:,i,j); % m

                salt_trans_1d = pden_E.*salt_E.*1e-3.*dz_E.*dy_E.*u_E; % kg/s
                salt_trans_sum = salt_trans_sum + sum(salt_trans_1d);
            end

            if i == 1
                point_S = 0;
            else
                point_S = mask_basin(i-1,j);
            end
            if point_S == 1
                salt_S = (salt(:,i-1,j) + salt(:,i,j))/2; % g/kg
                temp_S = (temp(:,i-1,j) + temp(:,i,j))/2;
                dz_S = (dz(:,i-1,j) + dz(:,i,j))/2; % m
                z_S = (z_r(:,i-1,j) + z_r(:,i,j))/2;
                lat_S = (g.lat_rho(i-1,j) + g.lat_rho(i,j))/2;
                pres = sw_pres(abs(z_S), lat_S);
                pden_S = sw_pden_ROMS(salt_S, temp_S, pres, 0); % kg/m^3
                dx_tmp = (dx(i-1,j) + dx(i,j))/2;
                dx_S = repmat(dx_tmp, [1,g.N])'; % m
                v_S = v(:,i-1,j); % m

                salt_trans_1d = pden_S.*salt_S.*1e-3.*dz_S.*dx_S.*v_S; % kg/s
                salt_trans_sum = salt_trans_sum + sum(salt_trans_1d);
            end

            if j == 1
                point_W = 0;
            else
                point_W = mask_basin(i,j-1);
            end
            if point_W == 1
                salt_W = (salt(:,i,j-1) + salt(:,i,j))/2; % g/kg
                temp_W = (temp(:,i,j-1) + temp(:,i,j))/2;
                dz_W = (dz(:,i,j-1) + dz(:,i,j))/2; % m
                z_W = (z_r(:,i,j-1) + z_r(:,i,j))/2;
                lat_W = (g.lat_rho(i,j-1) + g.lat_rho(i,j))/2;
                pres = sw_pres(abs(z_W), lat_W);
                pden_W = sw_pden_ROMS(salt_W, temp_W, pres, 0); % kg/m^3
                dy_tmp = (dy(i,j-1) + dy(i,j))/2; 
                dy_W = repmat(dy_tmp, [1,g.N])'; % m
                u_W = u(:,i,j-1); % m

                salt_trans_1d = pden_W.*salt_W.*1e-3.*dz_W.*dy_W.*u_W; % kg/s
                salt_trans_sum = salt_trans_sum + sum(salt_trans_1d);
            end
        end % point
    end % j
end % i

salt_trans(fi) = salt_trans_sum;

else

salt_trans(fi) = NaN;    

end % exist

disp(filename)
end % fi


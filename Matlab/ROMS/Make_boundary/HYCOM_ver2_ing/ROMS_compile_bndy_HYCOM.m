clear; clc

yyyy = 2013;
mm = 1:12;
casename = 'EYECS';

quot = '''';

ROMS_title = 'Northwestern Pacific Model';
bryname = ['.\roms_bndy_', casename, '_HYCOM_', num2str(yyyy), '.nc'];

g = grd(casename);
grdname = g.grd_file;
theta_s = g.theta_s;
theta_b = g.theta_b;
hc = g.hc;
N = g.N;

roms_time = [15:30:365];
if leapyear(yyyy)
    cycle_length = 366.25;
else
    cycle_length = 365.25;
end

varis_3d = {'temp', 'salt', 'u', 'v'};
varis_2d = {'zeta', 'ubar', 'vbar'};
direction_list = {'east', 'west', 'south', 'north'};
obc = [1 0 0 0]; % open boundaries (1 = open , [S E N W])

create_bryfile_J(bryname, grdname, ROMS_title, ...
    obc, theta_s, theta_b, hc, N, roms_time, cycle_length, 'clobber');

for mi = mm(1):mm(end);
    filename = ['HYCOM_Y', num2str(yyyy,4), 'M', num2str(mi), '.nc'];
    nc = netcdf(filename);
    
    for i_dir = 1:length(direction_list);
        direction = direction_list{i_dir};
        
        for i_3d = 1:length(varis_3d);
            var_3d = [varis_3d{i_3d}, '_', direction];
            eval([var_3d, '_all(mi, :, :) = nc{', quot, var_3d, quot, '}(:);'])
        end
        for i_2d = 1:length(varis_2d);
            var_2d = [varis_2d{i_2d}, '_', direction];
            eval([var_2d, '_all(mi, :) = nc{', quot, var_2d, quot, '}(:);'])
        end
        
    end
    close(nc);
end

% Write variables
nc = netcdf(bryname, 'write');
nc{'spherical'}(:)= 'T';
nc{'Vtransform'}(:)=2;
nc{'Vstretching'}(:)=4;
nc{'tstart'}(:) = min([min(roms_time) min(roms_time) min(roms_time)]);
nc{'tend'}(:) = max([max(roms_time) max(roms_time) max(roms_time)]);
nc{'theta_s'}(:) = theta_s;
nc{'theta_b'}(:) = theta_b;
nc{'Tcline'}(:) = hc;
nc{'hc'}(:) = hc;
% nc{'sc_r'}(:) = sc_r;
% nc{'sc_w'}(:) = sc_w;
% nc{'Cs_r'}(:) = Cs_r;
% nc{'Cs_w'}(:) = Cs_w;
nc{'tclm_time'}(:) = roms_time;
nc{'temp_time'}(:) = roms_time;
nc{'sclm_time'}(:) = roms_time;
nc{'salt_time'}(:) = roms_time;
nc{'uclm_time'}(:) = roms_time;
nc{'vclm_time'}(:) = roms_time;
nc{'v2d_time'}(:) =  roms_time;
nc{'v3d_time'}(:) =  roms_time;
nc{'ssh_time'}(:) =  roms_time;
nc{'zeta_time'}(:) = roms_time;
nc{'bry_time'}(:) =  roms_time;
% South
if obc(1) == 1
nc{'u_south'}(:) = u_south_all;
nc{'v_south'}(:) = v_south_all;
nc{'ubar_south'}(:) = ubar_south_all;
nc{'vbar_south'}(:) = vbar_south_all;
nc{'zeta_south'}(:) = zeta_south_all;
nc{'temp_south'}(:) = temp_south_all;
nc{'salt_south'}(:) = salt_south_all;
end
% East
if obc(1) == 2
nc{'u_east'}(:) = u_east_all;
nc{'v_east'}(:) = v_east_all;
nc{'ubar_east'}(:) = ubar_east_all;
nc{'vbar_east'}(:) = vbar_east_all;
nc{'zeta_east'}(:) = zeta_east_all;
nc{'temp_east'}(:) = temp_east_all;
nc{'salt_east'}(:) = salt_east_all;
end
% North
if obc(1) == 3
nc{'u_north'}(:) = u_north_all;
nc{'v_north'}(:) = v_north_all;
nc{'ubar_north'}(:) = ubar_north_all;
nc{'vbar_north'}(:) = vbar_north_all;
nc{'zeta_north'}(:) = zeta_north_all;
nc{'temp_north'}(:) = temp_north_all;
nc{'salt_north'}(:) = salt_north_all;
end
% West
if obc(1) == 4
nc{'u_west'}(:) = u_west_all;
nc{'v_west'}(:) = v_west_all;
nc{'ubar_west'}(:) = ubar_west_all;
nc{'vbar_west'}(:) = vbar_west_all;
nc{'zeta_west'}(:) = zeta_west_all;
nc{'temp_west'}(:) = temp_west_all;
nc{'salt_west'}(:) = salt_west_all;
end
close(nc)
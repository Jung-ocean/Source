clear; clc

start_date = datetime(2018,7,1);
Mobj.rundays = 153;
Mobj.time = (start_date:hours(1):start_date + Mobj.rundays)';
Mobj.dt = 120;
Mobj.coord = 'geographic';

hgrid_file = './hgrid.gr3';
vgrid_file = './vgrid.in';

Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');
%
initial_filepath = './';
initial_filename = 'hotstart.nc';
initial_file = [initial_filepath, initial_filename];
var = ncread(initial_file, 'tr_nd');

var_temp = squeeze(var(1,:,:));
InitCnd.temp = var_temp';
var_salt = squeeze(var(2,:,:));
InitCnd.salt = var_salt';
clearvars var

hycom_filepath = '/data/jungjih/Models/SCHISM/test_schism/v1_SMS_min_5m_3D/gen_input/Hot/';
hycom_filename = 'hycom_20180701.nc';
hycom_file = [hycom_filepath, hycom_filename];
lon_HYCOM = ncread(hycom_file, 'xlon');
lat_HYCOM = ncread(hycom_file, 'ylat');
depth_HYCOM = -ncread(hycom_file, 'depth');
temp_HYCOM = permute(ncread(hycom_file, 'temperature'), [3 2 1]);
salt_HYCOM = permute(ncread(hycom_file, 'salinity'), [3 2 1]);

index = find(Mobj.depth == max(Mobj.depth));
lon_SCHISM = Mobj.lon;
lat_SCHISM = Mobj.lat;
depth_SCHISM = Mobj.depLayers;
temp_SCHISM = InitCnd.temp';
salt_SCHISM = InitCnd.salt';

points = [;
    lon_SCHISM(index), lat_SCHISM(index);
    -178.8+360, 59.5;
    -170+360, 51.3];

titles = {'Deepest', 'P1', 'P2'};

% plot
figure; hold on;
set(gcf, 'Position', [1 1 1200 900])
tiledlayout(2,3);
for pi = 1:size(points,1)
    lon_target = points(pi,1);
    lat_target = points(pi,2);

    dis_S = sqrt((lon_target - lon_SCHISM).^2 + (lat_target - lat_SCHISM).^2);
    index_S = find(dis_S == min(dis_S));

    temp_SCHISM_target = temp_SCHISM(:,index_S);
    salt_SCHISM_target = salt_SCHISM(:,index_S);
    depth_SCHISM_target = depth_SCHISM(:,index_S);

    lon_dis_H = abs(lon_target - lon_HYCOM);
    lat_dis_H = abs(lat_target - lat_HYCOM);
    index_lon_H = find(lon_dis_H == min(lon_dis_H));
    index_lat_H = find(lat_dis_H == min(lat_dis_H));

    temp_HYCOM_target = temp_HYCOM(:,index_lat_H,index_lon_H);
    salt_HYCOM_target = salt_HYCOM(:,index_lat_H,index_lon_H);

    nexttile(pi); hold on; grid on
    plot(temp_HYCOM_target, depth_HYCOM, 'k', 'LineWidth', 4)
    plot(temp_SCHISM_target, depth_SCHISM_target, '--r', 'LineWidth', 2)

    xlabel('^oC')
    ylabel('Depth (m)')
    
    if pi == 1
        l = legend('HYCOM', 'SCHISM');
        l.FontSize = 20;
        l.Location = 'SouthEast';
    end
    title([titles{pi}, ', Temperature'])

    nexttile(pi+size(points,1)); hold on; grid on
    plot(salt_HYCOM_target, depth_HYCOM, 'k', 'LineWidth', 4)
    plot(salt_SCHISM_target, depth_SCHISM_target, '--r', 'LineWidth', 2)

    xlabel('g/kg')
    ylabel('Depth (m)')
    title([titles{pi}, ', Salinity'])

end

print('initial_profile', '-dpng')
save('points_profile.mat', 'points')
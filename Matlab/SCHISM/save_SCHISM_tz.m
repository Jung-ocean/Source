clear; clc

variable = 'salinity';
expname = 'noshapiro';
day_all = [1:7];

points = load('../../Hot/points_profile.mat');
points = points.points;

start_date = datetime(2018,7,1);
timenum = datenum(start_date:1/24:start_date+7);
Mobj.rundays = 153;
Mobj.time = (start_date:hours(1):start_date + Mobj.rundays)';
Mobj.dt = 120;
Mobj.coord = 'geographic';

hgrid_file = '../hgrid.gr3';
vgrid_file = '../vgrid.in';

Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

lon_SCHISM = Mobj.lon;
lat_SCHISM = Mobj.lat;

for pi = 1:size(points,1)
    lon_target = points(pi,1);
    lat_target = points(pi,2);

    dis_S = sqrt((lon_target - lon_SCHISM).^2 + (lat_target - lat_SCHISM).^2);
    index_S(pi) = find(dis_S == min(dis_S));
end

%
initial_filepath = '../../Hot/';
initial_filename = 'hotstart.nc';
initial_file = [initial_filepath, initial_filename];
var = ncread(initial_file, 'tr_nd');

var_temp = squeeze(var(1,:,:));
InitCnd.temp = var_temp';
var_salt = squeeze(var(2,:,:));
InitCnd.salt = var_salt';
clearvars var

switch variable
    case 'temperature'
        vari_str_ini = 'temp';
        vari_str_SCHISM = variable;
        climit = [5 20];
        unit = '^oC';
    case 'salinity'
        vari_str_ini = 'salt';
        vari_str_SCHISM = variable;
        climit = [31.5 33.5];
        unit = 'g/kg';
end

vari_SCHISM = NaN(length(index_S), Mobj.maxLev, 24*length(day_all));
for di = 1:length(day_all)
    day = day_all(di);

    % SCHISM
    SCHISM_filepath = ['../outputs_', expname, '/'];
    SCHISM_filename = [vari_str_SCHISM, '_', num2str(day), '.nc'];
    SCHISM_file = [SCHISM_filepath, SCHISM_filename];
    vari = ncread(SCHISM_file, vari_str_SCHISM);

    for i = 1:length(index_S)
        vari_SCHISM(i,:,(di*24-23):di*24) = squeeze(vari(:,index_S(i),:));
    end
end
clearvars vari
vari_SCHISM(vari_SCHISM > 1e30) = NaN;

vari_ini_all = eval(['InitCnd.', vari_str_ini]);
vari_ini = vari_ini_all(index_S,:);

vari_SCHISM_w_ini = NaN(length(index_S), Mobj.maxLev, 24*length(day_all)+1);
vari_SCHISM_w_ini(:,:,1) = vari_ini;
vari_SCHISM_w_ini(:,:,2:end) = vari_SCHISM;

depth_SCHISM = Mobj.depLayers(:,index_S)';

save(['vari_SCHISM_', vari_str_ini,'.mat'], 'vari_SCHISM_w_ini', 'depth_SCHISM', 'timenum', 'points')
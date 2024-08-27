clear; clc

start_date = datetime(2019,7,1);
Mobj.rundays = 153;
Mobj.time = (start_date:hours(1):start_date + Mobj.rundays)';
Mobj.dt = 60;
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

ROMS_filepath = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2018/Dsm4_phi3m1/Output/';
ROMS_filename = 'Winter_2018_Dsm4_phi3m1_his_0364.nc';
ROMS_file = [ROMS_filepath, ROMS_filename];

DS = get_ROMS_init_bys_from_file(Mobj, ROMS_file);

check_schism_init_w_ROMS(Mobj, DS, InitCnd, 'temp')
saveas(gcf, 'initial_temp.png')

check_schism_init_w_ROMS(Mobj, DS, InitCnd, 'salt')
saveas(gcf, 'initial_salt.png')
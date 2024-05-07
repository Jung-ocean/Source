clear; clc

start_date = datetime(2018,7,1);
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

hycom_filepath = '/data/jungjih/Models/SCHISM/test_schism/v1_SMS_min_5m_3D/gen_input/Hot/';
hycom_filename = 'hycom_20180701.nc';
hycom_file = [hycom_filepath, hycom_filename];

DS = get_hycom_init_bys_from_file(Mobj, hycom_file);

check_schism_init(Mobj, DS, InitCnd, 'temp')
saveas(gcf, 'initial_temp.png')

check_schism_init(Mobj, DS, InitCnd, 'salt')
saveas(gcf, 'initial_salt.png')
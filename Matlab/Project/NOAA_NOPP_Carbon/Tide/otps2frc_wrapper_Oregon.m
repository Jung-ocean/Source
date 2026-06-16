clear; clc

sourcepath = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/Make_tide/roms_tides_Hunter/';
addpath(genpath(sourcepath));

yyyy = 2024;
mm = 1;
dd = 1;
timenum = datenum(yyyy,mm,dd);
yyyymmdd = datestr(timenum, 'yyyymmdd');
domain = 'Oregon_1km';
g = grd(domain);

gfile = g.grd_file;
base_date=datenum(yyyy,mm,dd,0,0,0);
pred_date=datenum(yyyy,mm,dd,0,0,0);
ofile=['tide_', domain, '_TPXO9v5a_', yyyymmdd,'.nc'];
tide_file='/data/jungjih/Models/Tide/TPXO9v5a/DATA/Model_tpxo9.v5a';
ncon = 8; % the number of constituents
%otps2frc_v5(gfile,base_date,pred_date,ofile,model_file, domain)
otps2frc_v5_J(gfile,base_date,pred_date,ofile,tide_file, domain, ncon)

rmpath(genpath(sourcepath));
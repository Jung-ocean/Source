clear; clc

addpath(genpath('C:\Users\User\Dropbox\Matlab\ROMS\Make_tide\roms_tides_Hunter'));

for yi = 2020:2020
    yyyy = yi;
    mm = 1;
    dd = 1;
    domain = 'EYECS';
    g = grd(domain);
    
    gfile = g.grd_file;
    base_date=datenum(yyyy,mm,dd,0,0,0);
    pred_date=datenum(yyyy,mm,dd,0,0,0);
    ofile=['roms_tide_', domain, '_TPXO72_', num2str(yyyy), num2char(mm,2), num2char(dd,2),'.nc'];
    model_file='C:\Users\User\Dropbox\Matlab\ROMS\Make_tide\roms_tides_Hunter\update\otps\DATA\Model_tpxo7.2';
    ncon = 10; % the number of constituents
    %otps2frc_v5(gfile,base_date,pred_date,ofile,model_file, domain)
    otps2frc_v5_J(gfile,base_date,pred_date,ofile,model_file, domain, ncon)
    
end

rmpath(genpath('C:\Users\User\Dropbox\Matlab\ROMS\Make_tide\roms_tides_Hunter'));
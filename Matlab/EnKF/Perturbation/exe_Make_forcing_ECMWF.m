clear; clc

ens_list = 25:32;
casename = 'NWP';
target_year = 2016;
fpath = '.\';

for ei = ens_list
    
    ens_num = ei;
    Make_forcing_ECMWF_T
    clearvars -except ens_list ei target_year fpath casename
    
    ens_num = ei;
    Make_forcing_ECMWF_U
    clearvars -except ens_list ei target_year fpath casename
    
    ens_num = ei;
    Make_forcing_ECMWF_V
    clearvars -except ens_list ei target_year fpath casename
    
end
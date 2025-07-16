%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make climatology of ARGO BOA
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2015:2023;
mm_all = 1:12;

% ARGO
filepath_ARGO = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');
    
    salt_sum = zeros;
    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi);
        ystr = num2str(yyyy);

        filename_ARGO = ['BOA_Argo_', ystr, '_', mstr, '.mat'];
        file_ARGO = [filepath_ARGO, filename_ARGO];
        ARGO = load(file_ARGO);

        salt_sum = salt_sum + ARGO.salt;
    end
    salt_mean = salt_sum./length(yyyy_all);

    lat = ARGO.lat;
    lon = ARGO.lon;
    salt = salt_mean;

    save(['BOA_Argo_climate_', mstr, '.mat'], 'lat', 'lon', 'salt')
end
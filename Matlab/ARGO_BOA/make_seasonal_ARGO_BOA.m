%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make seasonal mean of ARGO BOA
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2019:2023;
mm_all = [1:3];
savename = 'JFM';

% ARGO
filepath_ARGO = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);
    
    SSS_all = NaN(360,160,length(mm_all));
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        filename_ARGO = ['BOA_Argo_', ystr, '_', mstr, '.mat'];
        file_ARGO = [filepath_ARGO, filename_ARGO];
        ARGO = load(file_ARGO);
        lat = ARGO.lat;
        lon = ARGO.lon;

        SSS_all(:,:,mi) = ARGO.salt(:,:,1);
        SSS_mean = mean(SSS_all, 3);

        save(['mean_', ystr, '_', savename, '.mat'], 'yyyy', 'mm_all', 'lat', 'lon', 'SSS_mean')
    end
end
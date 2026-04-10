%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make mean and std of ARGO BOA
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2019:2023;
mm_all = [7:9];

% ARGO
filepath_ARGO = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];

SSS_all = NaN(360,160,length(yyyy_all)*length(mm_all));
dataind = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        dataind = dataind+1;
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        filename_ARGO = ['BOA_Argo_', ystr, '_', mstr, '.mat'];
        file_ARGO = [filepath_ARGO, filename_ARGO];
        ARGO = load(file_ARGO);

        SSS_all(:,:,dataind) = ARGO.salt(:,:,1);
    end
end

SSS_mean = mean(SSS_all, 3);
SSS_std = std(SSS_all, [], 3);

lat = ARGO.lat;
lon = ARGO.lon;

save(['mean.mat'], 'yyyy_all', 'mm_all', 'lat', 'lon', 'SSS_mean')
save(['std.mat'], 'yyyy_all', 'mm_all', 'lat', 'lon', 'SSS_std')
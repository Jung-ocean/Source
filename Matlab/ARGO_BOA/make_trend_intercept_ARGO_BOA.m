%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make trend and intercept of ARGO BOA
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2019:2023;
mm_all = [1:12];

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

trend = NaN(size(SSS_all,[1 2]));
intercept = NaN(size(SSS_all,[1 2]));
for i = 1:size(SSS_all,1)
    for j = 1:size(SSS_all,2)

        SSS_tmp = squeeze(SSS_all(i,j,:));
        b = polyfit(1:length(SSS_tmp), SSS_tmp, 1);

        trend(i,j) = b(1);
        intercept(i,j) = b(2);
    end
end

lat = ARGO.lat;
lon = ARGO.lon;

save(['trend.mat'], 'yyyy_all', 'mm_all', 'lat', 'lon', 'trend')
save(['intercept.mat'], 'yyyy_all', 'mm_all', 'lat', 'lon', 'intercept')
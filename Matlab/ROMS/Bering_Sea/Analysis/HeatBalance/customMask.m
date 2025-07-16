function [mask_custom]=customMask(boxName,grd)

% Returns mask_custom of 1's inside a selected area and 0's everywhere else
% grd is the dictionary variable with fields lon_rho,lat_rho,mask_rho,h (can be
% explanded in the future):

[xi_rho,eta_rho]=size(grd.mask_rho);
mask_custom=zeros(xi_rho,eta_rho);

if strcmp(boxName,'ORE')
 mask_custom(grd.mask_rho==1 & grd.lat_rho>=42 & grd.lat_rho<=46 & grd.h<200)=1;
elseif strcmp(boxName,'NCA')
 disp('WARNING: choice of indices is specific for the 2-km WCOFS grid!');
 mask_custom(:,958:1189)=1; % works for the WCOFS 2-km grid only
 mask_custom(grd.mask_rho==0 | grd.h>200)=0;
elseif strcmp(boxName,'CCA')
 % use WCOFS grid indices, approx 34-37N
 disp('WARNING: choice of indices is specific for the 2-km WCOFS grid!');
 mask_custom(:,731:903)=1; % works for the WCOFS 2-km grid only
 mask_custom(grd.mask_rho==0 | grd.h>200)=0;
elseif strcmp(boxName,'SCA')
 mask_custom(grd.mask_rho==1 & grd.lat_rho>=32 & grd.lon_rho>=-119 & grd.h<200)=1;
 % exclude islands:
 mask_custom(grd.lat_rho<=33.5 & grd.lon_rho<=-118.2 & grd.h<200)=0;
% Refined domains by physical boundaries:
elseif strcmp(boxName,'ORE4346')
 mask_custom(grd.mask_rho==1 & grd.lat_rho>=43 & grd.lat_rho<=46 & grd.h<200)=1;
elseif strcmp(boxName,'CMCB')
 % Area between C. Mendocino and C. Blanco
 mask_custom(grd.mask_rho==1 & grd.lat_rho>=40.5 & grd.lat_rho<=43 & grd.h<200)=1;
elseif strcmp(boxName,'SFCM')
 % From just north of SF Bay to C. Mendocino
 mask_custom(grd.mask_rho==1 & grd.lat_rho>=38.2 & grd.lat_rho<=40.5 & grd.h<200)=1;
else 
 error(['inactive option: ' boxName]);   
end

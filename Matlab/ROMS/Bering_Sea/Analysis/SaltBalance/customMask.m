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
elseif strcmp(boxName, 'Koryak_coast')
    polygon = [;
        -188.8807   62.6
        -181.0028   62.6
        -181.0028   56
        -188.8807   56
        -188.8807   62.6
        ];
    [in, on] = inpolygon(grd.lon_rho, grd.lat_rho, polygon(:,1), polygon(:,2));
    mask_custom = grd.mask_rho.*double(in);
    mask_custom(grd.mask_rho==0 | grd.h > 200)=0;
elseif strcmp(boxName, 'Koryak_coast_basin')
        polygon = [;
        -188.8807   62.6
        -181.0028   62.6
        -181.0028   56
        -188.8807   56
        -188.8807   62.6
        ];
    [in, on] = inpolygon(grd.lon_rho, grd.lat_rho, polygon(:,1), polygon(:,2));
    mask_custom = grd.mask_rho.*double(in);
    mask_custom(grd.mask_rho==0 | grd.h <= 200)=0;

elseif strcmp(boxName,'GOA') || strcmp(boxName,'GOA_10m') || strcmp(boxName,'GOA_50m')
 % Area of the Gulf of Anadyr
 polygon = [;
     -180.9180   62.3790
     -172.9734   64.3531
     -178.7092   66.7637
     -184.1599   64.8934
     -180.9180   62.3790
     ];
 [in, on] = inpolygon(grd.lon_rho, grd.lat_rho, polygon(:,1), polygon(:,2));
 mask_custom = grd.mask_rho.*double(in);
 if strcmp(boxName,'GOA_10m')
     mask_custom(grd.mask_rho==0 | grd.h<=10)=0;
 elseif strcmp(boxName,'GOA_50m')
      mask_custom(grd.mask_rho==0 | grd.h<=50)=0;
 end

elseif strcmp(boxName,'basin')
 % Arbitrary basin
 mask_custom(grd.mask_rho==1 & ...
     grd.lat_rho>=55 & grd.lat_rho<=60 & ...
     grd.lon_rho>=-187.5 & grd.lon_rho<=-180) = 1;
 elseif strcmp(boxName,'NS') || strcmp(boxName,'NS_10m')
 % Area of the Gulf of Anadyr
 polygon = [;
     -167.7995   65.6339
     -165.6279   61.6417
     -159.7853   63.6663
     -160.5092   65.2917
     -167.7995   65.6339
     ];
 [in, on] = inpolygon(grd.lon_rho, grd.lat_rho, polygon(:,1), polygon(:,2));
 mask_custom = grd.mask_rho.*double(in);
 if strcmp(boxName,'NS_10m')
      mask_custom(grd.mask_rho==0 | grd.h<=10)=0;
 end

 elseif strcmp(boxName,'BB') || strcmp(boxName,'BB_10m')
 % Area of the Gulf of Anadyr
 polygon = [;
     -161.5213   58.8741
     -160.2454   56.0180
     -156.9278   57.3865
     -156.8768   60.0046
     -161.5213   58.8741
     ];
 [in, on] = inpolygon(grd.lon_rho, grd.lat_rho, polygon(:,1), polygon(:,2));
 mask_custom = grd.mask_rho.*double(in);
 if strcmp(boxName,'BB_10m')
      mask_custom(grd.mask_rho==0 | grd.h<=10)=0;
 end

else 
 error(['inactive option: ' boxName]);   
end

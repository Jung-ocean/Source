function [mask, area] = mask_and_area(region, g)

dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

switch region
    case 'eshelf'
        mask_Scott = load('/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BSf_region_polygons.mat');
        indbsb = mask_Scott.indbsb;
        %indshelf = mask_Scott.indshelf;
        indshelf = eval(['mask_Scott.ind', region]);
        indBS = [indbsb; indshelf'];
        [row,col] = ind2sub([1460, 957], indBS);
        indmask = sub2ind([957, 1460], col, row); % transpose

        mask_ind = NaN(size(mask));
        mask_ind(indmask) = 1;
        mask = mask.*mask_ind;
        area = area.*mask_ind;
    case 'midshelf'
        mask_Scott = load('/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BSf_region_polygons.mat');
        indbsb = mask_Scott.indeoshelf;
        [row,col] = ind2sub([1460, 957], indbsb);
        indmask = sub2ind([957, 1460], col, row); % transpose

        mask_ind = NaN(size(mask));
        mask_ind(indmask) = 1;

        latind = find(g.lat_rho < 57.6 | g.lat_rho > 59.8);
        mask_ind(latind) = NaN;
        lonind = find(g.lon_rho > -163);
        mask_ind(lonind) = NaN;

        mask = mask.*mask_ind;
        area = area.*mask_ind;

        hind = find(g.h < 50 | g.h > 150);
        mask(hind) = NaN;
        area(hind) = NaN;
    case 'Gulf_of_Anadyr'
%         mask_Scott = load('/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BSf_region_polygons.mat');
%         indbsb = mask_Scott.indeoshelf;
%         [row,col] = ind2sub([1460, 957], indbsb);
%         indmask = sub2ind([957, 1460], col, row); % transpose
% 
%         mask_ind = NaN(size(mask));
%         mask_ind(indmask) = 1;
% 
%         latind = find(g.lat_rho < 61);
%         mask_ind(latind) = NaN;
%         lonind = find(g.lon_rho > -172.5);
%         mask_ind(lonind) = NaN;
% 
%         mask = mask.*mask_ind;
%         area = area.*mask_ind;
% 
%         hind = find(g.h < 50);
%         mask(hind) = NaN;
%         area(hind) = NaN;
        polygon = [;
            -177.5   60
            -175     60
            -175     63
            -177.5   63
            -177.5   60
            ];

        [in, on] = inpolygon(g.lon_rho, g.lat_rho, polygon(:,1), polygon(:,2));
        mask = mask.*in./in;
        area = area.*mask;
 
    case 'Karaginsky_Island'
        polygon = [;
            -197.0539   56.4146
            -189.6927   60.2560
            -192.0364   61.4679
            -196.9219   60.1417
            -198.7044   57.8323
            -197.0539   56.4146
            ];

        [in, on] = inpolygon(g.lon_rho, g.lat_rho, polygon(:,1), polygon(:,2));
        mask = mask.*in./in;
        area = area.*mask;

        hind = find(g.h < 200);
        mask(hind) = NaN;
        area(hind) = NaN;

end
end
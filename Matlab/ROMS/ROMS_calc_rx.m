clear; clc; close all

casename = 'NWP_ver40_layer20';
g = grd(casename);

[numi, numj] = size(g.lon_rho);
z_w = g.z_w;

my_rx0 = 0;
my_rx1 = 0;
for lati = 2:numi
    for loni = 1:numj
        
        rx0(lati, loni) = abs( (z_w(1,lati,loni)-z_w(1,lati-1,loni)) / (z_w(1,lati,loni)+z_w(1,lati-1,loni)) );
        my_rx0 = max(my_rx0, rx0(lati, loni));
        
        for k = 1:g.N
            rx1(k,lati,loni) = abs( (z_w(k+1,lati,loni)-z_w(k+1,lati-1,loni)+z_w(k,lati,loni)-z_w(k,lati-1,loni)) ...
                / (z_w(k+1,lati,loni)+z_w(k+1,lati-1,loni)-z_w(k,lati,loni)-z_w(k,lati-1,loni)) );
            my_rx1 = max(my_rx1, rx1(k,lati,loni));
        end        
        
        
    end
end

my_rx0
my_rx1

my_ry0 = 0;
my_ry1 = 0;
for lati = 1:numi
    for loni = 2:numj
        
        ry0(lati, loni) = abs( (z_w(1,lati,loni)-z_w(1,lati,loni-1)) / (z_w(1,lati,loni)+z_w(1,lati,loni-1)) );
        my_ry0 = max(my_ry0, ry0(lati, loni));
        
        for k = 1:g.N
            ry1(k,lati,loni) = abs( (z_w(k+1,lati,loni)-z_w(k+1,lati,loni-1)+z_w(k,lati,loni)-z_w(k,lati,loni-1)) ...
                / (z_w(k+1,lati,loni)+z_w(k+1,lati,loni-1)-z_w(k,lati,loni)-z_w(k,lati,loni-1)) );
            my_ry1 = max(my_ry1, ry1(k,lati,loni));
        end        
        
        
    end
end

my_ry0
my_ry1

figure;
pcolor(rx0.*g.mask_rho./g.mask_rho); shading flat
title('rx0')
colorbar
caxis([0 1])
saveas(gcf, ['rx0_', casename, '.png'])

figure;
pcolor(ry0.*g.mask_rho./g.mask_rho); shading flat
title('ry0')
colorbar
caxis([0 1])
saveas(gcf, ['ry0_', casename, '.png'])

for i = 1:1
figure;
pcolor(squeeze(rx1(i,:,:)).*g.mask_rho./g.mask_rho); shading flat
title(['layer ', num2str(i), ' rx1'])
colorbar
caxis([0 10])
saveas(gcf, ['layer', num2str(i), '_rx1_', casename, '.png'])
end

for i = 1:1
figure;
pcolor(squeeze(ry1(i,:,:)).*g.mask_rho./g.mask_rho); shading flat
title(['layer ', num2str(i), ' ry1'])
colorbar
caxis([0 10])
saveas(gcf, ['layer', num2str(i), '_ry1_', casename, '.png'])
end
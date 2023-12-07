clear; clc; close all

dye = 'dye_01';

month = 8; mstr = num2char(month,2);
yyyy = 2013; ystr = num2str(yyyy);

g = grd('EYECS_20190904');
z = g.z_r;

filename = ['monthly_',ystr, mstr, '.nc'];
ncload(filename);

depth_list = -[1 20:20:40];

figure('units','normalized','outerposition',[0 0 0.4 1])
hold on
xlim([124 129]); ylim([33 36]); view(14, 10.8000);

for di = 1:length(depth_list)
    
    depth = depth_list(di);
    
    vari = get_hslice_J(filename,g,dye,depth,'r');
    vari_mask = vari.*g.mask_rho./g.mask_rho;
    
    vari_mask(vari_mask < 0) = 0;
    vari_mask(vari_mask > 1000) = 1000;
    
    maskindex = find(g.mask_rho == 0);
    vari_mask(maskindex) = -100;
    
    surf(g.lon_rho, g.lat_rho, depth*ones(200,500), vari_mask/10);
    caxis([-10 100])
end
shading flat
zlim([-40 0])
set(gca, 'FontSize', 12)

c = colormap('jet');
c1 = [.8 .8 .8; c];
colormap(c1);

cb = colorbar;
cb.Limits = [0 100];
cb.Label.String = 'Concentration (%)';
cb.FontSize = 12;

xlabel('Longitude'); ylabel('Latitude'); zlabel('Depth (m)')

saveas(gcf, [dye, '_', ystr, mstr, '.png'])

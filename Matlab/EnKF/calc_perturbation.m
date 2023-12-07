clear; clc; close all

g = grd('NWP');

num_ens = 31;
Ne = num_ens;

for ei = 1:num_ens
    filename = ['ocean_rst_ens', num2char(ei+1,2),'_in.nc'];
    nc = netcdf(filename);
    temp = nc{'temp'}(40,:,:);
    temp_all(ei,:,:) = temp;
    close(nc)
end

temp_all_mean = squeeze(mean(temp_all));

base = netcdf('ocean_rst_ens01_in.nc');
temp_base = base{'temp'}(40,:,:);
close(base)

temp_diff = (temp_all_mean - temp_base).*g.mask_rho./g.mask_rho;
pcolor(temp_diff); shading flat
caxis([-5 5])

for ei = 1:num_ens
    filename = ['ocean_rst_ens', num2char(ei+1,2),'_in.nc'];
    nc = netcdf(filename);
    temp = nc{'temp'}(40,:,:);
    close(nc)
    temp_diff = (temp - temp_base).*g.mask_rho./g.mask_rho;
    figure;
    pcolor(g.lon_rho, g.lat_rho, temp_diff); shading flat
    colorbar;
    caxis([-5 5])
    title(['Ensemble ', num2char(ei+1,2)], 'FontSize', 20)
    %saveas(gcf, ['diff_ensemble', num2char(ei+1,2), '.png'])
end
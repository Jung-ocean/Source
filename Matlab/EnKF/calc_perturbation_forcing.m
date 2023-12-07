clear; clc; close all

g = grd('NWP');

num_ens = 31;
Ne = num_ens;

for ei = 1:num_ens
    filename = ['Tair_2003_ens', num2char(ei+1,2),'.nc'];
    nc = netcdf(filename);
    temp = nc{'Tair'}(576,:,:);
    temp_all(ei,:,:) = temp;
    close(nc)
end

temp_all_mean = squeeze(mean(temp_all));

base = netcdf('G:\Model\ROMS\Case\NWP\input\Tair_NWP_ECMWF_2003.nc');
temp_base = base{'Tair'}(576,:,:);
close(base)

temp_diff = (temp_all_mean - temp_base).*g.mask_rho./g.mask_rho;
pcolor(temp_diff); shading flat
caxis([-0.001 0.001])

for ei = 1:num_ens
    filename = ['Tair_2003_ens', num2char(ei+1,2),'.nc'];
    nc = netcdf(filename);
    temp = nc{'Tair'}(576,:,:);
    close(nc)
    %temp_diff = (temp - temp_base).*g.mask_rho./g.mask_rho;
    temp_diff = (temp - 0).*g.mask_rho./g.mask_rho;
    figure;
    pcolor(g.lon_rho, g.lat_rho, temp_diff); shading flat
    colorbar;
    caxis([0 30])
    title(['Ensemble ', num2char(ei+1,2)], 'FontSize', 20)
    %saveas(gcf, ['diff_ensemble', num2char(ei+1,2), '.png'])
end
clear; clc; close all

g = grd('NWP');

exp_step = 8;
ens_number = 1;
depth_ind = 40;

yyyy = 2013;
mm = 06;
dd = 02;

inidatenum = datenum(yyyy,mm,dd);
refdatenum = datenum(yyyy,1,1);

filenum_start = inidatenum - refdatenum + 1;
filenum = filenum_start:filenum_start+exp_step;

truepath = 'G:\DataAssimilation\case\2017\pre\output\true\';
controlpath = 'G:\DataAssimilation\case\2017\pre_samewind\output\control\';
adapath = '.\after_DA\';

for i = 2:exp_step
    tnc = netcdf([truepath, 'avg_', num2char(filenum(i), 4), '.nc']);
    cnc = netcdf([controlpath, 'his_ens', num2char(ens_number, 2), '_', num2char(filenum(i), 4), '.nc']);
    anc = netcdf([adapath, 'his_ens', num2char(ens_number, 2), '_', num2char(filenum(i), 4), '.nc']);
    
    % bda
    bda_temp(i-1,:,:) = squeeze(mean(cnc{'temp'}(2:end, depth_ind, :, :))) - tnc{'temp'}(1, depth_ind, :, :);
    
    % ada
    ada_temp(i-1,:,:) = squeeze(mean(anc{'temp'}(2:end, depth_ind, :, :))) - tnc{'temp'}(1, depth_ind, :, :);
    
    close(tnc); close(cnc); close(anc);
end

bda_temp = squeeze(mean(bda_temp));
ada_temp = squeeze(mean(ada_temp));

figure

map_J('DA');
m_pcolor(g.lon_rho, g.lat_rho, (abs(ada_temp) - abs(bda_temp)).*g.mask_rho./g.mask_rho); shading flat
colormap redblue
c = colorbar; c.FontSize = 15;
c.Label.String = 'deg C'; c.Label.FontSize = 15;
caxis([-2 2])

title(['diff abs(err) weekly'], 'FontSize', 15)
plot_point_2017('2017');

saveas(gcf, ['diff_abs(err)_weekly.png'])
clear; clc; close all

DAcase = '2017';

g = grd('NWP');
[lon_range, lat_range] = domain_J('DA');
[lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, lon_range, lat_range);

[target_lon, target_lat] = read_point_2017('2017');
a = dist([target_lon' target_lat'], [g.lon_rho(:)'; g.lat_rho(:)']);
rmse_index_all = [];
for ri = 1:length(target_lon)
    rmse_index = find(a(ri,:) <= 1);
    rmse_index_all = [rmse_index_all rmse_index];
end
rmse_index_all = sort(rmse_index_all);
rmse_index_all2 = unique(rmse_index_all);

exp_step = 8;
ens_number = 1;
depth_ind = 40;

yyyy = 2016;
mm = 06;
dd = 01;

inidatenum = datenum(yyyy,mm,dd);
refdatenum = datenum(yyyy,1,1);

filenum_start = inidatenum - refdatenum + 1;
filenum = filenum_start:filenum_start+exp_step;

truepath = 'D:\Data\Satellite\OSTIA\2016\';
controlpath = '.\control\';
adapath = '.\afterDA\';

for i = 1:exp_step
    tfilepath = [truepath, num2char(filenum(i),3), '\'];
    tfilename = dir([tfilepath, '*.bz2']); tfilename = tfilename.name;
    [status, result] = unzip7([tfilepath, tfilename], tfilepath);
    tfile = [tfilepath, tfilename(1:end-4)];
    
    tnc = netcdf(tfile);
    temp = tnc{'analysed_sst'}(:);
    scale_factor = tnc{'analysed_sst'}.scale_factor(:);
    add_offset = tnc{'analysed_sst'}.add_offset(:);
    mask = tnc{'mask'}(:);
    lat_sat = tnc{'lat'}(:);
    lon_sat = tnc{'lon'}(:);
    close(tnc); delete(tfile)
    
    % Convert raw temperature -> Kelvin -> Celsius (with mask)
    temp_Kelvin = temp*scale_factor + add_offset;
    temp_Celsius = temp_Kelvin - add_offset;
    mask(mask ~= 1) = nan;
    sst_sat = temp_Celsius.*mask;
    
    [lon_grid, lat_grid] = meshgrid(lon_sat, lat_sat);
    sst_sat_model = griddata(lon_grid, lat_grid, sst_sat, g.lon_rho, g.lat_rho);
    sst_sat_model = sst_sat_model.*g.mask_rho./g.mask_rho;
    
    cnc = netcdf([controlpath, 'his_ens', num2char(ens_number, 2), '_', num2char(filenum(i), 4), '.nc']);
    anc = netcdf([adapath, 'his_ensmean_', num2char(filenum(i), 4), '.nc']);
    filedate = datestr([anc{'ocean_time'}(end-1)/60/60/24 + refdatenum], 'yyyymmdd');
    
    % bda
    bda_temp = (squeeze(mean(cnc{'temp'}(2:end, depth_ind, :, :))) - sst_sat_model).*g.mask_rho./g.mask_rho;
    bda_temp_area = bda_temp(rmse_index_all2);
    bda_temp_area(isnan(bda_temp_area)) = [];
    bda_rms(i) = rms(bda_temp_area);
    
    % ada
    ada_temp = (squeeze(mean(anc{'temp'}(2:end, depth_ind, :, :))) - sst_sat_model).*g.mask_rho./g.mask_rho;
    ada_temp_area = ada_temp(rmse_index_all2);
    ada_temp_area(isnan(ada_temp_area)) = [];
    ada_rms(i) = rms(ada_temp_area);
    
    figure;
    map_J('DA');
    m_pcolor(g.lon_rho, g.lat_rho, (abs(ada_temp) - abs(bda_temp))); shading flat
    colormap redblue
    c = colorbar; c.FontSize = 15;
    c.Label.String = 'deg C'; c.Label.FontSize = 15;
    caxis([-3 3])
    
    title(['diff abs(err) ', filedate], 'FontSize', 15)
    plot_point_2017(DAcase);
    
    saveas(gcf, ['diff_abs(err)_ensmean_', filedate, '.png'])
    close(cnc); close(anc);
end
save rms_1_ensmean.mat ada_rms bda_rms
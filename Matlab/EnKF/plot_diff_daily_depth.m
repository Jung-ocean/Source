clear; clc; close all

g = grd('NWP');
[lon_range, lat_range] = domain_J('DA');
[lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, lon_range, lat_range);

[target_lon, target_lat] = read_point_2017('2017');
a = dist([target_lon' target_lat'], [g.lon_rho(:)'; g.lat_rho(:)']);
rmse_index_all = [];
for ri = 1:10
    rmse_index = find(a(ri,:) <= 1);
    rmse_index_all = [rmse_index_all rmse_index];
end
rmse_index_all = sort(rmse_index_all);
rmse_index_all2 = unique(rmse_index_all);

exp_step = 8;
ens_number = 32;
depth = 50; dstr = num2char(depth,2);

yyyy = 2016;
mm = 05;
dd = 01;

inidatenum = datenum(yyyy,mm,dd);
refdatenum = datenum(yyyy,1,1);

filenum_start = inidatenum - refdatenum + 1;
filenum = filenum_start:filenum_start+exp_step;

truepath = 'G:\DataAssimilation\case\2017_7\observation\';
controlpath = '.\control\';
adapath = '.\afterDA\';

bda_rms_all = [];
ada_rms_all = [];
err_diff_sum_all = [];
for i = 1:exp_step
    tfile = [truepath, 'avg_', num2char(filenum(i), 4), '.nc'];
    tnc = netcdf(tfile);
    ttemp = get_hslice(tfile, g.grd_file, 'temp', 1, -depth, 'r');
    
    cfile = [controlpath, 'his_ens', num2char(ens_number, 2), '_', num2char(filenum(i), 4), '.nc'];
    cnc = netcdf(cfile);
    clen = length(cnc{'ocean_time'}(:))
    ctemp = [];
    for ci = 2:clen
        ctemp(ci-1,:,:) = get_hslice(cfile, g.grd_file, 'temp', ci, -depth, 'r');
    end
    ctemp = squeeze(mean(ctemp));
        
    afile = [adapath, 'his_ens', num2char(ens_number, 2), '_', num2char(filenum(i), 4), '.nc'];
    anc = netcdf(afile);
    alen = length(anc{'ocean_time'}(:))
    atemp = [];
    for ai = 2:alen
        atemp(ai-1,:,:) = get_hslice(afile, g.grd_file, 'temp', ai, -depth, 'r');
    end
    atemp = squeeze(mean(atemp));
    
    filedate = datestr([anc{'ocean_time'}(end)/60/60/24 + refdatenum], 'yyyymmdd');
    
    ot = tnc{'ocean_time'}(:);
    % bda
    bda_temp = ctemp - ttemp;
    bda_temp_area = bda_temp(rmse_index_all2);
    bda_temp_area(isnan(bda_temp_area)) = [];
    bda_rms_all = [bda_rms_all; ot, rms(bda_temp_area)];
    
    % ada
    ada_temp = atemp - ttemp;
    ada_temp_area = ada_temp(rmse_index_all2);
    ada_temp_area(isnan(ada_temp_area)) = [];
    ada_rms_all = [ada_rms_all; ot, rms(ada_temp_area)];
    
    err_diff = (abs(ada_temp) - abs(bda_temp));
    err_diff_area = err_diff(rmse_index_all2);
    err_diff_sum = nansum(err_diff_area);
    err_diff_sum_all = [err_diff_sum_all; ot, err_diff_sum];
    
    figure;
    map_J('DA');
    m_pcolor(g.lon_rho, g.lat_rho, err_diff); shading flat
    colormap redblue
    c = colorbar; c.FontSize = 15;
    c.Label.String = 'deg C'; c.Label.FontSize = 15;
    caxis([-2 2])
    
    title(['diff abs(err) ', filedate, ' ', dstr,'m'], 'FontSize', 15)
    plot_point_2017('2017');
    
    saveas(gcf, ['diff_abs(err)_', filedate, '_', dstr, 'm.png'])
    
    close(tnc); close(cnc); close(anc);
end
save(['rms_1_daily_', dstr ,'m.mat'], 'ada_rms_all', 'bda_rms_all', 'err_diff_sum_all')
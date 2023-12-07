clear; clc; close all

yyyy = 2013:2013;
depth_all = [-10];
temp_contour = 14; tcstr = num2str(temp_contour);

datenum_ref = datenum(2013,1,1);
filenumber = 182:243;
fns = num2char(filenumber, 4);
filedate = datestr(filenumber + datenum_ref -1, 'mmdd');

for fi = 1:length(filenumber)
    filename = ['avg_', fns(fi,:), '.nc']; ncload(filename)

for di = 1:length(depth_all)
    depth = depth_all(di);
    dstr = num2str(-depth);

for yi = 1:length(yyyy)
    year_target = yyyy(yi); yts = num2str(year_target);
    
    g = grd('NWP');
    mask2 = g.mask_rho./g.mask_rho;
    
    avgfilepath = 'G:\Model\ROMS\Case\NWP\output\exp_SODA3\avg\daily\';
    avgfile = [avgfilepath, filename];
    anc = netcdf(avgfile);
    atemp = anc{'temp'}(1,1,:,:);
    atemp_bottom = atemp.*mask2;
      
    avari = get_hslice_J(avgfile,g,'temp', depth,'r');
    avari_mask = avari.*mask2;
    
    index = find(isnan(avari_mask) == 1);
    avari_mask(index) = atemp_bottom(index);
    
    
    targetfilepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\daily\'];
    targetfile = [targetfilepath, filename];
    tnc = netcdf(targetfile);
    ttemp = tnc{'temp'}(1,1,:,:);
    ttemp_bottom = ttemp.*mask2;
    
    tvari = get_hslice_J(targetfile,g,'temp', depth,'r');
    tvari_mask = tvari.*mask2;
            
    index = find(isnan(tvari_mask) == 1);
    tvari_mask(index) = ttemp_bottom(index);
    
    figure; hold on
    map_J('YECS_flt')
    
    [cs, h_mean] = m_contour(g.lon_rho, g.lat_rho, avari_mask, [temp_contour temp_contour], 'Color', 'r', 'Linewidth', 2);
    %clabel(cs, h_mean);
    
    [cs, h_target] = m_contour(g.lon_rho, g.lat_rho, tvari_mask, [temp_contour temp_contour], 'b', 'Linewidth', 2);
    %clabel(cs, h_target);
    
    title([filedate(fi,:), ' ', dstr, 'm ', tcstr, '^oC'], 'FontSize', 20)
    l = legend([h_mean, h_target], 'mean (1980-2015)', yts);
    l.FontSize = 10;
    
    saveas(gcf, [filedate(fi,:), '_', dstr, 'm_', tcstr, '.png'])
    
end
end
end
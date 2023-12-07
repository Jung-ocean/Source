clear; clc; close all

yyyy = 2013:2013;

g = grd('NWP');
domain_case = 'KODC_mag';
depth_all = [-10];

var = 'temp';
colorbarname = 'Temperature (deg C)'; clim = [-4 4]; contour_interval = [clim(1):2:clim(2)];
%colorbarname = 'Absolute SSH (m)'; clim = [-0.15 0.15]; contour_interval = [clim(1):0.05:clim(2)];

datenum_ref = datenum(2013,1,1);
filenumber = 182:243;
fns = num2char(filenumber, 4);
filedate = datestr(filenumber + datenum_ref -1, 'mmdd');

for yi = 1:length(yyyy)
    year_target = yyyy(yi); yts = num2str(year_target);
    
    filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\daily\'];
    avgfilepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\avg\daily\'];
    
    for fi = 1:length(filenumber)
                
        filename = ['avg_', fns(fi,:), '.nc'];
        targetfile = [filepath, filename];
        avgfile = [avgfilepath, filename];
        
        for di = 1:length(depth_all)
            depth = depth_all(di); tds = num2str(depth);
            
            var_target = get_hslice_J(targetfile,g,var,depth,'r');
            var_avg = get_hslice_J(avgfile,g,var,depth,'r');
            
            var_diff = var_target - var_avg;
            
            warning off
            figure
            map_J(domain_case);
            m_pcolor(g.lon_rho, g.lat_rho, var_diff.*g.mask_rho./g.mask_rho); shading flat
            colormap('redblue');
            
            [cs, h] = m_contour(g.lon_rho, g.lat_rho, var_diff.*g.mask_rho./g.mask_rho, contour_interval, 'k');
            clabel(cs, h);
            
            c = colorbar; c.FontSize = 15;
            c.Label.String = colorbarname; c.Label.FontSize = 15;
            caxis(clim)
            
            title([filedate(fi,:)], 'fontsize', 25)
            saveas(gcf, [var, '_', tds, 'm_', domain_case, '_', filedate(fi,:), '.png'])
            
            close all
        end
    end
end
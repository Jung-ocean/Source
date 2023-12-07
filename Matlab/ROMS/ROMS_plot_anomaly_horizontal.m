clear; clc; close all

yyyy = 1992:1992;
mm = 2:2;

filepath_all = 'G:\내 드라이브\Model\ROMS\Case\YECS\output\control\';

g = grd('YECS');
domain_case = 'YECS_large';
depth_all = [40];

%var = 'temp'; colorbarname = '^oC'; clim = [-4 4]; contour_interval = [clim(1):2:clim(2)];
var = 'salt'; colorbarname = 'g/kg'; clim = [-1 1]; contour_interval = [clim(1):.5:clim(2)];
%var = 'zeta'; colorbarname = 'm'; clim = [-0.1 0.1]; contour_interval = [clim(1):.05:clim(2)];

for yi = 1:length(yyyy)
    year_target = yyyy(yi); ystr = num2str(year_target);
    
    for mi = 1:length(mm)
        month_target = mm(mi); mstr = num2char(month_target,2);
        
        filename = ['monthly_', ystr, mstr, '.nc'];
        avgfile = [filepath_all, 'climate\monthly_climate', mstr, '.nc'];
        
        targetfile = [filepath_all, ystr, '\', filename];
        
        for di = 1:length(depth_all)
            depth = depth_all(di); dstr = num2str(depth);
            
            var_target = get_hslice_J(targetfile,g,var,depth,'r');
            var_avg = get_hslice_J(avgfile,g,var,depth,'r');
            
            var_diff = var_target - var_avg;
            
            warning off
            figure
            map_J(domain_case);
            m_pcolor(g.lon_rho, g.lat_rho, var_diff.*g.mask_rho./g.mask_rho); shading flat
            colormap('redblue2');
            
            [cs, h] = m_contour(g.lon_rho, g.lat_rho, var_diff.*g.mask_rho./g.mask_rho, contour_interval, 'k');
            h.LineWidth = 1;
            clabel(cs, h, 'FontSize', 25, 'FontWeight', 'bold');
            
            c = colorbar; c.FontSize = 25;
            %c.Label.String = colorbarname; c.Label.FontSize = 25;
            c.Title.String = colorbarname; c.Title.FontSize = 25;
            caxis(clim)
            
            %titlename = datestr(datenum(filename(9:end-3), 'yyyymm'), 'mmm yyyy');
            %title(['Anomaly ', titlename], 'FontSize', 25)
            setposition(domain_case)
            m_gshhs_i('patch', [.7 .7 .7])
            saveas(gcf, ['diff_', var, '_layer_', dstr, '_', domain_case, '_', ystr, mstr , '.png'])
            
        end
    end
end
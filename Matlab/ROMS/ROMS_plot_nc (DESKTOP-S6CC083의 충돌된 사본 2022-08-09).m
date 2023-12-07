%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

casename = 'YECS';
domain_case = 'KODC_large';
variable = 'temp';
layers = [-75];

for li = 1:length(layers)
    
    layer_target = layers(li);
    lts = num2str(layer_target);
    
    for yyyy = 1983:1983
        yi = yyyy; ystr = num2str(yi);
        if yyyy == 9999; ystr = 'climate'; end
        %cd(['G:\내 드라이브\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\', ystr, '\'])
        for mm = 8:8
            mi = mm; mstr = num2char(mi,2);
            
            filename = ['monthly_', ystr, mstr, '.nc'];
            %filename = ['ocean_avg_mon_', mstr, '.nc'];
            %filename = ['roms_ini_dye_', ystr, '_0601.nc'];
            %filename = ['roms_ini_YECS_NWPtest06.nc']
            
            figure('visible', 'off'); hold on
            switch variable
                case 'temp'
                    ROMS_plot_temp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                case 'htemp'
                    ROMS_plot_temp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                    hold on
                    g = grd(casename);
                    [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [50 50], 'r', 'linewidth', 2); %clabel(cs, h, 'FontSize', 15);
                case 'temp_comp'
                    ROMS_plot_temp_comp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                case 'temp_limit'
                    ROMS_plot_temp_limit_function(filename, 'temp', layer_target, casename, domain_case, 'contour on', 14)
                case 'htemp_comp'
                    ROMS_plot_temp_comp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                    g = grd(casename);
                    %m_pcolor(g.lon_rho,g.lat_rho,g.h.*g.mask_rho./g.mask_rho); shading flat
                    [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [50 100 200], 'r', 'linewidth', 2); %clabel(cs, h);
                case 'tuv'
                    ROMS_plot_temp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                    ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                case 'suv'
                    ROMS_plot_salt_function(filename, 'salt', layer_target, casename, domain_case, 'contour on')
                    ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                case 'uv'
                    ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                case 'uv_with_bar'
                    ROMS_plot_current_with_bar_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                case 'u'
                    ROMS_plot_u_function(filename, 'u', layer_target, casename, domain_case, 'contour off')
                case 'v'
                    ROMS_plot_v_function(filename, 'v', layer_target, casename, domain_case, 'contour off')
                case {'u_rho', 'v_rho'}
                    ROMS_plot_uvrho_function(filename, 'v_rho', 'u', 'v', layer_target, casename, domain_case, 'contour on')
                case {'hu_rho', 'hv_rho'}
                    ROMS_plot_uvrho_function(filename, 'v_rho', 'u', 'v', layer_target, casename, domain_case, 'contour off')
                    hold on
                    g = grd(casename);
                    [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [50 50], 'k', 'linewidth', 2); %clabel(cs, h, 'FontSize', 15);
                case 'w'
                    ROMS_plot_w_function(filename, 'w', layer_target, casename, domain_case, 'contour off')
                case 'huv'
                    ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                    hold on
                    g = grd('mask4southern');
                    [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [50 75 100], 'r', 'linewidth', 2); clabel(cs, h, 'FontSize', 15, 'Color', 'red');
                case 'zeta'
                    ROMS_plot_zeta_function(filename, 'zeta', casename, domain_case, 'contour on')
                case 'sla'
                    ROMS_plot_sla_function(filename, 'zeta', casename, domain_case, 'contour on')
                case 'slauv'
                    ROMS_plot_sla_function(filename, 'zeta', casename, domain_case, 'contour on')
                    ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                case 'hzeta'
                    ROMS_plot_zeta_function(filename, 'zeta', casename, domain_case, 'contour on')
                    hold on
                    g = grd(casename);
                    %m_pcolor(g.lon_rho,g.lat_rho,g.h.*g.mask_rho./g.mask_rho); shading flat
                    [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [50 100 200], 'r', 'linewidth', 2); clabel(cs, h, 'FontSize', 15);
                case 'salt'
                    ROMS_plot_salt_function(filename, 'salt', layer_target, casename, domain_case, 'contour on')
                case 'salt_comp'
                    ROMS_plot_salt_comp_function(filename, 'salt', layer_target, casename, domain_case, 'contour on')
                case 'density'
                    ROMS_plot_density_function(filename, layer_target, casename, domain_case, 'contour on')
                case 'density_comp'
                    ROMS_plot_density_comp_function(filename, layer_target, casename, domain_case, 'contour on')
                    
                case {'dye_01', 'dye_02', 'dye_03'}
                    ROMS_plot_dye_function(filename, variable, layer_target, casename, domain_case, 'contour on', 'logscale off')
            end
            
            %title([datestr(datenum(0,mi,1), 'mmm'), ' ', tys], 'fontsize', 25, 'Interpreter', 'none')
            setposition(domain_case)
            m_gshhs_i('patch', [.7 .7 .7])
            saveas(gcf, [variable, '_layer', lts, '_', casename, '_', domain_case, '_', ystr, mstr,'.png'])
            
        end
        %close all;
    end
    
end
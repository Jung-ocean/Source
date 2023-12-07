%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

casename = 'EYECS_20190904';
domain_case = 'KODC_small';
variable = 'temp';
layers = [1];

rotind = 1; theta = -20;

for li = 1:length(layers)
    
    layer_target = layers(li);
    lts = num2str(layer_target);
    
    for yyyy = 9999:9999
        yi = yyyy; ystr = num2str(yi);
        if yyyy == 9999; ystr = 'avg'; end
        %cd(['G:\내 드라이브\Model\ROMS\Case\YECS\output\control\', ystr, '\'])
        for mm = 1:12
            mi = mm; mstr = num2char(mi,2);
            
            %filepath = ['G:\내 드라이브\Model\ROMS\Case\YECS\output\control\monthly\'];
            %filename = [filepath, 'monthly_', ystr, mstr, '.nc'];
            filename = ['monthly_', ystr, mstr, '.nc'];

            figure('visible', 'off'); hold on
            switch variable
                case 'temp'
                    ROMS_plot_temp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                case 'temp_temp'
                    ROMS_plot_temp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                    
                    ystr_contour = num2str(str2num(ystr));
                    filepath_contour = ['G:\내 드라이브\Model\ROMS\Case\YECS\output\control\', ystr_contour, '\'];
                    filename_contour = [filepath_contour, 'monthly_', ystr_contour, '08', '.nc'];
                    ROMS_plot_temp_function_contour(filename_contour, 'temp', -50, casename, domain_case, 'contour on')
                case 'htemp'
                    ROMS_plot_temp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                    hold on
                    g = grd(casename);
                    [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [50 50], 'r', 'linewidth', 2); %clabel(cs, h, 'FontSize', 15);
                case 'temp_comp'
                    ROMS_plot_temp_comp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                    g = grd(casename);
                    [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, -[layer_target layer_target], 'r', 'linewidth', 2); %clabel(cs, h, 'FontSize', 15);
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
                case 'ubar'
                    ROMS_plot_ubar_function(filename, 'ubar', 'vbar', casename, domain_case, rotind, theta)
                case 'vbar'
                    ROMS_plot_vbar_function(filename, 'ubar', 'vbar', casename, domain_case, rotind, theta)
                case 'uvbar'
                    ROMS_plot_current_bar_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                    
                case {'dye_01', 'dye_02', 'dye_03'}
                    ROMS_plot_dye_function(filename, variable, layer_target, casename, domain_case, 'contour on', 'logscale on')
            end
            
            %title([datestr(datenum(0,mi,1), 'mmm'), ' ', tys], 'fontsize', 25, 'Interpreter', 'none')
            setposition(domain_case)
            m_gshhs_i('patch', [.7 .7 .7])
            saveas(gcf, [variable, '_layer', lts, '_', casename, '_', domain_case, '_', ystr, mstr,'.png'])
            
        end
        close all;
    end
    
end
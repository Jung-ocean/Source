function ROMS_plot_dye_function(filename, variname, layer_ind, casename, domain_case, contour, logscale)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_temp_function(filename, variname, depth_ind, casename, domain_case, contour)
%
%   filename: model output filename (usually netcdf format)
%   variname: temperature variable name in model output file (ex, 'temp', 'temperautre' ... )
%   layer_ind: layer number you want to plot
%   casename: model case (grid)
%   domain_case: domain case (figure)
%   contour: 'contour on' or 'contour off'
%
%   J.Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%scale_case = 690e3/(100);
scale_case = 1500/(100);
FS = 15;

if strcmp(logscale, 'logscale on')
    clim = [-8 -1];
    contour_interval = [clim(1):1:clim(2)];
    colorbarname = 'log_1_0 [Bq/L]';
    scale_factor = 1;
    colormapname = parula;
else
    %clim = [1e-4 1]; contour_interval = [.5 .5];
    clim = [0 50]; contour_interval = [10 10];
    colorbarname = '%';
    scale_factor = 1;
    %colormapname = flipud(parula);
    colormapname = parula;
end

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

if layer_ind > 0
    
    nc = netcdf(filename);
    if length(size(nc{variname})) == 3
        vari = nc{variname}(layer_ind,:,:);
    elseif length(size(nc{variname})) == 4
        vari = nc{variname}(1,layer_ind,:,:);
    end
    close(nc)
    vari = vari*scale_factor; % Percentage
    
    vari(vari < 0) = 0;
    vari(vari > 100) = 100;
%     if strcmp(domain_case, 'YECS_large')
%         vari(vari == 0) = NaN;
%     end
    
    vari_mask = vari.*mask2;
    if strcmp(logscale, 'logscale on')
        if strcmp(casename, 'NP')
            vari_mask = log10(vari_mask.*scale_case);
        else
            vari_mask = log10(vari_mask);
        end
        vari_mask(vari_mask < clim(1)) = NaN; %%%%%%%
    end
    
    map_J(domain_case)
    
    m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap(colormapname); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k', 'LineWidth', 1);
        clabel(cs, h, 'FontSize', FS, 'LabelSpacing', 500);
    end
    
    c = colorbar; c.FontSize = FS;
    c.Title.String = colorbarname; c.Title.FontSize = FS;
    caxis(clim);
    if strcmp(logscale, 'logscale on')
        %c.TickLabels = {'10^{-12}' '10^{-10}'  '10^{-8}' '10^{-6}' '10^{-4}' '10^{-2}' '1' '10^{2}'} ;
        %c.TickLabels = {'10^{-4}' '10^{-3}' '10^{-2}' '10^{-1}' '10^{0}' '10^{1}' '10^{2}'} ;
        %c.TickLabels = {'10^{-8}' '10^{-6}' '10^{-4}' '10^{-2}' '10^{0}' '10^{2}'} ;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif layer_ind < 0
    
    vari = get_hslice_J(filename,g,variname,layer_ind,'r');
    %vari = vari./10; % Percentage
    
    vari(vari < 0) = 0;
    vari(vari > 100) = 100;
    %     if strcmp(domain_case, 'YECS_large')
    %         vari(vari == 0) = NaN;
    %     end
    
    vari_mask = vari.*mask2;
    if strcmp(logscale, 'logscale on')
        if strcmp(casename, 'NP')
            vari_mask = log10(vari_mask.*scale_case);
        else
            vari_mask = log10(vari_mask);
        end
        vari_mask(vari_mask < clim(1)) = NaN; %%%%%%%
    end
    
    map_J(domain_case)
    
    warning off
    m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap(colormapname); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k', 'LineWidth', 1);
        clabel(cs, h, 'FontSize', FS, 'LabelSpacing', 500);
    end
    
    c = colorbar; c.FontSize = FS;
    c.Title.String = colorbarname; c.Title.FontSize = FS;
    caxis(clim);
    
end
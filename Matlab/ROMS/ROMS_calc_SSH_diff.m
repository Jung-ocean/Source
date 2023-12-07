%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

casename = 'NWP';
domain_case = 'NWP';
variable = 'ssh';
layer_target = 40; lts = num2char(layer_target,2);

for yyyy = 2013:2013
    yi = yyyy; tys = num2str(yi);
    
    path1 = ['G:\Model\ROMS\Case\NWP\output\exp_HYCOM\', tys, '_2012_SODA_bndy_ini\'];
    path2 = ['G:\Model\ROMS\Case\NWP\output\exp_HYCOM\', tys, '\'];
    
    for mm = 1:12
        mi = mm; tms = num2char(mi,2);
        
        filename1 = ['monthly_', tys, tms, '.nc'];
        filename2 = filename1;
        
        nc1 = netcdf([path1, filename1]);
        temp1 = nc1{'zeta'}(:,:);
        close(nc1)
        
        nc2 = netcdf([path2, filename2]);
        temp2 = nc1{'zeta'}(:,:);
        close(nc2)
        
        vari = temp1 - temp2;
        
        g = grd(casename);
        mask2 = g.mask_rho./g.mask_rho;
        
        clim = [-0.5 0.5];
        contour_interval = [clim(1):0.5:clim(2)];
        colorbarname = 'ssh (m)';
        
        vari_mask = vari.*mask2;
        
        figure; hold on
        map_J(domain_case)
        m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap('redblue'); shading flat;
        
        %if strcmp(contour, 'contour on')
       %     [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
       %     clabel(cs, h);
        %end
        
        c = colorbar; c.FontSize = 15;
        c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
        
        title(['SSH diff (SODA-HYCOM) ', tys, tms], 'fontsize', 25)
        saveas(gcf, ['SSH_diff_(SODA3-HYCOM)_', tys, tms,'.png'])
        
    end
end
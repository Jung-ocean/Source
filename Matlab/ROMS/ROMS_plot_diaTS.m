clear; clc; close all

yyyy = 2013;
mm = 8:8;

% refdatenum = datenum(yyyy,1,1);
% filenumber = 182:243;
% filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

tracers = {'temp'};
varis = {'rate', 'hadv', 'vadv', 'hdiff', 'vdiff'};
titles = {'temp_rate', 'Horizontal advection', 'Vertical advection', 'Horizontal diffusion', 'Vertical diffusion'};

casename = 'NWP';
domain_case = 'KODC_small';

g = grd(casename);

for yi = 1:length(yyyy)
    year_target = yyyy(yi); yts = num2str(year_target);
    for mi = 1:length(mm)
        
        mts = num2char(mm(mi), 2);
        
        filename = ['monthly_dia_', yts, mts, '.nc'];
        nc = netcdf(filename);
        
        for ti = 1:length(tracers)
            tracer = tracers{ti};
            
            for vi = 1:length(varis)
                var_str = [tracer, '_', varis{vi}];
                var = nc{var_str}(:);
                var_surf = squeeze(var(40,:,:));
                
                figure;
                map_J(domain_case)
                lon = g.lon_rho;
                lat = g.lat_rho;
                mask = g.mask_rho;
                mask2 = mask./mask;
                
                m_pcolor(lon, lat, var_surf.*mask2); shading flat
                c = colorbar;
                c.Label.String = '^oC/s';
                c.FontSize = 12;
                caxis([-1e-6 1e-6])
                
                saveas(gcf, [var_str, '_', yts, mts, '.png'])
                close all
            end % vi
        end % ti
    end % mi
end % yi
clear; clc; close all

yyyy = 2019;

rotind = 1; theta = -20;

%filenumber = 153:213; % Jun. ~ Jul.
%filenumber = [191 193 232 234];
filenumber = [190:193];

refdatenum = datenum(yyyy,1,1);
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

directions = {'ubar', 'vbar'};
%varis = {'cor', 'hadv', 'vadv', 'prsgrd', 'hvisc', 'vvisc'};
%varis = {'sstr', 'cor', 'prsgrd', 'bstr'};
varis = {'accel', 'cor', 'hadv', 'hvisc', 'prsgrd', 'sstr', 'bstr'};
titles = {'Acceleration', 'Coriolis', 'Horizontal advection', 'Horizontal viscosity', 'Pressure gradient', 'Surface stress', 'Bottom stress'};
%varis = {'cor', 'prsgrd', 'vvisc'};

casename = 'EYECS_20220110';
domain_case = 'southern';

g = grd(casename);

for yi = 1:length(yyyy)
    year_target = yyyy(yi); ystr = num2str(year_target);
    for fi = 1:length(filenumber)
        
        fns = num2char(filenumber(fi), 4);
        savename = filedate(fi,:);
        filename = ['dia_', fns, '.nc'];
        
%         mstr = num2char(mm(mi),2);
%         filename = ['monthly_dia_', ystr, mstr, '.nc'];
        
        nc = netcdf(filename);
        
        for di = 1:length(directions)
            direction = directions{di};
            
            for vi = 1:length(varis)
                var_str = [direction, '_', varis{vi}];
          
                ubar = nc{['ubar_', varis{vi}]}(:);
                vbar = nc{['vbar_', varis{vi}]}(:);
                
                skip = 1; npts = [0 0 0 0];
                [ubar_rho,vbar_rho,lon,lat,mask] = uv_vec2rho(ubar.*g.mask_u,vbar.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
                    
                    if rotind == 1
                        ubar_rho = cosd(theta)*ubar_rho + -sind(theta)*vbar_rho;
                        vbar_rho = sind(theta)*ubar_rho + cosd(theta)*vbar_rho;
                    end
                                            
                    var = eval([direction, '_rho']);
                
                figure;
                map_J(domain_case)
                lon = g.lon_rho;
                lat = g.lat_rho;
                mask = g.mask_rho;
                mask2 = mask./mask;
                
                m_pcolor(lon, lat, var.*mask2); shading flat
                colormap('redblue2')
                c = colorbar;
                c.Title.String = 'm/s^2';
                c.FontSize = 12;
                %caxis([-1e-4 1e-4])
                %caxis([-3e-5 3e-5])
                caxis([-5e-5 5e-5])
                %title([var_str, ' ', ystr, mstr], 'interpreter', 'none', 'FontSize', 25)
                %title([var_str, ' ', savename], 'interpreter', 'none', 'FontSize', 25)
                title([titles{vi}], 'interpreter', 'none', 'FontSize', 25)
                
                g = grd(casename);
                [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [30 60], 'Color', [.5 .5 .5], 'linewidth', 2);
                clabel(cs, h, 'FontSize', 15, 'Color', [.5 .5 .5]);
                
                saveas(gcf, [var_str, '_', savename, '.png'])
                %saveas(gcf, [var_str, '_', ystr, mstr, '.png'])
                close all
            end % vi
        end % di
    end % mi
end % yi
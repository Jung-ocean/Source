clear; clc; close all

yyyy = 2013;
mm = 7:8;

%refdatenum = datenum(yyyy,1,1);
%filenumber = 182:243;
%filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

directions = {'u'}%, 'v'};
%varis = {'cor', 'hadv', 'vadv', 'prsgrd', 'hvisc', 'vvisc'};
%varis = {'sstr', 'cor', 'prsgrd', 'bstr'};
%varis = {'cor', 'hadv', 'hvisc', 'prsgrd', 'sstr', 'bstr'};
varis = {'cor', 'prsgrd', 'vvisc'};

casename = 'EYECS_20190904';
domain_case = 'southern';

g = grd(casename);

for yi = 1:length(yyyy)
    year_target = yyyy(yi); ystr = num2str(year_target);
    for mi = 1:length(mm)
        
        %fns = num2char(filenumber(fi), 4);
        %savename = filedate(fi,:);
        %filename = ['dia_', fns, '.nc'];
        
        mstr = num2char(mm(mi),2);
        filename = ['monthly_dia_', ystr, mstr, '.nc'];
        
        nc = netcdf(filename);
        
        for di = 1:length(directions)
            direction = directions{di};
            
%            vmom=(v_accel-(v_cor+v_hadv+v_vadv+v_prsgrd+v_hvisc+v_vvisc));
%            umom=(u_accel-(u_cor+u_hadv+u_vadv+u_prsgrd+u_hvisc+u_vvisc));
            
%            ubarmom = ubar_accel - (ubar_bstr+ubar_cor+ubar_hadv+ubar_hvisc+ubar_prsgrd+ubar_sstr);
%            vbarmom = vbar_accel - (vbar_bstr+vbar_cor+vbar_hadv+vbar_hvisc+vbar_prsgrd+vbar_sstr);
            
            % for i = 1:g.N
            %     umom(i,:,:) = squeeze(umom(i,:,:)).*g.mask_u./g.mask_u;
            %     vmom(i,:,:) = squeeze(vmom(i,:,:)).*g.mask_v./g.mask_v;
            % end
            
            for vi = 1:length(varis)
                var_str = [direction, '_', varis{vi}];
                var = nc{var_str}(:);
                var_surf = squeeze(var(40,:,:));
                
                figure;
                map_J(domain_case)
                lon = eval(['g.lon_', direction(1)]);
                lat = eval(['g.lat_', direction(1)]);
                mask = eval(['g.mask_', direction(1)]);
                mask2 = mask./mask;
                
                m_pcolor(lon, lat, var_surf.*mask2); shading flat
                c = colorbar;
                c.Label.String = 'm/s^2';
                c.FontSize = 12;
                %caxis([-1e-4 1e-4])
                %caxis([-3e-5 3e-5])
                caxis([-1e-5 1e-5])
                title([var_str, ' ', ystr, mstr], 'interpreter', 'none', 'FontSize', 25)
                %title([var_str, ' ', savename], 'interpreter', 'none', 'FontSize', 25)
                
                %saveas(gcf, [var_str, '_', savename, '.png'])
                saveas(gcf, [var_str, '_', ystr, mstr, '.png'])
                close all
            end % vi
        end % di
    end % mi
end % yi
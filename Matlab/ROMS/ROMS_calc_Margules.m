clear; clc

yyyy = [1980:2015, 9999];
mm = 7:8;

gd = grd('NWP');

section = 'lon';
location = 127.6;
range = [33.7, 34.4];

for yi = 1:length(yyyy)
    yts = num2str(yyyy(yi));
    for mi = 1:length(mm)
        mts = num2char(mm(mi),2);
        
        if yyyy(yi) == 1980
            filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\old_1980\1980_ver38\output_14\'];
        elseif yyyy(yi) == 9999
            yts = 'avg';
            filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\'];
        else
            filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\'];
        end
        ncload([filepath, 'monthly_', yts, mts, '.nc']);
        depth = zlevs(gd.h,zeta,gd.theta_s,gd.theta_b,gd.hc,gd.N,'rho', 2);
        
        pdens = zeros(size(depth));
        for si = 1:gd.N
            pres = sw_pres(squeeze(depth(si,:,:)), gd.lat_rho);
            pdens(si,:,:) = sw_pden_ROMS(squeeze(salt(si,:,:)), squeeze(temp(si,:,:)), pres, 0);
        end
        
        var_str = 'density';
        var = pdens;
        [loc, loc_ind, xind, dir_str, Xi, Yi, data] = ROMS_plot_vertical_function(gd, depth, var_str, var, section, location, range);
        close all;
        dens = data;
        
        var_str = 'u';
        var = u;
        [loc, loc_ind, xind, dir_str, Xi, Yi, data] = ROMS_plot_vertical_function(gd, depth, var_str, var, section, location, range);
        close all;
        uvel = data;
        
        index_u24 = find(dens < 1025);
        index_l24 = find(dens > 1025);
        
        d1 = mean(dens(index_u24));
        d2 = mean(dens(index_l24));
        
        u1 = nanmean(uvel(index_u24));
        u2 = nanmean(uvel(index_l24));
        
        f = 10^-4;
        g = 10;
        
        u1d1_u2d2 = u1*d1 - u2*d2;
        d2_d1 = d2-d1;
        dhdy = f*(u1d1_u2d2) / (g*(d2_d1));
        Margules = dhdy*0.6*111*1000;
        
        eval(['u1d1_u2d2_', mts, '(yi) = u1d1_u2d2;']);
        eval(['d2_d1_', mts, '(yi) = d2_d1;']);
        eval(['Marg_', mts, '(yi) = Margules;']);
    end
end

save results.mat Marg_07 Marg_08 d2_d1_07 d2_d1_08 u1d1_u2d2_07 u1d1_u2d2_08
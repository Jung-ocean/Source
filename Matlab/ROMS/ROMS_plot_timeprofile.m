clear; clc; close all

yyyy = 2013;

refdatenum = datenum(yyyy,1,1);
filenumber = 182:243;
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

varis = {'temp', 'zeta'};

casename = 'NWP';

g = grd(casename);

lon = 128; lon_dist = abs(g.lon_rho - lon);
lat = 34.2; lat_dist = abs(g.lat_rho - lat);

[lat_ind,lon_ind] = find(lon_dist == min(min(lon_dist)) & lat_dist == min(min(lat_dist)));
depth = g.z_r(:,lat_ind, lon_ind);

lat_ind = 182:197;

all = zeros(16,62,2);
for fi = 1:length(filenumber)
    
    fns = num2char(filenumber(fi), 4);
    savename = filedate(fi,:);
    
    filename = ['..\daily\avg_', fns, '.nc'];
    nc = netcdf(filename);
    
    for vi = 1:length(varis)
        if vi == 1
            var_str = varis{vi};
            vari = get_hslice_J(filename,g,var_str,-1,'r');
            var = vari(lat_ind, lon_ind);
            all(:,fi,vi) = var;
        else
            var_str = varis{vi};
            var = nc{var_str}(:,lat_ind, lon_ind);
            all(:,fi,vi) = var;
        end
        
    end % vi
end % fi

for vi = 1:length(varis)
    figure; hold on;
    
    if vi == 1
        pcolor(filenumber+1, g.lat_rho(lat_ind, lon_ind), all(:,:,vi))
        [cs, h] = contour(filenumber+1, g.lat_rho(lat_ind, lon_ind), all(:,:,vi), [20:3:32], 'color', 'red', 'LineWidth', 2);
        clabel(cs, h, 'Color', 'white', 'FontSize', 15)
        caxis([20 32])
        c = colorbar;
        c.Label.String = '(deg C)'
    else
        
        pcolor(filenumber+1, g.lat_rho(lat_ind, lon_ind), all(:,:,vi))
        [cs, h] = contour(filenumber+1, g.lat_rho(lat_ind, lon_ind), all(:,:,vi), [-0.2:0.1:0.5], 'color', 'red', 'LineWidth', 2);
        clabel(cs, h, 'Color', 'white', 'FontSize', 15)
        caxis([-0.2 0.5])
        c = colorbar;
        c.Label.String = 'Absolute SSH (m)'
    
    end
    
    xtickindex = 1:5:length(filenumber);
    
    set(gca, 'Xtick', filenumber(xtickindex))
    set(gca, 'XtickLabel', filedate(xtickindex,:))
    axis tight
    ylim([-50 0])
    ylabel('Depth (m)')
    
    saveas(gcf, [varis{vi}, '.png'])
    
end
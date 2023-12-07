clear; clc; close all

yyyy = 2013;

refdatenum = datenum(yyyy,1,1);
filenumber = 182:243;
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

varis = {'temp', 'u', 'v', 'w'};

casename = 'EYECS_20190904';

g = grd(casename);

lon = 127.6667; lon_dist = abs(g.lon_rho - lon);
lat = 34.4167; lat_dist = abs(g.lat_rho - lat);

dist=sqrt((g.lon_rho-lon).^2+(g.lat_rho-lat).^2);
min_dist=min(min(dist));
[x,y]=find(dist==min_dist);
lat_ind = x;
lon_ind = y;
        
depth = g.z_r(:,lat_ind, lon_ind);
depth_w = g.z_w(:,lat_ind, lon_ind);

all = zeros(40,62,3);
all_w = zeros(41,62,1);
for fi = 1:length(filenumber)
    
    fns = num2char(filenumber(fi), 4);
    savename = filedate(fi,:);
    
    filename = ['.\daily\avg_', fns, '.nc'];
    nc = netcdf(filename);
    
    for vi = 1:length(varis)
        if vi == 4
            var_str = varis{vi};
            var = nc{var_str}(:,:,lat_ind, lon_ind);
            
            all_w(:,fi,1) = var;
        else
            var_str = varis{vi};
            var = nc{var_str}(:,:,lat_ind, lon_ind);
            
            all(:,fi,vi) = var;
        end
        
    end % vi
end % fi

for vi = 1:length(varis)
    figure; hold on;
    
    if vi == 1
        pcolor(filenumber+1, depth, all(:,:,vi))
        [cs, h] = contour(filenumber+1, depth, all(:,:,vi), [14:4:26], 'color', 'red', 'LineWidth', 2);
        clabel(cs, h, 'Color', 'white', 'FontSize', 15)
        caxis([10 30])
        c = colorbar;
        c.Label.String = '(deg C)'
    elseif vi == 4
        
        pcolor(filenumber+1, depth_w, all_w(:,:,1))
        caxis([-2e-4 2e-4])
        c = colorbar;
        c.Label.String = '(m/s)';
    else
        
        pcolor(filenumber+1, depth, all(:,:,vi))
        c = colorbar; colormap('jet')
        c.Label.String = '(m/s)'
        if vi == 2
            [cs, h] = contour(filenumber+1, depth, all(:,:,vi), [-1:0.2:1], 'color', 'blue', 'LineWidth', 2);
            clabel(cs, h, 'Color', 'k', 'FontSize', 15)
            caxis([-1 1])
        elseif vi == 3
            caxis([-0.2 0.2])
        end
    end
    
    xtickindex = 1:5:length(filenumber);
    
    set(gca, 'Xtick', filenumber(xtickindex))
    set(gca, 'XtickLabel', filedate(xtickindex,:))
    axis tight
    ylim([-50 0])
    ylabel('Depth (m)')
    
    %saveas(gcf, [varis{vi}, '.png'])
    
end
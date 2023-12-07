clear; clc; close all

load .\forcing\point.mat
distance_coastal = 3; % ~50km

x = x(25);
y = y(25);

yyyy = 2013;

refdatenum = datenum(yyyy,1,1);
filenumber = 182:243;
filedate = datestr(refdatenum + filenumber - 1, 'mmdd');

varis = {'temp', 'ubar'};

casename = 'EYECS_20190904';

g = grd(casename);

for fi = 1:length(filenumber)
    
    fns = num2char(filenumber(fi), 4)
    savename = filedate(fi,:);
    
    filename = ['.\daily\avg_', fns, '.nc'];
    nc = netcdf(filename);
    temp = nc{'temp'}(:);
    ubar = nc{'ubar'}(:);
    close(nc)
    vari = get_hslice_J(filename,g,'temp',-1,'r');
    
    for ii = 1:length(x)
    SST_tmp = vari(y:-1:y-(distance_coastal),x(ii));
    SST_coastal(fi,ii) = mean(SST_tmp);
    
    ubar_tmp = ubar(y:-1:y-(distance_coastal),x(ii));
    ubar_coastal(fi,ii) = mean(ubar_tmp);
    end
    
end % fi
SST_coastal(SST_coastal > 100) = NaN;
ubar_coastal(ubar_coastal > 100) = NaN;

SST_mean = nanmean(SST_coastal,2);
ubar_mean = nanmean(ubar_coastal,2);



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
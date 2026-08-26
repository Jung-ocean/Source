clear; clc; close all

g = grd('NANOOS');
file = '/data/jungjih/ROMS_BSL/ocean_his_7588.nc';
bsl = ncread(file, 'bsl');

f1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 500 800])
plot_map('US_west', 'mercator', 'l')
for ti = 1:size(bsl,3)
    bsl_tmp = 100*(bsl(:,:,ti) - bsl(:,:,1));
    p = pcolorm(g.lat_rho, g.lon_rho, bsl_tmp);
    colormap redblue
    caxis([-2 2])
    if ti == 1
        c = colorbar;
        c.Title.String = 'cm';
    end

    % Make gif
    gifname = ['test.gif'];
    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ti == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end
    
    delete(p)
end
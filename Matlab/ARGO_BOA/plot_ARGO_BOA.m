%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot Argo BOA
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2018:2022;
mm_all = 1:12;

casename = 'Bering';
vari_str = 'salt';
layer = 1; % 1 = surface, 58 = bottom
climit = [31.5 33.5];
unit = 'g/kg';

ind_png = 1;
ind_gif = 1;

% Model grid structure
g = grd('BSf');

f1 = figure; hold on;
set(gcf, 'Position', [1 200 1300 800])
plot_map(casename, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k')

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        timenum = datenum(yyyy,mm,15);

        % Argo
        filepath_Argo = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];
        filepattern_Argo = fullfile(filepath_Argo, (['*', ystr, '_', mstr, '*.mat']));
        filename_Argo = dir(filepattern_Argo);

        file_Argo = [filepath_Argo, filename_Argo.name];
        Argo = load(file_Argo);

        lon_Argo = Argo.lon'-360;
        lat_Argo = Argo.lat';
        vari_Argo = Argo.salt(:,:,1)';

        p = pcolorm(lat_Argo, lon_Argo, vari_Argo);
        uistack(p, 'bottom');
        caxis(climit);
        c = colorbar;
        c.Title.String = unit;

        title(['Argo BOA ', vari_str, ' layer ', num2str(layer), ' (', datestr(timenum, 'mmm, yyyy'), ')'], 'FontSize', 15)

        if ind_png == 1
            print([vari_str, '_layer_', num2str(layer), '_', casename, '_', datestr(timenum, 'yyyymm')], '-dpng')
        end

        if ind_gif == 1
            % Make gif
            gifname = [vari_str, '_layer_', num2str(layer), '_', casename, '.gif'];

            frame = getframe(f1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if yi == 1 && mi == 1
                imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
            else
                imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
            end
        end % ind_gif

        delete(p)
    end
end

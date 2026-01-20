clear; clc; close all

isplot = 1;

g = grd('NANOOS');
lat = g.lat_rho;
lon = g.lon_rho;
H = g.h;
rho0 = 1026;
gconst = 9.8;

datenum_start = datenum(2024,5,18);
dsstr = datestr(datenum_start, 'yyyymmdd');
datenum_end = datenum(2024,5,21);
destr = datestr(datenum_end, 'yyyymmdd');

% Load model variables
[timenum, zeta, temp, salt] = load_models_varis_for_IT('NANOOS', g, datenum_start, datenum_end);

% Load background density
avg_pden = load('ROMS_avg_pden.mat');
depth_rhob = avg_pden.depth_extra;
rhob = avg_pden.rhob_extra;

% BSL Calculation
BSL = NaN.*zeta;
for ti = 1:length(timenum)
    zeta_tmp = zeta(:,:,ti);
    temp_tmp = temp(:,:,:,ti);
    salt_tmp = salt(:,:,:,ti);

    [p_bc_tmp, dz_tmp] = calc_p_bc(g, zeta_tmp, temp_tmp, salt_tmp, rhob, depth_rhob);
    p_surf = p_bc_tmp(:,:,end);
    BSL_tmp = p_surf/(rho0*gconst);
    
    BSL(:,:,ti) = BSL_tmp;

%     % Analytical method
%     integrand = rho_prime.*gconst.*(1+(z_tmp-eta_tmp)./(H_tmp+eta_tmp));
%     p_surf = -sum(integrand.*dz_tmp);
%     BSL_tmp = p_surf/(rho0*gconst);

    disp(['BSL calculation ', num2str(ti), ' / ', num2str(length(timenum)), ' ...'])
end

% Bandpass filter
dt = 2; % 2 hour
constituent = 'M2';
istest = 0;

BSL_filtered = tide_bandpass_butter4(BSL, dt, constituent, istest);

% Save
save(['ROMS_BSL_', dsstr, '_', destr, '.mat'], 'timenum', 'lon', 'lat', 'BSL_filtered');

% Plot
if isplot == 1
    unit = 'cm';
    climit = [-2 2];
    interval = [.5];
    [color, contour_interval] = get_color('redblue', climit, interval);

    f1 = figure; hold on;
    set(gcf, 'Position', [1 200 500 800])
    for ti = 1:size(BSL_filtered,3)
        BSL_tmp = 100*squeeze(BSL_filtered(:,:,ti)); % m to cm
        if ti == 1
            plot_map('US_west', 'mercator', 'l')
            contourm(lat, lon, g.h, [200 1000], 'k');

            c = colorbar;
            c.Title.String = unit;
            c.Ticks = contour_interval;
        end
        p = plot_contourf([], lat, lon, BSL_tmp, color, climit, contour_interval);
        title(['ROMS M2 BSL (', datestr(timenum(ti), 'mm/dd/yy HH:MM'), ')'])

        % Make gif
        gifname = ['ROMS_BSL_', dsstr, '_', destr, '.gif'];
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
end
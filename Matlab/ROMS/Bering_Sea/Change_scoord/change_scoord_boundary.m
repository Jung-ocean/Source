%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Change vertical coordinate using theta_s, theta_b, and hc
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except filename; clc; close all

theta_s_new = 7;
theta_b_new = 3;
hc_new = 50;

varis = {'temp', 'salt', 'u', 'v'};
types = {'rho', 'rho', 'u', 'v'};
directions = {'north', 'east', 'south'}; % west is closed

% File
filepath = '/data/jungjih/ROMS_BSf/s7b3/';
% filename = 'BSf_HYCGLBy_Jan22_Jun22_thinice_bry.nc';
file = [filepath, filename];
ot = ncread(file, 'bry_time');

filename_new = [filename(1:end-3), '_s', num2str(theta_s_new), 'b', num2str(theta_b_new), '.nc'];
if ~exist([filepath, filename_new])
    copyfile(file, [filepath, filename_new])
end
file_new = [filepath, filename_new];

% Grid information
g = grd('BSf');
N = g.N;
theta_s_old = g.theta_s;
theta_b_old = g.theta_b;
hc_old = g.hc;

for vi = 1:length(varis)
    for di = 1:length(directions)
        direction = directions{di};

        vari_str = [varis{vi}, '_', direction];
        type = types{vi};

        h = g.h;
        lat = g.(['lat_', type]);
        lon = g.(['lon_', type]);

        switch direction
            case 'north'
                loc = lon(:,end);
                h_1d = h(:,end);
            case 'east'
                loc = lat(end,:)';
                h_1d = h(end,:)';
            case 'west'
                loc = lat(1,:)';
                h_1d = h(1,:)';
            case 'south'
                loc = lon(:,1);
                h_1d = h(:,1);
        end

        if ~isequal(size(loc), size(h_1d))
            h_1d = (h_1d(1:end-1) + h_1d(2:end))/2;
        end

        % Make latitude and longitude 3-D
        % +2 because of additional surface and bottom layers
        loc_2d = repmat(loc, [1 N+2]);

        vari_new = NaN([length(loc) N length(ot)]);
        for ti = 1:length(ot)

            % Calculate old and new depths at data point
            zeta = double(ncread(file, ['zeta_', direction], [1 ti], [Inf 1]));
            if ~isequal(size(loc), size(zeta))
                zeta = (zeta(1:end-1,:) + zeta(2:end,:))/2;
            end

            z_r = squeeze(zlevs(h_1d, zeta, theta_s_old, theta_b_old, hc_old, N, 'r', 2));
            % Add additional surface and bottom layers
            z_r_p2 = NaN(size(loc_2d));
            z_r_p2(:,2:end-1) = z_r;
            z_r_p2(:,1) = z_r(:,1) - 1000;
            z_r_p2(:,end) = z_r(:,end) + 10;

            z_r_new = squeeze(zlevs(h_1d, zeta, theta_s_new, theta_b_new, hc_new, N, 'r', 2));

            % Read in variable
            vari = double(ncread(file, vari_str, [1 1 ti], [Inf Inf 1]));
            vari_p2 = NaN(size(loc_2d));
            vari_p2(:,2:end-1) = vari;
            vari_p2(:,1) = vari(:,1);
            vari_p2(:,end) = vari(:,end);

            % Spread to 1D
            % scale (1e6) is needed to prevent scatterInterpolant
            % from lateral interpolation
            y = loc_2d(:).*1e6;
            z = z_r_p2(:);
            v = vari_p2(:);

            % Remove NaN value
            valid = ~isnan(z);
            yv = y(valid);
            zv = z(valid);
            vv = v(valid);

            % Scattered interpolant
            F = scatteredInterpolant(yv, zv, vv, 'linear', 'nearest');

            % Interpolation
            loc_new_tmp = squeeze(loc_2d(:,2:end-1));
            z_new_tmp = z_r_new;
            vari_new_tmp = squeeze(vari_new(:,:,ti));

            % Again, scale (1e6) is needed to prevent scatterInterpolant
            % from lateral interpolation
            y_new = loc_new_tmp(:).*1e6;
            z_new = z_new_tmp(:);

            valid_new = ~isnan(z_new);
            yv_new = y_new(valid_new);
            zv_new = z_new(valid_new);
            vv_new = F(yv_new,zv_new);

            if ~isempty(vv_new)
                vari_new_tmp(valid_new) = vv_new;
            end

            vari_new(:,:,ti) = vari_new_tmp;

            disp([vari_str, ' ', num2str(ti), '/', num2str(length(ot))])

            %         % Check profile
            %         chkind = 338;
            %         figure; hold on; grid on;
            %         plot(z_tmp(chkind,:), vari_tmp(chkind,:), '-o')
            %         plot(z_new_tmp(chkind,:), vari_new_tmp(chkind,:), '-o')
        end % ti

        ncwrite(file_new, vari_str, vari_new)
    end % di
end % vi

ncwrite(file_new, 'theta_s', theta_s_new);
ncwrite(file_new, 'theta_b', theta_b_new);
ncwrite(file_new, 'hc', hc_new);
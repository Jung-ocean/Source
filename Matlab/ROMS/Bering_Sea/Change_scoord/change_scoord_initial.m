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

% File
filepath = '/data/jungjih/ROMS_BSf/Initial/';
filename = 'SumFal_2021_Dsm4_nKC_his_1275.nc';
file = [filepath, filename];

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
    vari_str = varis{vi};
    type = types{vi};

    h = g.h;
    lat = g.(['lat_', type]);
    lon = g.(['lon_', type]);
    [xi,eta]=size(lat);

    % Make latitude and longitude 3-D
    % +2 because of additional surface and bottom layers
    lat_3d = repmat(lat, [1 1 N+2]);
    lon_3d = repmat(lon, [1 1 N+2]);

    % Calculate old and new depths at data point
    zeta = ncread(file, 'zeta');
    if strcmp(type, 'u')
        h = rho2u_2d_J(h);
        zeta = rho2u_2d_J(zeta);
    elseif strcmp(type, 'v')
        h = rho2v_2d_J(h);
        zeta = rho2v_2d_J(zeta);
    end
    
    z_r = zlevs(h, zeta, theta_s_old, theta_b_old, hc_old, N, 'r', 2);
    % Add additional surface and bottom layers
    z_r_p2 = NaN(size(lat_3d));
    z_r_p2(:,:,2:end-1) = z_r;
    z_r_p2(:,:,1) = z_r(:,:,1) - 1000;
    z_r_p2(:,:,end) = z_r(:,:,end) + 10;

    z_r_new = zlevs(h, zeta, theta_s_new, theta_b_new, hc_new, N, 'r', 2);

    % Read in variable
    vari = ncread(file, vari_str);
    vari_p2 = NaN(size(lat_3d));
    vari_p2(:,:,2:end-1) = vari;
    vari_p2(:,:,1) = vari(:,:,1);
    vari_p2(:,:,end) = vari(:,:,end);

    vari_new = NaN.*vari;
    for i = 1:xi
        lat_tmp = squeeze(lat_3d(i,:,:));
        z_tmp = squeeze(z_r_p2(i,:,:));
        vari_tmp = squeeze(vari_p2(i,:,:));

        % Spread to 1D
        % scale (1e6) is needed to prevent scatterInterpolant
        % from lateral interpolation
        y = lat_tmp(:).*1e6;
        z = z_tmp(:);
        v = vari_tmp(:);

        % Remove NaN value
        valid = ~isnan(z);
        yv = y(valid);
        zv = z(valid);
        vv = v(valid);

        % Scattered interpolant
        F = scatteredInterpolant(yv, zv, vv, 'linear', 'nearest');

        % Interpolation
        lat_new_tmp = squeeze(lat_3d(i,:,2:end-1));
        z_new_tmp = squeeze(z_r_new(i,:,:));
        vari_new_tmp = squeeze(vari_new(i,:,:));

        % Again, scale (1e6) is needed to prevent scatterInterpolant
        % from lateral interpolation
        y_new = lat_new_tmp(:).*1e6;
        z_new = z_new_tmp(:);

        valid_new = ~isnan(z_new);
        yv_new = y_new(valid_new);
        zv_new = z_new(valid_new);
        vv_new = F(yv_new,zv_new);

        if ~isempty(vv_new)
            vari_new_tmp(valid_new) = vv_new;
        end

        vari_new(i,:,:) = vari_new_tmp;

        disp([vari_str, ' ', num2str(i), '/', num2str(xi)])

%         % Check profile
%         chkind = 338;
%         figure; hold on; grid on;
%         plot(z_tmp(chkind,:), vari_tmp(chkind,:), '-o')
%         plot(z_new_tmp(chkind,:), vari_new_tmp(chkind,:), '-o')
    end

    ncwrite(file_new, vari_str, vari_new)
end % vi

ncwrite(file_new, 'theta_s', theta_s_new);
ncwrite(file_new, 'theta_b', theta_b_new);
ncwrite(file_new, 'hc', hc_new);
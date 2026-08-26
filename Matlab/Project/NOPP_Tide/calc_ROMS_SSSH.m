clear; clc; close all

isplot = 1;

datenum_start = datenum(2025,7,1);
dsstr = datestr(datenum_start, 'yyyymmdd');
datenum_end = datenum(2025,7,4);
destr = datestr(datenum_end, 'yyyymmdd');

filepath = '/home/server/ftp/dist/tides/ingria/ORWA/';

g = grd('NANOOS');
timenum_ref = datenum(2005,1,1);
lat = g.lat_rho;
lat_3d = repmat(lat, [1 1 g.N]);
lon = g.lon_rho;
lon_3d = repmat(lon, [1 1 g.N]);
H = g.h;
H_3d = repmat(H, [1 1 g.N]);
rho0 = 1026;
gconst = 9.8;

timenum = [];
zeta = NaN([size(g.lat_rho), 12*(datenum_end-datenum_start+1)]);
temp = NaN([size(g.lat_rho), g.N, 12*(datenum_end-datenum_start+1)]);
salt = NaN([size(g.lat_rho), g.N, 12*(datenum_end-datenum_start+1)]);
dataind = 0;
for di = datenum_start:datenum_end
    datenum_tmp = di;
    dstr = datestr(datenum_tmp, 'dd-mmm-yyyy');
    filenum = datenum_tmp - timenum_ref +1;
    fstr = num2str(filenum, '%04i');
    filename = ['ocean_his_', fstr, '_', dstr, '.nc'];
    file = [filepath, filename];
    ot = ncread(file, 'ocean_time');
    timenum_tmp = ot/60/60/24 + timenum_ref;
    timenum = [timenum; timenum_tmp];

    for ti = 1:length(ot)
        dataind = dataind+1;

        zeta_tmp = ncread(file, 'zeta', [1 1 ti], [Inf Inf 1]);
        temp_tmp = ncread(file, 'temp', [1 1 1 ti], [Inf Inf Inf 1]);
        salt_tmp = ncread(file, 'salt', [1 1 1 ti], [Inf Inf Inf 1]);
        salt_tmp(salt_tmp < 0) = 0;

        zeta(:,:,dataind) = zeta_tmp;
        temp(:,:,:,dataind) = temp_tmp;
        salt(:,:,:,dataind) = salt_tmp;
    end
    
    disp(['Loading ', file, ' ...'])
end

% Load background density
avg_dens = load('ROMS_avg_dens.mat');
zeta_avg = avg_dens.zeta_avg;
dens_avg = avg_dens.dens_avg;
dz = avg_dens.dz;

zetabar = zeta_avg; % time-mean
rhobar = sum(dz.*dens_avg,3)./sum(dz,3); % time-mean depth-averaged

% SSSH Calculation
SSSH = NaN.*zeta;
for ti = 1:length(timenum)
    zeta_tmp = zeta(:,:,ti);
    temp_tmp = temp(:,:,:,ti);
    salt_tmp = salt(:,:,:,ti);
    
    z = zlevs(H,zeta_tmp,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
    z_w = zlevs(H,zeta_tmp,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
    dz = z_w(:,:,2:end) - z_w(:,:,1:end-1);
    
    p = gsw_p_from_z(-abs(z), lat_3d);
    p(p < 0 ) = NaN;
    [SA, in_ocean] = gsw_SA_from_SP(salt_tmp,p,lon_3d,lat_3d);
    pt = temp_tmp;
    CT = gsw_CT_from_pt(SA,pt);
    dens = gsw_rho(SA,CT,p);
    
    rho = sum(dz.*dens,3)./sum(dz,3); % depth-averaged
    SSSH_tmp = (rhobar./rho).*zetabar + ((rhobar-rho)./rho).*H;
    SSSH(:,:,ti) = SSSH_tmp;

    disp(['SSSH calculation ', num2str(ti), ' / ', num2str(length(timenum)), ' ...'])
end

% Bandpass filter
dt = 2; % 2 hour

SSSH_filtered = SSSH;
for i = 1:size(lon,1)
    for j = 1:size(lon,2)
        SSSH_tmp = squeeze(SSSH(i,j,:));
        if sum(isnan(SSSH_tmp)) == 0
            SSSH_filtered(i,j,:) = tide_bandpass_butter4(SSSH_tmp, dt, 'M2', 0);
        end
    end
    disp(['Bandpass filter ', num2str(i), ' / ', num2str(size(lon,1)), ' ...'])
end
save(['ROMS_SSSH_', dsstr, '_', destr, '.mat'], 'timenum', 'lon', 'lat', 'SSSH_filtered');

% Plot
if isplot == 1
    unit = 'cm';
    climit = [-2 2];
    interval = [.5];
    [color, contour_interval] = get_color('redblue', climit, interval);

    f1 = figure; hold on;
    set(gcf, 'Position', [1 200 500 800])
    for ti = 1:size(SSSH_filtered,3)
        SSSH_tmp = 100*squeeze(SSSH_filtered(:,:,ti)); % m to cm
        if ti == 1
            plot_map('US_west', 'mercator', 'l')
            contourm(lat, lon, g.h, [200 1000], 'k');

            c = colorbar;
            c.Title.String = unit;
            c.Ticks = contour_interval;
        end
        p = plot_contourf([], lat, lon, SSSH_tmp, color, climit, contour_interval);
        title(['ROMS M2 SSSH (', datestr(timenum(ti), 'mm/dd/yy HH:MM'), ')'])

        % Make gif
        gifname = ['ROMS_SSSH_', dsstr, '_', destr, '.gif'];
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
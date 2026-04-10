clear; clc; close all

Ns = [45, 100, 200];
colors = {'k', 'r', 'b'};

isgif = 1;

datenum_start = datenum(2018,7,1)+.5;
datenum_end = datenum(2023,12,1);
dt = 15;

datenum_ref = datenum(1968,5,23);

g = grd('BSf');
theta_s = g.theta_s;
theta_b = g.theta_b;
hc = g.hc;

grid_org = '../grid/grid_1D_DP.nc';
lon = ncread(grid_org, 'lon_rho');
lon = mean(lon(:));
lat = ncread(grid_org, 'lat_rho');
lat = mean(lat(:));
depth = ncread(grid_org, 'h');
depth = mean(depth(:));

ylimit = [-2000 0];
lw = 2;
FS = 12;
TFS = 15;

f1 = figure;
set(gcf, 'Position', [1 200 1300 800]);
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'tight';

isfirst = 1;
for ti = datenum_start:dt:datenum_end
    timenum_tmp = ti;
    title(t, [datestr(timenum_tmp, 'mmm dd, yyyy')], 'FontSize', 25);

    profile = load_models_profile('BSf', g, floor(timenum_tmp), lon, lat);
    z_r_3d = profile.depth;
    temp_3d = profile.temp;
    salt_3d = profile.salt;
    pden_3d = profile.pden;

    nexttile(1); hold on; grid on;
    pt(4) = plot(temp_3d, z_r_3d, '-', 'Color', [.7 .7 .7], 'LineWidth', lw);
    nexttile(2); hold on; grid on;
    ps(4) = plot(salt_3d, z_r_3d, '-', 'Color', [.7 .7 .7], 'LineWidth', lw);
    nexttile(3); hold on; grid on;
    pp(4) = plot(pden_3d-1000, z_r_3d, '-', 'Color', [.7 .7 .7], 'LineWidth', lw);

    for ni = 1:length(Ns)
        N = Ns(ni);
        Nstr = num2str(N);
        legends{ni} = ['N = ', Nstr];
        filepath = ['../output_all/output_N', Nstr, '/'];
        filename = 'avg.nc';
        file = [filepath, filename];
        ot = ncread(file, 'ocean_time');
        timenum = datenum_ref + ot/60/60/24;
        tindex = find(timenum == timenum_tmp);
        
        z_r = squeeze(zlevs(depth,0,theta_s,theta_b,hc,N,'r',2));
        temp = ncread(file, 'temp', [1 1 1 tindex], [Inf Inf Inf 1]);
        temp = squeeze(mean(mean(temp,1),2));
        salt = ncread(file, 'salt', [1 1 1 tindex], [Inf Inf Inf 1]);
        salt = squeeze(mean(mean(salt,1),2));

        p = gsw_p_from_z(z_r,lat);
        p(p < 0 ) = NaN;
        [SA, in_ocean] = gsw_SA_from_SP(salt,p,lon,lat);
        pt0 = temp;
        CT = gsw_CT_from_pt(SA,pt0);
        pden = gsw_rho(SA,CT,0);

        % temp
        nexttile(1); hold on; grid on;
        pt(ni) = plot(temp, z_r, '-', 'Color', colors{ni}, 'LineWidth', 2);
        ylim(ylimit)
        xlabel('^oC')
        ylabel('Depth (m)')
        set(gca, 'FontSize', FS)
        title('Temperature', 'FontSize', TFS)
        
        % salt
        nexttile(2); hold on; grid on;
        ps(ni) = plot(salt, z_r, '-', 'Color', colors{ni}, 'LineWidth', 2);
        ylim(ylimit)
        xlabel('psu')
        yticklabels('')
        set(gca, 'FontSize', FS)
        title('Salinity', 'FontSize', TFS)

        % pden
        nexttile(3); hold on; grid on;
        pp(ni) = plot(pden-1000, z_r, '-', 'Color', colors{ni}, 'LineWidth', 2);
        ylim(ylimit)
        xlabel('kg/m^3')
        yticklabels('')
        set(gca, 'FontSize', FS)
        title('Potential density', 'FontSize', TFS)
    end % ni

    if isnan(profile.depth)
        l = legend(pp, legends);
    else
        l = legend(pp, [legends, '3D']);
    end
    l.Location = 'SouthWest';
    l.FontSize = 25;

    if isgif == 1
        % Make gif
        gifname = ['1D_DP_sigma_layers.gif'];

        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if isfirst == 1
            isfirst = 0;
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end

    delete(pt)
    delete(ps)
    delete(pp)
end % ti
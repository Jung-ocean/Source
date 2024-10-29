clear; clc; close all

variable = 'elevation';
expname = 'control';
start_date = datenum(2019,7,1);
yyyymm_all = [datenum(2019,7:11,15)];

% Read ROMS grid
g = grd('BSf');

% Read SCHISM grid
Mobj.dt = 60;
Mobj.coord = 'geographic';
hgrid_file = '../hgrid.gr3';
Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj.lon = Mobj.lon - 360;

vari_str_CMEMS = 'adt';
vari_str_ROMS = 'zeta';
vari_str_SCHISM = variable;
climit_CMEMS = [0 0.8];
climit = [-0.5 0.3];
unit = 'm';

xlimit = [-206 -156];
ylimit = [49 66.5];

figure; hold on;
set(gcf, 'Position', [1 200 1800 500])
t = tiledlayout(1,3);
for yi = 1:length(yyyymm_all)
    yyyymmdd = yyyymm_all(yi);

    % CMEMS
    CMEMS_filepath = '/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly/';
    CMEMS_filename = ['dt_global_allsat_phy_l4_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    CMEMS_file = [CMEMS_filepath, CMEMS_filename];
    lon_CMEMS = double(ncread(CMEMS_file,'longitude'));
    lat_CMEMS = double(ncread(CMEMS_file,'latitude'));
    vari_CMEMS = double(squeeze(ncread(CMEMS_file, vari_str_CMEMS))');
    
    index1 = find(lon_CMEMS > 0); index2 = find(lon_CMEMS < 0);
    vari_CMEMS = [vari_CMEMS(:,index1) vari_CMEMS(:,index2)];
    lon_CMEMS = lon_CMEMS - 180;

    % ROMS
    ROMS_filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/';
    ROMS_filename = ['Dsm2_spng_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    ROMS_file = [ROMS_filepath, ROMS_filename];
    vari_ROMS = ncread(ROMS_file, vari_str_ROMS)';

    % SCHISM
    SCHISM_filepath = ['../outputs_', expname, '/'];
    SCHISM_filename = ['elevation_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    SCHISM_file = [SCHISM_filepath, SCHISM_filename];
    vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM));

    % Plot
    ax1 = nexttile(1); cla(ax1)
    p1 = pcolor(lon_CMEMS, lat_CMEMS, vari_CMEMS); shading interp
    colormap jet
    cb = colorbar;
    cb.Title.String = unit;

    xlim(xlimit);
    ylim(ylimit);
    caxis(climit_CMEMS);
    title(['CMEMS ADT'])

    ax2 = nexttile(2); cla(ax2);
    p2 = pcolor(g.lon_rho, g.lat_rho, vari_ROMS.*g.mask_rho./g.mask_rho); shading interp
    colormap jet
%     cb = colorbar;
%     cb.Title.String = unit;

    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['ROMS ', vari_str_ROMS])

    ax3 = nexttile(3);
    if yi == 1
        p3 = disp_schism_var(Mobj, vari_SCHISM, 'EdgeColor', 'none');
        colormap jet
        cb = colorbar;
        cb.Title.String = unit;
    else
        p3.FaceVertexCData = vari_SCHISM;
    end
    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['SCHISM ', vari_str_SCHISM])

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    title(t, ['Elevation (', datestr(yyyymmdd, 'mmm, yyyy'), ')'], 'FontSize', 25)

    set(gcf, 'Position', [1 200 1800 500])
    pause(3)
    set(gcf, 'Position', [1 200 1800 500])
    pause(3)

    print(['cmp_', variable, '_SCHISM_to_CMEMS_ROMS_monthly_', datestr(yyyymmdd, 'yyyymm')] ,'-dpng')
end
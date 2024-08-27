clear; clc; close all

variable = 'elevation';
expname = 'control';
start_date = datenum(2018,7,1);
yyyymm_all = [datenum(2018,8,15)];

% Read ROMS grid
g = grd('BSf');

% Read SCHISM grid
Mobj.dt = 60;
Mobj.coord = 'geographic';
hgrid_file = '../hgrid.gr3';
Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj.lon = Mobj.lon - 360;

vari_str_HYCOM = 'ssh';
vari_str_ROMS = 'zeta';
vari_str_SCHISM = variable;
climit = [-0.5 0.3];
unit = 'm';

xlimit = [-206 -156];
ylimit = [49 66.5];

figure; hold on;
set(gcf, 'Position', [1 1 1800 500])
tiledlayout(1,3)
for yi = 1:length(yyyymm_all)
    yyyymmdd = yyyymm_all(yi);

    % HYCOM
    HYCOM_filepath = '/data/jungjih/HYCOM_extract/Bering_Sea/2018/Time_Filtered/monthly/';
    HYCOM_filename = ['HYCOM_glbvBeringSea_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    HYCOM_file = [HYCOM_filepath, HYCOM_filename];
    lon_HYCOM = ncread('/data/sdurski/HYCOM_extract/Bering_Sea/2018/HYCOM_glbvBeringSea_20180701.nc', 'Longitude')';
    lat_HYCOM = ncread('/data/sdurski/HYCOM_extract/Bering_Sea/2018/HYCOM_glbvBeringSea_20180701.nc', 'Latitude')';
    vari_HYCOM = ncread(HYCOM_file, vari_str_HYCOM)';
    vari_HYCOM(vari_HYCOM == 0) = NaN;

    % ROMS
    ROMS_filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/';
    ROMS_filename = ['Dsm2_spng_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    ROMS_file = [ROMS_filepath, ROMS_filename];
    vari_ROMS = ncread(ROMS_file, vari_str_ROMS)';

    % SCHISM
    SCHISM_filepath = ['../outputs_', expname, '/'];
    SCHISM_filename = ['out2d_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    SCHISM_file = [SCHISM_filepath, SCHISM_filename];
    vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM));

    % Plot
    ax1 = nexttile(1); cla(ax1)
    p1 = pcolor(lon_HYCOM, lat_HYCOM, vari_HYCOM); shading interp
    colormap jet

    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['HYCOM ', variable, ' ', datestr(yyyymmdd, 'mmm, yyyy')])

    ax2 = nexttile(2); cla(ax2);
    p2 = pcolor(g.lon_rho, g.lat_rho, vari_ROMS.*g.mask_rho./g.mask_rho); shading interp
    colormap jet

    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['ROMS ', variable, ' ', datestr(yyyymmdd, 'mmm, yyyy')])

    ax3 = nexttile(3);
    if yi == 1
        p3 = disp_schism_var(Mobj, vari_SCHISM, 'EdgeColor', 'none');
        colormap jet
        cb = colorbar;
        cb.Layout.Tile = 'east';
        cb.Title.String = unit;
    else
        p3.FaceVertexCData = vari_SCHISM;
    end
    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['SCHISM ', variable, ' ', datestr(yyyymmdd, 'mmm, yyyy')])

    set(gcf, 'Position', [1 1 1800 500])
    pause(3)
    set(gcf, 'Position', [1 1 1800 500])
    pause(3)

    print(['cmp_SCHISM_monthly_',variable, '_w_HYCOM_ROMS_', datestr(yyyymmdd, 'yyyymm')] ,'-dpng')
end
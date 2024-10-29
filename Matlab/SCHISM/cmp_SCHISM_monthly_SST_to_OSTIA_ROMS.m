clear; clc; close all

variable = 'temperature';
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

vari_str_ROMS = 'temp';
vari_str_SCHISM = variable;
climit = [5 20];
unit = '^oC';

xlimit = [-206 -156];
ylimit = [49 66.5];

figure; hold on;
set(gcf, 'Position', [1 200 1800 500])
t = tiledlayout(1,3);
for yi = 1:length(yyyymm_all)
    yyyymmdd = yyyymm_all(yi);

    % OSTIA
    OSTIA_filepath = ['/data/jungjih/Observations/Satellite_SST/OSTIA/monthly/'];
    OSTIA_filename = ['OSTIA_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    OSTIA_file = [OSTIA_filepath, OSTIA_filename];
    lon_OSTIA = double(ncread(OSTIA_file, 'lon'));
    lat_OSTIA = double(ncread(OSTIA_file, 'lat'));
    vari_OSTIA = ncread(OSTIA_file, 'analysed_sst')' - 273.15; % K to dec C
    
    index1 = find(lon_OSTIA < 0);
    index2 = find(lon_OSTIA > 0);

    lon_OSTIA = [lon_OSTIA(index2)-360; lon_OSTIA(index1)];
    vari_OSTIA = [vari_OSTIA(:,index2) vari_OSTIA(:,index1)];

    % ROMS
    ROMS_filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/';
    ROMS_filename = ['Dsm2_spng_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    ROMS_file = [ROMS_filepath, ROMS_filename];
    vari_ROMS = squeeze(ncread(ROMS_file, vari_str_ROMS, [1 1 45 1], [Inf Inf 1 1]))';

    % SCHISM
    SCHISM_filepath = ['../outputs_', expname, '/'];
    SCHISM_filename = [variable, '_surf_', datestr(yyyymmdd, 'yyyymm'), '.nc'];
    SCHISM_file = [SCHISM_filepath, SCHISM_filename];
    vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM))';

    % Plot
    ax1 = nexttile(1); cla(ax1)
    p1 = pcolor(lon_OSTIA, lat_OSTIA, vari_OSTIA); shading interp
    colormap jet
%     cb = colorbar;
%     cb.Title.String = unit;

    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['OSTIA'])

    ax2 = nexttile(2); cla(ax2);
    p2 = pcolor(g.lon_rho, g.lat_rho, vari_ROMS.*g.mask_rho./g.mask_rho); shading interp
    colormap jet
%     cb = colorbar;
%     cb.Title.String = unit;

    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['ROMS'])

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
    title(['SCHISM'])

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    title(t, ['SST (', datestr(yyyymmdd, 'mmm, yyyy'), ')'], 'FontSize', 25)

    set(gcf, 'Position', [1 200 1800 500])
    pause(3)
    set(gcf, 'Position', [1 200 1800 500])
    pause(3)
    set(gcf, 'Position', [1 200 1800 500])

    print(['cmp_', variable, '_SCHISM_to_OSTIA_ROMS_monthly_', datestr(yyyymmdd, 'yyyymm')] ,'-dpng')
end
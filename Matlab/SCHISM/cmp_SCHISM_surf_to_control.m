clear; clc; close all

variable = 'temperature';
control = 'control';
depth_ind_control = 45;
expname = 'dt30_kkl';
depth_ind = 45;
start_date = datenum(2018,7,1);
day_all = [1 7 14 21 28 35 42 49 56 63];
%day_all = [49];

% Read ROMS gr id
g = grd('BSf');

% Read SCHISM grid
% Mobj.time = (datetime(2018,7,1):hours(1):datetime(2018,6,3))';
% Mobj.rundays = days(Mobj.time(end)-Mobj.time(1));
Mobj.dt = 120;
Mobj.coord = 'geographic';
hgrid_file = '../hgrid.gr3';
Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj.lon = Mobj.lon - 360;
% vgrid_file = '/data/jungjih/Models/SCHISM/test_schism/vgrid.in';
% Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

switch variable
    case 'temperature'
        filename_str = variable;
        vari_str_SCHISM = variable;
        climit = [5 20];
        climit_diff = [-5 5];
        unit = '^oC';
        title_str = 'SST';
    case 'salinity'
        filename_str = variable;
        vari_str_SCHISM = variable;
        climit = [31.5 33.5];
        climit_diff = [-1 1];
        unit = 'g/kg';
        title_str = 'SSS';
    case 'elevation'
        filename_str = 'out2d';
        vari_str_SCHISM = variable;
        climit = [-0.5 0.5];
        climit_diff = [-0.2 0.2];
        unit = 'm';
        title_str = 'SSH';
end
xlimit = [-206 -156];
ylimit = [49 66.5];

figure; hold on;
set(gcf, 'Position', [1 1 1800 500])
tiledlayout(1,3)
for di = 1:length(day_all)
    day = day_all(di);
    timenum = start_date + (day-1);

    % SCHISM control
    SCHISM_filepath = ['/data/jungjih/Models/SCHISM/test_schism/v1_SMS_min_5m_3D/gen_input/v1_SMS_min_5m_3D/outputs_', control,'/'];
    SCHISM_filename = [filename_str, '_', num2str(day), '.nc'];
    SCHISM_file = [SCHISM_filepath, SCHISM_filename];
    if strcmp(variable, 'elevation')
        vari_SCHISM = ncread(SCHISM_file, vari_str_SCHISM);
    else
        vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM, [depth_ind_control, 1, 1], [1, Inf, Inf]));
    end
    vari_SCHISM_control = mean(vari_SCHISM,2);

    % SCHISM
    SCHISM_filepath = ['../outputs_', expname, '/'];
    SCHISM_filename = [filename_str, '_', num2str(day), '.nc'];
    SCHISM_file = [SCHISM_filepath, SCHISM_filename];
    if strcmp(variable, 'elevation')
        vari_SCHISM = ncread(SCHISM_file, vari_str_SCHISM);
    else
        vari_SCHISM = squeeze(ncread(SCHISM_file, vari_str_SCHISM, [depth_ind, 1, 1], [1, Inf, Inf]));
    end
    vari_SCHISM = mean(vari_SCHISM,2);

    % Plot
    ax1 = nexttile(1);
    if di == 1
        p1 = disp_schism_var(Mobj, vari_SCHISM_control, 'EdgeColor', 'none');
        colormap jet
        cb = colorbar;
        cb.Title.String = unit;
    else
        p1.FaceVertexCData = vari_SCHISM_control;
    end
    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['SCHISM ', title_str, ' (', control, ') ', datestr(timenum, 'mmm dd, yyyy')], 'interpreter', 'none')

    ax2 = nexttile(2);
    if di == 1
        p2 = disp_schism_var(Mobj, vari_SCHISM, 'EdgeColor', 'none');
        colormap jet
        cb = colorbar;
        cb.Title.String = unit;
    else
        p2.FaceVertexCData = vari_SCHISM;
    end
    xlim(xlimit);
    ylim(ylimit);
    caxis(climit);
    title(['SCHISM ', title_str, ' (', expname, ') ', datestr(timenum, 'mmm dd, yyyy')], 'interpreter', 'none')

    ax3 = nexttile(3);
    if di == 1
        p3 = disp_schism_var(Mobj, vari_SCHISM-vari_SCHISM_control, 'EdgeColor', 'none');
        colormap(ax3,'redblue')
        cb = colorbar;
        cb.Title.String = unit;
    else
        p3.FaceVertexCData = vari_SCHISM-vari_SCHISM_control;
    end
    xlim(xlimit);
    ylim(ylimit);
    caxis(climit_diff);
    title('Difference')

    set(gcf, 'Position', [1 1 1800 500])
    pause(3)
    set(gcf, 'Position', [1 1 1800 500])
    pause(3)

    print(['cmp_SCHISM_surf_',variable, '_w_', control, '_', datestr(timenum, 'yyyymmdd')] ,'-dpng')
end
% clear; clc

% Mobj.time = (datetime(2018,7,1):hours(1):datetime(2018,6,3))';
% Mobj.rundays = days(Mobj.time(end)-Mobj.time(1));
Mobj.dt = 120;
Mobj.coord = 'geographic';

hgrid_file = './hgrid.gr3';
% vgrid_file = '/data/jungjih/Models/SCHISM/test_schism/vgrid.in';

% Mobj = read_schism_hgrid(Mobj, hgrid_file);
% Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

initial_file = '/data/jungjih/Models/SCHISM/test_schism/v1_SMS_min_5m_3D/gen_input/Hot/hotstart.nc';

start_date = datenum(2018,7,1);

variable = 'temperature';
depth_ind = 45;
filenum = 42;
time_ind = 1;

timenum = datenum(start_date + (filenum-1) + time_ind/24);

switch variable
    case 'temperature'
        vari_filename = variable;
        vari_ini = 'tr_nd';
        ini_ind = 1;
        climit = [0 20];
        climit_diff = [-3 3];
    case 'salinity'
        vari_filename = variable;
        vari_ini = 'tr_nd';
        ini_ind = 2;
        climit = [31.5 33.5];
        climit_diff = [-.5 .5];
    case 'elevation'
        vari_filename = 'out2d';
        vari_ini = 'eta2';
        climit = [-.8 .8];
        climit_diff = [-.4 .4];
end

schism_file = ['../outputs/', vari_filename, '_', num2str(filenum), '.nc'];

vari_ini = ncread(initial_file, vari_ini);
if ndims(vari_ini) == 3
    vari_ini_surf = squeeze(vari_ini(ini_ind,depth_ind,:));
else
    vari_ini_surf = vari_ini;
end

vari_1h = ncread(schism_file, variable);
if ndims(vari_1h) == 3
    vari_1h_surf = squeeze(vari_1h(depth_ind,:,time_ind))';
else
    vari_1h_surf = squeeze(vari_1h(:,time_ind));
end

% Plot
figure; hold on;
set(gcf, 'Position', [1 1 1800 500])
tiledlayout(1,3)
nexttile(1)
p = disp_schism_var(Mobj, vari_ini_surf, 'EdgeColor', 'none');
caxis(climit)
title(['Initial (', datestr(start_date, 'mmm dd, yyyy'), ')'])

nexttile(2)
p = disp_schism_var(Mobj, vari_1h_surf, 'EdgeColor', 'none');
caxis(climit)
title(datestr(timenum, 'mmm dd, yyyy HH:MM'))

ax3 = nexttile(3);
p = disp_schism_var(Mobj, vari_1h_surf - vari_ini_surf, 'EdgeColor', 'none');
colormap(ax3, 'redblue')
caxis(climit_diff)
title('Difference')

pause(3)

print([variable, '_', datestr(timenum, 'yyyymmdd_HH')] ,'-dpng')
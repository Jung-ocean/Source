clear; clc

start_date = datetime(2019,7,1);
Mobj.rundays = 153;
Mobj.time = (start_date:days(1):start_date + Mobj.rundays)';
Mobj.dt = 120;
Mobj.coord = 'geographic';

hgrid_file = './hgrid.gr3';
vgrid_file = './vgrid.in';

Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');
%
iTime = 1;
yyyymmdd = datestr(start_date + (iTime-1), 'yyyymmdd');

bndy_filepath = './';
bndy_filename = 'TEM_3D.th.nc';
bndy_file = [bndy_filepath, bndy_filename];
var = ncread(bndy_file, 'time_series');
var = squeeze(var);

hycom_filepath = '/data/jungjih/Models/SCHISM/test_schism/v2_JZ/gen_input/2019/3Dth/HYCOM/';
hycom_filename = ['HYCOM_', yyyymmdd, '.nc'];
hycom_file = [hycom_filepath, hycom_filename];

DS = get_hycom_bdry_bys_from_file(Mobj, hycom_file);
D = DS.temp;

nNodes_obc = Mobj.nNodes_obc;
nDeps_new = Mobj.maxLev;
nDeps_raw = numel(D.depth);

varData = var;
varData2 = D.var;

varNew = squeeze(varData(:,:,iTime));
depNew = Mobj.depLayers(:, Mobj.obc_nodes_tot);
distNew = repmat(1:nNodes_obc, nDeps_new, 1);

% varRaw = squeeze(varData2(:,:, indTime))';
varRaw = squeeze(varData2)';
depRaw = repmat(D.depth(:), 1, nNodes_obc);
distRaw =  repmat(1:nNodes_obc, nDeps_raw, 1);

depRaw = -abs(depRaw);
depNew = -abs(depNew);

figure;
subplot(211)
pcolor(distNew, depNew, varNew)
shading flat
colormap jet
colorbar
varLim = caxis;
yvarLim = ylim;
xlabel('Along Open Boundary Nodes', 'FontWeight','bold')
ylabel('Depth (m)', 'FontWeight','bold')
title(['SCHISM (', datestr(Mobj.time(iTime), 'yyyy-mm-dd'), ')'])

subplot(212)
pcolor(distRaw, depRaw, varRaw)
shading flat
colormap jet
colorbar
caxis(varLim)
ylim(yvarLim)
xlabel('Along Open Boundary Nodes', 'FontWeight','bold')
ylabel('Depth (m)', 'FontWeight','bold')
title(['Raw Data (', datestr(D.time, 'yyyy-mm-dd'), ')'])
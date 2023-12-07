clear; close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vari = 'density';
section_dir = 'lat';
target_year = 2013;     tys = num2str(target_year);
target_month = 8;       tms = num2char(target_month, 2);
ylimit = [0 90];
xlimit = [33.5 34.5];

Nline = 205;
line_list = [20500:20508];

filepath='D:\Data\Ocean\KODC\';
filename='KODC1961-2015.txt';
file = [filepath,filename];

fig_path='.\';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contourinterval = [18:1:28];
clim = [contourinterval(1) contourinterval(end)];
colorbarname = 'Density (\sigma_t)';

tys = num2str(target_year);
tms = num2char(target_month,2);
targetdate_start = [tys, tms, '00'];
targetdate_end = [tys, tms, '31'];

data_all = load(file);
line_chk = find(data_all(:,1) >= line_list(1) & data_all(:,1) <= line_list(end));
data_all = data_all(line_chk,:);

date_list = [str2num(targetdate_start):str2num(targetdate_end)];
date_chk = find(data_all(:,2) >= date_list(1) & data_all(:,2) <= date_list(end));
data_all = data_all(date_chk, :);

st = data_all(:,1); date = data_all(:,2); lon = data_all(:,3); lat = data_all(:,4);
dep = data_all(:,5); temp = data_all(:,6); salt = data_all(:,7);

grd_gap = 0.1; grd_dep = 2;
std_loc = eval(section_dir);
[std_loc2,std_dep2] = meshgrid([min(std_loc(:))-grd_gap*2:grd_gap:max(std_loc(:))+grd_gap*2],...
    [min(dep(:))-grd_dep*2:grd_dep:max(dep(:))+grd_dep*2]);

pres = sw_pres(dep, lat);
pdens = sw_pden(salt, temp, pres, 0);
density = pdens - 1000;

variable = eval(vari);
variable2 = griddata(std_loc, dep, variable, std_loc2, std_dep2);

figure; hold on;
pcolor(std_loc2,std_dep2,variable2); shading flat;
caxis(clim); colormap('jet');
c = colorbar; c.FontSize = 15;
c.Label.String = colorbarname; c.Label.FontSize = 15;
[cs, h] = contour(std_loc2, std_dep2, variable2, contourinterval, 'k');
tl = clabel(cs, 'FontSize', 15);
h = findobj('Type', 'line');
%for hi = 1:length(h)
%    h(hi).Marker = '.';
%end
plot(std_loc,dep,'k.','MarkerSize',10,'Linewidth',2);
set(gca, 'fontsize', 20, 'YDir','reverse');
titlename = [vari, ' ', tys, tms, ' line-', num2str(Nline)];
title(titlename, 'Fontsize', 25);

xlabel('Longitude')
ylabel('Depth(m)')

xlim(xlimit)
ylim(ylimit)

saveas(gcf, [fig_path, vari, '_vertical_', section_dir, '_', num2char(Nline, 3), '_', tys, tms, '.png'])
clear; close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vari = 'salt';
section_dir = 'lat';
target_year = 9999;     tys = num2str(target_year);
target_month = 6;       tms = num2char(target_month, 2);

Nline = 205;
if Nline == 204
    line_list = [20400:20406];
elseif  205
    line_list = [20500:20505];
    xlimit = [33.6217 34.4167];
    ylimit = [0 120];
    grd_gap = .01; grd_dep = 5;
    standard_dep = [0 10 20 30 50 75 100 120];
elseif Nline == 206
    line_list = [20600:20603];
elseif Nline == 400
    line_list = [40000 40013 40014 40015 40016];
end

%line_list = [10400:10414];

if strcmp(section_dir, 'lon')
    xlimit = [129 133];
    xlabelstr =  'Longitude(^oE)';
else
    xlimit = [33.6 34.4];
    xlabelstr = 'Latitude(^oN)';
end
ylimit = [0 120];

filepath='D:\Data\Ocean\KODC\';
filename='KODC1961-2015.txt';

file = [filepath,filename];

fig_path='D:\Data\Ocean\KODC\avg_ts(2010_2019)\';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(vari, 'temp')
    clim = [0 30];
    contourinterval = [clim(1):1:clim(2)];
    colorbarname = '^oC';
    colormapname = 'parula';
elseif strcmp(vari, 'salt')
    clim = [30 35];
    contourinterval = [clim(1):.5:clim(2)];
    colorbarname = 'g/kg';
    colormapname = 'jet';
end

tys = num2str(target_year);
tms = num2char(target_month,2);
targetdate_start = [tys, tms, '00'];
targetdate_end = [tys, tms, '31'];

if target_year == 9999
    tys = 'climate';
    
    filepath='D:\Data\Ocean\KODC\avg_ts(2010_2019)\';
    filename = 'KODC_avg(2010_2019).mat';
    file = [filepath,filename];
    load(file)
    
    data_all = data_avg;
    line_all = data_all(:,7)*100 + data_all(:,8);
    
    line_chk = find(ismember(line_all, line_list));
    data_all = data_all(line_chk,:);
    
    month_chk = find(data_all(:,2) == target_month | data_all(:,2) == target_month+1);
    data_all = data_all(month_chk,:);
    
    dep = data_all(:,11);
    index = find(ismember(dep,standard_dep) ~= 1);
    data_all(index,:) = [];
    
    lon = data_all(:,10); lat = data_all(:,9);
    dep = data_all(:,11); temp = data_all(:,12); salt = data_all(:,13);
    
else
    data_all = load(file);
    
    %line_chk = find(data_all(:,1) >= line_list(1) & data_all(:,1) <= line_list(end));
    line_chk = find(ismember(data_all(:,1), line_list));
    data_all = data_all(line_chk,:);
    
    date_list = [str2num(targetdate_start):str2num(targetdate_end)];
    date_chk = find(data_all(:,2) >= date_list(1) & data_all(:,2) <= date_list(end));
    data_all = data_all(date_chk, :);
    
    st = data_all(:,1); date = data_all(:,2); lon = data_all(:,3); lat = data_all(:,4);
    dep = data_all(:,5); temp = data_all(:,6); salt = data_all(:,7);
    
end

std_loc = eval(section_dir);
[std_loc2,std_dep2] = meshgrid([min(std_loc(:))-grd_gap*2:grd_gap:max(std_loc(:))+grd_gap*2],...
    [min(dep(:))-grd_dep*2:grd_dep:max(dep(:))+grd_dep*2]);

variable = eval(vari);
variable2 = griddata(std_loc, dep, variable, std_loc2, std_dep2);

figure; hold on;
pcolor(std_loc2,std_dep2,variable2); shading flat;
caxis(clim); colormap(colormapname);
c = colorbar; c.FontSize = 15;
c.Title.String = colorbarname; c.Title.FontSize = 15;
[cs, h] = contour(std_loc2, std_dep2, variable2, contourinterval, 'k');
h.LineWidth = 1;
tl = clabel(cs,h,'LabelSpacing',144, 'FontSize', 15, 'FontWeight', 'bold');
h = findobj('Type', 'line');
for hi = 1:length(h)
    h(hi).Marker = '.';
end
plot(std_loc,dep,'k.','MarkerSize',5,'Linewidth',2);
set(gca, 'fontsize', 15, 'YDir','reverse');
titlename = [datestr(datenum(1,target_month,1), 'mmm'), ' ', tys];
title(titlename, 'Fontsize', 25);

xlabel(xlabelstr)
ylabel('Depth(m)')

%xlim(xlimit)
ylim(ylimit)

saveas(gcf, [fig_path, vari, '_vertical_', section_dir, '_', num2char(Nline, 3), '_', tys, tms, '.png'])
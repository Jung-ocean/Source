clear; clc; %close all

vari = 'temp';

yyyy_all = 9999:9999;
mm_all = [8];

figpath = 'C:\Users\User\Dropbox\Research\Upwelling_intensitiy\PIO\Figures\observation\';
titletype = [''];

filepath = figpath;
%file1 = 'KODC_avg(1990_1995).mat';
file1 = 'D:\Data\Ocean\KODC\avg_ts(1979_2020)\KODC_avg(1979_2020).mat';
file2 = 'data_vertical_2013.mat';
load([filepath, file2]);
data_file2_all = data_all;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_year = yyyy; ystr = num2str(target_year);
target_month = mm; mstr = num2str(target_month, '%02d');

Nline = 205;
switch Nline
    case 204
        line_list = [20400:20406];
        ylimit = [0 120];
    case  205
        section_dir = 'lat';
        line_list = [20500:20505];
        xlimit = [33.6217 34.4167];
        ylimit = [0 120];
        grd_gap = .01; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75 100 120];
    case 206
        line_list = [20600:20603];
        ylimit = [0 120];
    case 207
        line_list = [20701:20703];
        ylimit = [0 120];
    case 208
        line_list = [20801:20804];
        ylimit = [0 150];
    case 310
        section_dir = 'lon';
        line_list = [31003:31010];
        xlimit = [124.4 125.8];
        ylimit = [0 90];
        grd_gap = .1; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75];
    case 311
        section_dir = 'lon';
        line_list = [31104:31110];
        xlimit = [124.3 125.8];
        ylimit = [0 90];
        grd_gap = .1; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75];
    case 312
        section_dir = 'lon';
        line_list = [31202:31210];
        xlimit = [124 126.63];
        ylimit = [0 90];
        grd_gap = .1; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75];
    case 313
        line_list = [31302:31310];
        xlimit = [119 126.63];
        ylimit = [0 90];
        grd_gap = .1; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75];
    case 314
        line_list = [31401:31409];
        xlimit = [119 126.63];
        ylimit = [0 90];
        grd_gap = .1; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75];
    case 315
        line_list = [31512:31522];
        xlimit = [119 126.63];
        ylimit = [0 90];
        grd_gap = .1; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75 100];
    case 400
        line_list = [40000 40013 40014 40015 40016];
        ylimit = [0 95];
end
%line_list = [10400:10414];

if strcmp(section_dir, 'lon')
    xlabelstr =  'Longitude(^oE)';
else
    xlabelstr = 'Latitude(^oN)';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(vari, 'temp')
    clim = [-2 2];
    contourinterval = [clim(1):1:clim(2)];
    colorbarname = '^oC';
    colormapname = 'redblue2';
    varindex = 12;
elseif strcmp(vari, 'salt')
    clim = [-1 1];
    contourinterval = [clim(1):.2:clim(2)];
    colorbarname = 'g/kg';
    colormapname = 'redblue2';
    varindex = 13;
end

    load([file1])
    data_file1_all = data_avg;
    
    index1 = find(data_file1_all(:,2) == mm & data_file1_all(:,7) == Nline);
    data1 = data_file1_all(index1,:);
    
    index2 = find(data_file2_all(:,2) == mm & data_file2_all(:,7) == Nline);
    data2 = data_file2_all(index2,:);
    
    data_diff = [];
    for d2i = 1:size(data2, 1)
        obsline = data2(d2i,7);
        obspoint = data2(d2i,8);
        depth = data2(d2i,11);
        
        index = find(data1(:,7) == obsline & data1(:,8) == obspoint & data1(:,11) == depth);
        
        data_diff = [data_diff; data2(d2i,:)];
        data_diff(d2i, varindex) = data2(d2i, varindex) - data1(index, varindex);
    end
    
lon = data_diff(:,10); lat = data_diff(:,9);
dep = data_diff(:,11); temp = data_diff(:,12); salt = data_diff(:,13);

std_loc = eval(section_dir);
[std_loc2,std_dep2] = meshgrid([min(std_loc(:))-grd_gap*2:grd_gap:max(std_loc(:))+grd_gap*2],...
    [min(dep(:))-grd_dep*2:grd_dep:max(dep(:))+grd_dep*2]);

variable = eval(vari);
variable2 = griddata(std_loc, dep, variable, std_loc2, std_dep2);

figure; hold on;
pcolor(std_loc2,std_dep2,variable2); shading interp;
caxis(clim); colormap(colormapname);
c = colorbar; c.FontSize = 15;
c.Title.String = colorbarname; c.Title.FontSize = 15;
%c.Label.String = colorbarname; c.Label.FontSize = 15;
[cs, h] = contour(std_loc2, std_dep2, variable2, contourinterval, 'k');
h.LineWidth = 1;
tl = clabel(cs,h,'LabelSpacing',500, 'FontSize', 20, 'FontWeight', 'bold');
h = findobj('Type', 'line');
for hi = 1:length(h)
    h(hi).Marker = '.';
end
plot(std_loc,dep,'k.','MarkerSize',15,'Linewidth',2);
set(gca, 'fontsize', 15, 'YDir','reverse');
titlename = [datestr(datenum(1,target_month,1), 'mmm'), ' ', ystr];
%title(titlename, 'Fontsize', 25);

xlabel(xlabelstr)
ylabel('Depth(m)')

set(gca, 'FontSize', 20)

xlim(xlimit)
ylim(ylimit)

ax = get(gca);
xlim([ax.XLim(1)-0.005 ax.XLim(2)+0.01])
ylim([-.5 ylimit(2)])
%yticks([-120 -80 -40 0])
ax.XAxis.TickDirection = 'out';
ax.YAxis.TickDirection = 'out';
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2;

box on

%saveas(gcf, [filepath, 'diff_', vari, '_vertical_', section_dir, '_', num2char(Nline, 3), '_', ystr, mstr, '.png'])

    end
end
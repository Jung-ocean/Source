clear; clc; %close all

Nline = 205;
vari = 'salt';

yyyy_all = 2020:2020;
mm_all = [6];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_year = yyyy; ystr = num2str(target_year);
target_month = mm; mstr = num2str(target_month, '%02d');


switch Nline
    case 203
        section_dir = 'lat';
        line_list = [20300:20303];
        xlimit = [33.5 34.1];
        ylimit = [0 120];
        grd_gap = .01; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75 100 125];
    case 204
        section_dir = 'lat';
        line_list = [20400:20406];
        xlimit = [33.5 34.4167];
        ylimit = [0 130];
        grd_gap = .01; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75 100 125];
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
        section_dir = 'lat';
        line_list = [40000 40013 40014 40015 40016];
        xlimit = [34 34.7];
        ylimit = [0 80];
        grd_gap = .1; grd_dep = 5;
        standard_dep = [0 10 20 30 50 75 100];
end
%line_list = [10400:10414];

if strcmp(section_dir, 'lon')
    xlabelstr =  'Longitude(^oE)';
else
    xlabelstr = 'Latitude(^oN)';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(vari, 'temp')
    clim = [10 30];
    contourinterval = [clim(1):2:clim(2)];
    colorbarname = '^oC';
    colormapname = 'parula';
elseif strcmp(vari, 'salt')
    clim = [30 35];
    contourinterval = [clim(1):.5:clim(2)];
    colorbarname = 'g/kg';
    colormapname = 'jet';
end

if target_year ~= 9999
    filepath='D:\Data\Ocean\KODC\excel\';
    filename= ['KODC_', ystr, '.xls'];
    file = [filepath,filename];
    
    [num, raw, txt] = xlsread(file);
    
    obsline = txt(3:end,2); obspoint = txt(3:end,3);
    lat = txt(3:end, 5); lon = txt(3:end, 6);
    date = datenum(txt(3:end, 7));
    dep = txt(3:end, 8);
    temp = txt(3:end, 9);
    salt = txt(3:end, 11);
    
    data_cell = [obsline obspoint lat lon dep temp salt];
    datasize = size(data_cell);
    
    clearvars data
    for i = 1:datasize(1)
        for j = 1:datasize(2)
            if isempty(cell2mat(data_cell(i,j))) == 1
                data(i,j) = NaN;
            else
                data(i,j) = str2num(cell2mat(data_cell(i,j)));
            end
        end
    end
    
    data_all = [datevec(date) data];
    
else % Æò³â
    filepath='D:\Data\Ocean\KODC\avg_ts(1979_2020)\';
    filename = 'KODC_avg(1979_2020).mat';
    file = [filepath, filename];
    data_all = load(file);
    data_all = data_all.data_avg;
end

nanmat = (isnan(data_all));
nanind_sum = sum(nanmat, 2);
nanind = find(nanind_sum > 0);
data_all(nanind,:) = [];

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
tl = clabel(cs,h,'LabelSpacing',200, 'FontSize', 20, 'FontWeight', 'bold');
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

saveas(gcf, [filepath, vari, '_vertical_', section_dir, '_', num2char(Nline, 3), '_', ystr, mstr, '.png'])

    end
end
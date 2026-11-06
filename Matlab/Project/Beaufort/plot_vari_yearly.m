clear; clc; close all

yyyy_all = 2004:2025;

filepath = '/data/jungjih/Project/Beaufort/';
filename = ['SIC_NSIDC_v4.nc'];
file = [filepath, filename];
timenum = ncread(file, 'time') + datenum(2000,1,1);
timevec = datevec(timenum);
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');
SIC = ncread(file, 'SIC');

vari_str = 'SIC';
switch vari_str
    case 'SIT'
        climit = [0 4.5];
        clabel = 'Sea ice thickness [m]';
        color = 'jet(9)';
    case 'SIC'
        climit = [0 100];
        clabel = 'Sea ice concentration [%]';
        color = 'jet(10)';
end

figure('Color', 'w');
set(gcf, 'Position', [1 200 1300 900])
t = tiledlayout(4,6);
t.Padding = 'compact';
t.TileSpacing = 'compact';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    index = find(timevec(:,1) == yyyy);
    vari = squeeze(mean(SIC(:,:,index),3));
    vari(vari < 0.001) = NaN;

    nexttile(yi)
    plot_arctic_map
    caxis(climit);
    
    p = pcolorm(lat, lon, vari);
    uistack(p, 'bottom')
    colormap(color)

    title(ystr, 'FontSize', 20)
end

c = colorbar;
c.Layout.Tile = 'east';
c.Label.String = clabel;
c.FontSize = 12;
asdf
print([vari_str, '_yearly'], '-dpng')
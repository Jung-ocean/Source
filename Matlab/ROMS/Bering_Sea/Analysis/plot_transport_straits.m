clear; clc; close all

yyyy_all = 2019:2023;
mm_all = 1:12;
ver = 'uv';
ismap = 0;

straits = {'Anadyr_Strait', 'Shpanberg_Strait', 'Cape_Navarin-Navarin_Canyon', 'Navarin_Canyon-Unimak_Island'};
colors = {'r', '0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b'};

if strcmp(ver, 'transect')

    filepath_all = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/transect/';
    straits = {st1, st2, st3, st4};

    for si = 1:length(straits)
        strait = straits{si};
        filepath = [filepath_all, strait, '/'];
        filename = ['transport_', strait, '.mat'];
        file = [filepath filename];
        load(file)
        trans = trans';
    end

elseif strcmp(ver, 'uv')
    load transport_straits.mat
    trans_all = trans*1e6;
    for si = 1:length(straits)
        strait = straits{si};
        if strcmp(strait, 'Anadyr_Strait') | strcmp(strait, 'Shpanberg_Strait')
            trans(si,:) = -trans(si,:);
        end
    end
end

%%%
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    timenum = [timenum datenum(yyyy,mm_all,1)];
end

if ismap == 1
g = grd('BSf');

% Map plot
figure;
set(gcf, 'Position', [1 200 800 500])
plot_map('Eastern_Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
% Anadyr Strait
lonu_f = [-173.1215 -171.5040];
latu_f = [64.5319 63.4801];
plotm(latu_f, lonu_f, '-', 'LineWidth', 4, 'Color', colors{1})
% Shpanberg_Strait
lonu_f = [-168.9263 -164.6972];
latu_f = [63.2776 62.8325];
plotm(latu_f, lonu_f, '-', 'LineWidth', 4, 'Color', colors{2})
% Cape_Navarin-Navarin_Canyon
lonu_f = [-180.9119 -178.7993];
latu_f = [62.6569 61.3307];
plotm(latu_f, lonu_f, '-', 'LineWidth', 4, 'Color', colors{3})
% Navarin_Canyon-Unimak_Island
lonu_f = [-178.7993 -164.6709];
latu_f = [61.3307 54.4939];
plotm(latu_f, lonu_f, '-', 'LineWidth', 4, 'Color', colors{4})
print('map_straits', '-dpng')
end

figure; 
t = tiledlayout(2,1);
set(gcf, 'Position', [1 200 1300 800])

nexttile(1); hold on; grid on;
title('Monthly volume transport', 'FontSize', 20)
for si = 1:length(straits)
    p(si) = plot(timenum, trans(si,:), '-o', 'LineWidth', 2, 'Color', colors{si});
end
ylim([-3 3])
xticks(datenum(yyyy_all,1,1))
datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
ylabel('Sv')
set(gca, 'FontSize', 15)

nexttile(2); hold on; grid on;
title('Net transport', 'FontSize', 20)
net = sum(trans,1);
p(si+1) = plot(timenum, net, '-ok', 'LineWidth', 1);
ylim([-.8 .8])
xticks(datenum(yyyy_all,1,1))
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
ylabel('Sv')
set(gca, 'FontSize', 15)

print('transport_straits', '-dpng')
asdf
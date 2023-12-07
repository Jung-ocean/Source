clear; clc

yyyy = 2003;
mm_KS = [1:12];

ty = yyyy; tys = num2str(yyyy);
if yyyy == 9999;
    tys = 'avg';
    
    trans_Fukudome_WE_avg
else
    trans_Fukudome_WE
end

trans_all = load(['transport_Korea_strait_', tys,'.txt']);
KS = trans_all(1:length(mm_KS));
if mm_KS(end) ~=12
    KS(mm_KS(end)+1:12) = nan;
end
KS_west = trans_all(13:24);
KS_east = trans_all(25:end);

figure; hold on; grid on;

h_K = plot(KS, 'r', 'linewidth', 2);
h_F = plot(trans_FT, '--r', 'linewidth', 2);

h_KW = plot(KS_west, 'g', 'linewidth', 2);
h_FW = plot(trans_FW, '--g', 'linewidth', 2);

h_KE = plot(KS_east, 'b', 'linewidth', 2);
h_FE = plot(trans_FE, '--b', 'linewidth', 2);

set(gca, 'fontsize', 15)

xlabel('Month', 'fontsize', 15)
ylabel('Transport(sv)', 'fontsize', 15)
xlim([0 13]); ylim([0 4.5])

h = legend([h_K, h_KW h_KE], 'Korea Strait', 'Western', 'Eastern', 'location', 'NorthWest');

h.FontSize = 15;
title(['KS transport ', tys], 'FontSize', 15)

saveas(gcf, ['transport_KSWE_', tys, '.png'])
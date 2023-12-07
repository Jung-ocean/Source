clear; clc

yyyy = 2016;
mm_KS = [1:12];

ty = yyyy; tys = num2str(yyyy);
if yyyy == 9999;
    tys = 'avg';
    
    trans_Nishimura_avg
    trans_Fukudome_avg
else
    trans_Nishimura
    trans_Fukudome
end

trans_all = load(['transport_straits_', tys,'.txt']);
%trans_all = load(['transport_Korea_strait_2018.txt']);
KS = trans_all(1:length(mm_KS));
if mm_KS(end) ~=12
    KS(mm_KS(end)+1:12) = nan;
end

figure; hold on; grid on;

h_K = plot(KS, 'linewidth', 2);
h_N = plot(trans_N, 'linewidth', 2, 'color', [0.8510    0.3294    0.1020]);
h_F = plot(trans_F, 'linewidth', 2, 'color', [0.9294    0.6902    0.1294]);

set(gca, 'fontsize', 15)

xlabel('Month', 'fontsize', 15)
ylabel('Transport(sv)', 'fontsize', 15)
xlim([0 13]); ylim([0 4.5])

h = legend([h_K, h_N, h_F], 'Model', 'Sea level diff (Nishimura)', 'ADCP (Fukudome)', 'location', 'SouthWest');
if yyyy >=2008
    h = legend([h_K, h_F], 'Model', 'ADCP (Fukudome)', 'location', 'SouthWest');
end
if yyyy == 9999 || yyyy > 2015
    h = legend([h_K, h_N, h_F], 'Model', 'Sea level diff (Nishimura)', 'ADCP (Fukudome)', 'location', 'SouthWest');
end

h.FontSize = 15;
title(['KS transport ', tys], 'FontSize', 15)

saveas(gcf, ['transport_KS_', tys, '.png'])
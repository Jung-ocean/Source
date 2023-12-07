clear; clc

ty = 2016; % target year
tys = num2str(ty);

trans_Fukudome_2008

KS = load(['transport_KS_', tys,'.txt']);

figure; hold on;

plot(KS, 'linewidth', 2)
plot(trans_F, 'linewidth', 2)

set(gca, 'fontsize', 15)

xlabel('Month', 'fontsize', 15)
ylabel('Transport(sv)', 'fontsize', 15)
xlim([0 13])
ylim([0.5 4.5])
title(['KS transport, ', tys], 'FontSize', 15)

legend(['ROMS NWP ', tys], 'Fukudome (ADCP)', 'fontsize', 15, 'location', 'SouthWest')
title(['KS transport ', tys], 'FontSize', 15)

saveas(gcf, ['transport_KS_', tys, '.png'])
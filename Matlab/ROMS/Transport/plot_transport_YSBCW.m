clear; clc

mm_KS = [1:12];
yyyy = 1980:2015;

Y2S_all = [];
Jeju_all = [];

for yi = 1:length(yyyy)
    ty = yyyy(yi); tys = num2str(ty);
    if ty == 9999
        tys = 'avg';
    end
    
    filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', tys, '\'];
    if ty == 1980
        filepath = 'G:\Model\ROMS\Case\NWP\output\exp_SODA3\old_1980\1980_ver38\output_14\';
    end
    
    filename = ['transport_straits_', tys,'.txt'];
    file = [filepath, filename];
    
    trans_all = load(file);
    
    Y2S = trans_all(25:36);
    Jeju = trans_all(37:48);
    
    Y2S_all = [Y2S_all; Y2S'];
    Jeju_all = [Jeju_all; Jeju'];
    
    if ty == 2013
        Y2S_2013 = Y2S;
        Jeju_2013 = Jeju;
    end
end
Y2S_mean = mean(Y2S_all);
Y2S_std = std(Y2S_all);

Jeju_mean = mean(Jeju_all);
Jeju_std = std(Jeju_all);

figure(1); hold on; grid on;
errorbar(1:12, Y2S_mean, Y2S_std);
plot(1:12, Y2S_2013, 'LineWidth', 2)
set(gca, 'fontsize', 15)
xlabel('Month', 'fontsize', 15)
ylabel('Transport(sv)', 'fontsize', 15)
xlim([0 13]); ylim([1.5 3])
title('Y2S')

figure(2); hold on; grid on;
errorbar(1:12, Jeju_mean, Jeju_std);
plot(1:12, Jeju_2013, 'LineWidth', 2)
set(gca, 'fontsize', 15)
xlabel('Month', 'fontsize', 15)
ylabel('Transport(sv)', 'fontsize', 15)
xlim([0 13]); ylim([-0.5 1.5])
title('Jeju Strait')

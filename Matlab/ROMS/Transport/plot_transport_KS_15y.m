clear; clc; close all

yyyy = 2006:2015;

xdate = [];
for yi = yyyy
    for mi = 1:12;
        xdate = [xdate; yi mi];
    end
end

trans_N_all = [];
trans_F_all = [];
trans_KS_all = [];

for yi = yyyy
    ty = yi; ystr = num2str(ty);
    filepath = ['.\', ystr, '\'];
    if ty == 1980
        filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\old_1980\1980_ver38\output_14\'];
    end
    trans_Nishimura;
    if ~isempty(trans_N)
        trans_N_all = [trans_N_all; trans_N];
    else
        trans_N_all = [trans_N_all; [1:12]'*NaN];
    end
    
    trans_Fukudome;
    if ~isempty(trans_F)
        trans_F_all = [trans_F_all; trans_F];
    else
        trans_F_all = [trans_F_all; [1:12]'*NaN];
    end
    
    clearvars trans_F trans_N
    
    trans_straits = load([filepath, 'transport_straits_', ystr, '.txt']);
    trans_KS = trans_straits(1:12);
    trans_KS_all = [trans_KS_all; trans_KS];
    
end

xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

figure; hold on; grid on
plot(xdatenum, trans_KS_all, 'LineWidth', 2)
plot(xdatenum, trans_N_all, 'LineWidth', 2)
plot(xdatenum, trans_F_all, 'LineWidth', 2)
datetick('x', 'yy')

ylim([0.5 4])
xlim([datenum(yyyy(1)-1, 12, 31), datenum(yyyy(end)+1, 1, 1)])
xlabel('Year'); ylabel('Transport(sv)')
set(gca, 'FontSize', 20)
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
set(gca, 'XtickLabel', [yyyy(1):yyyy(end)])

h = legend('ROMS', 'Nishimura (Sea level diff)', 'Fukudome (ADCP)', 'location', 'SouthEast');
h.FontSize = 25;
title('Korea Strait transport', 'FontSize', 25)
clear; clc; close all

yyyy = 1993:2015;

xdate = [];
for yi = yyyy
    for mi = 1:12
        xdate = [xdate; yi mi];
    end
end

trans_F_all = [];
trans_KS_all = [];

for yi = yyyy
    ty = yi; tys = num2str(ty);
    filepath = ['.\', tys, '\'];
    if ty == 1980
        filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\old_1980\1980_ver38\output_14\'];
    end
    
    data = load('D:\Data\Ocean\Transport\transport_Fukudome.txt');
    trans = data(:,3);
    yyyy_F = data(:,1);
    mm_F = data(:,2);
    ind = find(yyyy_F == ty);
    trans_F = trans(ind);
    trans_F_all = [trans_F_all; trans_F];
    clearvars trans_F
    
    trans_straits = load([filepath, 'transport_straits_', tys, '.txt']);
    trans_KS = trans_straits(1:12);
    trans_KS_all = [trans_KS_all; trans_KS];
    
end

F_datenum = datenum(yyyy_F, mm_F, 15, 0 ,0, 0);

HYCOM_filepath = 'D:\Data\Ocean\Transport\HYCOM\hycom_trans\';
HYCOM_filename = 'hycom_trans.dat';
HYCOM_file = [HYCOM_filepath, HYCOM_filename];
HYCOM = load(HYCOM_file);
HYCOM_datenum = datenum(HYCOM(:,1), HYCOM(:,2), 15, 0 ,0, 0);
trans_HYCOM = HYCOM(:,3);

xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

figure; hold on; grid on
plot(xdatenum, trans_KS_all, 'LineWidth', 2)
plot(HYCOM_datenum, trans_HYCOM, 'LineWidth', 2)
plot(F_datenum, trans_F_all, 'color', [0.4706 0.6706 0.1882], 'LineWidth', 2)
datetick('x', 'yy')

ylim([0 5])
xlim([datenum(yyyy(1)-1, 12, 31), datenum(yyyy(end)+1, 1, 1)])
xlabel('Year'); ylabel('Transport(sv)')
set(gca, 'FontSize', 25)

h = legend('Model', 'HYCOM', 'ADCP (Fukudome et al., 2010)', 'location', 'SouthEast');
h.FontSize = 25;
%title('Korea Strait transport', 'FontSize', 25)
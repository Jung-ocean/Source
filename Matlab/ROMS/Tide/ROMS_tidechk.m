%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Check ROMS free-surface with tidal station
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

staind = 3; % 1 = Yeosu 2 = Wando 3 = Ieodo
switch staind
    case 1
        sta_name = 'Yeosu';
    case 2
        sta_name = 'Wando';
    case 3
        sta_name = 'Ieodo';
end

yyyy = 2013; ystr = num2str(yyyy);
mm_start = 8;
dd_start = 1;
mm_end = 8;
dd_end = 31;

%% Model
stafilepath = '.\';
stafilename = 'sta.nc';
stafile = [stafilepath, stafilename];

stanc = netcdf(stafile);
zeta = stanc{'zeta'}(:);
ot = stanc{'ocean_time'}(:);
close(stanc)

refdatenum = datenum(yyyy,01,01,0,0,0);
ot_datenum = ot/60/60/24 + refdatenum;

startdatenum = datenum(yyyy,mm_start,dd_start,0,0,0);
enddatenum = datenum(yyyy,mm_end,dd_end,0,0,0);

startind = find(ot_datenum == startdatenum);
endind = find(ot_datenum == enddatenum);

modeltime = ot_datenum(startind:endind) + 9/24; % GMT to KMT
model_zeta_target = zeta(startind:endind,staind);

%% Observation
switch staind
    case 1
        obsfilepath = 'D:\Data\Ocean\조위관측소\elevation\';
        obsfilename = ['여수_1시간조위_', ystr, '.txt'];
    case 2
        obsfilepath = 'D:\Data\Ocean\조위관측소\elevation\';
        obsfilename = ['완도_1시간조위_', ystr, '.txt'];
    case 3
        obsfilepath = 'D:\Data\Ocean\종합해양과학기지\';
        obsfilename = ['이어도_1시간조위_', ystr, '.txt'];
end

obsfile = [obsfilepath, obsfilename];
obsdata = load(obsfile);
obsdatenum = datenum(obsdata(:,1), obsdata(:,2), obsdata(:,3), obsdata(:,4), 0, 0);
obszeta = obsdata(:,6);

obszeta_m = (obszeta - mean(obszeta))/100; % cm to m

startind = find(obsdatenum == startdatenum + 9/24); % Because of KMT (GMT + 9)
endind = find(obsdatenum == enddatenum + 9/24);

obstime = obsdatenum(startind:endind);
obs_zeta_target = obszeta_m(startind:endind);
%% Plot
figure;
plot(obstime, obs_zeta_target,'b')
hold on
plot(modeltime, model_zeta_target,'r')

datetick('x', 'mm/dd')
ylim([-2 3])
xlabel('Time(Day)', 'fontsize', 15)
ylabel('Elevation (m)', 'fontsize', 15)
set(gca, 'fontsize', 15)
legend('Observation', 'Model')
title([sta_name, ' ', ystr], 'FontSize', 15)

saveas(gcf, [sta_name, '_', ystr, '.png'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Check ROMS free-surface with tidal station (Ver2 using dat file)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

station = 'Wando';

obsfilepath = 'D:\Data\Ocean\조위관측소\';
obsfilename = '완도_1시간조위_2013.txt';

%% Model
stafilepath = 'G:\Model\ROMS\Output\NWP\';
stafilename = ['DA_NWP_el_2013_', station, '.dat'];
stafile = [stafilepath, stafilename];
data_all = load(stafile);

ot = data_all(:,1);
zeta = data_all(:,2);

refdatenum = datenum(2013,01,01,0,0,0);
ot_datenum = ot/60/60/24 + refdatenum;

startdatenum = datenum(2013,1,1,0,0,0);
enddatenum = datenum(2013,3,1,0,0,0);

startind = find(ot_datenum == startdatenum);
endind = find(ot_datenum == enddatenum);

modeltime = ot_datenum(startind:endind) + 9/24; % GMT to KMT
model_zeta_target = zeta(startind:endind,:);

%% Observation
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

datetick('x', 'mm/dd', 'keepticks')
ylim([-2 3])
xlabel('Time(Day)', 'fontsize', 15)
ylabel('Elevation (m)', 'fontsize', 15)
set(gca, 'fontsize', 15)
legend('Observation', 'Model')
title(station, 'fontsize', 15)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Write ROMS free-surface data using ROMS station output file
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc
%% Model
stafilepath = 'G:\Model\ROMS\Output\ROMS_ECMWF\';
stafilename = 'sta.nc';
stafile = [stafilepath, stafilename];

staind = 1; % Second value in sta.nc file

stanc = netcdf(stafile);
zeta = stanc{'zeta'}(:);
lon_rho = stanc{'lon_rho'}(:);
lat_rho = stanc{'lat_rho'}(:);
ot = stanc{'ocean_time'}(:);
close(stanc)

refdatenum = datenum(2013,01,01,0,0,0);
ot_datenum = ot/60/60/24 + refdatenum;

startdatenum = datenum(2013,01,01,0,0,0);
enddatenum = datenum(2013,12,31,0,0,0);

startind = find(ot_datenum == startdatenum);
endind = find(ot_datenum == enddatenum);

modeltime = ot_datenum(startind:endind,:); % GMT
zeta_target = zeta(startind:endind,staind);

fmt = ['%12.7f%12.7f'];
for f = 1:length(zeta_target)
    fmt = [fmt '%10.3f'];
end

fid = fopen('zeta_model.dat','w');
fprintf(fid, fmt, [lon_rho(staind), lat_rho(staind), zeta_target']);
fclose(fid);
%% Observation
% Yeosu tide station
obs_lon = 126.7597; obs_lat = 34.3156;
obsfilepath = 'D:\Data\Ocean\조위관측소\';
obsfilename = '여수_1시간조위_2013.txt';
obsfile = [obsfilepath, obsfilename];
obsdata = load(obsfile);
obsdatenum = datenum(obsdata(:,1), obsdata(:,2), obsdata(:,3), obsdata(:,4), 0, 0);
obszeta = obsdata(:,6);

obszeta_m = (obszeta - mean(obszeta))/100; % cm to m

startind = find(obsdatenum == startdatenum + 9/24); % Because of KMT (GMT + 9)
endind = find(obsdatenum == enddatenum + 9/24);

obstime = obsdatenum(startind:endind);
obs_zeta_target = obszeta_m(startind:endind);

fmt = ['%12.7f%12.7f'];
for f = 1:length(obs_zeta_target)
    fmt = [fmt '%10.3f'];
end

fid = fopen('zeta_obs.dat','w');
fprintf(fid, fmt, [obs_lon, obs_lat, obs_zeta_target']);
fclose(fid);
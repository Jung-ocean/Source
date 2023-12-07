%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Tune ROMS tide forcing file using Least-Square results
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% harmonic analysis S2 M2 N2 K2 K1 P1 O1 q1  M4 MS4 M6 2MS6  
% TPXO6             M2 S2 N2 K2 K1 O1 P1 Q1 Mf Mm
clear; clc

tfilepath = 'D:\fortran\Detide\Least square\ECMWF\';
tfilename = 'roms_tide_TPXO7_2013010100_YS.nc';
tfile = [tfilepath, tfilename];
nc = netcdf(tfile,'w')

model_tide = load([tfilepath, 'zeta_model_lsq_YS.dat']);
obs_tide = load([tfilepath, 'zeta_obs_lsq_YS.dat']);

% Phase
phase = nc{'tide_Ephase'}(:);

model_M2 = model_tide(:,6);
model_S2 = model_tide(:,4);
model_N2 = model_tide(:,8);
model_K2 = model_tide(:,10);
model_K1 = model_tide(:,12);
model_O1 = model_tide(:,16);
model_P1 = model_tide(:,14);
model_Q1 = model_tide(:,18);

obs_M2 = obs_tide(:,6);
obs_S2 = obs_tide(:,4);
obs_N2 = obs_tide(:,8);
obs_K2 = obs_tide(:,10);
obs_K1 = obs_tide(:,12);
obs_O1 = obs_tide(:,16);
obs_P1 = obs_tide(:,14); 
obs_Q1 = obs_tide(:,18);

phase_M2 = phase(1,:, :);
phase_S2 = phase(2,:, :);
phase_N2 = phase(3,:, :);
phase_K2 = phase(4,:, :);
phase_K1 = phase(5,:, :);
phase_O1 = phase(6,:, :);
phase_P1 = phase(7,:, :);
phase_Q1 = phase(8,:, :);

phase_M2 = phase_M2 + (obs_M2 - model_M2);
phase_S2 = phase_S2 + (obs_S2 - model_S2);
phase_N2 = phase_N2 + (obs_N2 - model_N2);
phase_K2 = phase_K2 + (obs_K2 - model_K2);
phase_K1 = phase_K1 + (obs_K1 - model_K1);
phase_O1 = phase_O1 + (obs_O1 - model_O1);
phase_P1 = phase_P1 + (obs_P1 - model_P1);
phase_Q1 = phase_Q1 + (obs_Q1 - model_Q1);

phase(1,:, :) = phase_M2;
phase(2,:, :) = phase_S2;
phase(3,:, :) = phase_N2;
phase(4,:, :) = phase_K2;
phase(5,:, :) = phase_K1;
phase(6,:, :) = phase_O1;
phase(7,:, :) = phase_P1;
phase(8,:, :) = phase_Q1;

nc{'tide_Ephase'}(:) = phase;

% Amplitude
amp = nc{'tide_Eamp'}(:);

model_M2_a = model_tide(:,5);
model_S2_a = model_tide(:,3);
model_N2_a = model_tide(:,7);
model_K2_a = model_tide(:,9);
model_K1_a = model_tide(:,11);
model_O1_a = model_tide(:,15);
model_P1_a = model_tide(:,13);
model_Q1_a = model_tide(:,17);

obs_M2_a = obs_tide(:,5);
obs_S2_a = obs_tide(:,3);
obs_N2_a = obs_tide(:,7);
obs_K2_a = obs_tide(:,9);
obs_K1_a = obs_tide(:,11);
obs_O1_a = obs_tide(:,15);
obs_P1_a = obs_tide(:,13); 
obs_Q1_a = obs_tide(:,17);

amp_M2 = amp(1,:, :);
amp_S2 = amp(2,:, :);
amp_N2 = amp(3,:, :);
amp_K2 = amp(4,:, :);
amp_K1 = amp(5,:, :);
amp_O1 = amp(6,:, :);
amp_P1 = amp(7,:, :);
amp_Q1 = amp(8,:, :);

amp_M2 = amp_M2 + (obs_M2_a - model_M2_a)/100;
amp_S2 = amp_S2 + (obs_S2_a - model_S2_a)/100;
amp_N2 = amp_N2 + (obs_N2_a - model_N2_a)/100;
amp_K2 = amp_K2 + (obs_K2_a - model_K2_a)/100;
amp_K1 = amp_K1 + (obs_K1_a - model_K1_a)/100;
amp_O1 = amp_O1 + (obs_O1_a - model_O1_a)/100;
amp_P1 = amp_P1 + (obs_P1_a - model_P1_a)/100;
amp_Q1 = amp_Q1 + (obs_Q1_a - model_Q1_a)/100;

amp(1,:, :) = amp_M2;
amp(2,:, :) = amp_S2;
amp(3,:, :) = amp_N2;
amp(4,:, :) = amp_K2;
amp(5,:, :) = amp_K1;
amp(6,:, :) = amp_O1;
amp(7,:, :) = amp_P1;
amp(8,:, :) = amp_Q1;

nc{'tide_Eamp'}(:) = amp;

close(nc)
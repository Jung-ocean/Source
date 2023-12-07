%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Tune ROMS tide forcing file using T-tide results
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

components = {'M2', 'S2', 'N2', 'K2', 'K1', 'O1', 'P1', 'Q1'};

tfilepath = 'G:\Model\ROMS\Output\ROMS_ECMWF\';
tfilename = 'roms_tide_2013010100.nc';
tfile = [tfilepath, tfilename];
nc = netcdf(tfile,'w');

%% Model
mfilepath = 'G:\Model\ROMS\Output\ROMS_ECMWF\';
mfilename = 'zeta_model_t_tide.txt';
mfile = [mfilepath, mfilename];

mfileID = fopen(mfile);
mdata = textscan(mfileID, '%s%f%f%f%f%f%f', 'HeaderLines', 16);
tide_comp = mdata{1}; freq = mdata{2}; amp = mdata{3}; amp_err = mdata{4};
pha = mdata{5}; pha_err = mdata{6}; snr = mdata{7}; % signal to noise ratio

for mi = 1:length(components)
    target_comp = cell2mat(components(mi));
    mi_ind = find(strcmp(['*', target_comp], tide_comp) == 1);
    eval(['model_amp_', target_comp, ' = amp(mi_ind);'])
    eval(['model_pha_', target_comp, ' = pha(mi_ind);'])
end

%% Observation

ofilepath = 'G:\Model\ROMS\Output\ROMS_ECMWF\';
ofilename = 'zeta_obs_t_tide.txt';
ofile = [ofilepath, ofilename];

ofileID = fopen(ofile);
odata = textscan(ofileID, '%s%f%f%f%f%f%f', 'HeaderLines', 16);
tide_comp = odata{1}; freq = odata{2}; amp = odata{3}; amp_err = odata{4};
pha = odata{5}; pha_err = odata{6}; snr = odata{7}; % signal to noise ratio

for oi = 1:length(components)
    target_comp = cell2mat(components(oi));
    oi_ind = find(strcmp(['*', target_comp], tide_comp) == 1);
    eval(['obs_amp_', target_comp, ' = amp(oi_ind);'])
    eval(['obs_pha_', target_comp, ' = pha(oi_ind);'])
end

%% Tuning
phase = nc{'tide_Ephase'}(:);

phase_M2 = phase(1,:, :);
phase_S2 = phase(2,:, :);
phase_N2 = phase(3,:, :);
phase_K2 = phase(4,:, :);
phase_K1 = phase(5,:, :);
phase_O1 = phase(6,:, :);
phase_P1 = phase(7,:, :);
phase_Q1 = phase(8,:, :);

for pi = 1:length(components)
    tc = cell2mat(components(pi)); % target_comp
    eval(['phase_', tc, ' = phase_', tc, ' + (obs_pha_', tc, ' - model_pha_', tc, ');'])
end

phase(1,:, :) = phase_M2;
phase(2,:, :) = phase_S2;
phase(3,:, :) = phase_N2;
phase(4,:, :) = phase_K2;
phase(5,:, :) = phase_K1;
phase(6,:, :) = phase_O1;
phase(7,:, :) = phase_P1;
phase(8,:, :) = phase_Q1;

phase(phase < 0) = phase(phase < 0) + 360;
phase(phase > 360) = phase(phase > 360) - 360;

nc{'tide_Ephase'}(:) = phase;

% Amplitude
amp = nc{'tide_Eamp'}(:);

amp_M2 = amp(1,:, :);
amp_S2 = amp(2,:, :);
amp_N2 = amp(3,:, :);
amp_K2 = amp(4,:, :);
amp_K1 = amp(5,:, :);
amp_O1 = amp(6,:, :);
amp_P1 = amp(7,:, :);
amp_Q1 = amp(8,:, :);

for ai = 1:length(components)
    tc = cell2mat(components(ai)); % target_comp
    eval(['amp_', tc, ' = amp_', tc, ' + (obs_amp_', tc, ' - model_amp_', tc, ')/100;']) % /100 means m to cm
end

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
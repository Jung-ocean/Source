%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Read T-tide output file
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear; clc

%filepath = '.\';
%filename = 'zeta_model_t_tide.txt';
%file = [filepath, filename];
fileID = fopen(file);
data = textscan(fileID, '%s%f%f%f%f%f%f', 'HeaderLines', 16)
tide_comp = data{1};
freq = data{2};
amp = data{3};
amp_err = data{4};
pha = data{5};
pha_err = data{6};
snr = data{7}; % signal to noise ratio
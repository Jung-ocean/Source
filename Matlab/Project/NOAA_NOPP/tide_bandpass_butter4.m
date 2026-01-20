function data_filtered = tide_bandpass_butter4(data, dt, constituent, istest)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function applies a bandpass filter around 0.8 to 1.2 times the
% frequency of a specified tidal constituent, using a 4th-order
% Butterworth filter.
%
% x: Data to be filtered (1D to 4D; except for the 1D case, the last 
%    dimension must be time)
% dt: Time interval of the data (in hours)
% constituent: Tidal constituent name (string, e.g., 'M2')
% istest: 0 or 1
%
% J. Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isvector(data)
    dim = 1;
else
    dim = ndims(data);
end
disp(['Applying bandpass filter around ', constituent, ' to the ', num2str(dim), 'D data']);

% Frequencies setting
fs = 1/dt; % cph;
freq_M2 = load_tidal_frequency(constituent);
freq_M2 = freq_M2/24; % cpd to cph
lf = 0.8*freq_M2;
hf = 1.2*freq_M2;

% Filter design
[b,a] = butter(4, [lf, hf]/(fs/2), 'bandpass');

if dim == 1
    x = data;
    x_filtered = filtfilt(b,a,x);
    data_filtered = x_filtered;
elseif dim == 2
    x = data'; % time x space
    x_filtered = filtfilt(b,a,x);
    data_filtered = x_filtered';
elseif dim == 3
    [nx,ny,nt] = size(data);
    nxny = nx*ny;
    % reshape to 2D: (nxny) x (nt)
    data_2D = reshape(data, [nxny, nt]);
    data_isnan = isnan(data_2D);
    data_isnan_sum = sum(data_isnan, 2);
    dataind = find(data_isnan_sum == 0);
    x = data_2D(dataind,:)';
    x_filtered = filtfilt(b,a,x);
    data_2D_filtered = data_2D;
    data_2D_filtered(dataind,:) = x_filtered';
    data_filtered = reshape(data_2D_filtered, [nx,ny,nt]);
elseif dim == 4
    [nx,ny,nz,nt] = size(data);
    nxny = nx*ny;
    data_filtered = NaN(size(data));
    for k = 1:nz
        data_3D = squeeze(data(:,:,k,:));
        % reshape to 2D: (nxny) x (nt)
        data_2D = reshape(data_3D, [nxny, nt]);
        data_isnan = isnan(data_2D);
        data_isnan_sum = sum(data_isnan, 2);
        dataind = find(data_isnan_sum == 0);
        x = data_2D(dataind,:)';
        x_filtered = filtfilt(b,a,x);
        data_2D_filtered = data_2D;
        data_2D_filtered(dataind,:) = x_filtered';
        data_3D_filtered = reshape(data_2D_filtered, [nx,ny,nt]);
        data_filtered(:,:,k,:) = data_3D_filtered;
    end
else
    error('Dimesion of the data should be 1, 2, 3, or 4')
end

if istest == 1
    if dim == 1
        data_test = data;
        data_test_filtered = data_filtered;
    elseif dim == 2
        dim_mid = round(size(data)/2);
        data_test = data(dim_mid(1),:);
        data_test_filtered = data_filtered(dim_mid(1),:);
    elseif dim == 3
        dim_mid = round(size(data)/2);
        data_test = squeeze(data(dim_mid(1),dim_mid(2),:));
        data_test_filtered = squeeze(data_filtered(dim_mid(1),dim_mid(2),:));
    elseif dim == 4
        dim_mid = round(size(data)/2);
        data_test = squeeze(data(dim_mid(1),dim_mid(2),end,:));
        data_test_filtered = squeeze(data_filtered(dim_mid(1),dim_mid(2),end,:));
    end

    figure; hold on; grid on;
    p1 = plot(data_test, '-k', 'LineWidth', 2);
    p2 = plot(data_test_filtered,'--r', 'LineWidth', 2);
    l = legend([p1, p2], 'Original', 'Filtered');
    title('At the center (if 4D, center of the surface field)')
end
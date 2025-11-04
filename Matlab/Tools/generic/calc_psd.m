function [psd, freq] = calc_psd(y, fs)

N = length(y);
freq = (0:(N/2)) * (fs/N);

% FFT
Y = fft(y);
Y1 = Y(1:N/2+1);
psd = (1/(fs*N)) * abs(Y1).^2;
psd(2:end-1) = 2*psd(2:end-1);
function [psd, freq] = calc_rotary_spectrum(u, v, fs)

z = u + sqrt(-1)*v;
N = length(z);
freq = (-(N+1)/2+1:(N)/2)*(fs/N);

% FFT
Z = fft(z);
Z = fftshift(Z);

% Rotary Spectrum
psd = (abs(Z).^2)/(fs*N);
function [psd, freq] = calc_rotary_spectrum(u, v, fs)
%% ------------------------------------------------------------------------
% Rotary Power Spectral Density (PSD)
% The FFT is normalized as
%
%       PSD = |FFT(z)|^2 / (fs * N)
%
% where
%       z  : complex velocity (u + i*v)
%       fs : sampling frequency (samples per unit time)
%       N  : number of samples
%
% This normalization satisfies Parseval's theorem:
%
%       sum(PSD) * df = mean(|z|^2)
%
% where
%
%       df = fs / N
%
% is the frequency resolution.
%
% Therefore, the integral of the PSD over frequency equals the mean
% kinetic energy of the complex velocity signal.
%
% PSD units:
%
%       (velocity)^2 / (cycles per unit time)
%
% Examples:
%   - If velocity is in m/s and frequency is in cycles/day:
%         PSD -> (m^2 s^-2)/(cycles/day)
%
%   - If velocity is in cm/s and frequency is in cycles/hour:
%         PSD -> (cm^2 s^-2)/(cycles/hour)
%
% Complex velocity definition:
%
%   z = u + i v
%
% Under MATLAB's FFT convention:
%
%   Positive frequency  -> Counterclockwise (CCW)
%   Negative frequency  -> Clockwise (CW)
%
% If clockwise-positive convention is desired,
% define z = u - i v instead.
% ------------------------------------------------------------------------

z = u + sqrt(-1)*v;
N = length(z);
% freq = (-(N+1)/2+1:(N)/2)*(fs/N);
freq = (-floor(N/2):ceil(N/2)-1)*(fs/N);

% FFT
Z = fft(z);
Z = fftshift(Z);

% Rotary Spectrum
psd = (abs(Z).^2)/(fs*N);

return

% Test code
% Sampling
dt = 1;              % hour
Ttotal = 72;         % total duration (hours)
t = (0:dt:Ttotal-dt)';

% 12-hour clockwise rotation
T = 12;              % period (hours)
omega = 2*pi/T;

u = cos(omega*t);
v = -sin(omega*t);

% Plot
figure; hold on; grid on
plot(u,v,'o-')
text(u(1),v(1),'start')
text(u(2),v(2),'one step after')
axis equal
xlabel('u')
ylabel('v')
title('Clockwise rotary motion')

fs = 1/dt;      % samples/hour
[psd,f] = calc_rotary_spectrum(u,v,fs);

figure
plot(f,psd,'k','LineWidth',1.5)
grid on
xlabel('Frequency (cycles/hour)')
ylabel('PSD')

function [px,py,pcw,pccw,freq,rdn] = s_rotation_spectra(x,y,Fs)
% written by Haidong Pan (First Institute of Oceanography) 2022/01/05 19:00
% email:panhaidong@fio.org.cn; panhaidong_phd@qq.com
% rotation spectrum function Ðý×ªÆ×º¯Êý
% modified from the Power spectral function cal_psd written by J-Chuning
%
% Input:    x    -  Original time series in x axis (cannot have missing values)
%           y    -  Original time series in y axis (cannot have missing values)

%           Fs   -  Sampling frequency [Hz]

% Output:   px    -  Power spectral density of x [Power/Hz]
%           py    -  Power spectral density of y [Power/Hz]
%           pcw   -  clockwise rotation spectrum [Power/Hz]
%           pccw  -  counterclockwise rotation spectrum [Power/Hz]
%           freq  -  Corresponded frequency [Hz]
%           rdn   -  Power spectral density of red noise

% The calculation was based on the matlab function fft: fast fourier
% transform. It transforms the signal into frequency domain. Red noise is
% calculated with function AR, which gives first order autoregression of
% the original signal, which represents red noise. So the test is better
% for red noise type signal, i.e., meteorological or oceanographic signal.
% It may not work will with white noise type signal !!!

%                                        For J - Chuning 2013/07/04
%                                                cnwang@eos.ubc.ca

% 2013/07/04 22:50

% Change S (Sampling interval) into FS (Sampling frequency) to match with
% other matlab functions

freq       = 0:Fs/length(x):Fs/2;
x          = x(:); freq = freq(:);
xi         = iddata(x,[],1/Fs);
m          = ar(xi,1);
mi         = idfrd(m,freq);
rdn        = squeeze(mi.SpectrumData);
N          = length(x);
%fft for x
xdft       = fft(x);
xdft       = xdft(1:floor(N/2)+1);
px          = (1/(Fs*N)).*abs(xdft).^2;
px(2:end-1) = 2*px(2:end-1);
%fft for y
ydft       = fft(y);
ydft       = ydft(1:floor(N/2)+1);
py          = (1/(Fs*N)).*abs(ydft).^2;
py(2:end-1) = 2*py(2:end-1);

sz1=size(xdft);
if sz1(1)>1
    xdft=xdft';
end
sz2=size(ydft);
if sz2(1)>1
    ydft=ydft';
end
%calculate counterclockwise rotation spectrum
ccw=0.5*(real(xdft)+imag(ydft)+sqrt(-1)*(real(ydft)-imag(xdft)));
pccw=0.5*ccw.*conj(ccw);
pccw          = (1/(Fs*N)).*pccw;
pccw(2:end-1) = 2*pccw(2:end-1);
%calculate clockwise rotation spectrum
cw=0.5*(real(xdft)-imag(ydft)+sqrt(-1)*(real(ydft)+imag(xdft)));
pcw=0.5*cw.*conj(cw);
pcw          = (1/(Fs*N)).*pcw;
pcw(2:end-1) = 2*pcw(2:end-1);
end

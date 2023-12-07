
function [f_final,s_final,phase]=fftspectrum(u,t)

%FFT 
% fft(1:10)을 실행하면, 10개의 수가 나오는데, 1번은 0 frequency, 2~5번은 + frequency, 6~10번은
% - frequency를 의미한다. 따라서 주파수가 - , 0 , + 순으로 나오게 하려면,
% fftshift(fft(1:10))으로 해주면 된다. 0 frequency는 1:10까지의 총합을 의미..

% load tjrwuv2yr.mat

[ns, nt] = size(u);

df = (nt-1)/(max(t)-min(t)); %unit : cycles per day

if mod(nt,2), f=df*[-(nt-1)/2:(nt-1)/2]/nt;
else, f = df*[-nt/2:nt/2-1]/nt;
end
deltaf=diff(f(1:2));

u=u-nanmean(u);      % 0 frequency가 높게나와 그림보는게 어려울 때가 있어 빼준다. 

ii=isnan(u);u(ii)=0; %addhoc
%ii = find(isnan(u) | isnan(v));

d=u;
fc=fftshift(fft(d))/nt;
phase = angle(fc);
s=abs(fc).^2/deltaf;

f_final=f(0<f);
s_final=s(0<f);



%paseval's theorem

% sum(s)*deltaf;  %spetrum의 총 면적(에너지)는 data의 분산값과 일치한다. 단, s에서 평균값을 빼줘야 같다.
% nanvar(u);      %분산은 평균값을 포함하지 않기 때문에
end


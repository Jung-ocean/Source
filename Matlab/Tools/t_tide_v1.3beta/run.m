clear all;close all;clc;

file = ('G:\t_tide_v1.3beta\test\model_u.dat');
data = load(file);    %데이터 파일의 위치 및 이름

% uu=c1(:,1);       %x방향 유속성분(1열)
% vv=c1(:,2);       %y방향 유속성분(2열)
% raw_data=uu+i*vv;

raw_data = data(1,3:end).*100; % meter to centimeter
inter = 1; %자료의 시간간격임 단위는 hr
lat = 34; % 인천
start_t = datenum(2014,5,1,9,0,0); %데이터 시작 시간(동경 135도 기준), 그리니치 기준은 9시간을 빼거나, start_t에서 0.3750을 빼면 될 것임 
output = 'test.txt' %조화분해 결과를 저장할 파일명과 경로
tt = 1:length(raw_data); 

[tidestruc,pout]=t_tide(raw_data,...
    'interval',inter,...   %자료 시간간격, 여기서 바로입력해도됨
    'latitude',lat,...      %위도, 여기서 바로입력해도됨
    'start',start_t,...     %시작시간, 여기서 바로입력해도됨
    'secular','mean',...    %장기관측에 다른 경향제거('mean','linear')
    'rayleigh',1,...         %해상력(관측기간이 충분하지 않은 경우 사용 가능)
    'output',output,...     %아웃풋 파일이름, 여기서 바로입력해도됨
     'shallow','M10',...    %천해조
     'error','wboot',...    %신뢰한계오차(‘wboot','cboot','linear')
     'synthesis',1);         %예측결과시 포함할 분조(신호 대 잡음비는 1 이상이 좋음)
save c1r %변수를 저장할 mat파일명

echo off

    %    pout=t_predic(tuk_time,tidestruc,,...
    %                  'latitude',69+27/60,...
    %                  'synthesis',1);

clf;orient tall;
subplot(211);
plot(tt,[raw_data; pout]);
line(tt,raw_data-pout,'linewi',2,'color','r');
xlabel('Hours');
ylabel('Velocity (cm/s)');
text(190,1000,'Original Time series','color','b');
text(190,1200,'Tidal prediction from Analysis','color',[0 .5 0]);
text(190,1400,'Original time series minus Prediction','color','r');
title('Demonstration of t\_tide toolbox');
legend('Raw data', 'Prediction', 'Subtidal')

subplot(212);
fsig=tidestruc.tidecon(:,1)>tidestruc.tidecon(:,2); % Significant peaks
semilogy([tidestruc.freq(~fsig),tidestruc.freq(~fsig)]',[.0005*ones(sum(~fsig),1),tidestruc.tidecon(~fsig,1)]','.-r');
line([tidestruc.freq(fsig),tidestruc.freq(fsig)]',[.0005*ones(sum(fsig),1),tidestruc.tidecon(fsig,1)]','marker','.','color','b');
line(tidestruc.freq,tidestruc.tidecon(:,2),'linestyle',':','color',[0 .5 0]);
set(gca,'ylim',[.0005 500],'xlim',[0 .5]);
xlabel('frequency (cph)');
text(tidestruc.freq,tidestruc.tidecon(:,1),tidestruc.name,'rotation',45,'vertical','base');
ylabel('Amplitude (cm)');
% text(.27,.4,'Analyzed lines with 95% significance level');
text(.3,150,'Significant Constituents','color','b');
text(.3,80,'Insignificant Constituents','color','r');
text(.3,30,'95% Significance Level','color',[0 .5 0]);



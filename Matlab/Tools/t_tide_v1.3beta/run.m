clear all;close all;clc;

file = ('G:\t_tide_v1.3beta\test\model_u.dat');
data = load(file);    %������ ������ ��ġ �� �̸�

% uu=c1(:,1);       %x���� ���Ӽ���(1��)
% vv=c1(:,2);       %y���� ���Ӽ���(2��)
% raw_data=uu+i*vv;

raw_data = data(1,3:end).*100; % meter to centimeter
inter = 1; %�ڷ��� �ð������� ������ hr
lat = 34; % ��õ
start_t = datenum(2014,5,1,9,0,0); %������ ���� �ð�(���� 135�� ����), �׸���ġ ������ 9�ð��� ���ų�, start_t���� 0.3750�� ���� �� ���� 
output = 'test.txt' %��ȭ���� ����� ������ ���ϸ�� ���
tt = 1:length(raw_data); 

[tidestruc,pout]=t_tide(raw_data,...
    'interval',inter,...   %�ڷ� �ð�����, ���⼭ �ٷ��Է��ص���
    'latitude',lat,...      %����, ���⼭ �ٷ��Է��ص���
    'start',start_t,...     %���۽ð�, ���⼭ �ٷ��Է��ص���
    'secular','mean',...    %�������� �ٸ� ��������('mean','linear')
    'rayleigh',1,...         %�ػ��(�����Ⱓ�� ������� ���� ��� ��� ����)
    'output',output,...     %�ƿ�ǲ �����̸�, ���⼭ �ٷ��Է��ص���
     'shallow','M10',...    %õ����
     'error','wboot',...    %�ŷ��Ѱ����(��wboot','cboot','linear')
     'synthesis',1);         %��������� ������ ����(��ȣ �� ������� 1 �̻��� ����)
save c1r %������ ������ mat���ϸ�

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



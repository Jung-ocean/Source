clear all;close all;clc

yswc34=load('.\coreNvel34dep-30.txt');
%yswc35=load('.\coreNvel35dep-30.txt');
%yswc36=load('.\coreNvel36dep-30.txt');
% yswc125=load('..\daily_velocity\coreEvel125dep-30.txt');
%nwwind=load('..\daily_wind\northwest_ys.txt');

[f34,s34]=fftspectrum(yswc34',[1:1:60]);
%[f35,s35]=fftspectrum(yswc35',[1:1:60]);
%[f36,s36]=fftspectrum(yswc36',[1:1:60]);
% [f125,s125]=fftspectrum(yswc125',[1:1:60]);
%[fw,sw]=fftspectrum(nwwind',[1:1:60]);
int_f=[min(f34):0.001:max(f34)];

int_s3=interp1(f34,s34,int_f,'linear');
%int_s4=interp1(f35,s35,int_f,'linear');
%int_s5=interp1(f36,s36,int_f,'linear');
% int_s6=interp1(f125,s125,int_f,'linear');
%int_sw=interp1(fw,sw,int_f,'linear');

figure(1)

%loglog(fw,sw,'k','linewidth',1.5)
hold on
loglog(f34,s34,'r','linewidth',1.5)
%loglog(f35,s35,'g','linewidth',1.5)
%loglog(f36,s36,'b','linewidth',1.5)
% loglog(f125,s125,'c','linewidth',1.5)

xlabel('frequency (cycles per day, cpd)','fontsize',16);
ylabel('spectrum ((m/s)^{2}/cpd)','fontsize',16);
% legend('NWwind','34━N','35━N','36━N','125━N',-1)
legend('NWwind','34━N','35━N','36━N',-1)
set(gca,'fontsize',16);
% pts = ginput(1)
% point=[num2str(pts(1))]
saveas(gcf,'spectrum1','tif')
figure(2)
% semilogx(fw,sw,'k')
hold on

% semilogx(f34,s34,'r')
% semilogx(f35,s35,'g')
% semilogx(f36,s36,'b')
% pts = ginput(1)
% point=[num2str(pts(1))]
xlabel('frequency (cycles per day, cpd)','fontsize',19);
ylabel('spectrum ((m/s)^2/cpd)','fontsize',19);
legend('NWwind','34━N','35━N','36━N')
set(gca,'fontsize',19);
saveas(gcf,'spectrum2','tif')
figure(3)
hold on
[Ax,H1,H2] = plotyy(int_f,int_s3,int_f,int_sw);
set(H1,'color','r','LineWidth',2);
set(H2,'color','k','LineWidth',2);
set(Ax(1),'Fontsize',20,'LineWidth',2);set(Ax(2),'Fontsize',20,'LineWidth',2)
set(Ax(1),'YLim',[0 0.005],'YTick',[0:0.001:0.005]);
set(Ax(2),'Ycolor','k');

set(get(Ax(2),'Ylabel'),'String','wind spectrum ((m/s)^{2}/cpd)','fontsize',20,'color','k')
set(get(Ax(1),'Ylabel'),'String','current spectrum ((m/s)^{2}/cpd)','fontsize',20)
plot(int_f,int_s4,'g','linewidth',2)
plot(int_f,int_s5,'b','linewidth',2)
% plot(int_f,int_s6,'c','linewidth',2)
xlabel('frequency (cpd)');
saveas(gcf,'spectrum3','tif')

% legend('NW-wind','34━N','35━N','36━N');
% plot(int_f,[int_s2],'g')
% plot(int_f,[int_s3],'b')
pts = ginput(1)
point=[num2str(pts(1))]
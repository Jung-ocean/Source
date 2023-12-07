clc;clear all;%close all

wtype_all = 1;
swrad = 300;

depth = [0:1:2000];

for wi=1:length(wtype_all)
    Jindex = wtype_all(wi);
    
lmd_mu1=[0.35 0.6 1 1.5  1.4 0.42 0.37 0.33 0.00468592];
lmd_mu2=[23 20 17 14 7.9 5.13 3.54 2.34 1.51];
lmd_r1= [0.58 0.62 0.67 0.77  0.78 0.57 0.57 0.57 0.55];

% lmd_mu1=[1.5 0.6 1 1.5 1.5];
% lmd_mu2=[5.9 20 17 14 1];
% lmd_r1= [0.98 0.62 0.67 0.77 3];

Zscale=-1;

Z=10;


fac1=Zscale/lmd_mu1(Jindex);
fac2=Zscale/lmd_mu2(Jindex);
fac3=lmd_r1(Jindex);
ic=0;
for Z=depth
    ic=ic+1;
    sw(wi,ic)=swrad*(fac3*exp((Z)*fac1)+exp((Z)*fac2)*(1.0-fac3));
end

end
figure; hold on; grid on
plot(sw(1,:),-depth,'r','linewidth',1.5);xlim([-10 200])
xlabel('shortwave radiation (W/m^{2})','fontsize',15);ylabel('Depth(m)','fontsize',15);
set(gca,'fontsize',15)

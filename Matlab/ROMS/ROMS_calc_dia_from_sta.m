ncload sta.nc

pm = g.pm(k);
pn = g.pn(k);

staind = 1;
ot_sta = ocean_time;
ot_all = [];

u_all = [];
u_daily = [];
uHomn_all = [];
uHomn_daily = [];
Homn_all = [];
Homn_daily = [];
uHomn_perturb = [];
ot_all = [];
for fi = 1:length(filenumber)
    
    ot(fi) = filenumber(fi)-1;
    index = find(floor(ot_sta/60/60/24) == ot(fi));
    
    z = zlevs(h(1), zeta(index,staind), 7, 2, 250, 40, 'w', 2);
    Hz = z(2:end,:) - z(1:end-1,:);
    
    Hz_surf = Hz(40,:);
    Homn = Hz_surf.*(1/pm).*(1/pn);
    
    u_surf = u(index,staind,40);
    uHomn = u_surf'.*Homn;

    u_perturb = u_surf - mean(u_surf);
    Homn_perturb = (Homn - mean(Homn));
    
    u_all = [u_all; u_surf];
    u_daily = [u_daily; mean(u_surf)];
    Homn_all = [Homn_all; Homn'];
    Homn_daily = [Homn_daily; mean(Homn)];
    uHomn_all = [uHomn_all; uHomn'];
    uHomn_daily = [uHomn_daily; mean(uHomn)];
    uHomn_perturb = [uHomn_perturb; (u_perturb.*Homn_perturb')];
    ot_all = [ot_all; ot_sta(index)];
end

duV = diff(uHomn_all);
duVdt = diff(uHomn_all)./diff(ot_all)';
ot_middle = (ot_all(2:end) + ot_all(1:end-1))/2;

for fi = 1:length(filenumber)
    
    ot(fi) = filenumber(fi)-1;
    index = find(floor(ot_middle/60/60/24) == ot(fi));
    duVdt_daily(fi) = mean(duVdt(index));
    dudt_daily(fi) = duVdt_daily(fi)./Homn_daily(fi);
end

figure; hold on; grid on
plot(filenumber-1, udia_all(1,:))
plot(filenumber-1, dudt_daily)

figure; hold on; grid on
plot(ot_all(1:24:end)/60/60/24, u_all(1:24:end))
plot(filenumber-1, u_daily)
plot(filenumber-1, u_all(1)+60*60*24*udia_all(1,:))

% ot_sta = ocean_time;
% ot_all = [];
% u_all = [];
% u_perturb_all = [];
% for fi = 1:length(filenumber)
%     
%     ot(fi) = filenumber(fi)-1;
%     index = find(floor(ot_sta/60/60/24) == ot(fi));
%     u_daily(fi) = mean(u_eastward(index,1,40));
%     u_perturb = u_eastward(index,1,40) - u_daily(fi);
%     
%     ot_all = [ot_all; ot_sta(index)/60/60/24];
%     u_all = [u_all; u_eastward(index,1,40)];
%     u_perturb_all = [u_perturb_all; u_perturb];
% end
% figure; hold on; grid on
% plot(ot_all, u_all)
% plot(ot_all, u_perturb_all)
% plot(ot, u_daily)
% 
% ot_sta = ocean_time;
% ot_all = [];
% zeta_all = [];
% zeta_perturb_all = [];
% for fi = 1:length(filenumber)
%     
%     ot(fi) = filenumber(fi)-1;
%     index = find(floor(ot_sta/60/60/24) == ot(fi));
%     zeta_daily(fi) = mean(zeta(index,1));
%     zeta_perturb = zeta(index,1) - zeta_daily(fi);
%     
%     ot_all = [ot_all; ot_sta(index)/60/60/24];
%     zeta_all = [zeta_all; zeta(index)];
%     zeta_perturb_all = [zeta_perturb_all; zeta_perturb];
% end
% figure; hold on; grid on
% plot(ot_all, zeta_all)
% plot(ot_all, zeta_perturb_all)
% plot(ot, zeta_daily)
% 
% ot_sta = ocean_time;
% ot_all = [];
% Hz_all = [];
% Hz_perturb_all = [];
% for fi = 1:length(filenumber)
%     
%     ot(fi) = filenumber(fi)-1;
%     index = find(floor(ot_sta/60/60/24) == ot(fi));
%     z = zlevs(h(1), zeta(index), 7, 2, 250, 40, 'w', 2);
%     Hz = z(2:end,:) - z(1:end-1,:);
%     Hz_surf = Hz(40,:);
%     
%     Hz_daily(fi) = mean(Hz_surf);
%     Hz_perturb = Hz_surf - Hz_daily(fi);
%     
%     ot_all = [ot_all; ot_sta(index)/60/60/24];
%     Hz_all = [Hz_all; Hz_surf'];
%     Hz_perturb_all = [Hz_perturb_all; Hz_perturb'];
% end
% figure; hold on; grid on
% plot(ot_all, Hz_all)
% plot(ot_all, Hz_perturb_all)
% plot(ot, Hz_daily)
ncload sta.nc

u_avg = u_surf;

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
ot_all = [];
for fi = 1:length(filenumber)
    
    ot(fi) = filenumber(fi)-1;
    index = find(floor(ot_sta/60/60/24) == ot(fi));
    
    z = zlevs(h(staind), zeta(index,staind), 7, 2, 250, 40, 'w', 2);
    Hz = z(end,:) - z(1,:);
    
    Homn = Hz.*(1/pm).*(1/pn);
    
    u_surf = ubar(index,staind);
    uHomn = u_surf.*Homn';

    u_all = [u_all; u_surf];
    u_daily = [u_daily; mean(u_surf)];
    Homn_all = [Homn_all; Homn'];
    Homn_daily = [Homn_daily; mean(Homn)];
    uHomn_all = [uHomn_all; uHomn];
    uHomn_daily = [uHomn_daily; mean(uHomn)];
    ot_all = [ot_all; ot_sta(index)];
end

duV = diff(uHomn_all);
duVdt = diff(uHomn_all)./diff(ot_all);
dudt = diff(u_all)/3600;
ot_middle = (ot_all(2:end) + ot_all(1:end-1))/2;

for fi = 1:length(filenumber)
    
    ot(fi) = filenumber(fi)-1;
    index = find(floor(ot_middle/60/60/24) == ot(fi));
    duVdt_daily(fi) = mean(duVdt(index));
    dudt_daily(fi) = duVdt_daily(fi)./Homn_daily(fi);
    
    duVdt_lp = lowpass(duVdt, 1, 28);
    duVdt_lp_daily(fi) = mean(duVdt_lp(index));
    dudt_lp_daily(fi) = duVdt_lp_daily(fi)./Homn_daily(fi);
    
    dudt_daily_from_his(fi) = mean(dudt(index));
end

figure; hold on; grid on
plot(filenumber-1+.5, udia_all(1,:))
plot(filenumber-1+.5, dudt_daily)
plot(filenumber-1+.5, dudt_daily_from_his)

figure; hold on; grid on
plot(ot_all/60/60/24, u_all, 'r')
plot(filenumber-1+.5, u_daily, '-r')
plot(filenumber-1+.5, u_avg, '-g')
plot(filenumber-1+.5, cumsum(60*60*24*dudt_daily_from_his), '-r')
plot(filenumber-1+.5, cumsum(60*60*24*dudt_daily), '-r')
plot(filenumber-1+.5, cumsum(60*60*24*dudt_lp_daily), '-r')
plot(filenumber-1+.5, cumsum(60*60*24*udia_all(1,:)), '-b')

figure; hold on; grid on
plot(ot_all/60/60/24, u_all)
plot(ot_middle/60/60/24, dudt*3600)
plot(filenumber-1+.5, (60*60*24*dudt_daily_from_his))
plot(ot_middle/60/60/24, u_all(1)+cumsum(dudt*3600))

interval = [12:24:length(ot_all)];
figure; hold on; grid on
plot(ot_all/60/60/24, u_all, '-r')
plot(ot_all(interval)/60/60/24, u_all(interval), '-ob')
plot(filenumber-1+.5, u_all(1)+ cumsum(60*60*24*udia_all(1,:)), '-ok')
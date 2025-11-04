clear; clc; close all

g = grd('BSf');
profile = load_BSf_profile(g, datenum(2022,5,31), 60, -180);

depth = profile.depth;
depth_N2 = (depth(1:end-1) + depth(2:end))/2;
N2 = profile.N2;

figure; 
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,3);
nexttile(1); hold on; grid on;
plot(N2, depth_N2)

dz = 5;
depth_interp = -5:-abs(dz):min(depth_N2);
N2_interp = interp1(depth_N2, N2, depth_interp)';
plot(N2_interp, depth_interp, '--')

% N2_interp = (N2_interp./N2_interp).*mean(N2_interp, 'omitnan');

Nm = 4;
FS_flag = 1;
Nm0 = 16;

[PHI_p, C, PHI_w] = MODES_FS(dz,N2_interp,Nm,FS_flag,Nm0);

nexttile(2); hold on; grid on;
for i = 1:Nm
    pp(i) = plot(PHI_p(:,i), depth_interp);
end
xlim([-3 3])

nexttile(3); hold on; grid on;
for i = 1:Nm
    pw(i) = plot(PHI_w(:,i), depth_interp);
end
xlim([-1000 1000])


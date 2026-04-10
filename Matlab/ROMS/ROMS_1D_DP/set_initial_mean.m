clear; clc;

g = grd('BSf');
N = g.N;

filename = 'initial_1D_DP_N45.nc';

aice = ncread(filename, 'aice');
aice = aice.*0;
ncwrite(filename, 'aice', aice);

hice = ncread(filename, 'hice');
hice = hice.*0;
ncwrite(filename, 'hice', hice);

ti = ncread(filename, 'ti');
ti = ti.*0;
ncwrite(filename, 'ti', ti);

varis = {'temp', 'salt'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    for ni = 1:N
        vari_tmp(:,:,ni) = vari_tmp(:,:,ni).*0 + mean(mean(vari_tmp(:,:,ni),1),2);
    end
    ncwrite(filename, vari, vari_tmp);
end

varis = {'zeta'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    vari_tmp = vari_tmp.*0 + mean(vari_tmp(:));

    ncwrite(filename, vari, vari_tmp);
end

varis = {'u', 'v'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    for ni = 1:N
        vari_tmp(:,:,ni) = vari_tmp(:,:,ni).*0;
    end
    ncwrite(filename, vari, vari_tmp);
end

varis = {'uice', 'vice', 'ubar', 'vbar'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    vari_tmp = vari_tmp.*0;

    ncwrite(filename, vari, vari_tmp);
end
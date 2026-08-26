clear; clc

domain = 'Oregon_1km_large';
g = grd(domain);
N = g.N;

day = 14;
dstr = num2str(day);

filename_org = ['boundary_', domain, '_LiveOcean.nc'];
filename = ['boundary_', domain, '_LiveOcean_', dstr, 'd_lpf.nc'];
copyfile(filename_org, filename);

yyyy = 2024;
bry_time = ncread(filename, 'bry_time');
nt = length(bry_time);

if bry_time(1) ~= 0
    bry_time = [0; bry_time];
end
if bry_time(end) ~= yeardays(yyyy)*60*60*24
    bry_time = [bry_time; yeardays(yyyy)*60*60*24];
end
ncwrite(filename, 'bry_time', bry_time);

% Apply lowpass filter to all boundary fields to remove tidal signal
fs = 1; % sample/day
fc = 1/day; % cycle/day
Wn = fc/(fs/2);
[b,a] = butter(4, Wn, 'low');

directions = {'north', 'south', 'west', 'east'};
isdirs = [1 1 1 0];
varis = {'zeta', 'ubar', 'vbar', 'u', 'v', 'temp', 'salt'};

for di = 1:length(directions)
    isdir = isdirs(di);
    if isdir
        direction = directions{di};
        for vi = 1:length(varis)
            vari_str = [varis{vi}, '_', direction];
            vari = double(ncread(filename, vari_str));
            dim = ndims(vari);
            vari_lp = [];
            vari_nc = [];
            if dim == 2
                vari = vari(:,1:nt);
                vari_lp = [filtfilt(b,a,vari')]';
                vari_lp = [vari_lp(:,1) vari_lp vari_lp(:,end)];
                vari_nc = vari_lp;
                ncwrite(filename, vari_str, vari_nc);
            elseif dim == 3
                for i = 1:N
                    vari_tmp = squeeze(vari(:,i,1:nt));
                    vari_lp = [filtfilt(b,a,vari_tmp')]';
                    vari_lp = [vari_lp(:,1) vari_lp vari_lp(:,end)];
                    vari_nc(:,i,:) = vari_lp;
                end
                ncwrite(filename, vari_str, vari_nc);
            end % dim
            disp(['Applying ', dstr, ' day lowpass filter to ', vari_str])
        end % vi
    end % isdir
end % di
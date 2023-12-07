clear; clc; close all

%lon_lim = [118 132]; lat_lim = [31 41];
%lon_lim = [124.7 125.6]; lat_lim = [33.8 34.3]; % 가거도 만재도 제거 영역
%lon_lim = [127 129]; lat_lim = [33.5 35]; % 남해
lon_lim = [126 129]; lat_lim = [33.5 35]; % 남해 확장

g = grd('EYECS_20220107');

xv = [lon_lim(1) lon_lim(1) lon_lim(2) lon_lim(2) lon_lim(1)];
yv = [lat_lim(1) lat_lim(2) lat_lim(2) lat_lim(1) lat_lim(1)];

mask = inpolygon(g.lon_rho, g.lat_rho, xv, yv);
[mi,mj] = size(mask);

figure; pcolor(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho.*mask./mask); shading flat

tnc = netcdf(g.grd_file, 'w');
h = tnc{'h'}(:);
h_new = h;

filepath_Kor30s = 'D:\Data\Ocean\Bathymetry\30s\';
filename_Kor30s = 'KorBathy30s.mat';
file_Kor30s = [filepath_Kor30s, filename_Kor30s];
load(file_Kor30s)
Zlon = xbathy; Zlat = ybathy; Zz = zbathy;

%Zz(Zz<0) = 0;

zind = find(lon_lim(1)-2 < Zlon & Zlon < lon_lim(2)+2 & lat_lim(1)-2 < Zlat & Zlat < lat_lim(2)+2);
Zlon2 = Zlon(zind); Zlat2 = Zlat(zind); Zz2 = Zz(zind);

% if max(Zlat2) < max(max(grid_lat))
%     disp('please check the domain!')
% end

load('G:\내 드라이브\Model\ROMS\Case\EYECS\input\tide\M2S2K1O1.mat')
% h_MSL = h_ALLW + M2S2K1O1;

h_new_part = griddata(Zlon2,Zlat2,Zz2, g.lon_rho, g.lat_rho, 'cubic');
h_new_part_MSL = h_new_part + M2S2K1O1;

h_new_part_MSL(isnan(h_new_part_MSL) == 1) = 7;
h_new_part_MSL(h_new_part_MSL < 7) = 7;

for i = 1:mi
    for j = 1:mj
        if mask(i,j) == 1
            h_new(i,j) = h_new_part_MSL(i,j);
%             if h_new(i,j) < 30
%                  h_new(i,j) = h_new(i,j)-20;
%             end
        end
    end
end
h_new(h_new < 7) = 7;

h_new_smooth = smoothgrid(h_new, g.mask_rho, 7, 100, 5000, .8, 1, 1);

for i = 1:mi
    for j = 1:mj
        if mask(i,j) == 1
            h(i,j) = h_new_smooth(i,j);
        end
    end
end

tnc{'h'}(:) = h;
close(tnc)
clear; clc; close all

yyyy_all = 2019:2022;
g = grd('BSf');

filepath_Sref = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/salt/';
filename_Sref = 'Sref_Gulf_of_Anadyr_2019.mat';

filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/transect/Gulf_of_Anadyr_NE_SW/';
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filename = ['Gulf_of_Anadyr_NE_SW_transect_ocean_vars_', ystr, '.mat'];
    file = [filepath, filename];

    load(file)

    %%%
    timenum = timeR; % timeR is just datenum of the date, ocean_time may be different
    %%%
    mask = Seg.mask;
    mask2d = Seg.mask2d;
    azimuth = Seg.azimuth;
    lon = Seg.lonseca;
    lat = Seg.latseca;

    ds = Seg.ds; % km
    ds = ds.*1000; % m
    ds_2d = repmat(ds', [1, g.N]);

    h = Seg.depth;
    temp = Sec.temp;
    salt = Sec.salt;
    v_n = Sec.v_n;
    u_t = Sec.u_t;
    zeta = Sec.zeta;
    sustr = Sec.sustr;
    svstr = Sec.svstr;

    for ti = 1:length(timenum)
        depth = zlevs(-h,zeta(:,ti),g.theta_s,g.theta_b,g.hc,g.N,'r',2)';
        z_w = zlevs(-h,zeta(:,ti),g.theta_s,g.theta_b,g.hc,g.N,'w',2)';
        dz = z_w(:,2:end) - z_w(:,1:end-1);

        S = salt(:,:,ti);

        v_n_tmp = v_n(:,:,ti);
        S_time_area = S.*v_n_tmp.*mask;%.*dz.*ds_2d.*mask; % psu m/s
        Sflux(yi,ti,:) = sum(S_time_area, 2);
    end
end

ddd
exportgraphics(gcf,'figure_Sflux.png','Resolution',150)
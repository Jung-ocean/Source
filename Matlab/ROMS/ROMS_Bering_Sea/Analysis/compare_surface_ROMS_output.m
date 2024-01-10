%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare two ROMS outputs at the surface
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
filenum_all = 1:152;

switch vari_str
    case 'salt'
        layer = 45;
        %climit = [26 35]; shelf ~ 200 m
        climit = [31.5 33.5]; % basin
        cdifflimit = [-.5 .5];
        unit = 'g/kg';
    case 'temp'
        layer = 45;
        climit = [0 20];
        cdifflimit = [-2 2];
        unit = '^oC';
    case 'zeta'
        climit = [-0.5 0.5];
        cdifflimit = [-.1 .1];
        unit = 'm';
end

filepath_all = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/';
case_control = 'Dsm_1';
filepath_control = [filepath_all, case_control, '/'];

case_exp = 'Dsm_1rnoff';
filepath_exp = [filepath_all, case_exp, '/'];

% Load grid information
grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
theta_s = 2;
theta_b = 0;
Tcline = 50;
N = 45;
scoord = [theta_s theta_b Tcline N];
Vtransform = 2;
g = roms_get_grid(grd_file,scoord,0,Vtransform);
lon = g.lon_rho;
lat = g.lat_rho;
mask = g.mask_rho./g.mask_rho;

for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
    
    filepattern_control = fullfile(filepath_control,(['*avg*',fstr,'*.nc']));
    filename_control = dir(filepattern_control);
    file_control = [filepath_control, filename_control.name];
    if strcmp(vari_str, 'zeta')
        vari_control = ncread(file_control,vari_str,[1 1 1],[Inf Inf 1])';
    else
        vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
    end
    time = ncread(file_control, 'ocean_time');
    time_units = ncreadatt(file_control, 'ocean_time', 'units');
    time_ref = datenum(time_units(end-18:end), 'yyyy-mm-dd HH:MM:SS');
    timenum = time_ref + time/60/60/24;
    time_title = datestr(timenum, 'mmm dd, yyyy');
    time_filename = datestr(timenum, 'yyyymmdd');

    filepattern_exp = fullfile(filepath_exp,(['*avg*',fstr,'*.nc']));
    filename_exp = dir(filepattern_exp);
    file_exp = [filepath_exp, filename_exp.name];
    if strcmp(vari_str, 'zeta')
        vari_exp = ncread(file_exp,vari_str,[1 1 1],[Inf Inf 1])';
    else
        vari_exp = ncread(file_exp,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
    end

    % Plot
    if fi == 1
        h1 = figure; hold on;
        set(gcf, 'Position', [1 1 1800 600])
        t = tiledlayout(1,3);
    else
        delete(ttitle);
    end
    ttitle = annotation('textbox', [.44 .85 .1 .1], 'String', time_title);
    ttitle.FontSize = 25;
    ttitle.EdgeColor = 'None';

    % Tile 1
    nexttile(1);
    if fi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
    else
        delete(T1);
    end
    T1 = pcolorm(lat,lon,vari_control.*mask);
    caxis(climit)
    c = colorbar('southoutside');
    c.Label.String = unit;

    title(case_control, 'Interpreter', 'None')

    % Tile 2
    nexttile(2);
    if fi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
    else
        delete(T2);
    end
    
    T2 = pcolorm(lat,lon,vari_exp.*mask);
    caxis(climit)
    c = colorbar('southoutside');
    c.Label.String = unit;

    title(case_exp, 'Interpreter', 'None');

    % Tile 3
    nexttile(3);
    if fi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
    else
        delete(T3)
    end

    T3 = pcolorm(lat,lon,(vari_exp-vari_control).*mask);
    ax = nexttile(3);
    colormap(ax,'redblue')
    caxis(cdifflimit)
    c = colorbar('southoutside');
    c.Label.String = unit;

    title(['Difference (', case_exp, ' - ', case_control, ')'], 'Interpreter', 'None')

    pause(1)
    %print(strcat('Compare_surface_', vari_str, '_' , time_filename),'-dpng');

    % Make gif
    gifname = ['compare_surface_', vari_str, '_', case_control, '_vs_', case_exp, '.gif'];

    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if fi == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    % Make avi
    aviname = ['compare_surface_', vari_str, '_', case_control, '_vs_', case_exp, '.avi'];
    if fi == 1
        v = VideoWriter(aviname);
        v.FrameRate = 2;
        open(v);
    end
        writeVideo(v,frame);
end % fi
close(v);

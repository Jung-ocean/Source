clear; clc

transect = 'meridional';
expname = 'noshapiro_dt60_kkl';
day_all = [1];

start_date = datetime(2018,7,1);
timenum = datenum(start_date:1/24:start_date+7);
Mobj.rundays = 153;
Mobj.time = (start_date:hours(1):start_date + Mobj.rundays)';
Mobj.dt = 120;
Mobj.coord = 'geographic';

hgrid_file = '../hgrid.gr3';
vgrid_file = '../vgrid.in';

Mobj = read_schism_hgrid(Mobj, hgrid_file);
Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

lon_SCHISM = Mobj.lon;
lat_SCHISM = Mobj.lat;

% Read transect
fid=fopen(['/data/jungjih/Models/SCHISM/test_schism/v1_SMS_min_5m_3D/gen_input/v1_SMS_min_5m_3D/analysis_control/transect_', transect, '.bp'],'r');
c1=textscan(fid,'%d%f%f%f','headerLines',2);
fclose(fid);
xbp=c1{2}(:);
ybp=c1{3}(:);
nbp=length(xbp);

if isinf((ybp(end)-ybp(1))/(xbp(end)-xbp(1)))
    xv = [min(xbp)-1; min(xbp)-1; max(xbp)+1; min(xbp)+1; min(xbp)-1];
    yv = [min(ybp)-1; max(ybp)+1; max(ybp)+1; min(ybp)-1; min(ybp)-1];

    ybp2 = repmat(ybp, [1,Mobj.maxLev])';
end
[in, on] = inpolygon(lon_SCHISM, lat_SCHISM, xv,yv);
index = find(in==1);

depth_interp = NaN(Mobj.maxLev, length(xbp));
for vi = 1:Mobj.maxLev
    depth_F = scatteredInterpolant(lon_SCHISM(index), lat_SCHISM(index), squeeze(Mobj.depLayers(vi,index))');
    depth_interp(vi,:) = depth_F(xbp, ybp);
end

temp_interp = NaN(24*length(day_all), Mobj.maxLev, length(xbp));
salt_interp = NaN(24*length(day_all), Mobj.maxLev, length(xbp));
u_interp = NaN(24*length(day_all), Mobj.maxLev, length(xbp));
v_interp = NaN(24*length(day_all), Mobj.maxLev, length(xbp));
for di = 1:length(day_all)
    day = day_all(di);

    % SCHISM
    SCHISM_filepath = ['../outputs_', expname, '/'];
    temp_filename = ['temperature_', num2str(day), '.nc'];
    temp_file = [SCHISM_filepath, temp_filename];
    temp = ncread(temp_file, 'temperature');

    salt_filename = ['salinity_', num2str(day), '.nc'];
    salt_file = [SCHISM_filepath, salt_filename];
    salt = ncread(salt_file, 'salinity');

    u_filename = ['horizontalVelX_', num2str(day), '.nc'];
    u_file = [SCHISM_filepath, u_filename];
    u = ncread(u_file, 'horizontalVelX');

    v_filename = ['horizontalVelY_', num2str(day), '.nc'];
    v_file = [SCHISM_filepath, v_filename];
    v = ncread(v_file, 'horizontalVelY');

    for vi = 1:Mobj.maxLev
        for hi = 1:size(temp,3)
            temp_hour = double(squeeze(temp(vi,index,hi)))';
            temp_F = scatteredInterpolant(lon_SCHISM(index), lat_SCHISM(index), temp_hour);
            temp_interp(24*(di-1)+hi,vi,:) = temp_F(xbp, ybp);

            salt_hour = double(squeeze(salt(vi,index,hi)))';
            salt_F = scatteredInterpolant(lon_SCHISM(index), lat_SCHISM(index), salt_hour);
            salt_interp(24*(di-1)+hi,vi,:) = salt_F(xbp, ybp);

            u_hour = double(squeeze(u(vi,index,hi)))';
            u_F = scatteredInterpolant(lon_SCHISM(index), lat_SCHISM(index), u_hour);
            u_interp(24*(di-1)+hi,vi,:) = u_F(xbp, ybp);

            v_hour = double(squeeze(v(vi,index,hi)))';
            v_F = scatteredInterpolant(lon_SCHISM(index), lat_SCHISM(index), v_hour);
            v_interp(24*(di-1)+hi,vi,:) = v_F(xbp, ybp);
        end
        disp(['Day ', num2str(day), ', ' num2str(vi), '/', num2str(Mobj.maxLev)])
    end
end

ylimit = [-1000 0];


h1 = figure; hold on
set(gcf, 'Position', [1 1 1800 600])
tiledlayout(2,2)
for ti = 1:size(temp_interp,1)
    
    ax1 = nexttile(1); cla
    p1 = pcolor(ybp2, depth_interp, squeeze(temp_interp(ti,:,:))); shading interp
    ylim(ylimit)
    xlabel('Latitude (^oN)');
    ylabel('Depth (m)');
    colormap(ax1, 'jet')
    caxis([3 9])
    c = colorbar;
    c.Title.String = '^oC';
    title(['Temperature ', datestr(timenum(ti+1), 'mmm dd, HH:MM')])

    ax2 = nexttile(2); cla
    p2 = pcolor(ybp2, depth_interp, squeeze(salt_interp(ti,:,:))); shading interp
    ylim(ylimit)
    xlabel('Latitude (^oN)');
    ylabel('Depth (m)');
    colormap(ax2, 'jet')
    caxis([32.5 34]);
    c = colorbar;
    c.Title.String = 'g/kg';
    title(['Salinity ', datestr(timenum(ti+1), 'mmm dd, HH:MM')])
    
    ax3 = nexttile(3); cla
    p3 = pcolor(ybp2, depth_interp, squeeze(u_interp(ti,:,:))); shading interp
    ylim(ylimit)
    xlabel('Latitude (^oN)');
    ylabel('Depth (m)');
    colormap(ax3, 'jet')
    caxis([-.2 .2]);
    c = colorbar;
    c.Title.String = 'm/s';
    title(['Zonal velocity ', datestr(timenum(ti+1), 'mmm dd, HH:MM')])

    ax4 = nexttile(4);
    p4 = pcolor(ybp2, depth_interp, squeeze(v_interp(ti,:,:))); shading interp
    ylim(ylimit)
    xlabel('Latitude (^oN)');
    ylabel('Depth (m)');
    colormap(ax4, 'jet')
    caxis([-.2 .2]);
    c = colorbar;
    c.Title.String = 'm/s';
    title(['Meridional velocity ', datestr(timenum(ti+1), 'mmm dd, HH:MM')])

    % Make gif
    gifname = ['vertical_section_', expname, '_',num2str(abs(ylimit(1))), 'm.gif'];

    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ti == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS vertical section along constant latitude
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var_str = 'temp'; %titlestr = 'Alongshore velocity';
fig_str = '400';
vec = 'off';

casename = 'EYECS_20220110';
g = grd(casename);

yyyy_all = [2020:2020];
mm_all = 6:2:8;

switch fig_str
    case 'TSB'
        domaxis = [33.8829 34.3199 127.8991 128.4143 -95 0]; % KODC 400 line
    case '400'
        domaxis = [34.0767 34.6 128.5 128.0833 -80 0]; % KODC 400 line
    case '204'
        domaxis = [33.5967 34.3 127.0533 127.533 -120 0]; % KODC 204 line
    case '205'
        domaxis = [33.6217 34.4167 128.1533 127.6667 -120 0]; % KODC 205 line
    case '206'
        domaxis = [34.3733 34.6333 128.8283 128.4167 -120 0]; % KODC 206 line
    case '208'
        domaxis = [35.475 35.185 129.455 129.8783 -150 0];
    case 'cross'
        domaxis = [33.6217 34.4167 128.1533 127.8667 -120 0];
    case 'KS_N'
        domaxis = [35.4 33.4 129 130.5 -150 0]; % Korea Strait N
    case 'KS_S'
        domaxis = [35 33.2 128.5 129.8 -150 0]; % Korea Strait S
    case 'KS'
        domaxis = [35.28 33.02 128.88 129.8 -150 0];
    case 'cross2'
        domaxis = [33.8767 34.6 128.6 128.0833 -100 0];
    case 'Fukushima_EW'
        domaxis = [37.4214 37.4214 141 147 -4700 0];
    case 'Fukushima_NS'
        domaxis = [32.4214 37.4214 141 141 -4000 0];
    case '310'
        domaxis = [35.335 35.335 124.3917 125.8207 -90 0];
    case 'NECS'
        domaxis = [33 33.3 120 126.63 -90 0];
    case 'SYS'
        domaxis = [34.5 34.8 119 126.63 -90 0];
    case {'YS_325', 'YS_330', 'YS_335', 'YS_340', 'YS_345', 'YS_350', 'YS_355', 'YS_360'}
        lat = str2num(fig_str(4:6))/10;
        domaxis = [lat lat 119 126.63 -90 0];
    case {'Cheju_1245', 'Cheju_1250', 'Cheju_1255', 'Cheju_1260', 'Cheju_1265'}
        lon = str2num(fig_str(end-3:end))/10;
        domaxis = [33.4 34.5 lon lon -120 0];
    case '311'
        domaxis = [34.7167 34.7167 124.3 125.8 -90 0];
    case '312'
        domaxis = [34.0917 34.0917 124 126.63 -90 0];
        %case '310'
        %    domaxis = [35.335 35.335 124.3917 125.8207 -90 0];
end

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    if yyyy == 9999; ystr = 'climate'; end
%     filepath = ['G:\내 드라이브\Model\ROMS\Case\YECS\output\control\monthly\'];
    filepath = ['.\'];
    
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2char(mm,2);
        filename = ['monthly_', ystr, mstr, '.nc'];
        file = [filepath, filename];
        ncload(file)
        %filename = ['avg_0182.nc']; ncload(filename)
        %filename = ['yellow_monthly_', ystr, '_', mstr, '.nc']; ncload(filename)
        %filename = ['test06_monthly_', ystr, '_', mstr, '.nc']; ncload(filename)
        %filename = ['roms_ini_YECS_NWPtest06.nc']; ncload(filename)
        %filename = ['spinup_ini.nc']; ncload(filename)
        %filename = ['spinup1_monthly', mstr, '.nc']; ncload(filename)
        %filepath = ['G:\내 드라이브\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\2020\daily\'];
        %filename = [filepath, 'avg_0232.nc']; ncload(filename)
        depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
        if strcmp(var_str, 'w')
            depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w', 2);
        end
        
        depth(depth > 1000) = NaN;
        
        pdens = zeros(size(depth));
        for si = 1:g.N
            pres = sw_pres(squeeze(depth(si,:,:)), g.lat_rho);
            pdens(si,:,:) = sw_pden_ROMS(squeeze(salt(si,:,:)), squeeze(temp(si,:,:)), pres, 0);
        end
        density = pdens - 1000;
        
        if strcmp(var_str, 'u_rho') || strcmp(var_str, 'v_rho')
            skip = 1; npts = [0 0 0 0];
            for di = 1:g.N
                u_2d = squeeze(u(di,:,:));
                v_2d = squeeze(v(di,:,:));
                [u_rho(di,:,:),v_rho(di,:,:),lon,lat,mask] = uv_vec2rho(u_2d.*g.mask_u,v_2d.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
            end
        end
        
        var = eval(var_str);
        var(var > 1000) = NaN;
        
        [x, Yi, data] = ROMS_plot_vertical_function(g, depth, var_str, var, domaxis);
        
        ax = get(gca);
        xlim([ax.XLim(1)-0.005 ax.XLim(2)+0.01])
        ylim([domaxis(5) 0.5])
        %yticks([-120 -80 -40 0])
        ax.XAxis.TickDirection = 'out';
        ax.YAxis.TickDirection = 'out';
        ax.XAxis.LineWidth = 2;
        ax.YAxis.LineWidth = 2;
        
        if strcmp(vec, 'on')
            w(w > 1000) = 0;
            for ni = 1:g.N
                w_rho(ni,:,:) = (w(ni,:,:) + w(ni+1,:,:))/2;
            end
            w_rho_data = squeeze(w_rho(:,:,loc_ind));
            w_data = w_rho_data(:, xind);
            
            v_rho_data = squeeze(v_rho(:,:,loc_ind));
            v_data = v_rho_data(:, xind);
            
            w = (v_data+sqrt(-1).*(-w_data.*1e5));
            h1 = psliceuv_w(Xi, Yi, w, 4, 0.5, 'k');
            
            titlename = [datestr(datenum(mstr, 'mm'), 'mmm'), ' ', ystr];
            %title(titlename, 'FontSize', 25)
            box on
            %saveas(gcf, [var_str, '_vec_vertical_', section, '_', num2str(loc), '_', casename, '_', yts, mts, '.png'])
        else
            titlename = [datestr(datenum(mstr, 'mm'), 'mmm'), '. ', ystr];
            %title([titlestr, ' (', titlename, ')'], 'FontSize', 25, 'FontWeight', 'bold')
            box on
            %setposition('vertical')
            
            hold on
            plot(37.4, 0, '.r', 'MarkerSize', 70)
            
            saveas(gcf, [var_str, '_vertical_', fig_str, '_', casename, '_', ystr, mstr, '.png'])
            %print([var_str, '_vertical_', fig_str, '_', casename, '_', yts, mts, '.tiff'], '-dtiff','-r300')
        end
        %eval([var_str, '_KS_mean_surf(mi) = nanmean(data(20,:));']);
        %eval([var_str, '_KS_mean_bot(mi) = nanmean(data(1,:));']);
        %save([ystr, mstr, '_', fig_str,'.mat'], 'x', 'Yi', 'data')
        
    end
end
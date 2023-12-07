%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

casename = 'EYECS_20220110';
domain_case = 'southern';
variable = 'ubar_with_wind';
layer_target = 40; lts = num2str(layer_target);

rotind = 1; theta = -20;

yyyy = 2019;
datenum_ref = datenum(yyyy,1,1);

%filenumber = 245:274; % Sep.
filenumber = 121:274; % Jun. ~ Jul.
filenumber = [234, 249];
%filenumber = [186:190];
%filenumber = [153:213]% 192:202 269:271];
%filenumber = 232:233; % 2020 Aug. KODC
%filenumber = 163:164; % 2020 Jun. KODC
%filenumber = 239:239; % 2013 KODC
%filenumber = [156 174];
%filenumber = [166 173];
fns = num2char(filenumber, 4);
filedate = datestr(filenumber + datenum_ref -1, 'mmdd');
titlestr = datestr(filenumber + datenum_ref -1, 'dd-mmm-yyyy');

for yyyy = 2019:2019
    yi = yyyy; ystr = num2str(yi);
    if yyyy == 9999; ystr = 'avg'; end
    %cd(['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', tys, '\'])
    for fi = 1:length(filenumber)
        
        filename = ['avg_', fns(fi,:), '.nc']; ncload(filename)
        
        figure('visible', 'off'); hold on
        switch variable
            case 'temp'
                ROMS_plot_temp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
            case 'temp_comp'
                ROMS_plot_temp_comp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
            case 'tuv'
                ROMS_plot_temp_function(filename, 'temp', layer_target, casename, domain_case, 'contour on')
                ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
            case 'suv'
                ROMS_plot_salt_function(filename, 'salt', layer_target, casename, domain_case, 'contour on')
                ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
            case 'u'
                ROMS_plot_u_function(filename, 'u', 'v', layer_target, casename, domain_case, rotind, theta)
                m_plot([128.1533 127.666], [33.6217 34.4167], 'k', 'LineWidth', 4)
            case 'ubar'
                ROMS_plot_ubar_function(filename, 'ubar', 'vbar', casename, domain_case, rotind, theta)
                %m_plot([128.1533 127.666], [33.6217 34.4167], 'k', 'LineWidth', 4)
            case 'ubar_with_wind'
                ROMS_plot_ubar_function(filename, 'ubar', 'vbar', casename, domain_case, rotind, theta)
                
                stations = {'거문도', '거제도', '통영'};
                for si = 1:1%length(stations)
                    station = stations{si};
                    load(['D:\OneDrive - SNU\Research\Counter_current\Observation\Buoy_KMA\Buoy_KMA_', station, '_', ystr, '.mat']);
                    
                    time1 = day_all;
                    index = find(time1 == filenumber(fi));
                    dfdf
                    uwind = uwind_daily(index);
                    vwind = vwind_daily(index);
                    w = (uwind+sqrt(-1).*vwind);
                    h1 = m_psliceuv(lon,lat, w, 1, 1, 'k');
                end
                
            case 'uv'
                ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
            case 'uvbar'
                ROMS_plot_current_bar_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
            case 'uv_with_obs'
                ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                
                %                 load('G:\내 드라이브\Research\Counter_current\Observation\장기조류\specific\2020_20LTC06_S_daily.mat')
                %                 u1 = u_daily/100; v1 = v_daily/100; time1 = timenum_unique - datenum(2020,1,1)+1;
                %                 index = find(time1 == filenumber(fi));
                %                 w = (u1(index)+sqrt(-1).*v1(index));
                %                 if ~isempty(w)
                %                     h1 = m_psliceuv(127.7103,34.2936,w, 1, 6, 'r');
                %                 end
                %
                %                 load('G:\내 드라이브\Research\Counter_current\Observation\Buoy\specific\2020_남해동부_daily.mat')
                %                 u1 = u_daily/100; v1 = v_daily/100; time1 = timenum_unique - datenum(2020,1,1)+1;
                %                 index = find(time1 == filenumber(fi));
                %                 w = (u1(index)+sqrt(-1).*v1(index));
                %                 if ~isnan(w)
                %                     h1 = m_psliceuv(128.419027,34.222472,w, 1, 6, 'r');
                %                 end
                
                stations = {'거문도', '거제도', '통영'};
                for si = 1:1%length(stations)
                    station = stations{si};
                    load(['D:\OneDrive - SNU\Research\Counter_current\Observation\Buoy_KMA\Buoy_KMA_', station, '_', ystr, '.mat']);
                    
                    time1 = day_all;
                    index = find(time1 == filenumber(fi));
                    
                    uwind = uwind_daily(index);
                    vwind = vwind_daily(index);
                    w = (uwind+sqrt(-1).*vwind);
                    h1 = m_psliceuv(lon,lat, w, 1, 2, 'b');
                end
                %                 load('G:\내 드라이브\Research\Counter_current\Observation\Tidal_station_wind\2020_GM_wind.mat');
                
                %                 index = find(time1 == filenumber(fi));
                %
                %                 uwind = uwind_daily(index);
                %                 vwind = vwind_daily(index);
                %
                %                 w = (uwind+sqrt(-1).*vwind);
                %                 h1 = m_psliceuv(127.308889,34.028333,w, 1, 6, 'b');
                
            case 'uvbar_with_obs'
                ROMS_plot_current_bar_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                            
                stations = {'거문도', '거제도', '통영'};
                for si = 1:1%length(stations)
                    station = stations{si};
                    load(['D:\OneDrive - SNU\Research\Counter_current\Observation\Buoy_KMA\Buoy_KMA_', station, '_', ystr, '.mat']);
                    
                    time1 = day_all;
                    index = find(time1 == filenumber(fi));
                    
                    uwind = uwind_daily(index);
                    vwind = vwind_daily(index);
                    w = (uwind+sqrt(-1).*vwind);
                    h1 = m_psliceuv(lon,lat, w, 1, 1, 'k');
                end
            case 'w'
                ROMS_plot_w_function(filename, 'w', layer_target, casename, domain_case, 'contour off')
            case 'huv'
                ROMS_plot_current_function(filename, 'u', 'v', layer_target, casename, domain_case, 1)
                hold on
                g = grd(casename);
                m_pcolor(g.lon_rho,g.lat_rho,g.h.*g.mask_rho./g.mask_rho); shading flat
            case 'zeta'
                ROMS_plot_zeta_function(filename, 'zeta', casename, domain_case, 'contour on')
            case 'salt'
                ROMS_plot_salt_function(filename, 'salt', layer_target, casename, domain_case, 'contour on')
        end
        
        %ROMS_plot_density_function(filename, depth, casename, domain_case, 'contour on')
        g = grd(casename);
        [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [30 60], 'Color', [.5 .5 .5], 'linewidth', 2);
        clabel(cs, h, 'FontSize', 15, 'Color', [.5 .5 .5]);
        
        title([titlestr(fi,:)], 'fontsize', 25)
        setposition(domain_case)
        m_gshhs_i('patch', [.7 .7 .7])
        saveas(gcf, [variable, '_layer', lts, '_', casename, '_', domain_case, '_', filedate(fi,:),'.png'])
        
    end
    %close all;
end
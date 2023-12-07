%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS vertical section along constant latitude
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yyyy = 2013; ystr = num2str(2013);
fig_str = 'cross2';

directions = {'u', 'v'};
%varis = {'accel', 'cor', 'adv', 'hadv', 'vadv', 'prsgrd', 'hvisc', 'vvisc', 'geo', 'baroc', 'barot'};
%titles = {'Acceleration', 'Coriolis', 'Advection', 'Horizontal advection', 'Vertical advection', 'Pressure gradient', 'Horizontal viscosity', 'Vertical viscosity', 'Ageostrophic (Coriolis + Prsgrd)', 'Baroclinic prsgrd', 'Barotropic prsgrd'};
%varis = {'cor', 'prsgrd', 'vvisc'};
%titles = {'Coriolis', 'Pressure gradient', 'Vertical viscosity'};
varis = {'accel'};
titles = {'Acceleration'};

%varis = {'cor', 'hadv', 'hvisc', 'prsgrd', 'sstr', 'bstr'};

casename = 'EYECS_20190904';
g = grd(casename);

switch fig_str
    case '400'
        domaxis = [34.0767 34.6 128.5 128.0833 -95 0]; % KODC 400 line
    case '204'
        domaxis = [33.5967 34.3 127.0533 127.533 -120 0]; % KODC 204 line
    case '205'
        domaxis = [33.6217 34.4167 128.1533 127.6667 -120 0]; % KODC 205 line
    case '206'
        domaxis = [34.3733 34.6333 128.8283 128.4167 -120 0]; % KODC 206 line
    case 'cross'
        domaxis = [33.6217 34.4167 128.1533 127.8667 -120 0];
    case 'cross2'
        domaxis = [33.8767 34.6 128.6 128.0833 -100 0];
    case 'ss'
        domaxis = [34 34.7 128 128 -80 0]; % South Sea
end

masku3 = []; maskv3 = [];
for ni = 1:40
    masku3(ni,:,:) = g.mask_u./g.mask_u;
    maskv3(ni,:,:) = g.mask_v./g.mask_v;
end

for mi = 7:8
    mm = mi;     mstr = num2char(mm,2);
    filename = ['monthly_dia_', ystr, mstr, '.nc'];
    nc = netcdf(filename);
    
    depth = zlevs(g.h,g.zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
    depth(depth > 1000) = NaN;
    
    for di = 1:length(directions)
        direction = directions{di};
        
        for vi = 1:length(varis)
            
            var_str = [direction, '_', varis{vi}];
            if strcmp(varis{vi}, 'geo')
                var1 = nc{[direction, '_cor']}(:);
                var2 = nc{[direction, '_prsgrd']}(:);
                
                var = var1 + var2;
            
            elseif strcmp(varis{vi}, 'adv')
                var1 = nc{[direction, '_hadv']}(:);
                var2 = nc{[direction, '_vadv']}(:);
                
                var = var1 + var2;
            
            elseif strcmp(varis{vi}, 'baroc')
                var1 = nc{[direction, '_prsgrd']}(:);
                var2 = ROMS_calc_barot(['.\monthly_', ystr, mstr, '.nc'], direction);

                var = [];
                for ni = 1:g.N
                    var(ni,:,:) = squeeze(var1(ni,:,:)) - var2;
                end
                
            elseif strcmp(varis{vi}, 'barot')
                var2d = ROMS_calc_barot(['.\monthly_', ystr, mstr, '.nc'], direction);
                var = [];
                for ni = 1:g.N
                    var(ni,:,:) = var2d;
                end
                
            else
                var = nc{var_str}(:);
            end
            
            section = 'lon';
            if strcmp(section, 'lon')
                location = 127.51; range = [33.5 35];
                
            elseif strcmp(section, 'lat')
                %location = 35.855; range = [124.38 126.245]; % 309 line
                location = 34.5; range = [123 126];
            end
            
            var = eval(['var.*mask', direction, '3']);
            
            [x, Yi, data] = ROMS_plot_dia_vertical_function(g, depth, var_str, var, domaxis);
                        
            ax = get(gca);
            xlim([ax.XLim(1)-0.005 ax.XLim(2)+0.01])
            ylim([domaxis(5) 0.5])
            ax.XAxis.TickDirection = 'out';
            ax.YAxis.TickDirection = 'out';
            ax.XAxis.LineWidth = 2;
            ax.YAxis.LineWidth = 2;
            
            titlename = [titles{vi}];
            title(titlename, 'FontSize', 37)
            box on
            
            %saveas(gcf, [fig_str, '\', var_str, '_vertical_', fig_str, '_', casename, '_', ystr, mstr, '.png'])
            print([fig_str, '\', var_str, '_vertical_', fig_str, '_', casename, '_', ystr, mstr, '.tiff'],'-dtiff','-r300');
            
        end
    end
    close(nc)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS vertical section along constant latitude
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yyyy = 2013; yts = num2str(2013);

datenum_ref = datenum(yyyy,1,1);

filenumber = 182:243;
fns = num2char(filenumber, 4);
filedate = datestr(filenumber + datenum_ref -1, 'mmdd');

tracers = {'temp'};
varis = {'rate', 'hadv', 'xadv', 'yadv', 'vadv', 'hdiff', 'vdiff', 'adv'};
titles = {'temp_rate', 'Horizontal advection', 'Vertical advection', 'Horizontal diffusion', 'Vertical diffusion'};

casename = 'NWP';
g = grd(casename);
masku2 = g.mask_u./g.mask_u;
maskv2 = g.mask_v./g.mask_v;

theta_s = g.theta_s; theta_b = g.theta_b;
hc = g.hc; h = g.h; N = g.N;

for fi = 1:length(filenumber)
    filename = ['dia_', num2char(filenumber(fi), 4), '.nc'];
    nc = netcdf(filename);
    
    depth = zlevs(g.h,g.zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
    depth(depth > 1000) = NaN;
    
    for ti = 1:length(tracers)
        tracer = tracers{ti};
        
        for vi = 1:length(varis)
            var_str = [tracer, '_', varis{vi}];
            var = nc{var_str}(:);
            
            if strcmp(var_str, 'temp_adv')
                var = nc{[tracer,'_hadv']}(:) + nc{[tracer,'_vadv']}(:);
            end
            
            section = 'lon';
            if strcmp(section, 'lon')
                location = 127.6; range = [33.5 35];
                
            elseif strcmp(section, 'lat')
                %location = 35.855; range = [124.38 126.245]; % 309 line
                location = 34.5; range = [123 126];
            end
            
            [loc, dir_str, Xi, Yi, data] = ROMS_plot_diaTS_vertical_function(g, depth, var_str, var, section, location, range);
            loc = round(loc*10)/10;
            
            ax = get(gca);
            xlim([ax.XLim(1)-0.005 ax.XLim(2)+0.01])
            ylim([-100 0.5])
            ax.XAxis.TickDirection = 'out';
            ax.YAxis.TickDirection = 'out';
            ax.XAxis.LineWidth = 2;
            ax.YAxis.LineWidth = 2;
            
            %titlename = titles{vi};
            %title(titlename, 'FontSize', 25)
            box on
            saveas(gcf, [var_str, '_vertical_', section, '_', num2str(loc), '_', casename, '_', filedate(fi,:), '.png'])
            close all
        end
    end
    close(nc)
end
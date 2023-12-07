%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS floats using the flt.nc file
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% depth longitude latitude 순서로 바뀐다

clear; clc; close all

filepath = 'G:\Model\ROMS\Case\NWP\output\exp_SODA3\2013\';
filename = 'flt.nc';
file = [filepath, filename];

casename = 'YECS_flt_small';

NFLOATS = 108; % Total number of floats to release
N = 1; % Number floats to be released at each point
initime = datenum(2013,01,01,00,00,00);
Ft0 = [120, 151, 181]; len_Ft0 = length(Ft0);
% Fx0 = [124 125 126]; len_Fx0 = length(Fx0);
% Fy0 = [33 34 35 36]; len_Fy0 = length(Fy0);
Fx0 = [124:0.5:126]; len_Fx0 = length(Fx0);
Fy0 = [33:0.5:36]; len_Fy0 = length(Fy0);
Fz0 = [-2 -30, -50]; len_Fz0 = length(Fz0);

plot_symbol = {'p', 'd', 's', 'o', '^'};
% plot_color = {[0 0.4510 0.7412], [0.8510 0.3294 0.1020], [0.9294 0.6902 0.1294] ...
%     [0.4902 0.1804 0.5608], [0.4706 0.6706 0.1882], [0.3020 0.7490 0.9294] ...
%     [0.6392 0.0784 0.1804], [.5 .5 .5], [1 0 1], [1 1 0], [0 1 0], [0 0 0]};
plot_color = {'r', '[0.8510 0.3294 0.1020]', '[0.9294 0.6902 0.1294]', '[0.4706 0.6706 0.1882]', '[0 1 0]', '[0.3020 0.7490 0.9294]', 'b'};

for ci = 1:length(plot_color)
    for si = 1:length(plot_symbol)
        plot_marker{5*(ci-1) + si} = [plot_symbol{si}];
        plot_marker_color{5*(ci-1) + si} = plot_color{ci};
    end
end

for ti = Ft0(3:3)
    for zi = Fz0(3:3)
        
        target_t = ti;
        target_z = zi;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figpath = '.';
        
        date_start = ti;
        date_end = datenum(2013,8,31) - initime;
        date_all = date_start:2:date_end;
        
        nc = netcdf(file);
        lat = nc{'lat'}(:);
        lon = nc{'lon'}(:);
        depth = nc{'depth'}(:);
        ot = nc{'ocean_time'}(:);
        temp = nc{'temp'}(:);
        salt = nc{'salt'}(:);
        close(nc)
        
        depth(depth > 1000 | depth == 0) = NaN;
        temp(temp > 1000) = NaN;
        lat(lat > 1000 | lat == 0) = NaN;
        lon(lon > 1000 | lon == 0) = NaN;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        t_s = num2str(target_t); % time string
        z_s = num2str(target_z); % depth string
        
        tind = find(Ft0 == target_t);
        zind = find(Fz0 == target_z);
        
        plot_column_list = [];
        for yi = Fy0
            yind = find(Fy0 == yi);
            for xi = Fx0
                xind = find(Fx0 == xi);
                
                column_ind = (tind - 1)*len_Fy0*len_Fx0*len_Fz0*N + ...
                    (yind - 1)*len_Fx0*len_Fz0*N + ...
                    (xind - 1)*len_Fz0*N + ...
                    (zind - 1)*N + 1;
                
                plot_column_list = [plot_column_list; column_ind];
            end
        end
        
        figure; hold on;
        map_J(casename)
        
        for di = 1:length(date_all)
            dindex = find(ot/60/60/24 == date_all(di)) + 1;
            dindex1 = find(ot/60/60/24 == date_all(1)) + 1;
            pindex = find(depth(dindex1, plot_column_list) > target_z + 10);
            pindex2 = [];
                        
            for pi = 1:length(plot_column_list)
                
                p = m_plot(lon(dindex, plot_column_list(pi)), lat(dindex, plot_column_list(pi)), ...
                    plot_marker{pi}, 'MarkerSize', 6, 'Color', plot_marker_color{pi}, 'MarkerFaceColor', plot_marker_color{pi});
                
                if ismember(pi, pindex)
                    delete(p)
                end
                
                if ismember(pi, pindex2)
                    delete(p)
                end
                
            end
            target_date = datestr(date_all(di) + initime, 'yyyymmdd');
            title([target_date, ' ', z_s, 'm'], 'fontsize', 15)
            
            d(di,:) = [date_all(di) + initime; dindex];            
            
            saveas(gcf,['flt_', t_s, '_', z_s, '_', target_date,'.png'])
        end
        close all
    end % zi
end % ti
%clear; clc; close all

%dstr = '30'; southern_index = [1 4 5 9 10 14 15 18 19 29];
dstr = '50'; southern_index = [4 5 9 10 14 15 17 19 24];

di = 1;
dindex = find(ot/60/60/24 == date_all(di)) + 1;

figure; map_J('YECS_flt_small')
for pi = 1:length(plot_column_list)
    if ismember(pi, pindex)
        
    else
        p = m_plot(lon(dindex, plot_column_list(pi)), lat(dindex, plot_column_list(pi)), '.k', 'MarkerSize', 25);
    end
end
saveas(gcf, ['floats_point_', dstr, 'm.png'])

figure; map_J(casename)
for pi = 1:length(plot_column_list)
    if ismember(pi, pindex)
    else
        
        pindex2 = plot_column_list(pi);
        if ~ismember(pi, southern_index)
            
            m_plot(lon(d(:,2), pindex2), lat(d(:,2), pindex2), '-', 'color', [.7 .7 .7], 'linewidth', 1);
            
            m_plot(lon(d(1,2), pindex2), lat(d(1,2), pindex2), '.', 'color', [.7 .7 .7], 'MarkerSize', 15)
        end
    end
end

for pi = 1:length(plot_column_list)
    if ismember(pi, pindex)
    else
        
        pindex2 = plot_column_list(pi);
        if ismember(pi, southern_index)
            
            if pi < 11
                color = [0.8510 0.3294 0.1020];
            else
                color = [0 .45 .74];
            end
            m_plot(lon(d(:,2), pindex2), lat(d(:,2), pindex2), '-', 'color', color, 'linewidth', 2);
            m_plot(lon(d(1,2), pindex2), lat(d(1,2), pindex2), '.', 'color', color, 'MarkerSize', 25);
            
        end
    end
end
saveas(gcf, [dstr, 'm_point.png'])
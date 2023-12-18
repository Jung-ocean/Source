function plot_map(casename)

[lon, lat] = load_domain(casename);
fc = [.7 .7 .7];
xticks = 5; 
yticks = 5;
fs = 12;

set(gca,'ydir','nor');
m_proj('miller','lon',[lon(1) lon(2)],'lat',[lat(1) lat(2)]);

m_gshhs_c('line', 'Color','k', 'LineWidth', 1.5); % plot intermediate resolution coastline, black color
m_gshhs_c('patch',fc);

m_grid('XTick', xticks, 'YTick', yticks, ...
    'LineWidth', 2, 'LineStyle', 'none', 'TickStyle', 'dd', 'TickDir', 'out', 'FontSize', fs, ...
    'FontWeight', 'bold','FontName', 'Times');

end % function plot_map

function [lon, lat] = load_domain(casename)

switch casename
    case 'US_west'
        lon = [-140 -110]; lat = [28 55];
    case 'Bering_Arctic'
        lon = [-185 -155]; lat = [45 85];
    case 'Bering'
        lon = [-205.98 -156.86]+360; lat = [49.11 66.30];
end

end % function load_domain
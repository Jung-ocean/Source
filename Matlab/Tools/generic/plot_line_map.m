function plot_line_map(longitude, latitude, color, linestyle)

LW = 2;

if strcmp(color, 'default1')
    color = [0 0.4470 0.7410];
elseif strcmp(color, 'default2')
    color = [0.8500 0.3250 0.0980];
end

hold on
m_plot([longitude(1) longitude(2)], [latitude(1) latitude(1)], 'Color', color, 'LineWidth', LW, 'LineStyle', linestyle)
m_plot([longitude(1) longitude(2)], [latitude(2) latitude(2)], 'Color', color, 'LineWidth', LW, 'LineStyle', linestyle)
m_plot([longitude(1) longitude(1)], [latitude(1) latitude(2)], 'Color', color, 'LineWidth', LW, 'LineStyle', linestyle)
m_plot([longitude(2) longitude(2)], [latitude(1) latitude(2)], 'Color', color, 'LineWidth', LW, 'LineStyle', linestyle)

end
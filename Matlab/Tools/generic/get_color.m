function [color, contour_interval] = get_color(colormap, climit, interval)

fig = get(groot,'CurrentFigure');
if isempty(fig)
    isclose = 1;
else
    isclose = 0;
end

num_color = double(diff(climit)/interval);
contour_interval = climit(1):interval:climit(end);
if strcmp(colormap, 'redblue')
    color_tmp = eval(colormap);
    if isclose == 1
        close
    end
    color = color_tmp(floor(linspace(1,length(color_tmp),num_color)),:);
else
    color = eval([colormap, '(num_color)']);
end

end
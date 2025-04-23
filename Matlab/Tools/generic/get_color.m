function [color, contour_interval] = get_color(colormap, climit, interval)

num_color = double(diff(climit)/interval);
contour_interval = climit(1):interval:climit(end);
if strcmp(colormap, 'redblue')
    color_tmp = eval(colormap);
    close
    color = color_tmp(floor(linspace(1,length(color_tmp),num_color)),:);
else
    color = eval([colormap, '(num_color)']);
end

end
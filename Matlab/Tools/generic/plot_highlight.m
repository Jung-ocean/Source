function plot_highlight(xdate, data_all, num_highlight, color)

figure; hold on
xdatenum = xdate;
len_x = length(xdatenum);
len_data = length(data_all);

for i = 1:len_data/len_x
    if i == num_highlight
        h_target = plot(xdatenum, data_all(len_x*i-(len_x-1):len_x*i), 'LineWidth', 2, 'Color', color);
    else
        h = plot(xdatenum, data_all(len_x*i-(len_x-1):len_x*i), 'LineWidth', 1, 'Color', [.7 .7 .7]);
    end
end
uistack(h_target, 'top')
datetick('x', 'mm')

end
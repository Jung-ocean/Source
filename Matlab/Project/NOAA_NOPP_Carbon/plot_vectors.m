function q = plot_vectors(region, lon, lat, u, v, interval, color, isscale)

switch region
    case 'Oregon'
        scale_vec = .01;

        scale = 20;
        scale_lat = 47.7;
        scale_lon = -124.35;
        scale_text = [num2str(scale), ' cm/s'];
        scale_text_lat = scale_lat-.15;
        scale_text_lon = scale_lon;
        FS = 12;
end
[scalex, scaley, lon_scl] = adjust_vector(scale_lon, scale_lat, scale, scale);

% Adjust vector scale according to lon, lat
[u, v, lon_scl] = adjust_vector(lon, lat, u, v);

q = quiverm(lat(1:interval:end, 1:interval:end), ...
    lon(1:interval:end, 1:interval:end), ...
    v(1:interval:end, 1:interval:end).*scale_vec, ...
    u(1:interval:end, 1:interval:end).*scale_vec, ...
    0);
q(1).Color = color;
q(2).Color = color;
q(1).LineWidth = 1;
q(2).LineWidth = 1;
%     uistack(q, 'bottom')

if isscale == 1
    qscalex = quiverm(scale_lat, scale_lon, 0.*scale_vec, scalex.*scale_vec, 0);
    qscalex(1).Color = 'r';
    qscalex(2).Color = 'r';
    qscalex(1).LineWidth = 2;
    qscalex(2).LineWidth = 2;
    qscaley = quiverm(scale_lat, scale_lon, scaley.*scale_vec, 0.*scale_vec, 0);
    qscaley(1).Color = 'r';
    qscaley(2).Color = 'r';
    qscaley(1).LineWidth = 2;
    qscaley(2).LineWidth = 2;

    tscale = textm(scale_text_lat, scale_text_lon, scale_text, 'Color', 'r', 'FontSize', FS);
end

end
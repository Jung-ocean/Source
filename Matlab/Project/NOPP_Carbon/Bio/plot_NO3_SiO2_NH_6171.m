clear; clc; close all

domain = 'Oregon_1km';
expname = 'bio_20261008';

cd(['/data/jungjih/Project/NOPP_Carbon/', domain, ...
    '/Results/Output_', expname])

filepath = '/data/jungjih/Observations/NH_line/NH_6171/';
stations = {'nh5', 'nh15', 'nh25', 'nh45'};

% Station-specific depth intervals
depthIntervals = [10, 10, 50, 100];

% Figure
figure;
t = tiledlayout(2,2);
t.Padding = 'compact';
t.TileSpacing = 'compact';

set(gcf, 'Position', [1 200 1100 850]);

for si = 1:length(stations)

    station = stations{si};
    filename = [station, 'nut6171.dat'];
    file = [filepath, filename];

    % Read data
    opts = detectImportOptions(file);
    opts = setvartype(opts, opts.VariableNames([3, 10, 11]), 'char');
    data = readtable(file, opts);

    % Extract variables and convert to numeric
    depth = str2double(string(data{:,3}));
    NO3   = str2double(string(data{:,10}));
    SIO2  = str2double(string(data{:,11}));

    % Remove invalid values
    valid = isfinite(depth) & isfinite(NO3) & isfinite(SIO2) ...
            & NO3 >= 0 & SIO2 >= 0;

    depth = depth(valid);
    NO3   = NO3(valid);
    SIO2  = SIO2(valid);

    % Skip station if no valid observations
    if isempty(depth)
        warning('%s: No valid observations.', station);
        continue
    end

    % Station-specific depth interval
    depthInterval = depthIntervals(si);

    % Depth groups
    depthGroup = floor(depth/depthInterval);

    % Maximum valid depth group
    maxGroup = max(depthGroup);
    nBins = maxGroup + 1;

    % Individual colormap
    cmap = jet(nBins);

    % Plot
    ax = nexttile(si);
    hold(ax, 'on');
    box(ax, 'on');
    grid(ax, 'on');

    % Scatter plot
    scatter(ax, NO3, SIO2, 25, depthGroup, 'filled');

    % 1:1 reference line
    plot(ax, [0 120], [0 120], 'k--', ...
        'LineWidth', 1.2);

    % Axis settings
    xlim(ax, [0 120]);
    ylim(ax, [0 120]);

    axis(ax, 'square');

    xlabel(ax, 'NO_3 (mmol N m^{-3})');
    ylabel(ax, 'SiO_2 (mmol Si m^{-3})');

    title(ax, upper(station));

    set(ax, 'FontSize', 11);

    % Individual colormap and color limits
    colormap(ax, cmap);
    clim(ax, [-0.5, nBins-0.5]);

    % Individual colorbar
    cb = colorbar(ax);

    cb.Ticks = 0:nBins-1;

    cb.TickLabels = arrayfun(@(k) ...
        sprintf('%d-%d', k*depthInterval, ...
        (k+1)*depthInterval), ...
        0:nBins-1, 'UniformOutput', false);

    cb.Label.String = 'Depth (m)';
    cb.Label.FontSize = 10;
    cb.FontSize = 9;

    % Display valid depth range
    fprintf('%s: Valid depth range = %.1f - %.1f m\n', ...
        upper(station), min(depth), max(depth));

end

% Overall title
title(t, 'NO_3 vs SiO_2 at NH Stations (61-71)', ...
    'FontSize', 14, 'FontWeight', 'bold');

print('NO3_SiO2_NH_6171', '-dpng')
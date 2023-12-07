function map_J(casename)

if strcmp(casename, 'KODC_small')
    xticks = [125 127 129]; yticks = [33 35 37];
    fs = 20;
elseif strcmp(casename, 'southern')
    xticks = [127 129]; yticks = [34 35];
    fs = 20;
else
    xticks = 3; yticks = 3;
    fs = 15;
end

[lon_lim, lat_lim] = domain_J(casename);
lim = [lon_lim lat_lim];
%fc = [.95 .95 .95 ];
fc = [.7 .7 .7];

%figure; hold on;
hold on;
set(gca,'ydir','nor');
m_proj('miller','lon',[lim(1) lim(2)],'lat',[lim(3) lim(4)]);
if strcmp(casename, 'NP')
    m_gshhs_c('line', 'Color','k', 'LineWidth', 1.5) % plot intermediate resolution coastline, black color
    m_gshhs_c('patch',fc)
else
    m_gshhs_i('line', 'Color','k', 'LineWidth', 1.5) % plot intermediate resolution coastline, black color
    m_gshhs_i('patch',fc)
end

m_grid('XTick', xticks, 'YTick', yticks, ...
    'LineWidth', 2, 'LineStyle', 'none', 'TickStyle', 'dd', 'TickDir', 'out', 'FontSize', fs, ...
    'FontWeight', 'bold','FontName', 'Times');

end
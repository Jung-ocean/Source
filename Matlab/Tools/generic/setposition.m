function setposition(casename)

switch casename
    case 'KODC_small'
        set(gcf, 'Position', [7   434   762   553])
        set(gca, 'Position', [0.1186    0.1100    0.7072    0.8150])
        
    case 'KODC_small_obs'
        set(gcf, 'Position', [7   434   762   553])
        set(gca, 'Position', [0.2186    0.1100    0.7072    0.8150])
        
    case 'vertical'
        set(gcf, 'Position', [3   130   830   760])
        set(gca, 'Position', [0.2158    0.2055    0.5960    0.7195])
        
    case 'vertical_dia'
        set(gcf, 'Position', [3   2   1225   993])
        set(gca, 'Position', [0.2158    0.2055    0.5960    0.7195])
        
    case 'southern'
        set(gcf, 'Position', [13   499   750   477])
        set(gca, 'Position', [0.1171    0.1100    0.6980    0.8150])
        
    case 'southern_obs'
        set(gcf, 'Position', [13   499   750   477])
        set(gca, 'Position', [0.2171    0.1100    0.6980    0.8150])
        
end
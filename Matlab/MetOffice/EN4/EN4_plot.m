%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot EN4 variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

domain_case = 'ECS2';
variable = 'temp';
layers = [-200];

for li = 1:length(layers)
    
    layer_target = layers(li);
    lstr = num2str(layer_target);
    
    for yyyy = 2013:2013
        yi = yyyy; ystr = num2str(yi);
        
        for mm = 8:8
            mi = mm; mstr = num2char(mi,2);
            
            filename = ['EN.4.2.1.f.analysis.l09.', ystr, mstr, '.nc'];
            
            figure('visible', 'off'); hold on
            switch variable
                case 'temp'
                    EN4_plot_temp_function(filename, 'temperature', layer_target, domain_case, 'contour on')
            end
            
            saveas(gcf, [variable, '_layer', lstr, '_EN4_', domain_case, '_', ystr, mstr,'.png'])
            
        end
        close all;
    end
    
end
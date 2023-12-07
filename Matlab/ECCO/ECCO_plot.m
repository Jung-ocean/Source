%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot SODA3 variables
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
            
            filename = ['THETA.', ystr, '.nc'];
            
            figure('visible', 'off'); hold on
            switch variable
                case 'temp'
                    ECCO_plot_temp_function(filename, mi, 'THETA', layer_target, domain_case, 'contour on')
            end
            
            saveas(gcf, [variable, '_layer', lstr, '_ECCO_', domain_case, '_', ystr, mstr,'.png'])
            
        end
        close all;
    end
    
end
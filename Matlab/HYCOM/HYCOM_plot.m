%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot SODA3 variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

domain_case = 'EYECS_topo';
variable = 'temp';
layers = [-1];

for li = 1:length(layers)
    
    layer_target = layers(li);
    lstr = num2str(layer_target);
    
    for yyyy = 2013:2013
        yi = yyyy; ystr = num2str(yi);
        
        for mm = 1:12
            mi = mm; mstr = num2char(mi,2);
            
            filename = ['HYCOM_', ystr, mstr, '.nc'];
            
            figure('visible', 'off'); hold on
            switch variable
                case 'temp'
                    HYCOM_plot_temp_function(filename, 'temp', layer_target, domain_case, 'contour on')
                case 'salt'
                    HYCOM_plot_salt_function(filename, 'salt', layer_target, domain_case, 'contour on')
            end
            
            saveas(gcf, [variable, '_layer', lstr, '_HYCOM_', domain_case, '_', ystr, mstr,'.png'])
            
        end
        close all;
    end
    
end
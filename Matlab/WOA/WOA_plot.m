%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot WOA variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

domain_case = 'YECS_flt_small';
variable = 'salt';
layers = [-50];

for li = 1:length(layers)
    
    layer_target = layers(li);
    lstr = num2str(layer_target);
    
    for yyyy = 9999:9999
        yi = yyyy; ystr = num2str(yi);
        
        for mm = 6:8
            mi = mm; mstr = num2char(mi,2);
            
            figure('visible', 'off'); hold on
            switch variable
                case 'salt'
                    filename = ['eas_decav_s', mstr, '_10.nc'];
                    WOA_plot_salt_function(filename, mi, 's_an', layer_target, domain_case, 'contour on')
                case 'temp'
                    filename = ['eas_decav_t', mstr, '_10.nc'];
                    WOA_plot_temp_function(filename, mi, 't_an', layer_target, domain_case, 'contour on')
            end
            
            saveas(gcf, [variable, '_layer', lstr, '_WOA_', domain_case, '_', mstr, '.png'])
            
        end
        close all;
    end
    
end
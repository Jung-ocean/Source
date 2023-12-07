%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot SODA3 variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

domain_case = 'YECS_flt';
variable = 'salt';
layers = [-1];

for li = 1:length(layers)
    
    layer_target = layers(li);
    lstr = num2str(layer_target);
    
    for yyyy = 2012:2012
        yi = yyyy; ystr = num2str(yi);
        
        for mm = 1:1
            mi = mm; mstr = num2char(mi,2);
            
            filename = ['soda3.4.2_mn_ocean_reg_', ystr, '.nc'];
            
            figure('visible', 'off'); hold on
            switch variable
                case 'temp'
                    SODA3_plot_temp_function(filename, mi, 'temp', layer_target, domain_case, 'contour on')
                case 'salt'
                    SODA3_plot_salt_function(filename, mi, 'salt', layer_target, domain_case, 'contour on')
            end
            
            saveas(gcf, [variable, '_layer', lstr, '_SODA3_', domain_case, '_', ystr, mstr,'.png'])
            
        end
        close all;
    end
    
end
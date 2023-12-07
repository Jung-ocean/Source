%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot SODA3 variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

domain_case = 'EYECS_topo';
variable = 'salt';
layers = [-1];

for li = 1:length(layers)
    
    layer_target = layers(li);
    lstr = num2str(layer_target);
    
    for yyyy = 2001:2001
        yi = yyyy; ystr = num2str(yi);
        
        for mm = [3:7]
            mi = mm; mstr = num2char(mi,2);
            
            filename = ['mercatorglorys12v1_gl12_mean_', ystr, mstr, '.nc'];
            
            figure('visible', 'off'); hold on
            switch variable
                case 'temp'
                    MyOcean_plot_temp_function(filename, 'thetao', layer_target, domain_case, 'contour on')
                case 'salt'
                    MyOcean_plot_salt_function(filename, 'so', layer_target, domain_case, 'contour on')
            end
            
            saveas(gcf, [variable, '_layer', lstr, '_MyOcean_', domain_case, '_', ystr, mstr,'.png'])
            
        end
        close all;
    end
    
end
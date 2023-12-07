clear; clc; close all

yyyy = 2013;
datenum_ref = datenum(yyyy,1,1);
filenumber = 182:243;
fns = num2char(filenumber, 4);
filedate = datestr(filenumber + datenum_ref -1, 'mmdd');

g = grd('NWP');
z = g.z_r;

exp = 'control';
temp_target = 14; tts = num2str(temp_target);
salt_target = 33.5; sts = num2str(salt_target);
z_target = -20; zts = num2str(z_target);
%yyyy = [1980:2015];
%mm = [7:8];

for yi = 1:length(yyyy)
    year_target = yyyy(yi); tys = num2str(year_target);
    if year_target == 9999; tys = 'avg'; end
    for fi = 1:length(filenumber)
        %month_target = mm(mi); tms = num2char(month_target,2);
        %filename = ['monthly_', tys, tms, '.nc'];
        
        filepath = 'G:\Model\ROMS\Case\NWP\output\exp_SODA3\2013\daily\';
        filename = ['avg_', fns(fi,:), '.nc'];
        targetfile = [filepath, filename];
                
        ncload(targetfile);
        
        figure; hold on
        topo = squeeze(-g.h).*g.mask_rho./g.mask_rho;
        topo(isnan(topo)==1) = 1;
        s = surf(g.lon_rho, g.lat_rho, topo); shading flat
        caxis([-150 4])
        xlim([124 129]); ylim([33 36]); zlim([-100 4])
        view(-38.4000,   60.4000);
        contour3(g.lon_rho, g.lat_rho, topo, [-10 -10], 'k', 'LineWidth', 2)
        
        c = colormap('bone');
        c(end-1,:) = [0.3 0.3 0.3];
        c(end,:) = [0.3020    0.7490    0.9294];
        %c(1,:) = [0.3020    0.7490    0.9294];
        colormap(c);
        
        z0 = NaN(size(topo));
        z_temp = topo;
        for i = 1:40
            z_i = squeeze(z(i,:,:)).*g.mask_rho./g.mask_rho;
            t_i = squeeze(temp(i,:,:)).*g.mask_rho./g.mask_rho;
            s_i = squeeze(salt(i,:,:)).*g.mask_rho./g.mask_rho;
            index = find(s_i > salt_target); %t_i < temp_target &  %& z_i > z_target); 
            
            z0(index) = z_i(index);
            z_temp(index) = 2;
            
        end
        
        surf(g.lon_rho, g.lat_rho, z0, z_temp);
        
        xlabel('Longitude'); ylabel('Latitude'); zlabel('Depth (m)')
        
        title([filedate(fi,:), ' salt > ', sts], 'FontSize', 15)
        saveas(gcf, [filedate(fi,:), '.png'])
        
    end
end
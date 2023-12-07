%--------------------------------------------------------------------------
%
%
%                        Plotting ROMS OUT ( 365daily )
%
%                                             date : 2005. 11. 19
%                                             made by K.S. Moon
%
%                                             date : 2007. 10. 28
%                                             edited by Y.G.
%
%--------------------------------------------------------------------------
clear all;close all;
%==========================================================================
max_level= 40;
variation = 2;  %  1 = temperature , 2 = salinity ,3 = density, 4 = u, 5 = v, 6 = velocity

current   = 1;   skip_v = 3;     size_v = 2;    color_v = 'k';

plot_pcolorjw = 1;    temp_lim = [0 30];    salt_lim = [30 35]; den_lim = [25 27.5]; u_lim = [0 0.5]; v_lim = [0 1];

plot_contour  = 1;    color_c  ='-k' ;      temp_c  =[temp_lim(1):5:temp_lim(2)];salt_c  =[salt_lim(1):.5:salt_lim(2)]; u_c = [0:0.1:0.5]; v_c = [v_lim(1):0.2:v_lim(2)];

% plot_geoshow  = 0;    color_g = [.7 .7 .7];'black';

switch_save   = 1;    out_type = 'png';

section = 1; % 0 => whole, 1=> yellowsea, 2=> eastsea

if variation == 2
    colormapname = 'jet';
else
    colormapname = 'parula';
end

% grdfile       = 'd:\add2_ini_bry_grd\grid\roms_grid2_ADD_10_ep.nc';

yy = 2013; ystr = num2str(yy);
start_mm=8;
end_mm=8;
time_step=1;

file_dir=['.\'];

mm=start_mm;
%==========================================================================

gd = grd('EYECS_20190904');
lon_rho  = gd.lon_rho;
lat_rho  = gd.lat_rho;
mask_rho = gd.mask_rho;
h=gd.h;
N = gd.N;
depth=zlevs(h,gd.zeta,gd.theta_s,gd.theta_b,gd.hc,N,'r',2);
% angle    = gd{'angle'}(:);
% mask_u = gd{'mask_u'}(:);
% mask_v = gd{'mask_v'}(:);
warning off
mask_rho = mask_rho./mask_rho;
% mask_u = mask_u./mask_u;
% mask_v = mask_v./mask_v;
%warning on
vname = {'temp','salt', 'density', 'u', 'v'};%,'zeta','ubar','vbar','u','v','omega'};

for im=start_mm:time_step:end_mm
    mid=[num2char(im,2)];
    file = [file_dir,'monthly_', ystr, mid,'.nc'];
    %file = ['test49_monthly_', num2str(yy), '_', mid, '.nc'];
    
    disp([file,' : ', num2char(im,2)])
    nc=netcdf(file);
    date=[num2str(yy),'. ',num2str(im)];
    switch variation
        case 1
            value=nc{char(vname(variation))}(:);
            val_name='Temperature';
            unit = '^oC';
            out_name_1=['vertical_NS_Temp-',num2str(yy),'-'];
            val_caxis=temp_lim;
            level_c=temp_c;
            data=value;
            clear value;
        case 2
            value=nc{char(vname(variation))}(:);
            val_name='Salinity';
            unit = 'psu';
            out_name_1=['vertical_NS_Salt-',num2str(yy),'-'];
            val_caxis=salt_lim;
            level_c=salt_c;
            data=value;
            clear value;
            
        case 4
            value=nc{char(vname(variation))}(:);
            val_name='Zonal velocity';
            unit = 'm/s';
            out_name_1=['vertical_NS_U-',num2str(yy),'-'];
            val_caxis=u_lim;
            level_c=u_c;
            data=value;
            clear value;
            
        case 5
            value=nc{char(vname(variation))}(:);
            val_name='Meridional velocity';
            unit = 'm/s';
            out_name_1=['vertical_NS_V-',num2str(yy),'-'];
            val_caxis = v_lim;
            level_c = v_c;
            data=value;
            clear value;
            
        case 6
            u = nc{'u'}(:); u = u*100;
            v = nc{'v'}(:); v = v*100;
            
            u_rho = zeros([gd.N,size(gd.lon_rho)]);
            v_rho = zeros([gd.N,size(gd.lon_rho)]);
            for i = 1:gd.N
                [ured,vred,lonred,latred,maskred] = ...
                    uv_vec2rho(squeeze(u(i,:,:)),squeeze(v(i,:,:)),gd.lon_rho,gd.lat_rho,gd.angle,gd.mask_rho,1,[0 0 0 0]);
                
                u_rho(i,:,:) = ured;
                v_rho(i,:,:) = vred;
            end
            
            u_rho(u_rho > 10000) = NaN;
            v_rho(v_rho > 10000) = NaN;
            
            val_name='Velocity';
            colormapname = 'jet';
            unit = 'cm/s';
            out_name_1=['vertical_NS_current-',num2str(yy),'-'];
            val_caxis = [-150 150];
            level_c = [-140:20:140];
            data = u_rho;
            clear value;
    end
    
    
    if (plot_pcolorjw)
        for i=1:1:length(data(:,1))
            for j=1:1:length(data(1,:))
                if data(i,j) > 10000
                    data(i,j) = NaN;
                end
            end
        end
        
        switch section
            case 1
                %domaxis=[38 39.5 120 124 -100 0]; % 발해
                %domaxis=[30 36 122 125 -200 0]; % 발해
                %domaxis=[23 30 118.3 124 -100 0]; % 대만해협 along
                %domaxis=[25 24 118.5 121 -100 0]; % 대만해협 cross
                %domaxis=[29.0047 27.5218 125.9953 128.2412 -1000 0]; % PN-line
                %domaxis = [37.0567 37.0567 129 133 -550 0]; % KODC 104 line
                %domaxis = [33.6217 34.4167 128.1533 127.6667 -120 0]; % KODC 205 line
                domaxis = [34.0767 34.6 128.5 128.0833 -120 0]; % KODC 400 line
                
                if variation == 6
                    
                    [dx,lons,lats] = m_lldist([domaxis(3) domaxis(4)],[domaxis(2), domaxis(2)],1);
                    [dy,lons,lats] = m_lldist([domaxis(3) domaxis(3)],[domaxis(1), domaxis(2)],1);
                    if domaxis(1) > domaxis(2)
                        dy = -dy;
                    end
                    theta1 = atan2(dy,dx);
                    theta1_degree = theta1*180/pi;
                    
                    uv_rho = [u_rho(:), v_rho(:)];
                    mat_rot = [cos(theta1) -sin(theta1); sin(theta1) cos(theta1)];
                    uv_rho_ = uv_rho*mat_rot;
                    v_ = reshape(uv_rho_(:,2), [gd.N, size(gd.lon_rho)]);
                    
                    data = v_;
                    
                end
                
                dist=sqrt((lon_rho-domaxis(3)).^2+(lat_rho-domaxis(1)).^2);
                min_dist=min(min(dist));
                dist2=sqrt((lon_rho-domaxis(4)).^2+(lat_rho-domaxis(2)).^2);
                min_dist2=min(min(dist2));
                [x1,y1]=find(dist==min_dist);
                [x2,y2]=find(dist2==min_dist2);
                lat1=lat_rho(x1(1),y1(1));lon1=lon_rho(x1(1),y1(1));
                lat2=lat_rho(x2(1),y2(1));lon2=lon_rho(x2(1),y2(1));
                if (lon2-lon1) >= (lat2-lat1)
                    lon_line=[lon1:0.05:lon2];
                    lat_line=(lon_line-lon1)/((lon2-lon1)/(lat2-lat1))+lat1;
                    x=repmat(lon_line,gd.N,1);
                    x_label='Longitude(^oE)';
                    domaxis=[domaxis(3) domaxis(4) domaxis(5) domaxis(6) domaxis(5) domaxis(6)];
                else
                    lat_line=[min(lat1,lat2):0.05:max(lat1,lat2)];
                    lon_line=(lat_line-lat1)*((lon2-lon1)/(lat2-lat1))+lon1;
                    x=repmat(lat_line,gd.N,1);
                    x_label='Latitude(^oN)';
                end
                Temp=zeros(gd.N,length(lat_line));
                for k=1:1:gd.N
                    lon_range=lon_rho(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
                    lat_range=lat_rho(min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2));
                    data_range=squeeze(data(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
                    depth_range=squeeze(depth(k,min(x1,x2):max(x1,x2),min(y1,y2):max(y1,y2)));
                    Temp(k,:)=griddata(lon_range,lat_range,data_range,lon_line,lat_line);
                    Yi(k,:)=griddata(lon_range,lat_range,depth_range,lon_line,lat_line);
                end
                data=Temp;
        end
    end
    
    figure('position',[400 100 550 550],'PaperUnits','inches','PaperPosition',[0 0 5.7 5.8]);
    set(gca,'Position',[0.2 0.15 0.73 0.75]);
    text_posi_x=(domaxis(2)-domaxis(1))/20+domaxis(1);
    text_posi_y1=(domaxis(6)-domaxis(5))/20+domaxis(5);
    text_posi_y2=2*(domaxis(6)-domaxis(5))/20+domaxis(5);
    text_posi_y3=3*(domaxis(6)-domaxis(5))/20+domaxis(5);
    switch section
        case 1
            hold on
            pcolor(x,Yi,data); colormap(colormapname);
            axis([domaxis(1) domaxis(2) domaxis(5) domaxis(6)]);
            shading flat;caxis(val_caxis)
            set(gca,'box','on','linewidth',1.5,'fontsize',17)
            xlabel(x_label,'color',color_v,'FontSize',17,'fontweight','bold')
            ylabel('Depth(m)','color',color_v,'FontSize',17,'fontweight','bold')
            text(text_posi_x,text_posi_y2,val_name,'color',color_v,'FontSize',17,'fontweight','bold')
            text(text_posi_x,text_posi_y3,date,'color',color_v,'FontSize',17,'fontweight','bold')
            %title('Data assimilation','fontsize',17);
            out_name_1=['YellowSea',out_name_1];
            if (plot_contour)
                hold on
                [C,h]=contour(x,Yi,data,level_c,color_c,'linewidth',1);
                %[C2,h2]=contour(x,Yi,data,level_c-0.5,color_c,'linewidth',1);
                %[C2,h2]=contour(x,Yi,data,[-1:2:1],'-w','linewidth',1);
                clabel(C,h,'FontSize',15,'Color','k','labelspacing',100000,'Rotation',0,'fontweight','bold');
            end
    end
    %             caxis(val_caxis);
    bar = colorbar('fontsize',17,'fontweight','bold');
    set(get(bar,'title'),'string',unit,'FontSize',17,'fontweight','bold')
    
    out_name=[file_dir,'test',out_name_1,num2char(im,2)];
    
    if (switch_save)
        saveas(gcf,out_name,out_type);
    end
    close all
end
%      close all
% % % end
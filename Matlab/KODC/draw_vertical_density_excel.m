clear; close all; clc;

yyyy_all = 1990:2001;
mm_all = [2:2:6];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        vari = 'density';
        section_dir = 'lon';
        target_year = yyyy;     ystr = num2str(target_year);
        target_month = mm;       mstr = num2str(target_month, '%02d');
        
        Nline = 310;
        if Nline == 204
            line_list = [20400:20406];
        elseif Nline == 205
            line_list = [20500:20505];
            xlimit = [33.6217 34.4167];
            ylimit = [0 120];
            grd_gap = .01; grd_dep = 5;
            standard_dep = [0 10 20 30 50 75 100 120];
        elseif Nline == 206
            line_list = [20600:20603];
        elseif 310
            line_list = [31003:31010];
            xlimit = [124.4 125.8];
            ylimit = [0 90];
            grd_gap = .1; grd_dep = 5;
            standard_dep = [0 10 20 30 50 75];
        elseif Nline == 400
            line_list = [40000 40013 40014 40015 40016];
        end
        
        %line_list = [10400:10414];
        
        if strcmp(section_dir, 'lon')
            xlabelstr =  'Longitude(^oE)';
        else
            xlabelstr = 'Latitude(^oN)';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        contourinterval = [18:.5:28];
        clim = [contourinterval(1) contourinterval(end)];
        colorbarname = '\sigma_t';
        colormapname = 'parula';
        
        if target_year ~= 9999
            filepath='D:\Data\Ocean\KODC\excel\';
            filename= ['KODC_', ystr, '.xls'];
            file = [filepath,filename];
            
            [num, raw, txt] = xlsread(file);
            
            obsline = txt(3:end,2); obspoint = txt(3:end,3);
            lat = txt(3:end, 5); lon = txt(3:end, 6);
            date = datenum(txt(3:end, 7));
            dep = txt(3:end, 8);
            temp = txt(3:end, 9);
            salt = txt(3:end, 11);
            
            data_cell = [obsline obspoint lat lon dep temp salt];
            datasize = size(data_cell);
            
            clearvars data
            for i = 1:datasize(1)
                for j = 1:datasize(2)
                    if isempty(cell2mat(data_cell(i,j))) == 1
                        data(i,j) = NaN;
                    else
                        data(i,j) = str2num(cell2mat(data_cell(i,j)));
                    end
                end
            end
            
            data_all = [datevec(date) data];
            
        else % Æò³â
            filepath='D:\Data\Ocean\KODC\avg_ts(2006_2015)\';
            filename = 'KODC_avg(2006_2015).mat';
            file = [filepath, filename];
            data_all = load(file);
            data_all = data_all.data_avg;
        end
        
        line_all = data_all(:,7)*100 + data_all(:,8);
        
        line_chk = find(ismember(line_all, line_list));
        data_all = data_all(line_chk,:);
        
        month_chk = find(data_all(:,2) == target_month | data_all(:,2) == target_month+1);
        data_all = data_all(month_chk,:);
        
        dep = data_all(:,11);
        index = find(ismember(dep,standard_dep) ~= 1);
        data_all(index,:) = [];
        
        lon = data_all(:,10); lat = data_all(:,9);
        dep = data_all(:,11); temp = data_all(:,12); salt = data_all(:,13);
        
        std_loc = eval(section_dir);
        [std_loc2,std_dep2] = meshgrid([min(std_loc(:))-grd_gap*2:grd_gap:max(std_loc(:))+grd_gap*2],...
            [min(dep(:))-grd_dep*2:grd_dep:max(dep(:))+grd_dep*2]);
        
        pres = sw_pres(dep, lat);
        pdens = sw_pden(salt, temp, pres, 0);
        density = pdens - 1000;
        
        variable = eval(vari);
        variable2 = griddata(std_loc, dep, variable, std_loc2, std_dep2);
        
        figure; hold on;
        pcolor(std_loc2,std_dep2,variable2); shading interp;
        caxis(clim); colormap(colormapname);
        c = colorbar; c.FontSize = 15;
        c.Title.String = colorbarname; c.Title.FontSize = 15;
        [cs, h] = contour(std_loc2, std_dep2, variable2, contourinterval, 'k');
        h.LineWidth = 1;
        tl = clabel(cs,h,'LabelSpacing',144, 'FontSize', 15, 'FontWeight', 'bold');
        h = findobj('Type', 'line');
        for hi = 1:length(h)
            h(hi).Marker = '.';
        end
        plot(std_loc,dep,'k.','MarkerSize',5,'Linewidth',2);
        set(gca, 'fontsize', 15, 'YDir','reverse');
        titlename = [datestr(datenum(1,target_month,1), 'mmm'), ' ', ystr];
        title(titlename, 'Fontsize', 25);
        
        xlabel(xlabelstr)
        ylabel('Depth(m)')
        
        set(gca, 'FontSize', 20)
        
        xlim(xlimit)
        ylim(ylimit)
        
        ax = get(gca);
        xlim([ax.XLim(1)-0.005 ax.XLim(2)+0.01])
        ylim([-.5 ylimit(2)])
        %yticks([-120 -80 -40 0])
        ax.XAxis.TickDirection = 'out';
        ax.YAxis.TickDirection = 'out';
        ax.XAxis.LineWidth = 2;
        ax.YAxis.LineWidth = 2;
        
        box on
        
        saveas(gcf, [filepath, vari, '_vertical_', section_dir, '_', num2char(Nline, 3), '_', ystr, mstr, '.png'])
        
    end
end
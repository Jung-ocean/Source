clear; clc; close all

year_all = [1980:2019];
month_all = [2:2:12];
line_all = [105 205 309];

clim = [-5 5];
contourinterval = [clim(1):1:clim(2)];
colormapname = 'redblue2';
colorbarname = '^oC';

fpath = 'D:\Data\Ocean\KODC\excel\';
figpath = 'D:\Data\Ocean\KODC\KODC_';

data_all = [];
for yi = 1:length(year_all)
    year = year_all(yi); ystr = num2str(year)
    fname = [fpath, 'KODC_', ystr, '.xls'];
    
    [num, raw, txt] = xlsread(fname);
    
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
    
    data_year = [datevec(date) data];
    data_all = [data_all; data_year];
end

index = find(isnan(mean(data_all,2)) == 1);
data_all(index,:) = [];

data_30ydiff = [];
for li = 1:length(line_all) % line
    line_target = line_all(li);
    lindex = find(data_all(:,7) == line_target);
    data_line = data_all(lindex,:);
    
    obspoint_list = unique(data_line(:,8));
    for oi = 1:length(obspoint_list) % point
        obspoint_target = obspoint_list(oi);
        oindex = find(data_line(:,8) == obspoint_target);
        data_point = data_line(oindex,:);
        for mi = 1:length(month_all)
            month_target = month_all(mi);
            mindex1 = find(data_point(:,2) == month_target);
            mindex2 = find(data_point(:,2) == month_target+1);
            mindex = sort([mindex1; mindex2]);
            data_month = data_point(mindex,:);
            
            depth_list = unique(data_month(:,11));
            for di = 1:length(depth_list)
                depth_target = depth_list(di);
                dindex = find(data_month(:,11) == depth_target);
                data_depth = data_month(dindex,:);
                
                index1 = find(data_depth(:,1) >= 1980 & data_depth(:,1) <= 1989);
                index2 = find(data_depth(:,1) >= 2010 & data_depth(:,1) <= 2019);
                
                if length(index1) > 1 && length(index2) > 1
                    
                    temp1 = mean(data_depth(index1,12));
                    temp2 = mean(data_depth(index2,12));
                    
                    temp_diff = temp2 - temp1;
                    
                    data_30ydiff = [data_30ydiff; month_target data_depth(1,7:11) temp_diff];
                else
                end
            end
        end
    end
end

nodataindex = 0;
for li = 1:length(line_all)
    line_target = line_all(li); ltstr = num2str(line_target);
    lindex = find(data_30ydiff(:,2) == line_target);
    data_trend_line = data_30ydiff(lindex,:);
    
    for mi = 1:length(month_all)
        month_target = month_all(mi); mtstr = num2char(month_target,2);
        mindex = find(data_trend_line(:,1) == month_target);
        data_trend_month = data_trend_line(mindex,:);

        % offset ==========================================================
        calc_diff_10ymean_excel_subset
        %==================================================================
        
        if line_target == 105
            xdata = data_trend_month(:,5);
            xlabelstr = 'Longitude (^oE)';
            cff_polygon = 0.2;
            ylimits = [0 500];
            load land_105.mat
        elseif line_target == 309
            xdata = data_trend_month(:,5);
            xlabelstr = 'Longitude (^oE)';
            cff_polygon = 0.2;
            ylimits = [0 75];
            load land_309.mat
        elseif line_target == 205
            xdata = data_trend_month(:,4);
            xlabelstr = 'Latitude (^oN)';
            cff_polygon = 0.3;
            ylimits = [0 100];
            load land_205.mat
        end
        dep = data_trend_month(:,6);
        Tdiff = data_trend_month(:,7);

        grd_gap = 0.01; grd_dep = 2;
        std_loc = xdata;
        
%         [std_loc2,std_dep2] = meshgrid([min(std_loc(:))-grd_gap*2:grd_gap:max(std_loc(:))+grd_gap*2],...
%             [min(dep(:))-grd_dep*2:grd_dep:max(dep(:))+grd_dep*2]);
        [std_loc2,std_dep2] = meshgrid([min(std_loc(:)):grd_gap:max(std_loc(:))],...
            [min(dep(:)):grd_dep:max(dep(:))]);

        variable = Tdiff;
        variable2 = griddata(std_loc, dep, variable, std_loc2, std_dep2);
        
        if ~isempty(xdata)
            k = boundary(xdata, dep, cff_polygon);
            mask = inpolygon(std_loc2,std_dep2, xdata(k), dep(k));
        else
            mask = NaN;
        end
        
        %land = -100*ones(size(variable2)).*(~mask./~mask);
        
        figure; hold on;
        pcolor(std_loc2,std_dep2,land); shading interp % land
        
        pcolor(std_loc2,std_dep2,variable2.*mask./mask); shading flat;
        caxis(clim); colormap(colormapname);
        
        clim_ = 3;
        cm = colormap(colormapname);
        cm = [[.9 .9 .9]; cm;];
        cm2 = colormap(cm);
        clim2 = [clim(1)-clim_ clim(2)+clim_];
        
        caxis(clim2)
        c = colorbar; c.FontSize = 15;
        c.Title.String = colorbarname; c.Title.FontSize = 15;
        c.Limits = clim;
        
        [cs, h] = contour(std_loc2, std_dep2, variable2.*mask./mask, contourinterval, 'k');
        h.LineWidth = 1;
        tl = clabel(cs,h,'LabelSpacing',144, 'FontSize', 15, 'FontWeight', 'bold');
        h = findobj('Type', 'line');
        for hi = 1:length(h)
            h(hi).Marker = '.';
        end
        plot(std_loc,dep,'k.','MarkerSize',10,'Linewidth',2);
        if nodataindex == 1
           plot(nodatax,nodatadep,'kx','MarkerSize',10,'Linewidth',2); 
           nodataindex = 0;
        end
        
        set(gca, 'fontsize', 15, 'YDir','reverse');
        
        ylim(ylimits)
        
        xlabel(xlabelstr)
        ylabel('Depth (m)')
        
        title([ltstr, ' Line ', mtstr, '월'], 'FontSize', 25)
        saveas(gcf, ['temp_diff_10ymean_', ltstr, mtstr, '.png'])
        
        savefile = ['temp_diff_10ymean_', ltstr, mtstr, '.txt'];
        fid=fopen(savefile,'w');
        fprintf(fid, 'Month  Line  Point  Latitude(degreeN)  Longitude(degreeE)  Depth(m)  temp_diff(degreeC, mean(2010~2019)-mean(1980~1989)) \r\n')
        fprintf(fid,'%5d %7d %4d %17.4f %23.4f %12d %16.4f \r\n', data_trend_month');
        fclose(fid);
        
    end
end
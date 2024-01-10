%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot Saildron data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
yyyy = 2018; % 2018, 2019
variable = 'salt'; % temp, salt
%

if yyyy == 2018
    casename = 'US_west';
elseif yyyy == 2019
    casename = 'Bering_Arctic';
end

filenames = dir('*.nc');
for fi = 1:length(filenames)
    filename = filenames(fi).name;

    % Open netcdf file
    ncid = netcdf.open(filename);

    vars = {'latitude', 'longitude', 'time'};
    for vi = 1:length(vars)
        varname = vars{vi};
        varid = netcdf.inqVarID(ncid,varname);
        eval([varname, '= netcdf.getVar(ncid,varid);'])
        try
            Fillvalue = netcdf.getAtt(ncid,varid,'_FillValue');
        catch
        end
        eval([varname, '(', varname '== Fillvalue) = NaN;'])
    end
    time_origin = datenum(1970,1,1);
    time_datevec = datevec(time_origin + time/60/60/24);
    time_datenum = datenum(time_datevec);

    switch variable
        case 'temp'
            ylabel_string = 'Temperature (^oC)';
            ylimit = [-5 25];
            if yyyy == 2018
                varname = 'TEMP_CTD_MEAN';
            elseif yyyy == 2019
                varname = 'TEMP_CTD_RBR_MEAN';
            end
        case 'salt'
            ylabel_string = 'Salinity (g/kg)';
            ylimit = [28 35];
            if yyyy == 2018
                varname = 'SAL_MEAN'; 
            elseif yyyy == 2019
                disp('There is no salinity data in 2019')
                return
            end
    end
    varid = netcdf.inqVarID(ncid,varname);
    data = netcdf.getVar(ncid,varid);
    Fillvalue = netcdf.getAtt(ncid,varid,'_FillValue');
    data(data==Fillvalue) = NaN;

    % Close netcdf file
    netcdf.close(ncid)

    % Plot figure
    figure; hold on; 
    subplot(1,2,1); hold on
    plot_map_saildrone(casename)
    m_scatter(longitude, latitude, 1, time_datenum);
    c = colorbar('SouthOutside');
    c.Ticks = datenum(yyyy,1:12,1);
    c.TickLabels = {'Jan-01', 'Feb-01', 'Mar-01', 'Apr-01', 'May-01', 'Jun-01', 'Jul-01', 'Aug-01', 'Sep-01', 'Oct-01', 'Nov-01', 'Dec-01'};
    
    subplot(1,2,2); grid on;
    plot(time_datenum, data)
    xticks(datenum(yyyy,1:12,1));
    datetick('x', 'mmm-dd', 'keeplimits', 'keepticks')
    ylabel(ylabel_string)
    xlabel('Time')
    ylim(ylimit)
    set(gca, 'FontSize', 10)

    set(gcf, 'Position', [55 474 800 450])
    set(gcf, 'PaperPosition', [0.0833 3.1563 8.3333 4.6875])

    print([variable, '_', filename(1:end-3)],'-dpng')
end
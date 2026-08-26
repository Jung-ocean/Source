clear; clc

yyyy = 2024;
ystr = num2str(yyyy);
timenum_target = datenum(yyyy-1,12,31):datenum(yyyy+1,1,1);

rivers = {
    'Humptulips_River'
    'Yaquina_River'
    'Sixes_River'
    'Coos_River'
    'Coquille_River'
    };

stations = {
    'USGS-12039005'
    'USGS-14306030'
    'USGS-14327150'
    'USGS-432240124072700'
    'USGS-14327055'
    };

types = {
    'climate'
    'climate'
    'climate'
    'combined'
    'combined'
    };

filepath = '/data/jungjih/Observations/USGS/data_for_climate_and_combined/';
filepath_out = '/data/jungjih/Observations/USGS/discharge_for_2024/';

for ri = 1:length(rivers)
    river = rivers{ri};
    station = stations{ri};
    type = types{ri};

    filename_out = [station, '_', river, '.csv'];
    file_out = [filepath_out, type, '_', filename_out];

    switch river
        case 'Coos_River'
            lon = -124.124141666667;
            lat = 43.3777305555556;
            
            data1 = readtable([filepath, 'South_Fork_Coos_River.xls'], 'Sheet', ystr);
            for i = 1:width(data1)
                if isstring(data1.(i)) || iscellstr(data1.(i))
                    data1.(i) = str2double(data1.(i));
                end
            end
            data2 = readtable([filepath, 'West_Fork_Millicoma_River.xls'], 'Sheet', ystr);
            for i = 1:width(data2)
                if isstring(data2.(i)) || iscellstr(data2.(i))
                    data2.(i) = str2double(data2.(i));
                end
            end
            data3 = readtable([filepath, 'East_Fork_Millicoma_River.xlsx'], 'Sheet', ystr);
            for i = 1:width(data3)
                if isstring(data3.(i)) || iscellstr(data3.(i))
                    data3.(i) = str2double(data3.(i));
                end
            end
            
            mm_all_Coos = [10 11 12 1:9];
            timenum_Coos = [];
            discharge1 = [];
            discharge2 = [];
            discharge3 = [];
            for mi = 1:12
                mm_Coos = mm_all_Coos(mi);
                if mm_Coos > 9
                    timenum_Coos = [timenum_Coos; datenum(yyyy-1,mm_Coos,1:eomday(yyyy,mm_Coos))'];
                else
                    timenum_Coos = [timenum_Coos; datenum(yyyy,mm_Coos,1:eomday(yyyy,mm_Coos))'];
                end
                discharge1 = [discharge1; table2array(data1(3:eomday(yyyy,mm_Coos)+2,mi+1))];
                discharge2 = [discharge2; table2array(data2(3:eomday(yyyy,mm_Coos)+2,mi+1))];
                discharge3 = [discharge3; table2array(data3(3:eomday(yyyy,mm_Coos)+2,mi+1))];
            end

            yp1 = yyyy+1;
            ystrp1 = num2str(yp1);
            data1 = readtable([filepath, 'South_Fork_Coos_River.xls'], 'Sheet', ystrp1);
            data2 = readtable([filepath, 'West_Fork_Millicoma_River.xls'], 'Sheet', ystrp1);
            data3 = readtable([filepath, 'East_Fork_Millicoma_River.xlsx'], 'Sheet', ystrp1);
            for mi = 1:4
                mm_Coos = mm_all_Coos(mi);
                if mm_Coos > 9
                    timenum_Coos = [timenum_Coos; datenum(yp1-1,mm_Coos,1:eomday(yp1,mm_Coos))'];
                else
                    timenum_Coos = [timenum_Coos; datenum(yp1,mm_Coos,1:eomday(yp1,mm_Coos))'];
                end
                discharge1 = [discharge1; table2array(data1(3:eomday(yp1,mm_Coos)+2,mi+1))];
                discharge2 = [discharge2; table2array(data2(3:eomday(yp1,mm_Coos)+2,mi+1))];
                discharge3 = [discharge3; table2array(data3(3:eomday(yp1,mm_Coos)+2,mi+1))];
            end
            discharge1(isnan(discharge1) == 1) = 0;
            discharge2(isnan(discharge2) == 1) = 0;
            discharge3(isnan(discharge3) == 1) = 0;
            discharge_Coos = discharge1 + discharge2 + discharge3;
            
            index = find(ismember(timenum_Coos, timenum_target));
            discharge = discharge_Coos(index);
            
        case 'Coquille_River'
            lon = -124.181794444444;
            lat = 43.1579416666667;

            data1 = readtable([filepath, 'USGS-14327000_NF_Coquille_River.csv']);
            timenum1 = datenum(table2array(data1(:,7)));
            timevec1 = datevec(timenum1);
            discharge1 = datenum(table2array(data1(:,8)));

            data2 = readtable([filepath, 'USGS-14326510_SF_Coquille_River.csv']);
            timenum2 = datenum(table2array(data2(:,7)));
            timevec2 = datevec(timenum2);
            discharge2 = datenum(table2array(data2(:,8)));

            discharge = NaN(length(timenum_target),1);
            for ti = 1:length(timenum_target)
                timenum = timenum_target(ti);
                timevec = datevec(timenum);

                index1 = find(timenum1 == timenum);
                index2 = find(timenum2 == timenum);
                if isempty(index1) |  isempty(index2)
                    error
%                     mm = timevec(:,2);
%                     dd = timevec(:,3);
%                     index = find(timevec_all(:,2) == mm & timevec_all(:,3) == dd);
%                     discharge(ti,1) = mean(discharge_all(index));
                else
                    discharge(ti,1) = discharge1(index1) + discharge2(index2);
                end
            end

        otherwise
            filename = filename_out;
            file = [filepath, filename];
            data = readtable(file);
            lon = table2array(data(1,1));
            lat = table2array(data(1,2));
            timenum_all = datenum(table2array(data(:,7)));
            timevec_all = datevec(timenum_all);
            discharge_all = datenum(table2array(data(:,8)));
            discharge = NaN(length(timenum_target),1);
            for ti = 1:length(timenum_target)
                timenum = timenum_target(ti);
                timevec = datevec(timenum);

                index = find(timenum_all == timenum);
                if isempty(index)
                    mm = timevec(:,2);
                    dd = timevec(:,3);
                    index = find(timevec_all(:,2) == mm & timevec_all(:,3) == dd);
                    discharge(ti,1) = mean(discharge_all(index));
                else
                    discharge(ti,1) = discharge_all(index);
                end
            end
    end % swtich

    if sum(isnan(discharge)) > 0
        error('Discharge contains NaN')
    end

    time_series_id = [];
    monitoring_location_id = [];
    parameter_code = [];
    statistic_id = [];
    time = [];
    value = [];
    unit_of_measure = [];
    approval_status = [];
    qualifier = [];
    last_modified = [];
    geometry_type = [];
    geometry = [];
    daily_id = [];
    for ti = 1:length(timenum_target)
        time_series_id{ti,1} = '';
        monitoring_location_id{ti,1} = station;
        parameter_code{ti,1} = '';
        statistic_id{ti,1} = '';
        time{ti,1} = datestr(timenum_target(ti), 'yyyy-mm-dd');
        value{ti,1} = discharge(ti);
        unit_of_measure{ti,1} = 'ft^3/s';
        approval_status{ti,1} = '';
        qualifier{ti,1} = '';
        last_modified{ti,1} = datestr(now, 'yyyy-mm-dd');
        geometry_type{ti,1} = 'Point';
        geometry{ti,1} = ['[', num2str(lon), ', ', num2str(lat) ']'];
        daily_id{ti,1} = '';
    end

    table_tmp = table(...
        time_series_id, ...
    	monitoring_location_id, ...
    	parameter_code, ...
    	statistic_id, ...
    	time, ...
    	value, ...
    	unit_of_measure, ...
    	approval_status, ...
    	qualifier, ...
    	last_modified, ...
    	geometry_type, ...
    	geometry, ...
    	daily_id ...
        );

    writetable(table_tmp, file_out);
end
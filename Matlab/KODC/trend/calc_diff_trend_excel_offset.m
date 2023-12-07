if li == 1 && mi == 3
    data_trend_month(end+1:end+2,:) = [...
        month_target,105,6,37.5533,129.6883,500, 0; ...
        month_target,105,7,37.5533,130,500, 0];
    nodatax = [129.6883 130];
    nodatadep = [500; 500];
    nodataindex = 1;
elseif li == 1 && mi == 6
    offset = [ ...
        month_target, 105, 6, 37.5533, 129.6883, 500, 0; ...
        month_target, 105, 7, 37.5533, 130.0000, 500, 0; ...
        month_target, 105, 8, 37.5533, 130.3117, 500, 0; ...
        month_target, 105, 9, 37.5533, 130.6250, 500, 0; ...
        month_target, 105, 10, 37.5533, 130.9317, 500, 0; ...
        month_target, 105, 11, 37.5533, 131.2433, 500, 0];
    data_trend_month(end+1:end+6,:) = offset;
    nodatax = offset(:,5);
    nodatadep = offset(:,6);
    nodataindex = 1;
elseif li == 2 && mi == 1
    offset = [month_target,205,3,34.0917,127.9483,75,0];
    data_trend_month(end+1,:) = offset;
    nodatax = offset(:,4);
    nodatadep = offset(:,6);
    nodataindex = 1;
elseif li == 2 && mi == 4
    offset = [month_target,205,1,34.3717,127.8083,50,0];
    data_trend_month(end+1,:) = offset;
    nodatax = offset(:,4);
    nodatadep = offset(:,6);
    nodataindex = 1;
elseif li == 2 && mi == 5
    offset = [month_target,205,3,34.0917,127.9483,75,0];
    data_trend_month(end+1,:) = offset;
    nodatax = offset(:,4);
    nodatadep = offset(:,6);
    nodataindex = 1;
elseif li == 2 && mi == 6
    offset = [month_target,205,1,34.3717,127.8083,50,0; ...
        month_target,205,2,34.2500,127.8683,50,-1; ...
        month_target,205,3,34.0917,127.9483,75,0];
    data_trend_month(end+1:end+3,:) = offset;
    nodatax = offset(:,4);
    nodatadep = offset(:,6);
    nodataindex = 1;
elseif li == 3 && mi == 3
    offset = [month_target,309,2,35.8550,126.0330,30,0];
    data_trend_month(end+1,:) = offset;
    nodatax = offset(:,5);
    nodatadep = offset(:,6);
    nodataindex = 1;
end
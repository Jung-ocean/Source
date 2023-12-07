if li == 2 && mi == 1
    index = find(data_trend_month(:,6) > 100);
    data_trend_month(index,:) = [];
elseif li == 2 && mi == 3
    data_trend_month(23,:) = [];
elseif li == 3 && mi == 1
    data_trend_month([23 39],:) = [];
elseif li == 3 && mi == 2
    data_trend_month([38],:) = [];
elseif li == 3 && mi == 3
    data_trend_month([8 24 46],:) = [];
elseif li == 3 && mi == 4
    data_trend_month([23 39],:) = [];
elseif li == 3 && mi == 5
    data_trend_month(23,:) = [];
elseif li == 3 && mi == 6
    data_trend_month([23 39],:) = [];
end
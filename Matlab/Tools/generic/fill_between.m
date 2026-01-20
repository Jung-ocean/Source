function fill_between(x,y1,y2,c1,c2)

% Positive
pind = find(y1 > y2 & isnan(y1) == 0 & isnan(y2) == 0);
diff_pind = diff(pind);
jump = find(diff_pind > 1);

ind_start = pind(1);
for ji = 1:length(jump)
    if ji == length(jump)
        ind_end = pind(end);
        index = ind_start:ind_end;
    else
        ind_end = pind(jump(ji));
        index = ind_start:ind_end;
        ind_start = pind(jump(ji)+1);
    end
    fill([x(index); flip(x(index))], [y1(index); flip(y2(index))], c1, 'EdgeColor', 'none')
end

hold on;
% Negative
nind = find(y1 < y2 & isnan(y1) == 0 & isnan(y2) == 0);
diff_pind = diff(nind);
jump = find(diff_pind > 1);

ind_start = nind(1);
for ji = 1:length(jump)
    if ji == length(jump)
        ind_end = nind(end);
        index = ind_start:ind_end;
    else
        ind_end = nind(jump(ji));
        index = ind_start:ind_end;
        ind_start = nind(jump(ji)+1);
    end
    fill([x(index); flip(x(index))], [y1(index); flip(y2(index))], c2, 'EdgeColor', 'none')
end

end
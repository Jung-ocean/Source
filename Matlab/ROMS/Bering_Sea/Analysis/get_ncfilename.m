function file = get_ncfilename(exp, type, fnum)

timenum = fnum + datenum(2018,7,1) - 1;
if isnan(timenum(1)) == 1
    disp(['File number is NaN']);
    file = [];
    return
end
yyyymmdd = datestr(timenum, 'yyyymmdd');
timevec = datevec(timenum);
yyyy = timevec(:,1);
mm = timevec(:,2);
dd = timevec(:,3);

fstr = num2str(fnum, '%04i');
filepath_all = '/data/sdurski/ROMS_BSf/Output/';

switch exp
    case 'Dsm4_mk2'
        if (strcmp(type,'his') && fnum < 368) || (strcmp(type,'avg') && fnum < 367)
            exp = 'Dsm4_phih';
        end
end

listing = dir(fullfile(filepath_all, '**', ['*', exp, '*', type, '*', fstr, '*']));
if isempty(listing)
    disp(['No such file ', exp , ' ', type, ' on ', yyyymmdd]);
    file = [];
else
    if length(listing) > 1
        index = find([listing.bytes] == max([listing.bytes]));
        if length(index) > 1
            [~, index2] = max(cellfun(@length, {listing(index).name}));
            index = index(index2);
        end
        file = [listing(index).folder, '/', listing(index).name];
    else
        file = [listing.folder, '/', listing.name];
    end
end

end
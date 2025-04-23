function vari = load_models_surf_daily(model, vari_str, yyyy, mm, dd)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');
dstr = num2str(dd, '%02i');

switch model
    case 'NANOOS'
        filepath = '/data/jungjih/Models/NANOOS/daily/';
        filename = ['NANOOS_', ystr, mstr, dstr, '.nc'];
        file = [filepath, filename];
        vari = ncread(file, vari_str, [1 1 40 1], [Inf Inf 1 Inf]);
    case 'WCOFS'
        filepath = '/data/jungjih/Models/WCOFS/daily/';
        filename = ['WCOFS_2D_', ystr, mstr, dstr, '.nc'];
        file = [filepath, filename];
        if ismember(vari_str, {'u', 'v', 'temp', 'salt'})
            vari = ncread(file, [vari_str, '_sur']);
        else
            vari = ncread(file, vari_str);
        end
end

end
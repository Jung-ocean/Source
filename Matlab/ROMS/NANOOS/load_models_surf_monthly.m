function vari = load_models_surf_monthly(model, vari_str, yyyy, mm)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');

switch model
    case 'NANOOS'
        filepath = '/data/jungjih/Models/NANOOS/monthly/';
        filename = ['NANOOS_monthly_', ystr, mstr, '.nc'];
        file = [filepath, filename];
        vari = ncread(file, vari_str, [1 1 40 1], [Inf Inf 1 Inf]);
    case 'WCOFS'
        filepath = '/data/jungjih/Models/WCOFS/monthly/';
        filename = ['WCOFS_2D_monthly_', ystr, mstr, '.nc'];
        file = [filepath, filename];
        if ismember(vari_str, {'u', 'v', 'temp', 'salt'})
            vari = ncread(file, [vari_str, '_sur']);
        else
            vari = ncread(file, vari_str);
        end
end

end
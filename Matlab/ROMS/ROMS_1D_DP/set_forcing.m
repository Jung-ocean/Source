clear; clc;

filename_org = 'forcing_1D_DP.nc';

mode = '2022';
values = 1:1;

for vi = 1:length(values)
    Vwind_value = values(vi); vstr = num2str(Vwind_value, '%02i');

    if strcmp(mode, '2021') | strcmp(mode, '2022')
        filename = ['forcing_1D_DP_Vwind_', mode, '.nc'];

        lon_target = -177.5;
        lat_target = 63.5;

        file_ERA5 = ['/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/BSf_ERA5_', mode, '_05_ni2_a_frc.nc'];
        lon = ncread(file_ERA5, 'lon');
        lat = ncread(file_ERA5, 'lat');
        Uwind_ERA5 = ncread(file_ERA5, 'Uwind');
        Vwind_ERA5 = ncread(file_ERA5, 'Vwind');

        dis = sqrt((lon - lon_target).^2 + (lat - lat_target).^2);
        index = find(dis == min(dis(:)));
        [lonind,latind] = ind2sub(size(lon), index);

    else
        filename = ['forcing_1D_DP_Vwind_', mode, vstr, '.nc'];
    end

    copyfile(filename_org, filename)

    sfrc_time = ncread(filename, 'sfrc_time');
    sfrc_time = sfrc_time - sfrc_time(1);
    ncwrite(filename, 'sfrc_time', sfrc_time);

    varis = {'Pair', 'Tair', 'Qair'};
    for vii = 1:length(varis)
        vari = varis{vii};
        vari_tmp = ncread(filename, vari);
        vari_tmp = vari_tmp.*0 + mean(vari_tmp(:));

        ncwrite(filename, vari, vari_tmp);
    end

    varis = {'Uwind', 'swrad', 'lwrad_down', 'cloud', 'rain'};
    for vii = 1:length(varis)
        vari = varis{vii};
        vari_tmp = ncread(filename, vari);
        vari_tmp = vari_tmp.*0;

        ncwrite(filename, vari, vari_tmp);
    end

    Vwind = ncread(filename, 'Vwind');
    Vwind = Vwind.*0;
    index = find(sfrc_time > 3);
    for i = 1:size(Vwind,1)
        for ii = 1:size(Vwind,2)

            switch mode
                case 'p'
                    Vwind_tmp = sfrc_time.*0 + Vwind_value;
                    Vwind_tmp(index) = 0;
                    Vwind(i,ii,:) = Vwind_tmp;
                case 'c'
                    Vwind_tmp = sfrc_time.*0 + Vwind_value;
                    Vwind(i,ii,:) = Vwind_tmp;
                case 'r'
                    Vwind_tmp = Vwind_value.*sin(((2*pi)/12).*sfrc_time);
                    Vwind_tmp(index) = Vwind_value;
                    Vwind(i,ii,:) = Vwind_tmp;
                case 's'
                    Vwind_tmp = Vwind_value.*sin(((2*pi)/12).*sfrc_time);
                    Vwind(i,ii,:) = Vwind_tmp;
                case {'2021', '2022'}
                    Uwind_tmp = squeeze(Uwind_ERA5(lonind,latind,:));
                    Vwind_tmp = squeeze(Vwind_ERA5(lonind,latind,:));

                    Uwind(i,ii,:) = Uwind_tmp;
                    Vwind(i,ii,:) = Vwind_tmp;
            end

        end
    end
    
    ncwrite(filename, 'Vwind', Vwind);
    if strcmp(mode, '2021') | strcmp(mode, '2022')
        ncwrite(filename, 'Uwind', Uwind);
    end
end
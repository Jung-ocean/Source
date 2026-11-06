clear; clc

domain = 'Oregon_1km';
map = 'Oregon_1km';
expname = 'bio_20261008';
cd(['/data/jungjih/Project/NOPP_Carbon/', domain, '/Results/Output_', expname])

filenums = 1:36;

ot = [];
SST = [];
for fi = 1:length(filenums)
    filenum = filenums(fi);
    fstr = num2str(filenum, '%04i');
    filename = ['vari_', expname, '_', fstr, '.mat'];
    load(filename)
    temp_tmp = squeeze(vari_bio.temp);
    ot = [ot; vari_bio.timenum];
    SST = [SST; temp_tmp(45,:)'];
end

% 1. Parameters
% Maximum growth rates [d^-1]
Vp    = 0.8;   % Phytoplankton
Vpdia = 1.5;   % Diatom

% Temperature-dependent growth parameters
acof = 0.851;
bcof = 0.0633;

Topt_phy = 12;     % Optimum temperature for phytoplankton [deg C]
Topt_dia = 8;      % Optimum temperature for diatoms [deg C]

w_phy = 13;        % Temperature width for phytoplankton [deg C]
w_dia = 13;        % Temperature width for diatoms [deg C]

% 2. Temperature
temp = SST;

% 3. Temperature-dependent growth rates
% Phytoplankton
Vpt = acof .* exp(bcof .* temp) .* ...
      (1 - ((temp - Topt_phy) ./ (w_phy/2)).^2);

% Diatoms
Vptdia = acof .* exp(bcof .* temp) .* ...
         (1 - ((temp - Topt_dia) ./ (w_dia/2)).^2);

% 4. Minimum background growth rate
% Minimum growth rate = 0.01 d^-1
Vpt    = max(0.01, Vpt);
Vptdia = max(0.01, Vptdia);

% 5. Apply prescribed maximum growth rates
Vpt    = min(Vpt, Vp);
Vptdia = min(Vptdia, Vpdia);

% 6. Plot
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])

pp = plot(ot, Vpt, '-g', 'LineWidth', 2);
pd = plot(ot, Vptdia, '-r', 'LineWidth', 2);

plot(ot, zeros(size(ot))+Vp, '--g');
plot(ot, zeros(size(ot))+Vpdia, '--r');

datetick('x', 'mm/dd')
ylabel('Growth rate (d^{-1})');

title('Temperature-dependent Phytoplankton Growth Rate');

ylim([0, 2]);

yyaxis right
set(gca, 'YColor', 'k')
pt = plot(ot, temp, '-k', 'LineWidth', 1);
ylabel('SST (^oC)')

legend([pp, pd, pt], 'Phytoplankton', 'Diatoms', 'SST', 'Location', 'SouthWest');

print(['Vpt_', expname, '_Vp_', num2str(Vp*10, '%02i')], '-dpng')
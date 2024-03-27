%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate tide RMSE at the NOAA tidal stations
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2018; ystr = num2str(yyyy);
mm = 7; mstr = num2str(mm,'%02i');

target_cons = {'M2', 'S2', 'K1', 'O1'};

% SCHISM
start_date = datetime(yyyy,mm,1,0,0,0);
save_interval = hours(1);
time_first = start_date + save_interval;
rundays = 365;
num_output = rundays;
Mobj.time = (time_first:hours(1):start_date+rundays)';
Mobj.rundays = days(Mobj.time(end)-Mobj.time(1));
Mobj.dt = 150;
Mobj.coord = 'geographic';

hgrid_file = '../hgrid.gr3';
%vgrid_file = '/data/jungjih/Models/SCHISM/test_schism/vgrid.in';
Mobj = read_schism_hgrid(Mobj, hgrid_file);
%Mobj = read_schism_vgrid(Mobj, vgrid_file, 'v5.10');

stations.name = {'Adak Island', 'Unalakleet', 'Atka', ...
    'Unalaska', 'Nikolski', 'King Cove', ...
    'Village Cove, St Paul Island', 'Sand Point', ...
    'Nome, Norton Sound'};

stations.id = {'9461380', '9468333', '9461710', ...
    '9462620', '9462450', '9459881', ...
    '9464212', '9459450', ...
    '9468756'};

stations.indices = [499501, 489972, 500090, ...
    529254, 531990, 495277, ...
    803, 827040, ...
    489003]+1; % +1 because these indices are from python

stations.lon = [183.36242676, 199.21200562, 185.82749939, ...
    193.45968628, 191.12869263, 197.67388916, ...
    189.71479797, 199.4956665, ...
    194.56036377];

stations.lat = [51.86064148, 63.875, 52.23194122, ...
    53.87918854, 52.94060898, 55.05989075, ...
    57.12530136, 55.33171844, ...
    64.49461365];

stations.M2_amp = [0.191, 0.138, 0.172, ...
    0.27, 0.262, 0.675, ...
    0.251, 0.733, ...
    0.111];

stations.S2_amp = [0.017, 0.019, 0.032, ...
    0.025, 0.016, 0.224, ...
    0.004, 0.245, ...
    0.014];

stations.K1_amp = [0.419, 0.312, 0.381, ...
    0.338, 0.401, 0.415, ...
    0.289, 0.414, ...
    0.088];

stations.O1_amp = [0.282, 0.175, 0.271, ...
    0.228, 0.268, 0.264, ...
    0.195, 0.269, ...
    0.061];

stations.M2_pha = [80.7, 216.0, 90.8, ...
    80.2, 66.4, 328.2, ...
    95.0, 322.4, ...
    37.7];

stations.S2_pha = [269.4, 280.9, 281.5, ...
    310.0, 327.0, 353.6, ...
    195.8, 349.6 ...
    106.9];

stations.K1_pha = [332.3, 112.2, 336.0, ...
    318.7, 318.1, 284.3, ...
    326.7, 285.4, ...
    146.9];

stations.O1_pha = [309.5, 63.9, 315.6, ...
    306.8, 302.6, 269.9, ...
    312.8, 269.7, ...
    79.0];

ele_all = zeros(length(stations.name), length(Mobj.time));
for oi = 1:num_output
    oistr = num2str(oi);
    file = ['../outputs/out2d_', oistr, '.nc'];
    time = ncread(file, 'time');
    time_date = datetime(datevec(time/60/60/24+start_date));
    index = find(ismember(Mobj.time, time_date));

    for si = 1:length(stations.name)
        ele_all(si,index) = ncread(file, 'elevation', [stations.indices(si), 1], [1, Inf]);
    end
end

model_amp_all = []; model_pha_all = [];
for si = 1:length(stations.name)
    data = ele_all(si,:);
    interval = 1;
    lat = stations.lat(si);
    output = [stations.name{si}, '.txt'];
    
    [tidestruc, pout] = t_tide(data, ...
        'interval', interval, ...
        'latitude', lat, ...
        'start', datenum(time_first), ...
        'secular', 'mean', ...
        'rayleigh', 1, ...
        'output', output, ...
        'shallow', 'M10', ...
        'error', 'wboot', ...
        'synthesis', 1);

    for ci = 1:length(target_cons)
        cons = target_cons{ci};
        index = find(ismember(tidestruc.name, {cons})==1);
        model_amp_all(si,ci) = tidestruc.tidecon(index,1);
        model_pha_all(si,ci) = tidestruc.tidecon(index,3);
    end
end

for si = 1:length(stations.name)
    for ci = 1:length(target_cons)
        cons = target_cons{ci};
        obs_amp = eval(['stations.', cons, '_amp(si)']);
        obs_pha = eval(['stations.', cons, '_pha(si)']);

        model_amp = model_amp_all(si,ci);
        model_pha = model_pha_all(si,ci);

        Ahat = model_amp*cosd(model_pha) + 1i*model_amp*sind(model_pha);
        Bhat = obs_amp*cosd(obs_pha) + 1i*obs_amp*sind(obs_pha);

        D = Ahat - Bhat;
        
        RMSE(si,ci) = sqrt(1/2)*abs(D);
    end
end

figure; hold on;
set(gcf, 'Position', [1 1 1200 900])
tiledlayout(2,2);
for ci = 1:length(target_cons)
    nexttile(ci);
    plot_map('Bering', 'mercator', 'l');

    scatterm(stations.lat, stations.lon, 300, RMSE(:,ci), 'filled')
    caxis([0 0.17])

    title(['RMSE averaged over the period (', target_cons{ci}, ')'])
end
c = colorbar;
c.Layout.Tile = 'east';
c.Title.String = 'm';

print('RMSE_major4' ,'-dpng')
clear; clc; close all

yyyy_all = 2021:2024;
ysstr = num2str(yyyy_all(1));
yestr = num2str(yyyy_all(end));
mm_all = 4:9;
msstr = num2str(mm_all(1));
mestr = num2str(mm_all(end));
hlimit = 200;
hlstr = num2str(hlimit);

filename_data = ['data_glider_', ysstr, '_', yestr, '_', msstr, '_', mestr, '_', hlstr, 'm.mat'];
if ~exist(filename_data)
    ETOPO = load_ETOPO('US_west');

    filepath = '/data/jungjih/Observations/Glider_ERDDAP/';
    [filenames, timenums] = load_glider_filenames;
    timevecs = datevec(timenums);
    yindex = find(timevecs(:,1) >= yyyy_all(1) & timevecs(:,1) <= yyyy_all(end));
    filenames = filenames(yindex);

    lat = []; lon = []; timenum = []; profile = []; depth = [];
    do = []; temp = []; salt = []; p = []; SA = []; pt0 = []; pden = []; 
    sigma_theta = []; spiciness0 = []; n2 = []; n2_surf10 = []; n2_bot10 = []; BML = [];
    for fi = 1:length(filenames)
        filename = filenames{fi};
        file = [filepath, filename];
        type = 'ERDDAP';
        glider = load_glider(file, type);

        lat_tmp = glider.lat;
        lon_tmp = glider.lon;
        h_tmp = interp2(ETOPO.lat, ETOPO.lon, ETOPO.h, lat_tmp, lon_tmp);
        timenum_tmp = glider.timenum;
        timevec_tmp = datevec(timenum_tmp);

        index = find(...
            timevec_tmp(:,2) >= mm_all(1) & ...
            timevec_tmp(:,2) <= mm_all(end) & ...
            h_tmp < hlimit); % over continental shelf break (~ 200 m)

        lat = [lat; glider.lat(index)];
        lon = [lon; glider.lon(index)];
        timenum = [timenum; glider.timenum(index)];
        profile = [profile; glider.profile(index)];
        depth = [depth; -abs(glider.depth(index))];
        do = [do; glider.do(index)];
        temp = [temp; glider.temp(index)];
        salt = [salt; glider.salt(index)];
        p = [p; glider.p(index)];
        SA = [SA; glider.SA(index)];
        pt0 = [pt0; glider.pt0(index)];
        pden = [pden; glider.pden(index)];
        sigma_theta = [sigma_theta; glider.sigma_theta(index)];
        spiciness0 = [spiciness0; glider.spiciness0(index)];
        n2 = [n2; glider.n2(index)];
        n2_surf10 = [n2_surf10; glider.n2_surf10(index)];
        n2_bot10 = [n2_bot10; glider.n2_bot10(index)];
        BML = [BML; glider.BML(index)];
    end
    h = interp2(ETOPO.lat, ETOPO.lon, ETOPO.h, lat, lon);
    save(filename_data, '*');
else
    load(filename_data)
end
asdfasdf

ONI = load_ONI(timenum);

% DO QC and near bottom data
profile_unique = unique(profile);
for pi = 1:length(profile_unique)
    profile_tmp = profile_unique(pi);
    index = find(profile == profile_tmp);
    timenum_tmp = timenum(index);
    lat_tmp = lat(index);
    lon_tmp = lon(index);
    h_tmp = h(index);
    depth_tmp = depth(index);
    do_tmp = do(index);
    pden_tmp = pden(index);
    sigma_theta_tmp = sigma_theta(index);
    n2_tmp = n2(index);
    index2 = find(do_tmp < 61);
    depth_tmp2 = depth_tmp(index2);
    if max(depth_tmp2) > -10
        do(index) = NaN;
        disp(['DO in profile ', num2str(profile_tmp), ' is removed'])
    end
end

% Fitting
x = [SA pt0];
x_nan = isnan(x);
x_nan_sum = sum(x_nan,2);
y = do;
y_nan = isnan(y);

hbins = [0:10:200];

params_all = NaN([length(hbins)-1, 3]);
meanstd1 = NaN([length(hbins)-1, 2]);
meanstd2 = NaN([length(hbins)-1, 2]);
for hi = 1:length(hbins)-1
    index = find(...
        x_nan_sum == 0 & ...
        y_nan == 0 & ...
        lat > 44.6 &  lat < 44.7 & ...
        h > hbins(hi) & ...
        h <= hbins(hi+1));

    xdata = x(index,:);
    xdata1 = xdata(:,1);
    xdata1_mean = mean(xdata1);
    xdata1_std = std(xdata1);
    if xdata1_std == 0
        continue
    end
    xdata1_norm = (xdata1-xdata1_mean)./xdata1_std;
    xdata2 = xdata(:,2);
    xdata2_mean = mean(xdata2);
    xdata2_std = std(xdata2);
    if xdata2_std == 0
        continue
    end
    xdata2_norm = (xdata2-xdata2_mean)./xdata2_std;
    xdata_norm = [xdata1_norm xdata2_norm];
    do_binomial = y(index);
    do_binomial(do_binomial < 61) = 1;
    do_binomial(do_binomial >= 61) = 0;
    ydata = do_binomial;

    [params, logisticfun] = calc_LR(xdata_norm, ydata, 1);
    params_all(hi,:) = params;
    meanstd1(hi,:) = [xdata1_mean xdata1_std];
    meanstd2(hi,:) = [xdata2_mean xdata2_std];
end
filename_fit = ['fit_do_glider_LR_', ysstr, '_', yestr, '_', msstr, '_', mestr, '_', hlstr, 'm.mat'];
save(filename_fit, 'filenames', 'yyyy_all', 'mm_all', 'hlimit', 'hbins', 'params_all', 'logisticfun', 'meanstd1', 'meanstd2')

asdf

x1 = xdata(:,1);
x2 = xdata(:,2);

figure; hold on; grid on;
h1 = scatter(x1(ydata==0),x2(ydata==0),50, [.7 .7 .7], 'x'); % black dots for 0
h2 = scatter(x1(ydata==1),x2(ydata==1),50,'ok','filled'); % white dots for 1
xlabel('Absolute salinity (g/kg)');
ylabel('Potential temperature (^oC)');
xlim([25 35])
ylim([0 20])

ax = axis;
xvals = linspace(ax(1),ax(2),100);
yvals = linspace(ax(3),ax(4),100);
[xx,yy] = meshgrid(xvals,yvals);

% construct regressor matrix
X = [xx(:) yy(:)];
X(:,end+1) = 1;

% evaluate model at the points (but don't perform the final thresholding)
outputimage = reshape(logisticfun(X*params'),[length(yvals) length(xvals)]);

h3 = imagesc(outputimage,[0 1]); % the range of the logistic function is 0 to 1
set(h3,'XData',xvals,'YData',yvals);
colormap(jet(20));
colorbar;

% visualize the decision boundary associated with the model
% by computing the 0.5-contour of the image
[c4,h4] = contour(xvals,yvals,outputimage,[.5 .5]);
set(h4,'LineWidth',2,'LineColor','b'); % make the line thick and blue

% send the image to the bottom so that we can see the data points
uistack(h3,'bottom');

% send the contour to the top
uistack(h4,'top');

l = legend([h1 h2],{'DO \geq 61 \mumol/kg', 'DO < 61 \mumol/kg'},'Location','SouthOutside');
l.NumColumns = 2;
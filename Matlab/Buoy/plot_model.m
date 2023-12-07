clear; clc

station = '남해동부';

switch station
    case '통영'
        load TY.mat
    case '생일도'
        load SI.mat
    case '남해동부'
        load SE.mat
end

yyyy = 2016; ystr = num2str(yyyy)

vari = u_surf_target;

time = datenum(yyyy,1,1):datenum(yyyy,12,31);
xticks = datenum(yyyy, 1:12, 1);

figure; hold on; grid on
u_movmean = movmean(vari, 14, 'omitnan', 'Endpoints', 'fill')*100;
plot(time, u_movmean, 'k')

yp = (u_movmean + abs(u_movmean))/2;
yn = (u_movmean - abs(u_movmean))/2;

area(time,yp, 'FaceColor', 'r');
area(time,yn, 'FaceColor', 'b');

set(gca, 'xtick', xticks)
datetick('x', 'mm', 'keepticks')
xlabel('Month')
ylabel('m/s')
ylim([-20 20])

title(['Zonal velocity ', station, ' ', ystr])

set(gca, 'FontSize', 15)
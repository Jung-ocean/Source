clear; clc; close all

wind = [-2, -2];
current = [2, 1];
cor = -(wind+current);
drift = 2*[cosd(90) -sind(90); sind(90) cosd(90)]*cor';

figure; hold on; grid on;
axis equal;

qw = quiver(0,0,wind(1), wind(2), 'k', 'LineWidth', 2, 'MaxheadSize', 0.5);
qc = quiver(0,0,current(1), current(2), 'b', 'LineWidth', 2, 'MaxheadSize', 0.5);
qcor = quiver(0,0,cor(1), cor(2), 'r', 'LineWidth', 2, 'MaxheadSize', 1);
qd = quiver(0,0,drift(1), drift(2), 'Color', [.7 .7 .7], 'LineWidth', 2, 'MaxheadSize', 1);

xlim([-4 4])
ylim([-4 4])

xticklabels('')
yticklabels('')

l = legend([qw, qc, qcor, qd], 'Wind stress', 'Current stress', 'Coriolis', 'Sea ice drift');
l.Location = 'NorthEast';
l.FontSize = 15;

set(gcf, 'Position', [1 200 800 800])
print('example1', '-dpng')

wind = [-2, -2];
current = [2, 1];
prsgrd = [1, -1]
cor = -(wind+current+prsgrd);
drift = 2*[cosd(90) -sind(90); sind(90) cosd(90)]*cor';

figure; hold on; grid on;
axis equal;

qw = quiver(0,0,wind(1), wind(2), 'k', 'LineWidth', 2, 'MaxheadSize', 0.5);
qc = quiver(0,0,current(1), current(2), 'b', 'LineWidth', 2, 'MaxheadSize', 0.5);
qp = quiver(0,0,prsgrd(1), prsgrd(2), 'g', 'LineWidth', 2, 'MaxheadSize', 0.5);
qcor = quiver(0,0,cor(1), cor(2), 'r', 'LineWidth', 2, 'MaxheadSize', 1);
qd = quiver(0,0,drift(1), drift(2), 'Color', [.7 .7 .7], 'LineWidth', 2, 'MaxheadSize', 1);

xlim([-4 4])
ylim([-4 4])

xticklabels('')
yticklabels('')

l = legend([qw, qc, qp, qcor, qd], 'Wind stress', 'Current stress', 'Pressure gradient', 'Coriolis', 'Sea ice drift');
l.Location = 'NorthEast';
l.FontSize = 15;

set(gcf, 'Position', [1 200 800 800])
print('example2', '-dpng')
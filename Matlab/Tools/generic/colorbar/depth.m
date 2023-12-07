function c = depth(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
depth = load('depth.mat');
c = depth.mymap;

end
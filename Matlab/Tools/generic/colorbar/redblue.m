function c = redblue(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
redbluemap = load('redblue.mat');
c = redbluemap.mymap;

end
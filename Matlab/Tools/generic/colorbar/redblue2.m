function c = redblue2(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
redbluemap2 = load('redblue2.mat');
c = redbluemap2.mymap;

end
function c = msl(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
mslmap = load('msl.mat', 'msl');
c = mslmap.msl;

end
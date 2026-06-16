function [i,j,dist]=closest(X,Y,xi,yi)
%       [I,J]=CLOSEST(X,Y,XI,YI)
%	finds I,J indicies of coordinate arrays X and Y that give the 
%	point(s) closest to the input points(s) XI,YI.
%	The point(s) of interest XI,YI may be specified as a pair
%	points, a pair of vectors, or a matrix XY with two columns
%	i.e. [I,J]=CLOSEST(X,Y,XY).  This last option allows the
%	direct output of GINPUT to be used as the input XY,
%	e.g. [I,J]=CLOSEST(X,Y,GINPUT)
%
%	John Wilkin, 4 November 93

if nargin == 3
  yi = xi(:,2);
  xi = xi(:,1);
end

for k=1:length(xi)
  dist = abs( (xi(k)-X) + sqrt(-1)*(yi(k)-Y));
  [ii,jj] = findm(dist==min(dist(:)));
  %=========== J. Jung 2019-04-22
  if length(ii) > 1
      ii = ii(1);
      jj = jj(1);
  end
  %===========
  i(k) = ii;
  j(k) = jj;
  dist = min(dist(:));
end

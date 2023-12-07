function str = basedate2str(gd)
% Create a COARDS "days since..." base date string from a gregorian date
% vector 
%
% str = basedate2str(gd)
%
% gd is a 6-element Gregorian date vector

t = datenum(gd(1),gd(2),gd(3),gd(4),gd(5),gd(6));

xx = datestr(t, 6);
str = ['days since '  datestr(t, 10) '-' xx(1:2) '-' xx(4:5) ...
      ' ' datestr(t, 13)];

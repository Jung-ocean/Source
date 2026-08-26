function [rx0,ry0] = rfactor0(h_in)
% This function calculates the r factors of a depth array
%   Detailed explanation goes here
dhx = -(diff(h_in,1,1));   % written as h_1 - h_2
dhy = -(diff(h_in,1,2));
hsmx = h_in(1:end-1,:) + h_in(2:end,:);
hsmy = h_in(:,1:end-1) + h_in(:,2:end);
rx0 = abs(dhx./hsmx);
ry0 = abs(dhy./hsmy);
end
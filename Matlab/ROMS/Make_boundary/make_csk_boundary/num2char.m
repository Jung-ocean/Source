function [nc] = num2char(nn,num)

% function char_num = num2char(integer, number of char)
% example : [000012] = num2char(12,6)
% programmed by JJ

for i=1:length(nn)

   a = sprintf('%d',nn(i));
   b(1:num) = '0';
   na = length(a);
   if na > num
      error('value is less than number of char')
   end
   b(num-na+1:num) = a;
   nc(i,:) = b;
end


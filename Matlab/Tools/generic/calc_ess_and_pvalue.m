function [R, P, P_ess, ESS] = calc_ess_and_pvalue(x,y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function calculates Pearson correlation coefficient, p-value, 
% effective sample size (ESS), and p-value using ESS which is appropriate 
% for significance tests of the correlation between two time series
% 
% Reference: Bretherton et al. (1999)
%
% J. Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tx = length(x);
Ty = length(y);
if length(Tx) == length(Ty)
    T = Tx;
else
    error('Lengths of two data are different')
end

% Pearson correlation coefficient
[R, P] = corrcoef(x, y);
R = R(1,2);
P = P(1,2);

% Calculate effective sample size (ESS)
[rhox,lags] = xcorr(x, 'normalize');
[rhoy,lags] = xcorr(y, 'normalize');
index1 = find(lags == -(T-1));
index2 = find(lags == (T-1));
tau = [lags(index1):lags(index2)]';
numerator = T;
denominator = sum( (1-abs(tau)/T).*rhox.*rhoy );
ESS = numerator/denominator;

% p-value using effective sample size
% https://www.mathworks.com/matlabcentral/answers/20536-how-to-get-p-val-from-correlation-coefficient-and-number-of-sample
N = ESS;
t = sqrt(N-2).*R./sqrt(1-R.^2);
s = tcdf(t,N-2);
P_ess = 2*min(s,1-s);
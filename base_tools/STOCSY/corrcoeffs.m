function [CCXY,pXY]=corrcoeffs(X,Y,CCmetric)
% Description: This function calculates pair-wise correlation
% coefficients between all variables of X matrix and a single variable of interest
% of Y matrix
%  Input: X - input matrix of 
%         Y - a column vector
%         CCmetric defines either 'spearman' or 'pearson' cc measures
%    Output:
%         CCXY - a vector of cc values between all variables of X matrix and a single variable of interest
%         of Y matrix
%         pXY - a vector of p-values for testing the hypothesis of no correlation
% Author: Kirill Veselkov, Imperial College 2010. 

[nsmpls,nvarX]  = size(X);
[nsmplsY,nvarY] = size(Y);

if nsmpls~=nsmplsY
    error('The number of samples in data matrix X and Y must be equal for the calculation of the corrcoef measure');
end

if strcmp(CCmetric,'spearman')
    X = lineup(X,1);
    Y = lineup(Y,1);
end

stdX   = std(X)';
stdY   = std(Y)';
meanSp = mean(X);
X      = X-(meanSp(ones(1,nsmpls),:));
CovXY  = X'*(Y-mean(Y))./(nsmpls-1);
CCXY   = CovXY./(stdX*stdY);

if nargout==2
  % Tstat=Inf and p=0 if abs(r)==1
   denom = (1 - CCXY.^2);
   Tstat = Inf + zeros(size(CCXY));
   Tstat(CCXY<0) = -Inf;
   t = denom>0;
   CCtemp = CCXY(t);
   Tstat(t) = CCtemp .* sqrt((nsmpls-2) ./ denom(t));
   pXY = 2*tpvalue(-abs(Tstat),nsmpls-2);
end

function p = tpvalue(x,v)
%TPVALUE Compute p-value for t statistic

normcutoff = 1e7;
if length(x)~=1 && length(v)==1
   v = repmat(v,size(x));
end

% Initialize P to zero.
p=zeros(size(x));

% use special cases for some specific values of v
k = find(v==1);
if any(k)
    p(k) = .5 + atan(x(k))/pi;
end
k = find(v>=normcutoff);
if any(k)
    p(k) = 0.5 * erfc(-x(k) ./ sqrt(2));
end

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1
k = find(x ~= 0 & v ~= 1 & v > 0 & v < normcutoff);
if any(k),                            % first compute F(-|x|)
    xx = v(k) ./ (v(k) + x(k).^2);
    p(k) = betainc(xx, v(k)/2, 0.5)/2;
end

% Adjust for x>0.  Right now p<0.5, so this is numerically safe.
k = find(x > 0 & v ~= 1 & v > 0 & v < normcutoff);
if any(k), p(k) = 1 - p(k); end

p(x == 0 & v ~= 1 & v > 0) = 0.5;

% Return NaN for invalid inputs.
p(v <= 0 | isnan(x) | isnan(v)) = NaN;
function [X,a] = normalise(X,p)
% [X] = normalise(X,p) - normalise rows of 2D matrix
%
% X = (nXk) X data matrix
% p = power to normalise to or array to normalise to
% Written 281003 HK
% altered 16/10/05 HK to normalise to other variable
% (c) 2003 Dr. Hector Keun, Imperial College, London
[n,k] = size(X);
[i,j] = size(p);
if i*j == 1
    if p==0
        med =median(X);
        dummy = X./med(ones(1,n),:);
        a = median(dummy');
    else
    a = sum((X'.^p).^(1/p));
    end
%a = norm(X([1:end],:))
X = X./a(ones(k,1),:)';
else
a=p;
X = X./a(ones(k,1),:)';
end

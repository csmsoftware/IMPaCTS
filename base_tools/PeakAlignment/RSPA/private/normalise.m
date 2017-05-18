function [X,factors,normRef]=normalise(X,method,normRef)
% Removing dilutions between biofluid samples (normalisation of spectra)

% Reference: "Probabilistic quotient normalization as robust method...
% to account for dilution of complex biological mixtures". 

% X [observation dimension]
% method - total area (method='total')
% or qoutient probabistic method (method='prob')
% K.Veselkov, Imperial College London

if nargin<2
    error('incorrect number of input parameters');
end


[obs dim]=size(X);
factors=repmat(NaN,[1 obs]);
for i=1:obs
    factors(i)=sum(X(i,:));
    X(i,:)=X(i,:)./factors(i);
end



switch method
    case 'total'
        return
    case 'prob'
        X(0==X)=0.00000001;
        if nargin<3
            normRef=median(X);
%            normRef=X(1,:);
        end
        F=X./(normRef(ones(1,obs),:));
        for i=1:obs
            X(i,:)=10000.*X(i,:)./median(F(i,:));
             factors(i)=(factors(i)*median(F(i,:)))./10000;
        end
        return
end
return;
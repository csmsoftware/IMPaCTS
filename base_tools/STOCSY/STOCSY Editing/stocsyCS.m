function[cor cov pval pcor]=stocsyCS(X,peak,signif,ppm)
% calculates STOCSY correlation stats (and covariance if required) and
% plots results if ppm included as argument
%
% X = (mxn)  spectral data
% peak = (1x1) index of to drive correlation from
% ppm = (1xn) optional either ppm scale OR 1:n must include for plot to be
%       generated
%
% CJS 070409
% 100510 modified to work when X does not include peak index

if(isstruct(peak)); peak=peak.DataIndex; end
if(nargin<3||isempty(signif)); signif=0.05; end

if(length(peak)~=1); 
    driver=peak;
else
    driver=X(:,peak);
end

pval=zeros(1,size(X,2));
cov=zeros(1,size(X,2));

cor=zeros(1,size(X,2));
for i=1:1:size(X,2)
    [r pv] = corrcoef(X(:,i),driver);
    cor(i) = r(1,2);
    pval(i)= pv(1,2);
    [p] = covCS([X(:,i) driver]);
    cov(i) = p(1,2);
end

pcor=cor; pcor(pval>signif)=0;

% if(nargout==1&&ismember('cor',outarg))
%     out.driver=peak;
%     out.signif=signif;
%     out.cor=cor;
%     out.cov=cov;
%     out.pval=pval;
%     out.pcor=pcor;
% end


if(nargin>3)
    figure;colorplotCS(ppm,cov,cor.^2,0,1)
    set(gca,'Xdir','reverse')
end

function[cov]=covCS(X)

a = size(X,1);
b = X - repmat(sum(X,1)/a,a,1);  % Remove mean
cov = (b' * b) / (a-1);


function [pv,Q2p,R2p,m1] = JTPpermutate(X,Y,p,pcomp,ocomp,cv,scaling,model_type)

% [pv,Q2p,R2p,m1] = JTPpermutate(X,Y,p,pcomp,ocomp)
%
% Performs p permutations of the Y variable and returns the p-value (pv)
% for the model.
%
% Ouputs: pv=p-value
%       pv : p-value (non-parametric)
%       Q2p: vector of Q2 values for all permutations.
%       R2p: vector of R2 values for all permutations.
%       m1 : Canononical OrthPLS model.
%
% p = number of permutations
% pcomp = number of predictive component
% cv = cross-validation (7 for seven-fold)
% scaling = preprocessing: mc, for mean-centering only; uv for unit variance scaling
 
if strcmp(scaling, 'uv')
    uv = 'uv';
    mc = 'mc';
elseif strcmp(scaling, 'mc')
    uv = 'no';
    mc = 'mc';
elseif strcmp(scaling, 'pa')
    uv = 'pa';
    mc = 'mc';    
else
    uv = 'no';
    mc = 'no';
end


[nY,~] = size(Y);     

% Preprocessing now to save time
%Xuv = JTPscale(X,'r', scaling);
%Yuv = JTPscale(Y,'r', scaling);
%Xmc = mjrScale(X,'mc','no'); Xmc = Xmc.X;

Q2p = zeros(1,p);
R2p = zeros(1,p);
r = zeros(1,p);

progBar = DSprogressBar(p);

for i = 1:p
    progBar(i); 

    Yp=Y(randperm(nY),:);
	%m1=o2pls(X,Yp,'no',pcomp,ocomp,0,cv);
    m1 = mjrMainO2pls(X, Yp, pcomp, ocomp,0, cv, 'nfold', mc, uv, [], model_type, 'y', 'standard',[]);
    Q2p(i)=m1.cv.Q2Yhat(pcomp + ocomp);
    R2p(i)=m1.o2plsModel.R2Yhat(pcomp + ocomp);        
	rm=corrcoef(Yp,Y);
	r(i)=rm(1,2)^2;
end

%m1=o2pls(X,Y,scaling,pcomp,ocomp,0,cv);
m1 = mjrMainO2pls(X, Y, pcomp, ocomp,0, cv, 'nfold', mc, uv, [], model_type, 'y', 'standard',[]);

I=find(Q2p>=m1.cv.Q2Yhat(pcomp + ocomp));
t=isempty(I);

if t==1
    pv=1/p;
else
	pv=length(I)/p;
end

% Display the results in a SIMCA-like way 
% figure;
% hold on
% 
% %lines of best fit.
% % Fit regression line (Q2).
% [slope, intercept] = JTPregressThroughPoint(r, Q2p, 1, m1.cv.Q2Yhat(pcomp + ocomp));
% 
% linFit = [min(r) 1];
% plot(linFit, linFit.*slope+intercept, '-b');
% 
% % Fit regression line (R2).
% [slope, intercept] = JTPregressThroughPoint(r, R2p, 1, m1.o2plsModel.R2Yhat(pcomp + ocomp));
% 
% linFit = [min(r) 1];
% plot(linFit, linFit.*slope+intercept, '-g');
% 
% plot(r,Q2p,'.b')
% plot(r,R2p,'.g')
% 
% plot(m1.cv.Q2Yhat(pcomp + ocomp),'*b')
% plot(m1.o2plsModel.R2Yhat(pcomp + ocomp),'*g')
% xlabel('Correlation with design')
% ylabel('Q^2 and R^2')

m1.perm.pval = pv;
m1.perm.ntests = p;
m1.perm.Q2p = Q2p;
m1.perm.R2p = R2p;
m1.perm.r = r;

% Calculate correlation and covariance to Y

% Loadings for predictive component
% nc = size(Y,2);
% nv = size(X,2);
% 
% corY = NaN(nc,nv);
% pvalcorY = NaN(nc,nv);
% covY = NaN(nc,nv);
% 
% for c = 1:nc
%     Ymc = mjrScale(Y(:,c),'mc','no'); Ymc = Ymc.X;
% 
%     [corY(c,:),pvalcorY(c,:),covY(c,:)] = corCovCalc(Xmc,Ymc,'Pearson');
% end
% 
% m1.association_XY.cov = covY;
% m1.association_XY.cor = corY;
% m1.association_XY.cor_p_value = pvalcorY;


end

function [slope, intercept] = JTPregressThroughPoint(x, y, x0,y0)

slope = (x'-x0)\(y'-y0);

intercept = y0-slope*x0;

end


function[corrVect,pval,covVect] = corCovCalc(X,Y,method)

% calculate correlation and covariance
    
if(nargin<3); method = 'pearson'; end

[~,n]=size(X);
remainder=mod(n,1000);

[corrVect,pval] = corr(X,Y,'type',method);
corrVect = corrVect'; pval = pval';
cov(X,repmat(Y,1,size(X,2)));

i=0;
if(floor(n/1000)>0)
    for i = 1:floor(n/1000)
        start=(1+(i-1)*1000);
        stop=(i*1000);
        covVect( start:stop)=(1/(length(Y)-1))*Y'*X(:,start:stop);
    end
end

start=(1+(i)*1000);
stop=(i*1000+remainder);
covVect( start:stop)=(1/(length(Y)-1))*Y'*X(:,start:stop);

end
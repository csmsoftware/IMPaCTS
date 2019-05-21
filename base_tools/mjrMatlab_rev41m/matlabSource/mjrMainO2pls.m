function modelMain=mjrMainO2pls(X,Y,A,oax,oay,nrcv,cvType,centerType,scaleType,cvFrac,modelType,cvPred,orth_plsType,largeBlockSize)
% X= X matrix (features), rows are observations, columns are features
% Y= Y matrix/vector (predictors), rows are observations, columns are
%           features
% A= number predictive components (integer)
% oax= number of Y-orthogonal components (orth. comps in X)  (integer)
% oay= number of X-orthogonal components (orth. comps in Y)   (integer)
% nrcv= number of cross-validation rounds (integer)
% cvType = 'nfold' for n-fold, 'mccv' for monte-carlo, 'mccvb' for monte-carlo class -balanced
% centerType = 'mc' for meancentering, 'no' for no centering
% scaleType = 'uv' for scaling to unit variance, 'pa' for pareto, 'no' for no scaling
% cvFrac = fraction of samples used for modelling (if cvType is 'mc' or 'mb' - otherwise not used
% modelType = 'da' for discriminant analysis, 're' for regression - if 'da'
%               sensitivity and specificity will be calculated
% cvPred='x','y','b','0' - which cross validated blocks to return/collect (might be memory demanding to save)
% for the normal OrthPLS algorithm
%
% orth_plsType = 'large' for approximation of predictive weights in case of large Y matrix, or 'standard'
% largeBlockSize= if orth_plsType='large', then this will set the block size used in the approximation, choose as large number as possible (e.g ~500), not used if type is not 'large, set to e.g. [] in this case.
%Reference:
%
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
release='revision r42';

[N,m]=size(Y);
Yorig = Y;

% some minor checks....
if(strcmp(modelType,'da'))
    drRule='max'; %move to arg... %this is a parameter for DA decision rule
    
    tmp=unique(Y);
    if(all(tmp==[0; 1]))
        classVect=reDummy(Y);
        if(m==1)
            Y=getDummy(Y);
        end
    elseif(all(mod(Y,1)==0) && m==1)
        classVect=Y;
        Y=getDummy(Y+1);
    else
        error('modelType is da, but Y appears to be neither dummy (1 0) matrix nor a vector of (integer) class labels');
    end
    nclasses=length(unique(classVect));
end

if(strcmp(cvType,'mccvb') && ~strcmp(modelType,'da'))
    error('Class balanced monte-carlo cross validation only applicable to da modelling');
end

if(~any([strcmp(cvType,'mccvb'), strcmp(cvType,'mccv'), strcmp(cvType,'nfold')]))
    error([cvType, '- unknown Cross-validation type']);
end


Yhat=ones(size(Y))*NaN;
YhatDaSave=cell(1);
Xhat=ones(size(X))*NaN;
pressxVars=cell(1,1);
pressyVars=cell(1,1);
pressxVarsTot=cell(1,1);
pressyVarsTot=cell(1,1);
cvTestIndex=[];
cvTrainingIndex=[];
Xmc = mjrScale(X,'mc','no'); Xmc = Xmc.X;

%h = waitbar(0,['Please wait... cv round:',num2str(1),' of ',num2str(nrcv)]);

for( icv = 1:nrcv)
    %disp(['Cross-validation round: ',num2str(icv),'...']);
    %waitbar((icv-1)/nrcv,h,['Please wait... cv round:',num2str(icv),' of ',num2str(nrcv)]);
    
    cvSet=mjrGetCvSet(X,Y,cvFrac,cvType,nrcv,icv);
    cvTestIndex=[cvTestIndex;cvSet.testIndex];
    cvTrainingIndex=[cvTrainingIndex;cvSet.trainingIndex];
    
    cvSet=mjrScaleCvSet(cvSet,centerType,scaleType);
    if exist('largeBlockSize')
        model=mjrO2pls(cvSet.xTraining,cvSet.yTraining,A,oax,oay,orth_plsType,largeBlockSize);
    else
        model=mjrO2pls(cvSet.xTraining,cvSet.yTraining,A,oax,oay,orth_plsType);
    end
    
    ssy=sum(sum((cvSet.yTest).^2));
    ssyVars=(sum((cvSet.yTest).^2));
    ssx=sum(sum((cvSet.xTest).^2));
    ssxVars=(sum((cvSet.xTest).^2));
    
    if(icv==1)
        ssyTot=ssy;
        ssyVarsTot=ssyVars;
        ssxTot=ssx;
        ssxVarsTot=ssxVars;
    else
        ssyTot=ssyTot+ssy;
        ssyVarsTot=ssyVarsTot+ssyVars;
        ssxTot=ssxTot+ssx;
        ssxVarsTot=ssxVarsTot+ssxVars;
    end
    
    
    
    for( ioax = 1:oax+1)
        for( ioay = 1:oay+1)
            %yhat
            modelPredy=mjrO2plsPred(cvSet.xTest, cvSet.yTest, model,ioax-1,ioay-1,'x');
            %xhat
            modelPredx=mjrO2plsPred(cvSet.xTest, cvSet.yTest, model,ioax-1,ioay-1,'y');
            
            pressy(ioax,ioay)=sum(sum((cvSet.yTest-modelPredy.Yhat).^2));
            pressyVars{ioax,ioay}=(sum((cvSet.yTest-modelPredy.Yhat).^2));
            pressx(ioax,ioay)=sum(sum((cvSet.xTest-modelPredx.Xhat).^2));
            pressxVars{ioax,ioay}=(sum((cvSet.xTest-modelPredx.Xhat).^2));
            
            
            if((icv==1))
                pressyTot(ioax,ioay)=pressy(ioax,ioay);
                pressyVarsTot{ioax,ioay}=pressyVars{ioax,ioay};
                pressxTot(ioax,ioay)=pressx(ioax,ioay);
                pressxVarsTot{ioax,ioay}=pressxVars{ioax,ioay};
            else
                pressyTot(ioax,ioay)=pressyTot(ioax,ioay)+pressy(ioax,ioay);
                pressyVarsTot{ioax,ioay}=pressyVarsTot{ioax,ioay}+pressyVars{ioax,ioay};
                pressxTot(ioax,ioay)=pressxTot(ioax,ioay)+pressx(ioax,ioay);
                pressxVarsTot{ioax,ioay}=pressxVarsTot{ioax,ioay}+pressxVars{ioax,ioay};
            end
            
            
            %if 'da' save Yhat for all rounds
            if(strcmp(modelType,'da'))
                if(icv==1)
                    YhatDaSave{ioax,ioay}=[];
                end
                tmp=mjrRescale(cvSet.scaleY,modelPredy.Yhat);
                YhatDaSave{ioax,ioay}=[YhatDaSave{ioax,ioay};tmp.X];
            end
            
            %if highest number of oscs - save Yhat and Xhat
            if(ioax==oax+1 && ioay==oay+1)
                if(icv==1)
                    Yhat=[];
                    Xhat=[];
                    YhatRaw=[];%MJR - this is not resacaled
                    XhatRaw=[];%MJR - this is not resacaled
                end
                if(cvPred=='y' || cvPred=='b')
                    tmp=mjrRescale(cvSet.scaleY,modelPredy.Yhat);
                    Yhat=[Yhat;tmp.X];
                    YhatRaw=[YhatRaw;modelPredy.Yhat];
                end
                if(cvPred=='x' || cvPred=='b')
                    tmp=mjrRescale(cvSet.scaleX,modelPredx.Xhat);
                    Xhat=[Xhat;tmp.X];
                    XhatRaw=[XhatRaw;modelPredx.Xhat];
                end
            end
            
        end
        
    end
    
    
end %end icv

%waitbar(icv/(nrcv),h,'finishing up...');

[scaleX]=mjrScale(X,centerType,scaleType);
[scaleY]=mjrScale(Y,centerType,scaleType);
if exist('largeBlockSize')
    modelMain.o2plsModel=mjrO2pls(scaleX.X,scaleY.X,A,oax,oay,orth_plsType,largeBlockSize);
else
    modelMain.o2plsModel=mjrO2pls(scaleX.X,scaleY.X,A,oax,oay,orth_plsType);
end

modelMain.cv.Yhat=Yhat;
modelMain.cv.Xhat=Xhat;
if(cvPred=='y' || cvPred=='b')
    modelMain.cv.Tcv=YhatRaw*modelMain.o2plsModel.C*modelMain.o2plsModel.Bts{oax+1,oay+1}; %This is based on OC code
end

if(cvPred=='x' || cvPred=='b')
    modelMain.cv.Ucv=XhatRaw*modelMain.o2plsModel.W*modelMain.o2plsModel.Bus{oax+1,oay+1}; %this is based on OC code
end
modelMain.cv.Q2Yhat=[];
modelMain.cv.Q2Xhat=[];
modelMain.cv.Q2YhatVars=cell(1,1);
modelMain.cv.Q2XhatVars=cell(1,1);

for( ioax = 1:oax+1)
    for( ioay = 1:oay+1)
        modelMain.cv.Q2Yhat(ioax,ioay)=1-pressyTot(ioax,ioay)./ssyTot;
        modelMain.cv.Q2Xhat(ioax,ioay)=1-pressxTot(ioax,ioay)./ssxTot;
        modelMain.cv.Q2YhatVars{ioax,ioay}=1-pressyVarsTot{ioax,ioay}./ssyVarsTot;
        modelMain.cv.Q2XhatVars{ioax,ioay}=1-pressxVarsTot{ioax,ioay}./ssxVarsTot;
    end
end

modelMain.cv.cvTestIndex=cvTestIndex;
modelMain.cv.cvTrainingIndex=cvTrainingIndex;

if(strcmp(modelType,'da'))
    
    %get sens/spec for each y-orth component... eval of model
    for( i = 1:oax+1) %we would have no osc comps for dummy matrix...
        if(strcmp(drRule,'max'))
            predClass=maxClassify(YhatDaSave{i,1});
        elseif(strcmp(drRule,'fixed'))
            predClass=basicClassify(YhatDaSave{i,1},1/nclasses);
        else
            warning(['Decision rule given: ',drRule,' is not valid/implemnted'])
        end
        [da.sensAllOsc{i}, da.specAllOsc{i}, da.classvecAllOsc{i}, da.tot_sensAllOsc{i},da.meanSensAllOsc{i},da.meanSpecAllOsc{i}]=sens_spec(classVect(cvTestIndex), predClass);
    end
    
    
    
    % get sens/spec for max number of oscs.... (hmm redundant).
    
%     if(strcmp(drRule,'max'))
%         predClass=maxClassify(Yhat);
%     elseif(strcmp(drRule,'fixed'))
%         predClass=basicClassify(Yhat,1/nclasses);
%     else
%         warning(['Decision rule given: ',drRule,' is not valid/implemnted'])
%     end
    
    
    [da.sens, da.spec, da.classvec, da.tot_sens,da.meanSens,da.meanSpec]=sens_spec(classVect(cvTestIndex), predClass);
    [da.confusionMatrix]=mjrGetConfusionMatrix(classVect(cvTestIndex), predClass);
    da.trueClass=classVect(cvTestIndex);
    da.nclasses=nclasses;
    modelMain.da=da;
    modelMain.da.predClass=predClass;
    modelMain.da.decisionRule=drRule;
    %CHANGE TO ORIGNAL ORDER IF NFOLD CV - for backward
    %compatibility and comparison w/ simca-p etc
    if(strcmp(cvType,'nfold'))
        [tmp,cvOrder]=sort(cvTestIndex);
        modelMain.da.predClass=modelMain.da.predClass(cvOrder);
        modelMain.da.trueClass=modelMain.da.trueClass(cvOrder);
    end
    
end


%CHANGE TO ORIGNAL ORDER IF NFOLD CV - for backward
%compatibility and comparison w/ simca-p etc
if(strcmp(cvType,'nfold'))
    [tmp,cvOrder]=sort(cvTestIndex);
    if(cvPred=='y' || cvPred=='b')
        modelMain.cv.Yhat=modelMain.cv.Yhat(cvOrder,:);
        modelMain.cv.Tcv=modelMain.cv.Tcv(cvOrder,:);
    end
    
    if(cvPred=='x' || cvPred=='b')
        modelMain.cv.Xhat=modelMain.cv.Xhat(cvOrder,:);
        modelMain.cv.Ucv=modelMain.cv.Ucv(cvOrder,:);
    end
end

modelMain.release=release;
%close(h);
modelMain.args.oax=oax;
modelMain.args.oay=oay;
modelMain.args.A=A;


% Calculate correlation and covariance to Y

% Loadings for predictive component
nc = size(Yorig,2);
nv = size(X,2);

corY = NaN(nc,nv);
pvalcorY = NaN(nc,nv);
covY = NaN(nc,nv);

for c = 1:nc
    Ymc = mjrScale(Yorig(:,c),'mc','no'); Ymc = Ymc.X;

    [corY(c,:),pvalcorY(c,:),covY(c,:)] = corCovCalc(Xmc,Ymc,'Pearson');
end

modelMain.association_XY.cov = covY;
modelMain.association_XY.cor = corY;
modelMain.association_XY.cor_p_value = pvalcorY;


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

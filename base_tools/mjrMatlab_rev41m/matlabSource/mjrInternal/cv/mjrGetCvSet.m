function [cvSet]=mjrGetCvSet(X,Y,modelFrac,type,nfold,nfoldRound)
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------
    	
    modInd=[];
    predInd=[];

	
    if(strcmp(type,'mccvb'))  %'Monte-carlo cv - class Balanced'
            %check if Y is dummy or labels...
            tmp=unique(Y);
            if(all(tmp==[0 1]'))
                classVect=reDummy(Y);
            else
                classVect=Y;
            end
                
		minset=unique(classVect); %find all classlabels
        for i=1:length(minset) %for each class
            currentClass=minset(i); %current class label
            ind=find(classVect==currentClass); %find all samples from current class

            %randomize
            ran=rand(length(ind),1); %randomize
            [tmp,rand_ind]=sort(ran); %sort randomize number to get randomized index string
            ind=ind(rand_ind); %apply randomization on the real index vector
            %-end randomize

            modelLim=ceil(length(ind)*modelFrac); %number of elemnts that will get assigned as model
            modInd=[modInd;ind(1:modelLim)];
            predInd=[predInd;ind(modelLim+1:end)];
        end
    end
	
	
    if(strcmp(type,'mccv'))  %'Monte-carlo cv'		
            %randomize
            ran=rand(length(X(:,1)),1); %randomize
            [tmp,rand_ind]=sort(ran); %sort randomize number to get randomized index string
            ind=[1:length(ran)]';
            ind=ind(rand_ind); %apply randomization on the real index vector
            modelLim=ceil(length(ind)*modelFrac); %number of elemnts that will get assigned as model
            modInd=[ind(1:modelLim)];
            predInd=[ind(modelLim+1:end)];        
    end	
	
    if(strcmp(type,'nfold'))  %'N-Fold cross validation'
        predInd=[nfoldRound:nfold:length(Y(:,1))]';
        modInd=[setdiff(1:length(Y(:,1)),predInd)]';
    end
		cvSet.type=type;
		cvSet.nfold=nfold;
		cvSet.nfoldRound=nfoldRound;
    
        cvSet.xTraining=X(modInd,:);
        cvSet.yTraining=Y(modInd,:);

        cvSet.xTest=X(predInd,:);
        cvSet.yTest=Y(predInd,:);
        
        cvSet.trainingIndex=modInd;
        cvSet.testIndex=predInd;
        
end
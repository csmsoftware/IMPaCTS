function [cvSet]=mjrScaleCvSet(cvSet,centerTypeX,scaleTypeX,centerTypeY,scaleTypeY)
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------


	if(nargin==3)
		centerTypeY=centerTypeX;
		scaleTypeY=scaleTypeX;
    end

    
	[scaleS]=mjrScale(cvSet.xTraining,centerTypeX,scaleTypeX);
	cvSet.xTraining=scaleS.X;
	scaleS.X=[]; %free mem - work only in win?
	cvSet.scaleX=scaleS;
	
	[scaleSA]=mjrScaleApply(cvSet.xTest,cvSet.scaleX);
	cvSet.xTest=scaleSA.X;
	scaleSA=[];
	
	[scaleSY]=mjrScale(cvSet.yTraining,centerTypeY,scaleTypeY);
	cvSet.yTraining=scaleSY.X;
	scaleSY.X=[];
	cvSet.scaleY=scaleSY;
	
    
	[scaleSYA]=mjrScaleApply(cvSet.yTest,cvSet.scaleY);
	cvSet.yTest=scaleSYA.X;
	scaleSYA=[];
		
end
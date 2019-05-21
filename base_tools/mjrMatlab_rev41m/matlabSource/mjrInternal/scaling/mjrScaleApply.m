
function [scaleSA]=mjrScaleApply(X,scaleS)
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------


	scaleSA.centerType=scaleS.centerType;
	scaleSA.scaleType=scaleS.scaleType;
	scaleSA.meanV=scaleS.meanV;
	scaleSA.stdV=scaleS.stdV;
	[m,n]=size(X);
	
	if(strcmp(scaleS.centerType,'mc'))
		X=X-ones(m,1)*scaleS.meanV;
	end
	if(strcmp(scaleS.centerType,'uv'))
		X=X./repmat(scaleS.stdV,m,1);
	end
	if(strcmp(scaleS.centerType,'pa'))
		X=[X./repmat(sqrt(scaleS.stdV),m,1)];
	end
	
	scaleSA.X=X;
	return;	
end

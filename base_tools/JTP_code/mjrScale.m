function [scaleS]=mjrScale(X,centerType,scaleType)
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007


    scaleS.centerType=centerType;
	scaleS.scaleType=scaleType;
	scaleS.meanV=mean(X);
	scaleS.stdV=std(X);
	[m,n]=size(X);	
	if(strcmp(centerType,'mc'))
		X=X-ones(m,1)*scaleS.meanV;
	end
	if(strcmp(scaleType,'uv'))
		X=[X./repmat(scaleS.stdV,m,1)];
    end
    
	if(strcmp(scaleType,'pa'))
		X=[X./repmat(sqrt(scaleS.stdV),m,1)];
    end	
	scaleS.X = X;
	return;	
end






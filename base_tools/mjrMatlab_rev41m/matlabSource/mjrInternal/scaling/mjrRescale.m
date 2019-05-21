function [scaleS]=mjrRescale(scaleS,varargin)	
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------

	if(~isempty(varargin))
        X=varargin{1};
    else
        X=scaleS.X;
    end
    [m,n]=size(X);
	
	
	if(strcmp(scaleS.scaleType,'uv'))
		X=X.*repmat(scaleS.stdV,m,1);
	end
	if(strcmp(scaleS.scaleType,'pa'))
		X=X.*repmat(sqrt(scaleS.stdV),m,1);
	end
	
	if(strcmp(scaleS.scaleType,'mc'))
		X=X+ones(m,1)*scaleS.meanV;
	end
	
	scaleS.centerType='no';
	scaleS.scaleType='no';
	scaleS.X=X;
	return;	
end



